import { Inject, Injectable, Logger } from '@nestjs/common';
import type { PlaceSource, PlaceSuggestion } from '@taxcy/contracts';
import { APP_CONFIG, type AppConfig } from '../../platform/config.js';
import { RateLimiter } from '../../platform/rate-limit.js';
import { RedisService } from '../../platform/redis.service.js';

/**
 * The suggestions behind the trip pickup and drop fields, limited to India:
 * from Ola Maps' autocomplete first, and from Geoapify's (OpenStreetMap data)
 * when Ola has no key, is over budget or fails.
 *
 * The keys stay here rather than in the app, and answers are cached in Redis
 * for everyone, whoever found them: a hundred people typing "pune" cost one
 * request. Each provider's cache misses are counted against its own daily
 * budget (OLA_MAPS_DAILY_LIMIT, GEOAPIFY_DAILY_LIMIT); a provider past it is
 * skipped until midnight UTC. A provider that just failed is skipped for a
 * minute, so the next searches don't each wait out its timeout.
 *
 * Suggestions are a convenience, never in the way: with no key, over budget,
 * or both providers slow or down, the answer is simply empty and the field
 * keeps whatever is typed.
 */
const CACHE_PREFIX = 'places:v2:';
const CACHE_TTL_SECONDS = 30 * 24 * 3_600;
/** Per provider: with the fallback, a search waits at most twice this. */
const REQUEST_TIMEOUT_MS = 4_000;
const DOWN_SECONDS = 60;
const RESULT_LIMIT = 6;

/** Per signed-in user: typing pauses send at most one search, so this is generous. */
const USER_LIMIT_PER_MINUTE = 60;

const text = (value: unknown): string | null =>
  typeof value === 'string' && value.trim() !== '' ? value.trim() : null;

/** What was typed, as the cache knows it: "  Hinjewadi  PH" → "hinjewadi ph". */
export const placeQueryKey = (query: string): string =>
  query.toLowerCase().trim().replace(/\s+/g, ' ');

/**
 * A suggestion's label and the line under it: a town or region by its name
 * ("Lonavala"), anything smaller with its town unless its name already says
 * it ("Hinjawadi Phase 1, Pune", but "Pune Railway Station"), the state beneath.
 */
function describe(
  name: string,
  city: string | null,
  state: string | null,
  isArea: boolean,
): { label: string; detail: string | null } {
  const label =
    !isArea && city !== null && !name.toLowerCase().includes(city.toLowerCase())
      ? `${name}, ${city}`
      : name;
  return { label, detail: state !== null && state !== label ? state : null };
}

/** Drops repeats: the same name in another state is another place (Baner in Pune and in Odisha). */
function unique(places: PlaceSuggestion[]): PlaceSuggestion[] {
  const seen = new Set<string>();
  return places.filter((p) => {
    const key = `${p.label}|${p.detail ?? ''}`.toLowerCase();
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });
}

// ───────── Ola Maps ─────────

/** Only what we read of Ola Maps' autocomplete answer. */
export interface OlaPrediction {
  readonly description?: unknown;
  readonly structured_formatting?: { readonly main_text?: unknown };
  readonly terms?: readonly { readonly value?: unknown }[];
  readonly types?: unknown;
  readonly layer?: unknown;
  readonly geometry?: { readonly location?: { readonly lat?: unknown; readonly lng?: unknown } };
}
export interface OlaResponse {
  readonly predictions?: readonly OlaPrediction[];
}

/** Ola names the state among a prediction's terms; these are how we find it. */
const INDIAN_STATES = new Set(
  [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Andaman and Nicobar Islands',
    'Chandigarh',
    'Dadra and Nagar Haveli and Daman and Diu',
    'Delhi',
    'Jammu and Kashmir',
    'Ladakh',
    'Lakshadweep',
    'Puducherry',
  ].map((s) => s.toLowerCase()),
);

/**
 * Ola's types and layers for a whole town or region: their name says it all.
 * Places and streets come as layer "venue" (metro_station, street_address, …).
 */
const OLA_AREA_TYPES =
  /^(locality|localadmin|administrative_area_level_\d|county|macrocounty|region|macroregion|postal_code|postalcode|country)$/;

/**
 * Ola is India-only, but a stray result is dropped: outside India's bounding
 * box, or naming a neighbour the box also covers (Sri Lanka, Nepal, …).
 */
const inIndia = (lat: number, lng: number): boolean =>
  lat >= 6 && lat <= 37.5 && lng >= 68 && lng <= 97.5;
const NEIGHBOURS = new Set(
  ['Bangladesh', 'Bhutan', 'China', 'Myanmar', 'Nepal', 'Pakistan', 'Sri Lanka'].map((c) =>
    c.toLowerCase(),
  ),
);

/**
 * Ola's predictions as suggestions. The name is `main_text`; the state is the
 * term naming one, and the town the term just before it ("Hinjawadi Phase 1,
 * Hinjawadi, Pune, Maharashtra, India" → "Hinjawadi Phase 1, Pune" over
 * "Maharashtra"). Predictions without a position, outside India, or repeating
 * an earlier one are dropped.
 */
export function parseOla(payload: OlaResponse): PlaceSuggestion[] {
  const out: PlaceSuggestion[] = [];
  for (const p of payload.predictions ?? []) {
    const lat = p.geometry?.location?.lat;
    const lng = p.geometry?.location?.lng;
    if (typeof lat !== 'number' || typeof lng !== 'number' || !inIndia(lat, lng)) continue;
    const terms = (p.terms ?? []).map((t) => text(t.value)).filter((t) => t !== null);
    if (terms.some((t) => NEIGHBOURS.has(t.toLowerCase()))) continue;
    const name =
      text(p.structured_formatting?.main_text) ?? terms[0] ?? text(p.description)?.split(',')[0];
    if (name === undefined) continue;
    const at = terms.findIndex((t, i) => i > 0 && INDIAN_STATES.has(t.toLowerCase()));
    const state = at > 0 ? (terms[at] ?? null) : null;
    const city = at > 1 ? (terms[at - 1] ?? null) : null;
    const kinds = [p.types, p.layer].flatMap((k) => (Array.isArray(k) ? (k as unknown[]) : []));
    const isArea =
      INDIAN_STATES.has(name.toLowerCase()) ||
      kinds.some((k) => typeof k === 'string' && OLA_AREA_TYPES.test(k));
    out.push({ ...describe(name, city, state, isArea), lat, lng, source: 'ola' });
  }
  return unique(out);
}

// ───────── Geoapify ─────────

/** Results that are a whole town or region: their name says it all. */
const GEOAPIFY_AREA_TYPES = new Set(['city', 'county', 'state', 'postcode']);

/** Only what we read of Geoapify's `format=json` answer. */
export interface GeoapifyResult {
  readonly name?: unknown;
  readonly address_line1?: unknown;
  readonly city?: unknown;
  readonly state?: unknown;
  readonly country_code?: unknown;
  readonly result_type?: unknown;
  readonly lat?: unknown;
  readonly lon?: unknown;
}
export interface GeoapifyResponse {
  readonly results?: readonly GeoapifyResult[];
}

/**
 * Geoapify's results as suggestions, named as `describe` says. Results
 * outside India, without a position, or repeating an earlier one are dropped.
 */
export function parseGeoapify(payload: GeoapifyResponse): PlaceSuggestion[] {
  const out: PlaceSuggestion[] = [];
  for (const r of payload.results ?? []) {
    if (r.country_code !== 'in') continue;
    if (typeof r.lat !== 'number' || typeof r.lon !== 'number') continue;
    const city = text(r.city);
    const isArea = GEOAPIFY_AREA_TYPES.has(text(r.result_type) ?? '');
    const name = isArea
      ? (text(r.name) ?? city ?? text(r.address_line1))
      : (text(r.name) ?? text(r.address_line1));
    if (name === null) continue;
    out.push({
      ...describe(name, city, text(r.state), isArea),
      lat: r.lat,
      lng: r.lon,
      source: 'geoapify',
    });
  }
  return unique(out);
}

// ───────── the service ─────────

interface Provider {
  readonly name: PlaceSource;
  readonly label: string;
  readonly apiKey: string | undefined;
  readonly dailyLimit: number;
  readonly url: (query: string, apiKey: string) => string;
  readonly parse: (payload: unknown) => PlaceSuggestion[];
}

@Injectable()
export class PlacesService {
  private readonly logger = new Logger('Places');
  private readonly providers: readonly Provider[];
  private warnedNoKey = false;
  private readonly warnedBudget = new Map<PlaceSource, string>();

  constructor(
    @Inject(APP_CONFIG) config: AppConfig,
    private readonly redis: RedisService,
    private readonly limiter: RateLimiter,
  ) {
    this.providers = [
      {
        name: 'ola',
        label: 'Ola Maps',
        apiKey: config.OLA_MAPS_API_KEY,
        dailyLimit: config.OLA_MAPS_DAILY_LIMIT,
        url: (query, apiKey) =>
          `${config.OLA_MAPS_URL}?${new URLSearchParams({ input: query, api_key: apiKey }).toString()}`,
        parse: (payload) => parseOla(payload as OlaResponse).slice(0, RESULT_LIMIT),
      },
      {
        name: 'geoapify',
        label: 'Geoapify',
        apiKey: config.GEOAPIFY_API_KEY,
        dailyLimit: config.GEOAPIFY_DAILY_LIMIT,
        url: (query, apiKey) =>
          `${config.GEOAPIFY_URL}?${new URLSearchParams({
            text: query,
            filter: 'countrycode:in',
            lang: 'en',
            limit: String(RESULT_LIMIT),
            format: 'json',
            apiKey,
          }).toString()}`,
        parse: (payload) => parseGeoapify(payload as GeoapifyResponse),
      },
    ];
  }

  async search(userId: string, query: string): Promise<PlaceSuggestion[]> {
    const configured = this.providers.filter((p) => p.apiKey !== undefined);
    if (configured.length === 0) {
      if (!this.warnedNoKey) {
        this.warnedNoKey = true;
        this.logger.warn(
          'Neither OLA_MAPS_API_KEY nor GEOAPIFY_API_KEY is set: place suggestions are off',
        );
      }
      return [];
    }
    await this.limiter.consume([
      { key: `places:user:${userId}:1m`, max: USER_LIMIT_PER_MINUTE, windowSeconds: 60 },
    ]);

    const key = CACHE_PREFIX + placeQueryKey(query);
    const cached = await this.redis.client.get(key).catch(() => null);
    if (cached !== null) return JSON.parse(cached) as PlaceSuggestion[];

    for (const provider of configured) {
      if (await this.isDown(provider)) continue;
      if (!(await this.withinBudget(provider))) continue;
      const found = await this.ask(provider, query.trim());
      if (found === null) {
        await this.markDown(provider);
        continue;
      }
      // A failed request isn't cached; a real "nothing found" is.
      await this.redis.client
        .set(key, JSON.stringify(found), 'EX', CACHE_TTL_SECONDS)
        .catch(() => null);
      return found;
    }
    return [];
  }

  private downKey = (provider: Provider) => `places:${provider.name}:down`;

  private async isDown(provider: Provider): Promise<boolean> {
    return (await this.redis.client.get(this.downKey(provider)).catch(() => null)) !== null;
  }

  /** Skips a provider that just failed for a minute, so searches don't each wait for it. */
  private async markDown(provider: Provider): Promise<void> {
    await this.redis.client.set(this.downKey(provider), '1', 'EX', DOWN_SECONDS).catch(() => null);
  }

  /** Counts one request against the provider's budget today; false once it's spent. */
  private async withinBudget(provider: Provider): Promise<boolean> {
    const day = new Date().toISOString().slice(0, 10);
    const key = `places:${provider.name}:${day}`;
    const used = await this.redis.client
      .multi()
      .incr(key)
      .expire(key, 2 * 24 * 3_600, 'NX')
      .exec()
      .then((results) => Number(results?.[0]?.[1] ?? 0))
      .catch(() => 0);
    if (used <= provider.dailyLimit) return true;
    if (this.warnedBudget.get(provider.name) !== day) {
      this.warnedBudget.set(provider.name, day);
      this.logger.warn(
        `${provider.label} daily budget (${String(provider.dailyLimit)}) spent: ` +
          'not asking it again until midnight UTC',
      );
    }
    return false;
  }

  /** The provider's suggestions, or null when it couldn't be asked. */
  private async ask(provider: Provider, query: string): Promise<PlaceSuggestion[] | null> {
    try {
      const res = await fetch(provider.url(query, provider.apiKey ?? ''), {
        headers: { Accept: 'application/json' },
        signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS),
      });
      if (!res.ok) {
        // 401/403: a wrong key; 429: the provider's own limit.
        this.logger.warn(`${provider.label} returned HTTP ${String(res.status)}`);
        return null;
      }
      return provider.parse(await res.json());
    } catch (error) {
      this.logger.warn(`${provider.label} request failed: ${String(error)}`);
      return null;
    }
  }
}

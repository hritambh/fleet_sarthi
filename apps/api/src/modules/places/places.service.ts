import { Inject, Injectable, Logger } from '@nestjs/common';
import type { PlaceSuggestion } from '@taxcy/contracts';
import { APP_CONFIG, type AppConfig } from '../../platform/config.js';
import { RateLimiter } from '../../platform/rate-limit.js';
import { RedisService } from '../../platform/redis.service.js';

/**
 * The suggestions behind the trip pickup and drop fields, from Geoapify's
 * autocomplete (OpenStreetMap data), limited to India.
 *
 * The key stays here rather than in the app, and answers are cached in Redis
 * for everyone: a hundred people typing "pune" cost one Geoapify request. The
 * free plan allows 3,000 requests a day, so cache misses are counted against
 * GEOAPIFY_DAILY_LIMIT and, past it, only cached answers are served until
 * midnight UTC.
 *
 * Suggestions are a convenience, never in the way: with no key, over budget,
 * or Geoapify slow or down, the answer is simply empty and the field keeps
 * whatever is typed.
 */
const CACHE_PREFIX = 'places:v1:';
const CACHE_TTL_SECONDS = 30 * 24 * 3_600;
const REQUEST_TIMEOUT_MS = 8_000;
const RESULT_LIMIT = 6;

/** Per signed-in user: typing pauses send at most one search, so this is generous. */
const USER_LIMIT_PER_MINUTE = 60;

/** Results that are a whole town or region: their name says it all. */
const AREA_TYPES = new Set(['city', 'county', 'state', 'postcode']);

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

const text = (value: unknown): string | null =>
  typeof value === 'string' && value.trim() !== '' ? value.trim() : null;

/** What was typed, as the cache knows it: "  Hinjewadi  PH" → "hinjewadi ph". */
export const placeQueryKey = (query: string): string =>
  query.toLowerCase().trim().replace(/\s+/g, ' ');

/**
 * Geoapify's results as suggestions: a town by its name ("Lonavala"), anything
 * smaller with its town unless its name already says it ("Hinjawadi Phase 1,
 * Pune", but "Pune Railway Station"), the state beneath. Results outside
 * India, without a position, or repeating an earlier one are dropped.
 */
export function parseGeoapify(payload: GeoapifyResponse): PlaceSuggestion[] {
  const seen = new Set<string>();
  const out: PlaceSuggestion[] = [];
  for (const r of payload.results ?? []) {
    if (r.country_code !== 'in') continue;
    if (typeof r.lat !== 'number' || typeof r.lon !== 'number') continue;
    const city = text(r.city);
    const state = text(r.state);
    const type = text(r.result_type) ?? '';
    const name = AREA_TYPES.has(type)
      ? (text(r.name) ?? city ?? text(r.address_line1))
      : (text(r.name) ?? text(r.address_line1));
    if (name === null) continue;
    const label =
      !AREA_TYPES.has(type) && city !== null && !name.toLowerCase().includes(city.toLowerCase())
        ? `${name}, ${city}`
        : name;
    const detail = state !== null && state !== label ? state : null;
    // Same name in another state is another place (Baner in Pune and in Odisha).
    const key = `${label}|${detail ?? ''}`.toLowerCase();
    if (seen.has(key)) continue;
    seen.add(key);
    out.push({
      label,
      detail,
      lat: r.lat,
      lng: r.lon,
    });
  }
  return out;
}

@Injectable()
export class PlacesService {
  private readonly logger = new Logger('Places');
  private warnedNoKey = false;
  private warnedBudget = '';

  constructor(
    @Inject(APP_CONFIG) private readonly config: AppConfig,
    private readonly redis: RedisService,
    private readonly limiter: RateLimiter,
  ) {}

  async search(userId: string, query: string): Promise<PlaceSuggestion[]> {
    const apiKey = this.config.GEOAPIFY_API_KEY;
    if (apiKey === undefined) {
      if (!this.warnedNoKey) {
        this.warnedNoKey = true;
        this.logger.warn('GEOAPIFY_API_KEY is not set: place suggestions are off');
      }
      return [];
    }
    await this.limiter.consume([
      { key: `places:user:${userId}:1m`, max: USER_LIMIT_PER_MINUTE, windowSeconds: 60 },
    ]);

    const key = CACHE_PREFIX + placeQueryKey(query);
    const cached = await this.redis.client.get(key).catch(() => null);
    if (cached !== null) return JSON.parse(cached) as PlaceSuggestion[];

    if (!(await this.withinBudget())) return [];
    const found = await this.ask(apiKey, query);
    // A failed request isn't cached; a real "nothing found" is.
    if (found !== null) {
      await this.redis.client
        .set(key, JSON.stringify(found), 'EX', CACHE_TTL_SECONDS)
        .catch(() => null);
    }
    return found ?? [];
  }

  /** Counts one Geoapify request against today's budget; false once it's spent. */
  private async withinBudget(): Promise<boolean> {
    const day = new Date().toISOString().slice(0, 10);
    const key = `places:geoapify:${day}`;
    const used = await this.redis.client
      .multi()
      .incr(key)
      .expire(key, 2 * 24 * 3_600, 'NX')
      .exec()
      .then((results) => Number(results?.[0]?.[1] ?? 0))
      .catch(() => 0);
    if (used <= this.config.GEOAPIFY_DAILY_LIMIT) return true;
    if (this.warnedBudget !== day) {
      this.warnedBudget = day;
      this.logger.warn(
        `Geoapify daily budget (${this.config.GEOAPIFY_DAILY_LIMIT}) spent: ` +
          'serving cached place suggestions only until midnight UTC',
      );
    }
    return false;
  }

  /** Geoapify's suggestions, or null when it couldn't be asked. */
  private async ask(apiKey: string, query: string): Promise<PlaceSuggestion[] | null> {
    const params = new URLSearchParams({
      text: query.trim(),
      filter: 'countrycode:in',
      lang: 'en',
      limit: String(RESULT_LIMIT),
      format: 'json',
      apiKey,
    });
    try {
      const res = await fetch(`${this.config.GEOAPIFY_URL}?${params.toString()}`, {
        headers: { Accept: 'application/json' },
        signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS),
      });
      if (!res.ok) {
        // 401/403: a wrong key; 429: Geoapify's own limit.
        this.logger.warn(`Geoapify returned HTTP ${res.status}`);
        return null;
      }
      return parseGeoapify((await res.json()) as GeoapifyResponse);
    } catch (error) {
      this.logger.warn(`Geoapify request failed: ${String(error)}`);
      return null;
    }
  }
}

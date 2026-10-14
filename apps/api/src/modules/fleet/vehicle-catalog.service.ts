import { Inject, Injectable, Logger } from '@nestjs/common';
import type { CatalogBrand, CatalogModel } from '@taxcy/contracts';
import { APP_CONFIG, type AppConfig } from '../../platform/config.js';
import { AppError } from '../../platform/errors.js';
import { RedisService } from '../../platform/redis.service.js';

/**
 * The brand and model lists behind the add-vehicle form, built from two public
 * APIs rather than kept as a list in the code.
 *
 * What makes a car *available in India* is English Wikipedia's category tree
 * (VEHICLE_CATALOG_CATEGORY, "Cars of India") — the one public, maintained,
 * India-specific list of car models there is. Its per-brand subcategories
 * ("Maruti vehicles", "Tata cars") also name each brand the way India does,
 * which is how the Maruti cars that Wikipedia files under their Suzuki titles
 * end up under Maruti here.
 *
 * Wikidata (VEHICLE_CATALOG_URL) supplies only the brand vocabulary: the list of
 * car manufacturers, which is what tells us where the brand ends and the model
 * begins in a title like "Mercedes-Benz C-Class" or "Ashok Leyland MiTR".
 *
 * Neither source is fast and both change about once a year, so the whole
 * catalogue is built in one pass and cached in Redis for a week and in this
 * process for its lifetime. With no copy at all the route fails with
 * CATALOG_UNAVAILABLE and the form falls back to typing the make and model in.
 */
const CACHE_KEY = 'catalog:india:v1';
const CACHE_TTL_SECONDS = 7 * 24 * 3_600;
const REQUEST_TIMEOUT_MS = 30_000;

/** Wikidata: automobile manufacturer, automobile model, "manufacturer" (P176). */
const MANUFACTURER_CLASS = 'wd:Q786820';
const MODEL_CLASS = 'wd:Q3231690';
const MAX_BRAND_VOCABULARY = 400;

/** Pages per category request, and how many pages of those we follow. */
const CATEGORY_PAGE_SIZE = 500;
const MAX_CATEGORY_PAGES = 4;

/**
 * Wikimedia rate-limits bursts from one address, and answers a throttled request
 * with prose rather than JSON, so category requests go one at a time with a gap.
 */
const REQUEST_GAP_MS = 1_500;

/** A label Wikidata couldn't resolve comes back as the entity's own id. */
const ENTITY_ID = /^Q[1-9][0-9]{0,11}$/;

/** "Maruti vehicles", "Hyundai vehicles in India" → the brand they are about. */
const CATEGORY_SUFFIX = /\s+(vehicles|cars|automobiles)(\s+in\s+india)?$/i;
const CATEGORY_PREFIX = /^category:\s*/i;

/** A generation or disambiguation in brackets: "Škoda Rapid (India)". */
const BRACKETED = /\s*\([^()]*\)\s*$/;

export interface Catalogue {
  readonly brands: readonly CatalogBrand[];
  readonly models: Readonly<Record<string, readonly CatalogModel[]>>;
}

/** One category's members, as [categoryMembers] returns them. */
export interface CategoryMembers {
  readonly title: string;
  readonly pages: readonly string[];
  readonly subcategories: readonly string[];
}

const norm = (value: string): string => value.toLowerCase().trim().replace(/\s+/g, ' ');

/**
 * A brand name as an id: opaque to the client, stable across rebuilds. Accents
 * are folded rather than dropped, so Škoda is `skoda` and not `koda`.
 */
export const brandId = (name: string): string =>
  norm(name)
    .normalize('NFD')
    .replace(/\p{Diacritic}/gu, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '');

// ---------------------------------------------------------------- Wikidata

interface SparqlCell {
  readonly value?: unknown;
}
type SparqlBinding = Readonly<Record<string, SparqlCell | undefined>>;

/** Only what we read of the SPARQL JSON results format. */
export interface SparqlResults {
  readonly results?: { readonly bindings?: readonly SparqlBinding[] };
}

/** The manufacturer names Wikidata knows, used only to split titles. */
export function parseBrandVocabulary(payload: SparqlResults): string[] {
  const names = (payload.results?.bindings ?? []).flatMap((row): string[] => {
    const value = row['brandLabel']?.value;
    if (typeof value !== 'string') return [];
    const name = value.trim();
    return name === '' || ENTITY_ID.test(name) ? [] : [name];
  });
  return [...new Set(names)];
}

// ------------------------------------------------------- Building the list

/**
 * Where a brand name ends in a page title: normalised prefix → the brand's
 * display name. A prefix already taken is left alone, so the India-specific
 * names from the category tree win over Wikidata's corporate ones.
 */
type Prefixes = Map<string, string>;

const claim = (prefixes: Prefixes, prefix: string, display: string): void => {
  const key = norm(prefix);
  if (key !== '' && !prefixes.has(key)) prefixes.set(key, display);
};

/** The longest brand prefix of [title], at a word boundary. */
function matchBrand(prefixes: Prefixes, title: string): { length: number; brand: string } | null {
  const lower = norm(title);
  let best: { length: number; brand: string } | null = null;
  for (const [prefix, brand] of prefixes) {
    if (!lower.startsWith(prefix)) continue;
    const next = lower[prefix.length];
    if (next !== undefined && next !== ' ' && next !== '-') continue;
    if (best === null || prefix.length > best.length) {
      best = { length: prefix.length, brand };
    }
  }
  return best;
}

/**
 * The catalogue of Indian brands and models.
 *
 * [root] is the India category, [subcategories] its per-brand ones, and
 * [vocabulary] the manufacturer names from Wikidata. A title whose brand can't
 * be told from the model is left out, as is a category's own company page
 * ("Force Motors" inside Category:Force Motors), which has no model part.
 */
export function buildCatalogue(
  root: CategoryMembers,
  subcategories: readonly CategoryMembers[],
  vocabulary: readonly string[],
): Catalogue {
  const prefixes: Prefixes = new Map();

  // A subcategory names its brand, and is about that brand only if its members
  // are titled after it — which rules out "Indian racing cars" and the like.
  const brandCategories = subcategories.flatMap((category) => {
    const title = category.title.replace(CATEGORY_PREFIX, '').trim();
    const brand = title.replace(CATEGORY_SUFFIX, '').trim();
    if (brand === '') return [];
    return category.pages.some((p) => startsWith(p, brand)) ? [{ brand, category }] : [];
  });
  for (const { brand } of brandCategories) claim(prefixes, brand, brand);

  for (const name of vocabulary) {
    claim(prefixes, name, name);
    // "Tata Motors Limited" also answers to "Tata", "Škoda Auto" to "Škoda".
    const marque = norm(name).split(' ')[0] ?? '';
    if (marque.length >= 3) claim(prefixes, marque, titleCasePrefix(name));
  }

  // Wikipedia titles the Maruti cars after Suzuki, so the brand category is
  // taken as the better evidence: every prefix its members use is that brand's.
  for (const { brand, category } of brandCategories) {
    for (const page of category.pages) {
      const match = matchBrand(prefixes, stripBrackets(page));
      if (match !== null && match.brand !== brand) {
        prefixes.set(norm(stripBrackets(page)).slice(0, match.length), brand);
      }
    }
  }

  const titles = new Set<string>([
    ...root.pages,
    ...brandCategories.flatMap(({ category }) => [...category.pages]),
  ]);
  const byBrand = new Map<string, Set<string>>();
  for (const title of titles) {
    const clean = stripBrackets(title);
    const match = matchBrand(prefixes, clean);
    if (match === null) continue;
    const model = clean
      .slice(match.length)
      .replace(/^[\s-]+/, '')
      .trim();
    if (model === '') continue;
    const models = byBrand.get(match.brand) ?? new Set<string>();
    models.add(model);
    byBrand.set(match.brand, models);
  }

  const brands = [...byBrand.keys()]
    .map((name) => ({ id: brandId(name), name }))
    .sort((a, b) => a.name.localeCompare(b.name));
  const models: Record<string, CatalogModel[]> = {};
  for (const [name, set] of byBrand) {
    models[brandId(name)] = [...set]
      .sort((a, b) => a.localeCompare(b))
      .map((model) => ({ name: model }));
  }
  return { brands, models };
}

const stripBrackets = (title: string): string => title.replace(BRACKETED, '').trim();

const startsWith = (title: string, prefix: string): boolean => {
  const lower = norm(title);
  const key = norm(prefix);
  if (!lower.startsWith(key)) return false;
  const next = lower[key.length];
  return next === undefined || next === ' ' || next === '-';
};

/** The marque as the name spells it: "Škoda Auto" → "Škoda". */
const titleCasePrefix = (name: string): string => name.trim().split(/\s+/)[0] ?? name;

// ------------------------------------------------------------- The service

/** Only what we read of the MediaWiki categorymembers response. */
interface WikiResponse {
  readonly query?: {
    readonly categorymembers?: readonly { readonly title?: unknown; readonly ns?: number }[];
  };
  readonly continue?: { readonly cmcontinue?: string };
}

@Injectable()
export class VehicleCatalogService {
  private readonly logger = new Logger('VehicleCatalog');
  private memo: Catalogue | null = null;

  constructor(
    @Inject(APP_CONFIG) private readonly config: AppConfig,
    private readonly redis: RedisService,
  ) {}

  async brands(): Promise<CatalogBrand[]> {
    return [...(await this.catalogue()).brands];
  }

  /** Models of one brand, by the id [brands] gave for it. */
  async models(id: string): Promise<CatalogModel[]> {
    const catalogue = await this.catalogue();
    const models = catalogue.models[id];
    if (models === undefined) {
      throw new AppError('VALIDATION_FAILED', 'Unknown vehicle brand', { brand: id });
    }
    return [...models];
  }

  /**
   * Fills the cache so the first owner to open the add-vehicle form after a
   * deploy doesn't wait out a cold build. Called from the API's bootstrap once
   * it is listening — deliberately not an onApplicationBootstrap hook, because
   * the workers and the seed CLIs load this module too and would each rebuild
   * it, and the reference CLI runs before the API starts.
   *
   * Never fatal: a failure leaves the cache cold and the request path builds it.
   */
  async warm(): Promise<void> {
    if (this.config.NODE_ENV === 'test') return;
    try {
      await this.catalogue();
    } catch {
      this.logger.warn('could not warm the vehicle catalogue; it will build on first use');
    }
  }

  /**
   * Rebuilds from the two APIs and replaces the cached copy, whether or not it
   * had expired. Runs weekly, inside the cache's own week, so the TTL never
   * lapses under a request.
   */
  async refresh(): Promise<Catalogue> {
    const built = await this.build();
    this.memo = built;
    await this.store(built);
    return built;
  }

  /** The built catalogue, from this process, else Redis, else the two APIs. */
  private async catalogue(): Promise<Catalogue> {
    if (this.memo !== null) return this.memo;
    const stored = await this.redis.client.get(CACHE_KEY).catch(() => null);
    if (stored !== null) {
      const parsed = JSON.parse(stored) as Catalogue;
      this.memo = parsed;
      return parsed;
    }
    const built = await this.build();
    this.memo = built;
    await this.store(built);
    return built;
  }

  private async store(catalogue: Catalogue): Promise<void> {
    await this.redis.client
      .set(CACHE_KEY, JSON.stringify(catalogue), 'EX', CACHE_TTL_SECONDS)
      .catch(() => null);
  }

  private async build(): Promise<Catalogue> {
    const [vocabulary, root] = await Promise.all([
      this.brandVocabulary(),
      this.categoryMembers(this.config.VEHICLE_CATALOG_CATEGORY),
    ]);
    const subcategories: CategoryMembers[] = [];
    for (const title of root.subcategories) {
      subcategories.push(await this.categoryMembers(title));
    }
    const built = buildCatalogue(root, subcategories, vocabulary);
    if (built.brands.length === 0) {
      this.logger.warn('vehicle catalogue came back empty');
      throw this.unavailable();
    }
    this.logger.log(
      `vehicle catalogue built: ${built.brands.length} brands, ` +
        `${Object.values(built.models).reduce((n, m) => n + m.length, 0)} models`,
    );
    return built;
  }

  private async brandVocabulary(): Promise<string[]> {
    const sparql = `SELECT ?brand ?brandLabel (COUNT(DISTINCT ?model) AS ?models) WHERE {
  ?brand wdt:P31/wdt:P279* ${MANUFACTURER_CLASS} .
  ?model wdt:P176 ?brand ; wdt:P31/wdt:P279* ${MODEL_CLASS} .
  SERVICE wikibase:label { bd:serviceParam wikibase:language "en". }
}
GROUP BY ?brand ?brandLabel
ORDER BY DESC(?models)
LIMIT ${MAX_BRAND_VOCABULARY}`;
    const url = `${this.config.VEHICLE_CATALOG_URL}?query=${encodeURIComponent(sparql)}`;
    const payload: SparqlResults = await this.getJson(url, 'application/sparql-results+json');
    return parseBrandVocabulary(payload);
  }

  /** The pages and subcategories of one Wikipedia category, following `continue`. */
  private async categoryMembers(title: string): Promise<CategoryMembers> {
    const pages: string[] = [];
    const subcategories: string[] = [];
    let cont: string | undefined;
    for (let page = 0; page < MAX_CATEGORY_PAGES; page += 1) {
      await new Promise((resolve) => setTimeout(resolve, REQUEST_GAP_MS));
      const query = new URLSearchParams({
        action: 'query',
        list: 'categorymembers',
        cmtitle: title.startsWith('Category:') ? title : `Category:${title}`,
        cmlimit: String(CATEGORY_PAGE_SIZE),
        format: 'json',
        formatversion: '2',
      });
      if (cont !== undefined) query.set('cmcontinue', cont);
      const body: WikiResponse = await this.getJson(
        `${this.config.VEHICLE_CATALOG_WIKI_URL}?${query.toString()}`,
        'application/json',
      );
      for (const member of body.query?.categorymembers ?? []) {
        if (typeof member.title !== 'string') continue;
        // Namespace 0 is an article, 14 a category.
        if (member.ns === 0) pages.push(member.title);
        else if (member.ns === 14) subcategories.push(member.title);
      }
      cont = body.continue?.cmcontinue;
      if (cont === undefined) break;
    }
    return { title, pages, subcategories };
  }

  private async getJson<T>(url: string, accept: string): Promise<T> {
    try {
      const res = await fetch(url, {
        headers: {
          Accept: accept,
          // Wikimedia asks every client to identify itself and say where to
          // complain; an anonymous one is throttled harder.
          'User-Agent':
            'FleetSarthi/1.0 (fleet audit for small Indian cab fleets; https://github.com/hritambh/taxcy)',
        },
        signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS),
      });
      if (!res.ok) {
        this.logger.warn(`vehicle catalogue returned HTTP ${res.status}`);
        throw this.unavailable();
      }
      const text = await res.text();
      try {
        return JSON.parse(text) as T;
      } catch {
        this.logger.warn(`vehicle catalogue answered with non-JSON: ${text.slice(0, 80)}`);
        throw this.unavailable();
      }
    } catch (error) {
      if (error instanceof AppError) throw error;
      this.logger.warn(`vehicle catalogue request failed: ${String(error)}`);
      throw this.unavailable();
    }
  }

  private unavailable(): AppError {
    return new AppError(
      'CATALOG_UNAVAILABLE',
      "Couldn't reach the vehicle catalogue; type the make and model instead",
    );
  }
}

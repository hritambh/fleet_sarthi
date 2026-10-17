import { readFileSync } from 'node:fs';
import { afterEach, describe, expect, it, vi } from 'vitest';
import type { AppConfig } from '../../platform/config.js';
import type { RateLimiter } from '../../platform/rate-limit.js';
import type { RedisService } from '../../platform/redis.service.js';
import {
  parseGeoapify,
  parseOla,
  placeQueryKey,
  PlacesService,
  type GeoapifyResponse,
  type OlaResponse,
} from './places.service.js';

const hinjawadi = {
  name: 'Hinjawadi Phase 1',
  city: 'Pune',
  state: 'Maharashtra',
  country_code: 'in',
  result_type: 'suburb',
  lat: 18.5912,
  lon: 73.7389,
};

describe('parseGeoapify', () => {
  it('names a town alone and anything smaller with its town', () => {
    const found = parseGeoapify({
      results: [
        { ...hinjawadi },
        {
          name: 'Lonavala',
          city: 'Lonavala',
          state: 'Maharashtra',
          country_code: 'in',
          result_type: 'city',
          lat: 18.75,
          lon: 73.41,
        },
        {
          name: 'Pune Railway Station',
          city: 'Pune',
          state: 'Maharashtra',
          country_code: 'in',
          result_type: 'amenity',
          lat: 18.528,
          lon: 73.874,
        },
      ],
    });
    const source = 'geoapify';
    expect(found).toEqual([
      {
        label: 'Hinjawadi Phase 1, Pune',
        detail: 'Maharashtra',
        lat: 18.5912,
        lng: 73.7389,
        source,
      },
      { label: 'Lonavala', detail: 'Maharashtra', lat: 18.75, lng: 73.41, source },
      { label: 'Pune Railway Station', detail: 'Maharashtra', lat: 18.528, lng: 73.874, source },
    ]);
  });

  it('drops places abroad, without a position or a name, and repeats', () => {
    const found = parseGeoapify({
      results: [
        hinjawadi,
        { ...hinjawadi, lat: 18.6 },
        { ...hinjawadi, name: 'Kandy', city: 'Kandy', country_code: 'lk' },
        { ...hinjawadi, name: 'Nowhere', lat: undefined },
        { country_code: 'in', result_type: 'street', lat: 1, lon: 2 },
      ],
    });
    expect(found.map((p) => p.label)).toEqual(['Hinjawadi Phase 1, Pune']);
  });

  it('keeps a same-named place in another state', () => {
    const baner = (state: string, city: string, type: string) => ({
      name: 'Baner',
      city,
      state,
      country_code: 'in',
      result_type: type,
      lat: 1,
      lon: 2,
    });
    const found = parseGeoapify({
      results: [
        baner('Odisha', 'Baner', 'city'),
        baner('Himachal Pradesh', 'Baner', 'city'),
        baner('Maharashtra', 'Pune', 'suburb'),
      ],
    });
    expect(found.map((p) => `${p.label} (${p.detail ?? ''})`)).toEqual([
      'Baner (Odisha)',
      'Baner (Himachal Pradesh)',
      'Baner, Pune (Maharashtra)',
    ]);
  });

  it('a state is its own label, with nothing beneath', () => {
    const [goa] = parseGeoapify({
      results: [
        { name: 'Goa', state: 'Goa', country_code: 'in', result_type: 'state', lat: 15.3, lon: 74 },
      ],
    });
    expect(goa).toEqual({ label: 'Goa', detail: null, lat: 15.3, lng: 74, source: 'geoapify' });
  });

  it('tolerates a shapeless answer', () => {
    expect(parseGeoapify({})).toEqual([]);
  });
});

/** An Ola prediction as its autocomplete answers one. */
const ola = (
  main: string,
  terms: string[],
  lat: number | undefined,
  lng: number,
  types: string[] = ['point_of_interest'],
) => ({
  description: terms.join(', '),
  structured_formatting: { main_text: main, secondary_text: terms.slice(1).join(', ') },
  terms: terms.map((value, offset) => ({ value, offset })),
  types,
  geometry: { location: { lat, lng } },
});

const olaHinjawadi = ola(
  'Hinjawadi Phase 1',
  ['Hinjawadi Phase 1', 'Hinjawadi', 'Pune', 'Maharashtra', '411057', 'India'],
  18.5912,
  73.7389,
  ['sublocality'],
);

describe('parseOla', () => {
  it('reads a real Ola Maps answer (search "hinjewadi", 2026-10-17)', () => {
    const real = JSON.parse(
      readFileSync(new URL('./ola-hinjewadi.fixture.json', import.meta.url), 'utf8'),
    ) as OlaResponse;
    const found = parseOla(real);
    expect(found.map((p) => `${p.label} (${p.detail ?? ''})`)).toEqual([
      'Hinjewadi Metro Station, Pune (Maharashtra)',
      'Hinjewadi Phase III, Pimpri-Chinchwad (Maharashtra)',
      'Hinjewadi Phase 1 Road, Pune (Maharashtra)',
      'Hinjewadi (Godrej Elements), Pimpri-Chinchwad (Maharashtra)',
      'Hinjewadi Phase 3 (Hinjawadi Phase 3), Pimpri-Chinchwad (Maharashtra)',
    ]);
    expect(found[0]).toEqual({
      label: 'Hinjewadi Metro Station, Pune',
      detail: 'Maharashtra',
      lat: 18.59101,
      lng: 73.74628,
      source: 'ola',
    });
  });

  it('a town by its layer is named alone', () => {
    const [wakad] = parseOla({
      predictions: [
        {
          ...ola('Wakad', ['Wakad', 'Pune', 'Maharashtra', 'India'], 18.6, 73.76, []),
          layer: ['locality'],
        },
      ],
    });
    expect(wakad?.label).toBe('Wakad');
  });

  it('names a town alone and anything smaller with its town', () => {
    const found = parseOla({
      predictions: [
        olaHinjawadi,
        ola('Lonavala', ['Lonavala', 'Maharashtra', 'India'], 18.75, 73.41, ['locality']),
        ola(
          'Pune Railway Station',
          ['Pune Railway Station', 'Agarkar Nagar', 'Pune', 'Maharashtra', 'India'],
          18.528,
          73.874,
        ),
      ],
    });
    const source = 'ola';
    expect(found).toEqual([
      {
        label: 'Hinjawadi Phase 1, Pune',
        detail: 'Maharashtra',
        lat: 18.5912,
        lng: 73.7389,
        source,
      },
      { label: 'Lonavala', detail: 'Maharashtra', lat: 18.75, lng: 73.41, source },
      { label: 'Pune Railway Station', detail: 'Maharashtra', lat: 18.528, lng: 73.874, source },
    ]);
  });

  it('drops places abroad, without a position, and repeats', () => {
    const found = parseOla({
      predictions: [
        olaHinjawadi,
        { ...olaHinjawadi, geometry: { location: { lat: 18.6, lng: 73.74 } } },
        ola('Kandy', ['Kandy', 'Central Province', 'Sri Lanka'], 7.29, 80.63),
        ola('Nowhere', ['Nowhere', 'Pune', 'Maharashtra'], undefined, 73),
      ],
    });
    expect(found.map((p) => p.label)).toEqual(['Hinjawadi Phase 1, Pune']);
  });

  it('keeps a same-named place in another state', () => {
    const found = parseOla({
      predictions: [
        ola('Baner', ['Baner', 'Odisha', 'India'], 20, 85, ['locality']),
        ola('Baner', ['Baner', 'Pune', 'Maharashtra', 'India'], 18.56, 73.78, ['sublocality']),
      ],
    });
    expect(found.map((p) => `${p.label} (${p.detail ?? ''})`)).toEqual([
      'Baner (Odisha)',
      'Baner, Pune (Maharashtra)',
    ]);
  });

  it('a state is its own label; no state found leaves the line empty', () => {
    const found = parseOla({
      predictions: [
        ola('Goa', ['Goa', 'India'], 15.3, 74, ['administrative_area_level_1']),
        ola('Somewhere Chowk', ['Somewhere Chowk', 'India'], 19, 73),
      ],
    });
    expect(found).toEqual([
      { label: 'Goa', detail: null, lat: 15.3, lng: 74, source: 'ola' },
      { label: 'Somewhere Chowk', detail: null, lat: 19, lng: 73, source: 'ola' },
    ]);
  });

  it('tolerates a shapeless answer', () => {
    expect(parseOla({})).toEqual([]);
    expect(parseOla({ predictions: [{}] })).toEqual([]);
  });
});

describe('placeQueryKey', () => {
  it('ignores case and extra spaces', () => {
    expect(placeQueryKey('  Hinjewadi   PH ')).toBe('hinjewadi ph');
  });
});

/** Just enough of ioredis for the service: get/set (TTLs ignored) and the budget counters. */
function fakeRedis() {
  const store = new Map<string, string>();
  const client = {
    get: (key: string) => Promise.resolve(store.get(key) ?? null),
    set: (key: string, value: string) => {
      store.set(key, value);
      return Promise.resolve('OK');
    },
    multi: () => {
      let key = '';
      const chain = {
        incr: (k: string) => {
          key = k;
          return chain;
        },
        expire: () => chain,
        exec: () => {
          const next = Number(store.get(key) ?? 0) + 1;
          store.set(key, String(next));
          return Promise.resolve([[null, next]]);
        },
      };
      return chain;
    },
  };
  return { store, redis: { client } as unknown as RedisService };
}

function service(config: Partial<AppConfig> = {}) {
  const { store, redis } = fakeRedis();
  const consume = vi.fn(() => Promise.resolve());
  const places = new PlacesService(
    {
      GEOAPIFY_API_KEY: 'test-key',
      GEOAPIFY_URL: 'https://geoapify.test/autocomplete',
      GEOAPIFY_DAILY_LIMIT: 100,
      ...config,
    } as AppConfig,
    redis,
    { consume } as unknown as RateLimiter,
  );
  return { places, store, consume };
}

function answer(body: GeoapifyResponse, status = 200) {
  const fetch = vi.fn(() => Promise.resolve(new Response(JSON.stringify(body), { status })));
  vi.stubGlobal('fetch', fetch);
  return fetch;
}

/** Ola and Geoapify each answer (or fail) on their own host. */
function answers(
  olaAnswer: { body: OlaResponse; status?: number } | 'offline',
  geoapifyAnswer: { body: GeoapifyResponse; status?: number } | 'offline',
) {
  const fetch = vi.fn((input: string) => {
    const reply = new URL(input).host === 'ola.test' ? olaAnswer : geoapifyAnswer;
    if (reply === 'offline') return Promise.reject(new Error('offline'));
    return Promise.resolve(
      new Response(JSON.stringify(reply.body), { status: reply.status ?? 200 }),
    );
  });
  vi.stubGlobal('fetch', fetch);
  const hosts = () => fetch.mock.calls.map(([url]) => new URL(url).host);
  return { fetch, hosts };
}

/** Both providers configured; Ola first. */
const both = {
  OLA_MAPS_API_KEY: 'ola-key',
  OLA_MAPS_URL: 'https://ola.test/autocomplete',
  OLA_MAPS_DAILY_LIMIT: 100,
} satisfies Partial<AppConfig>;

describe('PlacesService', () => {
  afterEach(() => {
    vi.unstubAllGlobals();
  });

  // Geoapify alone (no Ola key): as before Ola Maps was added.

  it('asks Geoapify once, limited to India, then answers from the cache', async () => {
    const fetch = answer({ results: [hinjawadi] });
    const { places, consume } = service();

    expect(await places.search('u1', 'hinjewadi ph')).toHaveLength(1);
    expect(await places.search('u2', ' Hinjewadi  PH')).toHaveLength(1);

    expect(fetch).toHaveBeenCalledTimes(1);
    const url = new URL(String((fetch.mock.calls[0] as unknown[])[0]));
    expect(url.origin + url.pathname).toBe('https://geoapify.test/autocomplete');
    expect(url.searchParams.get('text')).toBe('hinjewadi ph');
    expect(url.searchParams.get('filter')).toBe('countrycode:in');
    expect(url.searchParams.get('format')).toBe('json');
    expect(url.searchParams.get('apiKey')).toBe('test-key');
    expect(consume).toHaveBeenCalledTimes(2);
  });

  it('without a key: no suggestions and no request', async () => {
    const fetch = answer({ results: [hinjawadi] });
    const { places } = service({ GEOAPIFY_API_KEY: undefined });
    expect(await places.search('u1', 'hinjewadi')).toEqual([]);
    expect(fetch).not.toHaveBeenCalled();
  });

  it('a failed request gives nothing, is not cached, and rests the provider a minute', async () => {
    const fetch = answer({}, 401);
    const { places, store } = service();
    expect(await places.search('u1', 'hinjewadi')).toEqual([]);
    expect(store.has('places:v2:hinjewadi')).toBe(false);
    expect(await places.search('u1', 'hinjewadi')).toEqual([]);
    expect(fetch).toHaveBeenCalledTimes(1); // marked down, not asked again

    store.delete('places:geoapify:down'); // the minute is up
    vi.stubGlobal(
      'fetch',
      vi.fn(() => Promise.reject(new Error('offline'))),
    );
    expect(await places.search('u1', 'hinjewadi')).toEqual([]);
    expect(store.has('places:geoapify:down')).toBe(true);
  });

  it('past the daily budget, only cached answers are served', async () => {
    const fetch = answer({ results: [hinjawadi] });
    const { places } = service({ GEOAPIFY_DAILY_LIMIT: 1 });
    expect(await places.search('u1', 'hinjewadi')).toHaveLength(1);
    expect(await places.search('u1', 'baner')).toEqual([]);
    expect(await places.search('u1', 'hinjewadi')).toHaveLength(1); // cached
    expect(fetch).toHaveBeenCalledTimes(1);
  });

  // Ola Maps first, Geoapify as the fallback.

  it('with both keys, asks only Ola and caches its answer', async () => {
    const { fetch, hosts } = answers({ body: { predictions: [olaHinjawadi] } }, 'offline');
    const { places } = service(both);

    const [found] = await places.search('u1', 'hinjewadi ph');
    expect(found).toMatchObject({ label: 'Hinjawadi Phase 1, Pune', source: 'ola' });
    expect(await places.search('u2', 'Hinjewadi PH')).toHaveLength(1);

    expect(hosts()).toEqual(['ola.test']);
    const url = new URL(String((fetch.mock.calls[0] as unknown[])[0]));
    expect(url.pathname).toBe('/autocomplete');
    expect(url.searchParams.get('input')).toBe('hinjewadi ph');
    expect(url.searchParams.get('api_key')).toBe('ola-key');
  });

  it('Ola failing: Geoapify answers, and Ola rests a minute', async () => {
    const { hosts } = answers({ body: {}, status: 500 }, { body: { results: [hinjawadi] } });
    const { places, store } = service(both);

    const [found] = await places.search('u1', 'hinjewadi');
    expect(found).toMatchObject({ label: 'Hinjawadi Phase 1, Pune', source: 'geoapify' });
    expect(store.has('places:v2:hinjewadi')).toBe(true);

    await places.search('u1', 'baner');
    expect(hosts()).toEqual(['ola.test', 'geoapify.test', 'geoapify.test']);
  });

  it('Ola unreachable: Geoapify answers', async () => {
    answers('offline', { body: { results: [hinjawadi] } });
    const { places } = service(both);
    expect(await places.search('u1', 'hinjewadi')).toHaveLength(1);
  });

  it('Ola past its budget: Geoapify answers', async () => {
    const { hosts } = answers(
      { body: { predictions: [olaHinjawadi] } },
      { body: { results: [hinjawadi] } },
    );
    const { places } = service({ ...both, OLA_MAPS_DAILY_LIMIT: 1 });
    expect((await places.search('u1', 'hinjewadi'))[0]?.source).toBe('ola');
    expect((await places.search('u1', 'baner'))[0]?.source).toBe('geoapify');
    expect(hosts()).toEqual(['ola.test', 'geoapify.test']);
  });

  it('Ola alone, without a Geoapify key', async () => {
    const { hosts } = answers({ body: { predictions: [olaHinjawadi] } }, 'offline');
    const { places } = service({ ...both, GEOAPIFY_API_KEY: undefined });
    expect(await places.search('u1', 'hinjewadi')).toHaveLength(1);
    expect(hosts()).toEqual(['ola.test']);
  });

  it('both failing: nothing, and nothing cached', async () => {
    const { hosts } = answers('offline', { body: {}, status: 429 });
    const { places, store } = service(both);
    expect(await places.search('u1', 'hinjewadi')).toEqual([]);
    expect(hosts()).toEqual(['ola.test', 'geoapify.test']);
    expect(store.has('places:v2:hinjewadi')).toBe(false);
  });

  it('both past their budget: only cached answers', async () => {
    const { hosts } = answers(
      { body: { predictions: [olaHinjawadi] } },
      { body: { results: [hinjawadi] } },
    );
    const { places } = service({ ...both, OLA_MAPS_DAILY_LIMIT: 1, GEOAPIFY_DAILY_LIMIT: 1 });
    await places.search('u1', 'hinjewadi');
    await places.search('u1', 'baner');
    expect(await places.search('u1', 'wakad')).toEqual([]);
    expect(await places.search('u1', 'hinjewadi')).toHaveLength(1); // cached
    expect(hosts()).toEqual(['ola.test', 'geoapify.test']);
  });

  it('with neither key: nothing asked', async () => {
    const { fetch } = answers('offline', 'offline');
    const { places } = service({ GEOAPIFY_API_KEY: undefined });
    expect(await places.search('u1', 'hinjewadi')).toEqual([]);
    expect(fetch).not.toHaveBeenCalled();
  });
});

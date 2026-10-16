import { afterEach, describe, expect, it, vi } from 'vitest';
import type { AppConfig } from '../../platform/config.js';
import type { RateLimiter } from '../../platform/rate-limit.js';
import type { RedisService } from '../../platform/redis.service.js';
import {
  parseGeoapify,
  placeQueryKey,
  PlacesService,
  type GeoapifyResponse,
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
    expect(found).toEqual([
      { label: 'Hinjawadi Phase 1, Pune', detail: 'Maharashtra', lat: 18.5912, lng: 73.7389 },
      { label: 'Lonavala', detail: 'Maharashtra', lat: 18.75, lng: 73.41 },
      { label: 'Pune Railway Station', detail: 'Maharashtra', lat: 18.528, lng: 73.874 },
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
    expect(goa).toEqual({ label: 'Goa', detail: null, lat: 15.3, lng: 74 });
  });

  it('tolerates a shapeless answer', () => {
    expect(parseGeoapify({})).toEqual([]);
  });
});

describe('placeQueryKey', () => {
  it('ignores case and extra spaces', () => {
    expect(placeQueryKey('  Hinjewadi   PH ')).toBe('hinjewadi ph');
  });
});

/** Just enough of ioredis for the service: get/set and the budget counter. */
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

describe('PlacesService', () => {
  afterEach(() => {
    vi.unstubAllGlobals();
  });

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

  it('a failed request gives nothing and is not cached', async () => {
    const fetch = answer({}, 401);
    const { places } = service();
    expect(await places.search('u1', 'hinjewadi')).toEqual([]);
    expect(await places.search('u1', 'hinjewadi')).toEqual([]);
    expect(fetch).toHaveBeenCalledTimes(2);

    vi.stubGlobal(
      'fetch',
      vi.fn(() => Promise.reject(new Error('offline'))),
    );
    expect(await places.search('u1', 'hinjewadi')).toEqual([]);
  });

  it('past the daily budget, only cached answers are served', async () => {
    const fetch = answer({ results: [hinjawadi] });
    const { places } = service({ GEOAPIFY_DAILY_LIMIT: 1 });
    expect(await places.search('u1', 'hinjewadi')).toHaveLength(1);
    expect(await places.search('u1', 'baner')).toEqual([]);
    expect(await places.search('u1', 'hinjewadi')).toHaveLength(1); // cached
    expect(fetch).toHaveBeenCalledTimes(1);
  });
});

// Regenerates assets/data/in_cities.json: the Indian cities and towns offered as
// a trip's pickup and drop. The source is the GeoNames India dump, which is the
// authoritative free list (Wikidata's is missing Mumbai, Delhi and Bengaluru).
//
//   curl -O https://download.geonames.org/export/dump/IN.zip
//   curl -O https://download.geonames.org/export/dump/admin1CodesASCII.txt
//   unzip IN.zip
//   node tool/generate_cities.mjs IN.txt admin1CodesASCII.txt assets/data/in_cities.json
//
// Every town of 20,000 people or more, which is about 2,900 of them: enough to
// cover anywhere a small fleet drives, small enough to bundle and filter in the
// app with no network call. Written as [name, state, lat, lng] tuples to keep
// the asset small. GeoNames data is CC BY 4.0.
import { createReadStream } from 'node:fs';
import { readFile, writeFile } from 'node:fs/promises';
import { createInterface } from 'node:readline';

const [, , inTxt, admin1Txt, outJson] = process.argv;
const MIN_POPULATION = 20_000;
// PPLX is a section of a city (a neighbourhood); the rest are towns upward.
const KINDS = new Set(['PPL', 'PPLA', 'PPLA2', 'PPLA3', 'PPLA4', 'PPLA5', 'PPLC', 'PPLG']);

const states = new Map();
for (const line of (await readFile(admin1Txt, 'utf8')).split('\n')) {
  const [code, name] = line.split('\t');
  if (code?.startsWith('IN.')) states.set(code, name);
}

const best = new Map();
const rl = createInterface({ input: createReadStream(inTxt, 'utf8'), crlfDelay: Infinity });
for await (const line of rl) {
  const f = line.split('\t');
  if (f[6] !== 'P' || !KINDS.has(f[7])) continue;
  const population = Number(f[14] || 0);
  if (population < MIN_POPULATION) continue;
  const name = (f[1] || '').trim();
  const state = states.get(`IN.${f[10]}`) ?? '';
  if (name === '' || state === '') continue;
  const key = `${name.toLowerCase()}\t${state.toLowerCase()}`;
  const previous = best.get(key);
  if (previous && previous.population >= population) continue;
  best.set(key, {
    name,
    state,
    lat: Number(Number(f[4]).toFixed(4)),
    lng: Number(Number(f[5]).toFixed(4)),
    population,
  });
}

const cities = [...best.values()].sort(
  (a, b) => b.population - a.population || a.name.localeCompare(b.name),
);
await writeFile(
  outJson,
  JSON.stringify(cities.map(({ name, state, lat, lng }) => [name, state, lat, lng])),
);
console.log(`cities: ${cities.length}, states: ${new Set(cities.map((c) => c.state)).size}`);
console.log('largest:', cities.slice(0, 12).map((c) => c.name).join(', '));
for (const q of ['Mumbai', 'Delhi', 'Bengaluru', 'Chennai', 'Hyderabad', 'Pune', 'Shirdi', 'Lonavla'])
  console.log(' ', q.padEnd(11), '->', cities.filter((c) => c.name === q).map((c) => `${c.name}, ${c.state}`).join(' | ') || '(none)');

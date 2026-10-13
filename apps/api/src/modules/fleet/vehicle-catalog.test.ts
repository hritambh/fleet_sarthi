import { describe, expect, it } from 'vitest';
import {
  brandId,
  buildCatalogue,
  parseBrandVocabulary,
  type CategoryMembers,
  type SparqlResults,
} from './vehicle-catalog.service.js';

const sparql = (labels: readonly string[]): SparqlResults => ({
  results: { bindings: labels.map((value) => ({ brandLabel: { value } })) },
});

const category = (
  title: string,
  pages: readonly string[],
  subcategories: readonly string[] = [],
): CategoryMembers => ({ title, pages, subcategories });

/** The manufacturer names, as Wikidata spells them. */
const vocabulary = [
  'Maruti Suzuki',
  'Suzuki Motor Corporation',
  'Tata Motors Limited',
  'Mahindra & Mahindra',
  'Toyota',
  'Hyundai Motor Company',
  'Mercedes-Benz Group',
  'Ashok Leyland',
  'Škoda Auto',
];

const modelsOf = (
  catalogue: { models: Readonly<Record<string, readonly { name: string }[]>> },
  name: string,
): string[] => (catalogue.models[brandId(name)] ?? []).map((m) => m.name);

describe('parseBrandVocabulary', () => {
  it('keeps the names and drops repeats and unresolved ids', () => {
    expect(parseBrandVocabulary(sparql(['Toyota', 'Q12072657', 'Toyota', '', 'Kia']))).toEqual([
      'Toyota',
      'Kia',
    ]);
  });

  it('tolerates a shapeless answer', () => {
    expect(parseBrandVocabulary({})).toEqual([]);
    expect(parseBrandVocabulary({ results: { bindings: [{ brandLabel: undefined }] } })).toEqual(
      [],
    );
  });
});

describe('buildCatalogue', () => {
  it('splits a title into the brand and the model', () => {
    const root = category('Cars of India', [
      'Toyota Innova',
      'Hyundai Creta',
      'Mercedes-Benz C-Class (W205)',
      'Ashok Leyland MiTR',
    ]);
    const built = buildCatalogue(root, [], vocabulary);
    expect(built.brands.map((b) => b.name)).toEqual([
      'Ashok Leyland',
      'Hyundai',
      'Mercedes-Benz',
      'Toyota',
    ]);
    expect(modelsOf(built, 'Toyota')).toEqual(['Innova']);
    expect(modelsOf(built, 'Mercedes-Benz')).toEqual(['C-Class']);
    expect(modelsOf(built, 'Ashok Leyland')).toEqual(['MiTR']);
  });

  it('collapses the generations of one model into a single entry', () => {
    const root = category('Cars of India', [
      'Hyundai Creta',
      'Mercedes-Benz C-Class (W204)',
      'Mercedes-Benz C-Class (W205)',
      'Mercedes-Benz C-Class (W206)',
    ]);
    expect(modelsOf(buildCatalogue(root, [], vocabulary), 'Mercedes-Benz')).toEqual(['C-Class']);
  });

  it("files a brand's cars under the name its category uses, not the title's", () => {
    // Wikipedia titles the Maruti cars after Suzuki, but files them under
    // Category:Maruti vehicles — which is the name an owner here looks for.
    const root = category(
      'Cars of India',
      ['Suzuki Fronx', 'Hyundai Creta'],
      ['Category:Maruti vehicles'],
    );
    const maruti = category('Category:Maruti vehicles', [
      'Maruti 800',
      'Maruti Suzuki Wagon R',
      'Suzuki Dzire',
      'Suzuki Swift',
    ]);
    const built = buildCatalogue(root, [maruti], vocabulary);
    expect(built.brands.map((b) => b.name)).toEqual(['Hyundai', 'Maruti']);
    // Including the one that was only in the India category, not the brand's.
    expect(modelsOf(built, 'Maruti')).toEqual(['800', 'Dzire', 'Fronx', 'Swift', 'Wagon R']);
    expect(modelsOf(built, 'Suzuki')).toEqual([]);
  });

  it('strips the suffix off a brand category, however it is worded', () => {
    const root = category(
      'Cars of India',
      [],
      ['Category:Tata cars', 'Category:Hyundai vehicles in India'],
    );
    const built = buildCatalogue(
      root,
      [
        category('Category:Tata cars', ['Tata Nexon']),
        category('Category:Hyundai vehicles in India', ['Hyundai Aura']),
      ],
      vocabulary,
    );
    expect(built.brands.map((b) => b.name)).toEqual(['Hyundai', 'Tata']);
    expect(modelsOf(built, 'Tata')).toEqual(['Nexon']);
  });

  it('keeps a company-named category, and leaves out its company page', () => {
    const root = category('Cars of India', [], ['Category:Ashok Leyland']);
    const built = buildCatalogue(
      root,
      [category('Category:Ashok Leyland', ['Ashok Leyland', 'Ashok Leyland STiLE'])],
      vocabulary,
    );
    expect(modelsOf(built, 'Ashok Leyland')).toEqual(['STiLE']);
  });

  it('ignores a subcategory that is not about a brand', () => {
    const root = category('Cars of India', ['Tata Nexon'], ['Category:Indian racing cars']);
    const built = buildCatalogue(
      root,
      [category('Category:Indian racing cars', ['DC Avanti', 'Formula LGB Swift'])],
      vocabulary,
    );
    expect(built.brands.map((b) => b.name)).toEqual(['Tata']);
    expect(modelsOf(built, 'Tata')).toEqual(['Nexon']);
  });

  it('leaves out a title whose brand it cannot tell from the model', () => {
    const root = category('Cars of India', [
      'Tata Nexon',
      'Armoured Carrier Wheeled Indian Pattern',
      'REVAi',
    ]);
    const built = buildCatalogue(root, [], vocabulary);
    expect(built.brands.map((b) => b.name)).toEqual(['Tata']);
  });

  it('is empty, not broken, when neither source answered', () => {
    expect(buildCatalogue(category('Cars of India', []), [], [])).toEqual({
      brands: [],
      models: {},
    });
  });

  it('gives every brand an id its models are listed under', () => {
    const root = category('Cars of India', ['Škoda Kushaq', 'Mercedes-Benz GLC']);
    const built = buildCatalogue(root, [], vocabulary);
    expect(built.brands.map((b) => b.id)).toEqual(['mercedes-benz', 'skoda']);
    for (const brand of built.brands) {
      expect(built.models[brand.id]).toBeDefined();
    }
  });
});

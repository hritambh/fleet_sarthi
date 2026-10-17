import { z } from 'zod';
import { access, defineRoute } from '../http.js';

/**
 * A place to suggest for a trip's pickup or drop. [label] is what goes in the
 * field when it's picked ("Hinjawadi Phase 1, Pune"); [detail] is the line
 * under it ("Maharashtra"); [source] is who found it, for the credit line.
 */
export const PlaceSource = z.enum(['ola', 'geoapify']);
export type PlaceSource = z.infer<typeof PlaceSource>;

export const PlaceSuggestion = z.object({
  label: z.string(),
  detail: z.string().nullable(),
  lat: z.number(),
  lng: z.number(),
  source: PlaceSource,
});
export type PlaceSuggestion = z.infer<typeof PlaceSuggestion>;

export const placeRoutes = {
  searchPlaces: defineRoute({
    method: 'GET',
    path: '/places/search',
    summary:
      'Places in India matching what was typed, for the trip pickup and drop fields. ' +
      'Asks Ola Maps first and Geoapify when Ola fails. Empty when neither is ' +
      'configured (OLA_MAPS_API_KEY, GEOAPIFY_API_KEY) or reachable.',
    tag: 'trips',
    access: access.anyMember,
    query: z.object({ q: z.string().trim().min(3).max(100) }),
    response: z.array(PlaceSuggestion),
  }),
};

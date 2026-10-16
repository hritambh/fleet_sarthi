import { z } from 'zod';
import { access, defineRoute } from '../http.js';

/**
 * A place to suggest for a trip's pickup or drop. [label] is what goes in the
 * field when it's picked ("Hinjawadi Phase 1, Pune"); [detail] is the line
 * under it ("Maharashtra").
 */
export const PlaceSuggestion = z.object({
  label: z.string(),
  detail: z.string().nullable(),
  lat: z.number(),
  lng: z.number(),
});
export type PlaceSuggestion = z.infer<typeof PlaceSuggestion>;

export const placeRoutes = {
  searchPlaces: defineRoute({
    method: 'GET',
    path: '/places/search',
    summary:
      'Places in India matching what was typed, for the trip pickup and drop fields. ' +
      'Empty when place search is switched off (no GEOAPIFY_API_KEY) or unreachable.',
    tag: 'trips',
    access: access.anyMember,
    query: z.object({ q: z.string().trim().min(3).max(100) }),
    response: z.array(PlaceSuggestion),
  }),
};

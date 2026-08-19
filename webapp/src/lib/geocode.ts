export interface GeocodeResult {
  displayName: string;
  lat: number;
  lon: number;
}

/**
 * Free, keyless geocoding via OpenStreetMap's Nominatim. Fine for occasional,
 * personal use (this app makes at most one request per manual search).
 */
export async function geocodeSearch(query: string): Promise<GeocodeResult[]> {
  if (query.trim().length < 3) return [];
  const url = `https://nominatim.openstreetmap.org/search?format=jsonv2&limit=5&q=${encodeURIComponent(query)}`;
  const res = await fetch(url, { headers: { Accept: 'application/json' } });
  if (!res.ok) return [];
  const data = (await res.json()) as Array<{ display_name: string; lat: string; lon: string }>;
  return data.map((d) => ({ displayName: d.display_name, lat: parseFloat(d.lat), lon: parseFloat(d.lon) }));
}

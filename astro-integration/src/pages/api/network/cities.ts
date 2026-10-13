import type { APIRoute } from "astro";
export const prerender = false;
export const GET: APIRoute = async ({ url }) => {
  const base = import.meta.env.DISCOURSE_URL;
  if (!base) return new Response("Discourse URL not configured", { status: 503 });
  const websiteKey = import.meta.env.PROFESSIONAL_NETWORK_WEBSITE_KEY || "default";
  // ?slug=<city-slug> proxies the per-city detail endpoint; otherwise the directory list.
  // ?map=1 proxies the aggregated map endpoint used by harta.astro / CommunityMap.astro.
  const slug = url.searchParams.get("slug");
  const path = url.searchParams.get("map")
    ? "/network/cities/map.json"
    : slug
      ? `/network/cities/${encodeURIComponent(slug)}.json`
      : "/network/cities.json";
  const target = new URL(path, base);
  target.searchParams.set("website_key", websiteKey);
  if (!slug && !url.searchParams.get("map")) {
    for (const key of ["status", "region", "country", "q"]) {
      const value = url.searchParams.get(key);
      if (value) target.searchParams.set(key, value);
    }
  }
  const response = await fetch(target, { headers: { Accept: "application/json" } });
  return new Response(await response.text(), { status: response.status, headers: { "Content-Type": "application/json", "Cache-Control": "no-store" } });
};

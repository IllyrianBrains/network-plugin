import type { APIRoute } from "astro";
export const prerender = false;
export const GET: APIRoute = async ({ url }) => {
  const username = url.searchParams.get("username");
  if (!username || !/^[a-zA-Z0-9_.-]{1,80}$/.test(username))
    return new Response("Invalid username", { status: 400 });
  const base = import.meta.env.DISCOURSE_URL;
  if (!base) return new Response("Discourse URL not configured", { status: 503 });
  const websiteKey = import.meta.env.PROFESSIONAL_NETWORK_WEBSITE_KEY || "default";
  const target = new URL(`/network/profiles/${encodeURIComponent(username)}.json`, base);
  target.searchParams.set("website_key", websiteKey);
  const response = await fetch(target, { headers: { Accept: "application/json" } });
  return new Response(await response.text(), { status: response.status, headers: { "Content-Type": "application/json", "Cache-Control": "no-store" } });
};

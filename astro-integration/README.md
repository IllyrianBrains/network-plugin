# Astro integration sample

Copy the `src` files into your Astro project. Set `DISCOURSE_URL` in the Astro server environment (e.g. https://community.example.org) and `PROFESSIONAL_NETWORK_WEBSITE_KEY` to the stable key for this website (defaults to `default`). Use an Astro server adapter for on-demand pages.

This demonstrates **public profile reads** only. Private member profiles, upload, confirmation and selected post creation require per-user authentication and CSRF protections. Do not put a Discourse admin API key in Astro browser code.

The Discourse plugin API for selected posts is `POST /professional-network/shares.json`. The member must supply a LinkedIn post URL, title and optional commentary.

`organizations.ts` and `cities.ts` proxy the read-only organization/business directory, city directory, per-city page and network map endpoints the same way `profile.ts` does. Organizations and cities are public data (published only, unless the viewer is that organization's own account/staff/signed-in Discourse session) and have no write examples here yet; writes (creating/editing an organization, managing offers) still need per-user authentication, same caveat as profile writes above.

`network/graph.astro` renders the `network-graph.json` endpoint (member/city/field-of-expertise nodes and edges) with [Cytoscape.js](https://js.cytoscape.org/), loaded from a CDN; `api/network/graph.ts` proxies the same endpoint if you'd rather fetch it client-side.

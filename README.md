# Discourse Professional Network

A Discourse plugin for member-approved LinkedIn PDF profile imports, selected
LinkedIn post links, an organization/business directory, a city directory,
and a member network graph. It does not scrape LinkedIn or sync a member's
full activity.

## Requirements

- Self-hosted Discourse with plugin support; test on staging first.
- PostgreSQL and a Discourse release supporting Rails 7 migrations.
- `pdftotext` from `poppler-utils`, installed inside the Discourse
  application container.
- No external AI service or LinkedIn credentials required.

## Install

Add to `containers/app.yml` under `hooks: after_code:`:

```yaml
- exec:
    cd: $home/plugins
    cmd:
      - git clone https://github.com/IllyrianBrains/network-plugin.git discourse-professional-network
```

Then run `./launcher rebuild app`. Alternatively, `make plugin` builds
`dist/discourse-professional-network-<version>.zip`; extract it into
`containers/plugins/discourse-professional-network/` and rebuild.

Enable the plugin with the `professional_network_enabled` site setting, and
set `professional_network_category_id` to a category where members may post.

## Local development

```bash
./dev/setup.sh
docker compose up -d postgres redis
docker compose run --rm web bash -lc 'bundle install && bundle exec rails db:create db:migrate'
./dev/create-admin.sh
docker compose up web
```

Open http://localhost:3000 and log in with the default local admin account
(`admin@example.test` / `LocalDevelopment123!`, overridable via
`DEV_ADMIN_EMAIL`/`DEV_ADMIN_PASSWORD`). Run `./dev/smoke.sh` to exercise the
main flows. Never use these credentials or `dev/create-admin.sh` outside
local development.

To populate the local directory from another Discourse, create an admin API
key on the source forum, fill in the gitignored root `.env` file, and run:

```bash
./dev/import-discourse-people.sh
```

The development-only importer copies active, non-staff accounts and creates a
minimal professional-network profile. It never copies passwords or privileges,
and it is safe to rerun: existing local accounts are matched by email. Profiles
remain private unless `IMPORT_PUBLISH_PROFILES=true` is set. Use
`IMPORT_DRY_RUN=true` to preview, `IMPORT_LIMIT=50` to cap the run, and
`IMPORT_WEBSITE_KEY=default` to choose the profile scope. API credentials are
read from `.env` and are not committed. `IMPORT_ENV_FILE=/path/to/file` selects
a different environment file.

## Safety

Imports are private drafts until the member confirms them. Do not upload
another person's PDF without permission, and do not publish private CV data
without consent.

## People recommendations

The **People to meet** page ranks published member profiles from the same
`website_key`. It uses an explainable hybrid score rather than sending profile
data to an embedding or AI service:

```text
final_score = 100 × (
  0.7 × normalized_rule_score +
  0.2 × cosine_profile_similarity +
  0.1 × interaction_quality
)
```

`normalized_rule_score` is the compatibility score divided by its maximum of
48. It rewards shared city (3), up to two shared fields (4 each), up to two
shared skills (1 each), up to two shared business interests (3 each),
complementary business needs such as hiring/job-seeking or
investing/fundraising (6 each), mutual help-text matches (3 in each direction),
target-field expertise (5), and a compatible mentor relationship (6).

`cosine_profile_similarity` is calculated locally from term-frequency vectors
built from public professional fields and public aspirations. It does not use
external embeddings. A cosine-only candidate must score at least `0.1` to be
included.

`interaction_quality` is currently `0`. The 10% allocation is intentionally
reserved for a future, consented signal such as a useful-introduction rating;
the plugin does not infer relationship quality from private messages or other
private activity. Until such a signal exists, the maximum attainable final
score is 90. Results with neither a rule match nor sufficient cosine similarity
are excluded, then the remaining results are sorted by final score.

Members can reorder six priorities under **My profile → Networking**:
business opportunities, mentoring, career relevance, mutual help, location,
and similar background. Their order applies the multipliers `1.5`, `1.3`,
`1.1`, `0.9`, `0.7`, and `0.5` respectively to matching evidence before the
final score is calculated. This preference is private, validated as a complete
order, and affects only that member's recommendations.

## Network map and city coordinates

The Network page includes an OpenLayers map alongside the relationship graph.
It plots one bubble at each active city's centre and sizes it by the number of
published member profiles matched to that city. It never stores or displays a
member's exact location.

City coordinates can be maintained directly in `professional_network_cities`
or imported idempotently from a CSV file. In this repository's Docker Compose
development environment, run:

```bash
docker compose run --rm web bundle exec rake professional_network:import_cities \
  CSV=plugins/discourse-professional-network/dev/example_cities.csv \
  WEBSITE_KEY=default
```

For an installed Discourse environment where the command already runs inside
the application container, use:

```bash
bundle exec rake professional_network:import_cities CSV=/path/to/cities.csv WEBSITE_KEY=default
```

The CSV requires `name` and accepts
`slug,country,region,lat,lng,aliases,status,region_color`. Separate aliases with
`|`, for example `Rome|Rom`. Rows are matched by `website_key` and slug, so
running the same import updates existing cities. Both latitude and longitude
must be present together. The plugin does not call a geocoding service at
profile-save or map-view time.

For local development, `./dev/seed-example-data.sh` imports the reusable
[`dev/example_cities.csv`](dev/example_cities.csv) fixture before creating the
example member profiles. The fixture mirrors the 52-city catalogue in the
adjacent website project and adds Lisbon, Prishtina, Podgorica, and Sarajevo
for broader seed coverage. It can also be passed directly to the rake task
above.

## More detail

- [AGENTS.md](AGENTS.md) -- repository layout, scope boundaries, and
  conventions for AI agents working in this codebase.
- [code-standards.md](code-standards.md) -- Ruby/JS style and conventions.

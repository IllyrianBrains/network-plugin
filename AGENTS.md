# AI Coding Agent Guide

Project-specific instructions for AI agents working in this repository. Read
this before making changes.

## What this is

A Discourse plugin (`discourse-professional-network`, module
`ProfessionalNetwork`) adding member-approved LinkedIn PDF profile imports,
selected LinkedIn post links, an organization/business directory, a city
directory, and a member network graph. See [README.md](README.md) for the
full feature history and API list -- it is the source of truth for what's
in scope per version and what's deliberately **not implemented** (member
registration/approval, teams, follows, posts/feed, blocks/reports). Don't
build those without checking with the user first; the README calls them out
as intentionally out of scope.

## Repository layout

- `plugin.rb` -- plugin entry point: site setting registration, custom
  field registration, `require_relative` list, route mounting.
- `app/models/professional_network/` -- ActiveRecord models.
- `app/services/professional_network/` -- plain Ruby service/query objects
  (not Discourse core's `Service::Base` pattern -- see
  [code-standards.md](code-standards.md)).
- `app/controllers/professional_network/` -- controllers, all inheriting
  `BaseController`.
- `config/settings.yml` -- plugin site settings. `config/locales/` --
  client translations.
- `db/` -- migrations.
- `assets/javascripts/discourse/` -- frontend: Glimmer components (`.gjs`),
  route map, initializers, connectors.
- `assets/stylesheets/` -- SCSS, registered via `register_asset` in
  `plugin.rb`.
- `theme/` -- a separate Discourse theme component (own `about.json`), not
  part of the plugin's asset pipeline.
- `astro-integration/` -- example Astro pages/API routes showing how an
  external site (the Illyrian Brains website) consumes this plugin's JSON
  endpoints. Reference/example code, not shipped with the plugin.
- `spec/` -- RSpec, mirroring `app/` (`spec/models/`, `spec/services/`).
- `dev/` -- local Docker Compose dev harness (`setup.sh`, `create-admin.sh`,
  `seed-example-data.sh`, `smoke.sh`). `dev/discourse/` is a full Discourse
  core checkout used by the stack; it's gitignored and never committed.
- `examples/` -- sample payloads/fixtures.

## Working in this codebase

- This plugin has no Ruby/Rails runtime available in most environments.
  There is no root-level `Gemfile`/`package.json` -- Ruby and JS tooling
  comes from the Discourse core checkout at `dev/discourse/` when the dev
  stack is set up. If you can't run `bin/rspec` or lint, say so explicitly
  rather than claiming tests pass; a plain `ruby -c` syntax check is better
  than nothing but is not a substitute.
- To actually run the plugin: `./dev/setup.sh`, then follow the Local Docker
  Compose Development section of [README.md](README.md). Never use the dev
  admin credentials or `dev/create-admin.sh` outside local development.
- Prefer extending existing service objects over adding controller logic --
  see how `DirectorySearch`, `RelatedProfiles`, `Aspirations` are structured
  and keep new business logic in `app/services/professional_network/`.
- Follow [code-standards.md](code-standards.md) for Ruby/JS style, comment
  philosophy, and controller/service conventions specific to this repo.
- When a change affects the API surface, update the endpoint list in
  [README.md](README.md). When a change affects scope (adds/removes a
  feature called out as "not implemented" or "out of scope"), update that
  section too -- the README's version history is treated as the changelog.
- `website_key` scoping (`Profile::WEBSITE_KEY`, `scope :for_website`) is
  how multiple frontend sites share one plugin instance. Don't bypass it in
  queries that return profile/organization data.
- Public vs. private data: fields gated by `#public_h` (profiles) or kept
  out of it entirely (e.g. `Aspirations#return_plan`/`return_countries`)
  must stay excluded from any new serialization path that a non-owner,
  non-staff caller can reach. Check `profiles_controller.rb` for the current
  pattern before adding a new public-facing field.

## Security

- All param allowlisting happens in controllers via `permit!`/`permit` on an
  explicit field list (see `BaseController#profile_params`) -- never widen
  an existing list without checking whether the new field should be public.
- `SiteSetting.professional_network_enabled` gates every request via
  `BaseController#ensure_enabled`; don't add routes that skip `BaseController`.
- Treat uploaded PDFs as untrusted input (`PdfParser` shells out to
  `pdftotext`) -- don't change parsing to pass user-controlled strings into
  a shell command.
- No external AI service or LinkedIn credentials are used anywhere in this
  plugin; don't introduce a dependency on either without flagging it to the
  user first, since the README states this as a property of the plugin.

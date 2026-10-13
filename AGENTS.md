# AI Coding Agent Guide

Project-specific instructions for AI agents working in this repository. Read
this before making changes.

## What this is

A Discourse plugin (`discourse-professional-network`, module
`ProfessionalNetwork`) adding member-approved LinkedIn PDF profile imports,
selected LinkedIn post links, an organization/business directory, a city
directory, and a member network graph. See [README.md](README.md) for
install/setup. The following are deliberately **not implemented**: member
registration/approval, teams, follows, posts/feed, blocks/reports. Don't
build those without checking with the user first -- they're intentionally
out of scope.

## Repository layout

This plugin follows the structure of Discourse's official plugin skeleton
(https://github.com/discourse/discourse-plugin-skeleton): a `Rails::Engine`
with `isolate_namespace` for Zeitwerk autoloading, routes centralized in
`config/routes.rb`, and site setting descriptions in
`config/locales/server.en.yml`. Keep new code consistent with that --
don't add manual `require_relative` calls back into `plugin.rb` for new
`app/` files, and don't declare routes there either.

- `plugin.rb` -- plugin entry point: site setting registration, engine
  require, custom field registration, the `post_created` hook.
- `lib/professional_network/engine.rb` -- defines `ProfessionalNetwork::Engine
  < Rails::Engine` with `isolate_namespace`. This is what makes everything
  under `app/` (models, services, controllers) autoload via Zeitwerk --
  there's no per-file `require_relative` list in `plugin.rb` anymore, so a
  new file like `app/services/professional_network/foo_bar.rb` just needs
  `module ProfessionalNetwork; class FooBar` to match its path and it loads
  automatically.
- `config/routes.rb` -- all plugin routes, drawn on
  `ProfessionalNetwork::Engine.routes` and mounted at `/network`
  on `Discourse::Application.routes`. Don't declare plugin routes in
  `plugin.rb` directly.
- `app/models/professional_network/` -- ActiveRecord models.
- `app/services/professional_network/` -- plain Ruby service/query objects
  (not Discourse core's `Service::Base` pattern -- see
  [code-standards.md](code-standards.md)).
- `app/controllers/professional_network/` -- controllers, all inheriting
  `BaseController`.
- `config/settings.yml` -- plugin site settings. `config/locales/` --
  client translations; `config/locales/server.en.yml` holds the
  `site_settings` descriptions shown in the admin UI.
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
  `seed-example-data.sh` + `seed_example_data.rb` for example member
  profiles, `smoke.sh`). `dev/discourse/` is a full Discourse core checkout
  used by the stack; it's gitignored and never committed.

## Working in this codebase

- This plugin has no Ruby/Rails runtime available in most environments.
  There is no root-level `Gemfile`/`package.json` -- Ruby and JS tooling
  comes from the Discourse core checkout at `dev/discourse/` when the dev
  stack is set up. If you can't run `bin/rspec` or lint, say so explicitly
  rather than claiming tests pass; a plain `ruby -c` syntax check is better
  than nothing but is not a substitute.
- To actually run the plugin: `./dev/setup.sh`, then follow the Local
  development section of [README.md](README.md). Never use the dev admin
  credentials or `dev/create-admin.sh` outside local development.
- Prefer extending existing service objects over adding controller logic --
  see how `DirectorySearch`, `RelatedProfiles`, `Aspirations` are structured
  and keep new business logic in `app/services/professional_network/`.
- Follow [code-standards.md](code-standards.md) for Ruby/JS style, comment
  philosophy, and controller/service conventions specific to this repo.
- When a change adds or removes a feature called out above as "not
  implemented" or "out of scope," update that list in this file.
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

## Planned / needs discussion

- **Auto-import a member's LinkedIn posts from their linked account.** Asked
  for 2026-10-13: given a member has set their LinkedIn profile URL, pull a
  list of their posts automatically instead of pasting one link at a time
  (`ProfessionalNetwork::SharesController#create`/`LinkedinPostPreview`
  currently only resolve one known post URL via Discourse's Oneboxer, which
  cannot enumerate "all posts by this person"). There is no public,
  unauthenticated API for this. Doing it for real needs either LinkedIn's
  official API (OAuth app + Partner Program approval -- a real credential
  dependency) or scraping a member's public activity feed, which the README
  explicitly rules out ("It does not scrape LinkedIn or sync a member's full
  activity"). Don't build either path without re-confirming with the user,
  since both contradict the plugin's current "no LinkedIn credentials"
  guarantee and would need the README/AGENTS.md updated first.
  Also checked: Discourse's own LinkedIn login (`Auth::LinkedInOidcAuthenticator`,
  `dev/discourse/lib/auth/linkedin_oidc_authenticator.rb`) can't be reused for
  this -- it requests `scope "openid profile email"` and only ever reads
  `/v2/userinfo` (name/email/picture). Reading a member's posts is a
  different, separately-gated LinkedIn API product (e.g. `r_member_social`)
  requiring its own Partner Program approval and its own
  `client_id`/`client_secret`, independent of whatever
  `linkedin_oidc_client_id`/`secret` the site already has for login. Decided
  2026-10-13: leave this planned, not implemented, until/unless that partner
  approval is actually pursued.

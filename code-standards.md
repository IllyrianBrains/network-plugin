# Code Standards

Conventions actually in use in this repository. Match these in new code
rather than introducing a different style.

## Ruby

- `# frozen_string_literal: true` at the top of every file.
- Double-quoted strings throughout.
- One namespace module per file: `module ProfessionalNetwork ... end`,
  classes nested inside it (`ProfessionalNetwork::Aspirations`, etc.), not
  defined with compact `::` class syntax.
- New files under `app/models/`, `app/services/`, or `app/controllers/`
  load automatically via the `ProfessionalNetwork::Engine`
  (`lib/professional_network/engine.rb`) -- Discourse's official plugin
  skeleton pattern. A new file's `module`/`class` nesting must match its
  path exactly for Zeitwerk to find it; don't add a `require_relative` for
  it in `plugin.rb`. New routes go in `config/routes.rb`, not `plugin.rb`.
  New site settings need a matching description under `site_settings` in
  `config/locales/server.en.yml`.
- Service/query objects under `app/services/professional_network/` are
  **plain Ruby classes**, not Discourse core's `Service::Base` pattern.
  Keep that consistent -- don't mix the two styles in this plugin.
- Constants for fixed vocabularies (enums, option lists) are frozen arrays
  or hashes at the top of the class (`MENTORING_INTERESTS = %w[...].freeze`),
  with a human-readable `_LABELS` hash alongside when a friendlier string is
  needed. Validate against these constants rather than trusting client
  input to be one of the allowed values.
- Models: thin ActiveRecord classes. Validation and format constants
  (`WEBSITE_KEY`) live on the model; cross-cutting query logic (filtering,
  sorting, matching) belongs in a service object, not a model scope, once it
  gets non-trivial -- see `DirectorySearch`/`RelatedProfiles` vs. the simple
  `scope :for_website` / `scope :published` on `Profile`.
- Controllers: inherit `ProfessionalNetwork::BaseController`. Keep
  controller actions thin -- parameter allowlisting and delegation to a
  service/model only. Use `raise Discourse::NotFound` /
  `Discourse::InvalidAccess` / `Discourse::InvalidParameters.new(:param)`
  for error paths, matching Discourse's own controller conventions, not ad
  hoc `render status:` calls.
- Explicit allowlists for any param that gets written (`profile_params`,
  `aspirations_params`) -- never `params.permit!` on the whole payload.

## Comments

- Default to no comments. Only write one when the _why_ isn't obvious from
  the code -- a non-obvious design decision, a deliberate exclusion, a
  constraint from another system (Discourse core, the website this plugin
  serves). See the header comment on `Aspirations` and `City` for the
  target style: short, explains a decision, doesn't restate what the code
  already says.
- Never describe history in comments ("used to be a Group", "added for v0.6")
  -- that belongs in the commit message or PR description, not in code. Code
  comments should be true regardless of when they're read.

## Size and composition

- Authored source files should not exceed 300 lines. This limit applies per file
  to Ruby (`.rb`), JavaScript/Glimmer (`.js`, `.gjs`), TypeScript (`.ts`), Astro
  (`.astro`), and Sass (`.scss`). Split an oversized file by responsibility
  before adding more code to it.
- The 300-line limit also applies to specs. Generated files and vendored
  dependencies are exempt; do not hand-edit those files merely to satisfy the
  limit. Run `./dev/check-file-lengths.sh` to audit all authored source files.
- Keep methods below 25 lines where practical. Extract cohesive private methods,
  service objects, helpers, child components, or stylesheet partials when code
  grows beyond either limit.
- Do not move unrelated code into arbitrary fragments just to lower the line
  count. Every extracted file should have a descriptive name and one clear
  reason to change.
- Keep shared vocabularies and their display labels in one module. Import them
  wherever forms, filters, and profile views need the same values so labels do
  not drift between screens.

## Tests (RSpec)

- Spec files mirror the `app/` tree: `spec/models/<name>_spec.rb`,
  `spec/services/<name>_spec.rb`.
- `# frozen_string_literal: true`, then `require "rails_helper"`.
- Use `fab!(:user)` (Discourse's fabrication shorthand) over manual
  `create(:user)` where a plain fabricated record is all that's needed.
- `subject(:name) { described_class.new(...) }` named to match what's being
  tested, then `describe "#method_name"` blocks with plain-English `it`
  descriptions of behavior, not implementation.

## Frontend (JS/Glimmer)

- Components are native Glimmer class components in `.gjs` files under
  `assets/javascripts/discourse/components/`, using `@glimmer/component`,
  `@glimmer/tracking` (`tracked`), `@ember/modifier` (`on`), `@ember/helper`
  (`fn`, `array`), and `@action` from `@ember/object`.
- Use `@service` injection (e.g. `currentUser`) rather than reaching into
  globals.
- Network calls go through `ajax` from `discourse/lib/ajax`, not raw
  `fetch`.
- Template logic uses Discourse's `discourse/truth-helpers` (`eq`,
  `includes`, etc.) instead of hand-rolled helpers.
- Fixed option lists for selects/radios are module-level `const` arrays of
  `{ value, label }` objects, not inline literals. Keep a list above the
  component class when it is local to one screen; export it from a focused
  module under `discourse/lib/` when multiple screens use the same vocabulary.
- Display strings are plain English sentences (sentence case), matching
  existing option labels -- this plugin does not currently route UI strings
  through Discourse's i18n client keys inside component bodies; follow
  whatever a given file already does rather than mixing both approaches in
  one component.

## Security and external data

This plugin ingests several kinds of attacker-reachable external data:
member-uploaded PDFs, pasted LinkedIn post URLs, and (in
`astro-integration/`) JSON consumed by a separate frontend. Treat all of it
as untrusted.

- **Shelling out.** `PdfParser.extract_pdf` is the only place this plugin
  invokes an external binary. It uses `Open3.capture3` with each argument
  passed as a separate array element (never a single interpolated string),
  so the uploaded bytes can't reach a shell. Keep that shape for any future
  shell-out: argv array, not string interpolation, not backticks, not
  `system("... #{var} ...")`. If a new integration needs another CLI tool,
  follow the same pattern and say so in a PR description rather than adding
  it quietly.
- **Uploaded files.** Write uploaded content to a `Tempfile` (as
  `extract_pdf` does) rather than trusting a client-supplied path or
  filename. Don't pass the original filename through to a shell command or
  use it to build a filesystem path.
- **External URLs (LinkedIn post links, profile/portfolio/contact URLs).**
  Parse with `URI.parse` and validate `scheme`, `host` (against an explicit
  allowlist, not a substring/regex match on the raw string), and `path`
  before storing or rendering -- see `SharedPost.normalize_url` for the
  pattern: scheme must be `https`, host must exactly match one of a small
  allowed set, `userinfo` must be `nil`. Reject on any `URI::InvalidURIError`
  rather than letting it propagate. Never render a stored URL into a
  template/attribute in a way that could execute as `javascript:` --
  the scheme check above is what prevents that.
- **Parsed PDF text.** `PdfParser.parse` extracts free text that becomes
  profile fields (name, headline, experience, etc.) and is rendered back to
  other members. It is member-authored but still attacker-controlled by the
  uploading member -- don't assume it's safe HTML/markup; keep output
  escaped wherever the frontend renders it, and don't add any step that
  evaluates or interprets the extracted text (e.g. no `eval`, no building
  SQL/shell strings from it). Parsed fields marked `"needs_review" => true`
  exist so a human confirms them before they're treated as authoritative --
  don't silently drop that flag or auto-publish review-needed data.
- **No outbound calls to LinkedIn or any AI service.** Per [AGENTS.md](AGENTS.md),
  this plugin never calls out to LinkedIn's API or an AI service -- all
  LinkedIn data arrives as a member-uploaded PDF or a pasted URL, never
  fetched live. Don't add an HTTP client call to linkedin.com or any LLM
  API without checking with the user first, even for something that looks
  like a quality-of-life improvement (e.g. "fetch the post preview").
- **`astro-integration/` consumers.** This is reference code for an
  external site, not shipped with the plugin, but the JSON shapes it
  documents are a real contract: don't add a field to a public JSON
  endpoint's output without checking it against the public/private field
  rule above, since an external site has no notion of "staff" or "owner"
  and will render whatever the endpoint returns.
- **Multi-tenancy boundary.** `website_key` is also a security boundary,
  not just a filter: a query that forgets `for_website`/`website_key`
  scoping leaks one site's member data to another site's requests. Treat it
  with the same care as an authorization check.

## Scope discipline

- Features explicitly called out in [AGENTS.md](AGENTS.md) as "not
  implemented" or "out of scope" (member registration/approval, teams,
  follows, posts/feed, blocks/reports) should not be added incidentally
  while working on something else. Flag it to the user instead of building
  it as a side effect of an unrelated change.
- Keep `website_key` multi-tenancy and public/private field boundaries
  (see [AGENTS.md](AGENTS.md)) intact in any new query or serializer.

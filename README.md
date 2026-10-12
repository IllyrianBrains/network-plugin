# Discourse Professional Network

Discourse plugin for member-approved LinkedIn PDF profile imports and **selected** LinkedIn post links. It does not scrape LinkedIn or sync a member's entire activity.

## Requirements

- Self-hosted Discourse with plugin support; **test on staging first**.
- PostgreSQL and a Discourse release supporting Rails 7 migrations.
- `pdftotext` from `poppler-utils` installed **inside the Discourse application container**.
- No external AI service or LinkedIn credentials required.

## Install (standard Discourse Docker setup)

Add to your `containers/app.yml` under `hooks: after_code:`:

```yaml
- exec:
    cd: $home/plugins
    cmd:
      - git clone https://YOUR-GIT-REPOSITORY/discourse-professional-network.git
```

Build with `./launcher rebuild app`. This ZIP is a source package: first put it in your own Git repository, or mount the plugin locally during development. Install poppler in your Discourse image/container using a persistent build configuration, not a manual change that disappears on rebuild.

Configure `professional_network_category_id` in admin site settings to a category where users may create topics. The plugin is enabled by `professional_network_enabled`.

## API (session authentication)

- `POST /professional-network/imports.json` multipart `file=@profile.pdf` -> draft preview
- `GET /professional-network/imports/:id.json` -> owner's preview
- `PUT /professional-network/imports/:id.json` JSON `{"data":{...}}` -> edited preview
- `POST /professional-network/imports/:id/confirm.json` -> save approved fields
- `PUT /professional-network/profile.json` JSON `{"data":{...},"aspirations":{...},"public_profile":true}` -> manual profile, links, business details, mentoring, aspirations and private return-plan edit
- `GET /professional-network/profiles/:username.json` -> public profile or owner/staff
- `GET /professional-network/profiles.json?website_key=default&q=ana&city=Berlin&field=Technology&aspiration_field=Technology&aspiration_subfield=Data%20science&mentoring_interest=mentoring_opportunity&business_interest=hiring_candidates` -> public member directory search and filters
- `GET /professional-network/profiles/:username/related.json?website_key=default&limit=10` -> explainable related-member suggestions
- `GET /professional-network/profiles/:username/activity.json` -> up to 20 visible linked shares and native topics (public profile or owner/staff)
- `POST /professional-network/shares.json` JSON `{"url":"https://www.linkedin.com/posts/...","title":"...","commentary":"..."}` -> new Discourse topic
- `GET /professional-network/shares/:username.json` -> shared links
- `GET /professional-network/cities.json?website_key=default&status=active&region=...&country=...&q=...` -> city directory
- `GET /professional-network/cities/:slug.json` -> one city and its public members
- `GET /professional-network/cities/map.json` -> every city with a member count, for a network map
- `GET /professional-network/network-graph.json?website_key=default` -> member/city/field-of-expertise nodes and edges for a member network visualization

Use a logged-in Discourse session and CSRF token or supported Discourse API authentication. For Astro, proxy via a trusted server and never expose an admin API key to browsers.

Profile reads, writes, imports, selected shares, directory searches and recommendations accept a `website_key` parameter. It is a lowercase hostname-like identifier (`default` when omitted), allowing one Discourse account to keep a separate profile, visibility choice and selected-share list for each consuming website. Searchable profile fields include name, headline, company, city, country, about, expertise, skills and experience level; exact filters are available for city, country, expertise, skill, experience level, aspiration field/subfield, mentoring interest and business interest. Recommendations return a score and human-readable reasons based on shared city, expertise, skills and career aspirations, plus complementary mentoring, hiring/job-seeking and funding/investment intent.

The member editor provides structured controls for LinkedIn and other profile links, public work statuses, portfolio and booking links, business opportunities, commercial availability and services, mentoring preferences, career aspirations, and return plans. Public statuses include openness to work, hiring, collaboration, speaking, volunteering, and relocation. Mentoring records direction plus separate `mentoring_wanted_types` and `mentoring_provided_types` arrays. Both use the validated values `project_guidance`, `career_orientation`, `technical_skills`, and `workshops`, plus a free-text `mentoring_note` (1000-character limit) for members to describe their mentoring style or what they're hoping to find. Mentoring and aspirations are visible with a public profile. Return-plan answers are intentionally private and are returned only to that member or staff.

`experience_level` uses the shared professional-level vocabulary: `student`,
`junior` (1–3 years), `mid` (4–6 years), `senior` (7–10 years), or `expert`
(10+ years).

## Important MVP limitations

- **PDF import is a review-first heuristic parser**, not a guaranteed LinkedIn-to-CV converter. Sidebar and page boundaries vary. Role grouping, multi-line certifications, long job descriptions, and dates may require correction. The preview is intentionally editable.
- Only PDFs with selectable text are supported; no OCR.
- PDF is processed temporarily and not saved by the plugin. Import drafts containing personal data remain in the database until removed; add retention cleanup before production.
- Imported profile defaults to **private**. User explicitly opts in to public visibility.
- Only selected LinkedIn links are shared; post content/images are not fetched.
- Adds an experimental Glimmer panel at the `user-profile-primary` plugin outlet, including PDF upload, structured field review, visibility control and selected-post sharing. The outlet name, component imports and rendering must be verified against your installed Discourse release. This is not yet a dedicated profile navigation tab.
- The implementation is a **starter, not production-certified**. Test against your exact Discourse version and review permissions, URL handling, CSRF, duplicate submissions and deployment before rollout.

## Smoke test

1. Upload a LinkedIn PDF as the logged-in user.
2. Check the returned `preview` carefully; edit incorrect records with PUT.
3. Confirm the import, then retrieve the private profile.
4. Enable public visibility with PUT and verify anonymous read access.
5. Configure the sharing category and share one LinkedIn URL; verify that a Discourse topic was created.
6. Repeat the URL and verify duplicate handling.

## Design

Discourse is source of truth for identity, professional data, and discussions. Astro reads the plugin JSON API via a server-side BFF. Imported experience/education/skills are currently stored in a versioned JSONB document for simple iteration; normalize into relational tables if filtering at scale becomes necessary.

The plugin is one installation with an internal capability boundary. The
`ProfessionalNetwork` services own professional profiles, imports, directories,
organizations, cities, activity, and general member discovery.
`ProfessionalNetwork::Mentoring` owns mentoring preferences and mentoring-only
matching behavior. It builds on professional profiles and ordinary Discourse
topics rather than introducing a second identity, messaging, notification, or
discussion system. The existing profile API continues to return mentoring
preferences inside `aspirations` for compatibility; that response shape is a
facade, not an ownership boundary.

LinkedIn is an optional profile-completion source, not the profile model. Manual
profiles and future member-authorized import sources should produce the same
normalized professional profile data.

The optional [`theme/`](theme/) package brings the Illyrian Brains website's
palette, typography, network motif, controls, and card treatment to the native
Discourse interface. It remains separate from plugin behavior, so the plugin
works with any Discourse theme and the visual layer can be tested or rolled
back independently.

## Astro integration example

The `astro-integration/` directory contains a server-side proxy, a profile viewer and an import/share component. Copy those files into your Astro project and adapt your authentication integration. The proxy example is deliberately **read-only**; write operations must be authenticated as the member, not as a shared administrator.

## Safety

Imports are private drafts until confirmed. Do not upload another person's PDF without permission. Do not publish private CV data without consent. The example UI provides an editable preview; use authenticated Discourse requests for confirmation and deletion. Schedule deletion of abandoned drafts (not implemented yet).

## v0.3 native Discourse interface (experimental)

The new `assets/javascripts/discourse/components/professional-network-panel.gjs` renders the owner-only PDF upload, JSON preview editor, confirmation, public visibility and LinkedIn post sharing controls. The connector lives under `assets/javascripts/discourse/connectors/user-profile-primary/`. It uses the logged-in Discourse browser session and `discourse/lib/ajax`.

**Compatibility:** This code has not been built or exercised with the Discourse Ember/Glimmer compiler. On staging, confirm that the `user-profile-primary` outlet exposes `outletArgs.model.username` in your release, the connector renders, and CSRF is supplied by Discourse's ajax helper. If the outlet is absent or arguments differ, adapt the connector for your version. The current editor is JSON for safe inspection; a structured form is the next enhancement.

**Known issue:** The parser is heuristic and the review must be checked before saving. The visibility toggle uses `PUT /professional-network/profile.json`, which currently replaces the full stored JSON with the UI's loaded profile; avoid concurrent profile edits. Post sharing needs `professional_network_category_id` configured.

## v0.4 unified activity (new)

- The professional profile panel now offers Experience, Education, Skills, and Posts tabs.
- The Posts tab displays selected LinkedIn URLs shared by the member, alongside Discourse topics created by that member.
- Each LinkedIn share is attributed as **shared by member**, never asserted to be authored by the LinkedIn account owner.
- `GET /professional-network/profiles/:username/activity.json` returns a unified, newest-first array.
- Discourse topic visibility is checked per request, and private professional profiles are not publicly accessible through this endpoint.
- Astro profile example displays the same activity list.
- This release does not sync LinkedIn, import content/images, or prove LinkedIn account ownership.
- Native profile panel compatibility and Discourse integration tests remain necessary.

## Local Docker Compose development (v0.5)

The repository now includes `docker-compose.yml` and `dev/setup.sh` for a local Discourse/PostgreSQL/Redis stack. This is a **development harness**, not a production installation. Docker was not available in the packaging environment, so image compatibility and end-to-end startup are **not verified**. Discourse development images and branch dependencies can change; pin a tested Discourse ref before team-wide use.

Requirements: Docker Engine + Compose v2, Git, enough RAM/disk for Discourse, and internet access on initial setup.

```bash
# from the plugin repository root
./dev/setup.sh
docker compose up -d postgres redis
# initialize database and dependencies; first run may take time
docker compose run --rm web bash -lc 'bundle install && bundle exec rails db:create db:migrate'
# create the default local administrator and complete the installation wizard
./dev/create-admin.sh
./dev/seed-example-data.sh # optional: example members
docker compose up web # starts both Rails and the frontend asset watcher
# separate terminal
./dev/smoke.sh
```

The local administrator credentials are:

```text
Email: admin@example.test
Password: LocalDevelopment123!
Admin privileges: Y
```

The email address only serves as a local login identifier. The script creates or updates the account, confirms the address internally, and clears Discourse's `finish-installation` flag, so no registration screen, working mailbox, or outgoing email configuration is required. The account is retained in the PostgreSQL Docker volume; rerun `./dev/create-admin.sh` to restore it or reset its password.

You can override either value for a local run:

```bash
DEV_ADMIN_EMAIL=me@example.test DEV_ADMIN_PASSWORD='another-local-password' ./dev/create-admin.sh
```

Never use these credentials or this bootstrap script in production.

Open http://localhost:3000 and log in with the local administrator account. The `web` service uses Discourse's `pnpm dev` launcher because current development releases need both the Rails server and the frontend asset watcher; its first start may install frontend dependencies and take several minutes. Enable `professional_network_enabled` and configure `professional_network_category_id`. Upload a **member-authorized** LinkedIn PDF and check the import preview before confirmation. Share one LinkedIn post URL and verify it appears in the user's Posts tab. The PDF parser uses `pdftotext`; if missing in the development image, install `poppler-utils` in a derivative image (not manually in a disposable container) before PDF testing.

**Important caveat:** the plugin mount is nested within the Discourse source bind mount. Docker supports this arrangement, and Compose masks the plugin repository's nested `dev/discourse` path inside the containers so Discourse's file watcher does not scan the core checkout twice. The host checkout must exist before running Compose. The dev image's preinstalled Ruby gems may not match the newest Discourse `main` branch; in that case use a compatible `DISCOURSE_REF` and rerun setup after removing `dev/discourse` (keep your plugin directory). Sidekiq is optional for the current synchronous MVP: `docker compose --profile jobs up -d sidekiq` if needed.

To stop: `docker compose down`. To **delete local test data**: `docker compose down -v` (irreversible). `dev/discourse/` is a local core checkout and should not be committed.

## v0.6 organizations, cities and a network graph (new)

This release extends the plugin from member profiles only toward the broader
directory the Illyrian Brains website (`../website`) already has: organization
and business listings, a city directory with map data, and a member network
graph endpoint. The website stays the frontend; this plugin is the backend it
reads from (see the `astro-integration/` examples). Membership
registration/approval, teams, follows and the public post feed were explicitly
**out of scope** for this release and remain website-only for now.

- **Organizations are not a new plugin-owned table either.** (Superseded in
  v0.7 below -- this described the first pass, kept for history: an
  "organization" used to be a plain Discourse `Group`, with group membership
  as a "representatives" list.)
- Offers/opportunities (`job | internship | event | project | volunteer |
  benefit | collaboration`) are the one genuinely one-to-many record per
  organization, so they remain a real table, keyed by the organization's
  profile id.
- Because the organization directory now lives in memory per request
  (filtered/sorted in Ruby rather than SQL), it scales to the hundreds of
  organizations the website currently has, not tens of thousands; revisit if
  that changes.
- `City` is a small new reference table (name, slug, country, lat/lng,
  status, image/Luma/Instagram URLs, activities, region, and alias
  spellings like "Rome" for "Roma"). Member and organization "city" fields
  stay free text, matched against a city's name/aliases — mirroring how
  the website already resolves `cityAliases` client-side, just centralized
  server-side instead of duplicated across four Astro components.
- `DirectorySearch` gained a `membership_type` filter and now also matches
  free text against experience/education entries, closer to the website's
  `/anetaret/` search.
- `RelatedProfiles` gained a shared-business-interest signal and a
  "complementary intent" bonus (you're seeking mentoring in a field, they
  offer it and work in that field), closer to the website's `relatedMembers()`
  heuristic. It reads `aspirations.mentoring_status`, an enforced enum
  (`none | seeking | offering | both`, validated in `ProfileData`) rather than
  free text, plus `aspirations.business_interests` (a free-text array, matched
  by exact case-insensitive overlap). `aspirations.mentoring_notes` is a free-text
  elaboration shown alongside the status but not used in matching.
  Members set all of this on a dedicated `/professional-network/profile` page
  (LinkedIn import, mentoring and aspirations as separate tabs), not inline in
  their Discourse preferences.
- **Not implemented, deliberately:** member `status` (pending/approved),
  self-service registration, teams, follows, posts/feed, blocks and reports.
  Adding those would touch the membership/approval workflow, which was kept
  out of this round's scope.
- **Unverified:** this plugin still has no automated way to run against a
  live Discourse+Postgres instance in this environment (no Ruby/Rails
  available here, only a plain `ruby -c` syntax check in a throwaway
  container), so the new migrations and controllers are reviewed and
  syntax-checked but not integration-tested. Run the existing `dev/setup.sh`
  stack and exercise the new endpoints on staging before relying on them.

## v0.7 organizations as accounts, not groups (new)

A Discourse `Group` modeled "many people manage one shared listing" --
useful for a company page with several admins, but overkill (and leaky:
group admin UI, group membership semantics) for this plugin's actual need.

- **An organization is now a plain account with a profile, exactly like a
  member** -- a company or NGO signs up for its own Discourse account
  (separate from any person's own account, the same way a LinkedIn company
  isn't anyone's personal profile) and fills in organization fields
  (`kind`, `category`, `stage`, `city`, `country`, links, logo, `status`,
  `admin_note`, `sponsor`, `collaborations`, `related_cities`,
  `related_partners`) on it, the same `professional_network_profiles` table
  a member's headline/skills/experience live in. The only new column is
  `profile_type` (`member` | `organization`); everything else lives in the
  existing free-form `data` JSONB, read/written through
  `ProfessionalNetwork::OrganizationProfile` (replaces `OrganizationFields`
  and all `Group`/`GroupCustomField` use).
- One Discourse account holds at most one profile per website, and it is
  either a member profile or an organization profile, never both --
  enforced with a clear 403 rather than letting the two collide. If an
  account already has a personal profile, turning it into an organization
  (or vice versa) is rejected; use a separate account for the organization.
- There is no more "representatives" list or staff reassignment endpoint.
  Whoever controls the organization's account login manages it, the same
  as a person manages their own profile; staff can still edit/moderate any
  organization the same way they can moderate a member profile.
- Organization endpoints moved from a numeric Discourse group id to the
  account's `username`, and from `POST/PUT /organizations/:id` to a single
  `PUT /organization` ("my organization"), matching the existing
  `PUT /profile` shape. See the API list above.
- `OrganizationOffer` now belongs to the organization's profile row
  (`profile_id`), not a group id.

## v0.8 introduction discovery (new)

- Member directory searches can filter on aspiration field/subfield,
  mentoring interest, and business interest, using the same structured
  profile concepts as the Illyrian Brains website.
- A dedicated `/professional-network/directory` page (linked from the
  community sidebar) exposes `GET /professional-network/profiles.json`'s
  filters -- text search, city, country, field of expertise, skill,
  experience level, availability, open-to-consulting/offering-services, and
  the aspiration/mentoring/business filters above -- as an in-app search UI,
  the same endpoint the Astro integration's directory consumes externally.
- Related-member suggestions now connect job seekers with members hiring and
  people seeking funding with members interested in investing. Results remain
  explainable and scoped to public profiles for the requested `website_key`.
- Return plans and return countries remain private and are not used by public
  directory filters or matching responses.
- Professional profiles use a validated five-level experience vocabulary:
  student, junior (1–3 years), mid (4–6 years), senior (7–10 years), and
  expert (10+ years).
- LinkedIn imports open as ordinary profile, expertise, skill, experience and
  education controls. Members review structured fields and never need to edit
  the underlying JSON document.
- Mentoring profiles distinguish what a member wants from what they can
  provide, with structured choices for project guidance, career orientation,
  technical skill teaching, and workshops.
- The free-text "what can you help with" / "what are you looking for"
  profile fields now feed the member directory's search and the
  related-member suggestions: a shared significant word between one
  member's `looking_for` and another's `can_help_with` surfaces an
  explainable "may be able to help" match in either direction.

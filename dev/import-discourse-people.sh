#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${IMPORT_ENV_FILE:-$ROOT/.env}"

if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
fi

: "${SOURCE_DISCOURSE_URL:?Set SOURCE_DISCOURSE_URL to the source Discourse base URL}"
: "${SOURCE_DISCOURSE_API_KEY:?Set SOURCE_DISCOURSE_API_KEY to a source Discourse admin API key}"
: "${SOURCE_DISCOURSE_API_USERNAME:?Set SOURCE_DISCOURSE_API_USERNAME to the API key owner}"

cd "$ROOT"
docker compose run --rm \
  -e SOURCE_DISCOURSE_URL \
  -e SOURCE_DISCOURSE_API_KEY \
  -e SOURCE_DISCOURSE_API_USERNAME \
  -e IMPORT_WEBSITE_KEY \
  -e IMPORT_LIMIT \
  -e IMPORT_DRY_RUN \
  -e IMPORT_PUBLISH_PROFILES \
  -e IMPORT_ALLOW_HTTP \
  web bundle exec rails runner \
  plugins/discourse-professional-network/dev/import_discourse_people.rb

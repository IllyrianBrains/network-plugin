#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ ! -f "$ROOT/dev/discourse/Gemfile" ]]; then
  git clone --depth 1 --branch "${DISCOURSE_REF:-main}" https://github.com/discourse/discourse.git "$ROOT/dev/discourse"
fi
# The mount overlays Discourse's plugins path; don't copy plugin files into core.
echo 'Discourse checkout ready. Run: docker compose up -d postgres redis'
echo 'Then: docker compose run --rm web bash -lc "bundle install && bundle exec rails db:create db:migrate"'
echo 'Then: docker compose up web'

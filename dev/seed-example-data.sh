#!/usr/bin/env bash
set -euo pipefail

docker compose run --rm web bundle exec rails runner plugins/discourse-professional-network/dev/seed_example_data.rb

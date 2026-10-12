#!/usr/bin/env bash
set -euo pipefail

DEV_ADMIN_EMAIL="${DEV_ADMIN_EMAIL:-admin@example.test}"
DEV_ADMIN_PASSWORD="${DEV_ADMIN_PASSWORD:-LocalDevelopment123!}"

export DEV_ADMIN_EMAIL DEV_ADMIN_PASSWORD

docker compose run --rm \
  -e DEV_ADMIN_EMAIL \
  -e DEV_ADMIN_PASSWORD \
  web bundle exec rails runner plugins/discourse-professional-network/dev/create_admin.rb

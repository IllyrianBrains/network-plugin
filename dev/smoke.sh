#!/usr/bin/env bash
set -euo pipefail
BASE="${DISCOURSE_URL:-http://localhost:3000}"
echo "Checking $BASE ..."
curl --fail --silent --show-error "$BASE/about.json" >/dev/null
echo 'Discourse reachable.'
# Anonymous requests must not expose private profiles or allow writes.
status="$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE/network/shares.json" -H 'Content-Type: application/json' -d '{"url":"https://www.linkedin.com/posts/test"}')"
case "$status" in 401|403|422) echo "Anonymous write rejected (HTTP $status)" ;; *) echo "Unexpected anonymous write status: $status"; exit 1;; esac
printf '%s\n' 'Manual checks: create user, upload PDF, edit preview, confirm, toggle visibility, share selected LinkedIn URL, inspect activity tab.'

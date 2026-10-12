#!/usr/bin/env bash

set -euo pipefail

readonly max_lines=300
readonly source_roots=(
  app
  assets
  astro-integration/src
  db
  spec
  theme
)

status=0

while IFS= read -r -d '' source_file; do
  line_count=$(wc -l < "$source_file")

  if ((line_count > max_lines)); then
    printf '%s: %d lines (maximum %d)\n' \
      "$source_file" \
      "$line_count" \
      "$max_lines"
    status=1
  fi
done < <(
  find "${source_roots[@]}" \
    -type f \
    \( \
      -name "*.rb" -o \
      -name "*.js" -o \
      -name "*.gjs" -o \
      -name "*.ts" -o \
      -name "*.astro" -o \
      -name "*.scss" \
    \) \
    -not -path "*/vendor/*" \
    -not -path "*/node_modules/*" \
    -print0
)

exit "$status"

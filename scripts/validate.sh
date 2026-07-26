#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 || ! -f $1 ]]; then
  printf 'Usage: %s <domain-list>\n' "$0" >&2
  exit 2
fi

source_file=$1
normalized=$(mktemp)
duplicates=$(mktemp)
trap 'rm -f "$normalized" "$duplicates"' EXIT

awk '
  /^[[:space:]]*($|#)/ { next }
  $0 !~ /^(\+\.)?[a-z0-9]([a-z0-9.-]*[a-z0-9])?$/ {
    printf "Invalid domain at line %d: %s\n", NR, $0 > "/dev/stderr"
    invalid = 1
  }
  !invalid { print }
  END { if (invalid) exit 1 }
' "$source_file" >"$normalized"

if [[ ! -s $normalized ]]; then
  printf 'Domain list is empty: %s\n' "$source_file" >&2
  exit 1
fi

LC_ALL=C sort "$normalized" | uniq -d >"$duplicates"
if [[ -s $duplicates ]]; then
  printf 'Duplicate domains:\n' >&2
  sed 's/^/  /' "$duplicates" >&2
  exit 1
fi

if ! LC_ALL=C sort -c "$normalized"; then
  printf 'Domains must be sorted with LC_ALL=C\n' >&2
  exit 1
fi

printf 'Validated %s domains in %s\n' "$(wc -l <"$normalized" | tr -d ' ')" "$source_file"

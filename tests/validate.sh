#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
validator="$repo_root/scripts/validate.sh"
fixtures=$(mktemp -d)
trap 'rm -rf "$fixtures"' EXIT

write_fixture() {
  local name=$1
  shift
  printf '%s\n' "$@" >"$fixtures/$name.list"
}

expect_pass() {
  local name=$1
  if ! bash "$validator" "$fixtures/$name.list" >/dev/null 2>&1; then
    printf 'FAIL: expected %s fixture to pass\n' "$name" >&2
    exit 1
  fi
}

expect_fail() {
  local name=$1
  if bash "$validator" "$fixtures/$name.list" >/dev/null 2>&1; then
    printf 'FAIL: expected %s fixture to fail\n' "$name" >&2
    exit 1
  fi
}

write_fixture valid \
  '# comments and blank lines are allowed' \
  '' \
  '+.docker.io' \
  'auth.docker.io' \
  'registry-1.docker.io'
write_fixture duplicate \
  'auth.docker.io' \
  'auth.docker.io'
write_fixture invalid \
  'https://registry-1.docker.io/v2/'
write_fixture uppercase \
  'Registry.NPMJS.org'
write_fixture unsorted \
  'registry.npmjs.org' \
  'files.pythonhosted.org'

expect_pass valid
expect_fail duplicate
expect_fail invalid
expect_fail uppercase
expect_fail unsorted

printf 'All validator tests passed\n'

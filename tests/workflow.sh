#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
workflow="$repo_root/.github/workflows/build.yml"

ruby -e '
  require "yaml"
  workflow = YAML.load_file(ARGV.fetch(0))
  concurrency = workflow.fetch("concurrency", {})
  abort "missing publish-rules concurrency group" unless concurrency["group"] == "publish-rules"
  abort "older publishing runs must be cancelled" unless concurrency["cancel-in-progress"] == true
' "$workflow"

printf 'Workflow tests passed\n'

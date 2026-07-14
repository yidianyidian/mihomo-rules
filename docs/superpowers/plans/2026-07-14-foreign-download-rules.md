# Foreign Download Rules Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build and publish a maintained mihomo MRS rule set for foreign developer downloads, then route it through a new `🌍 外网下载` policy group.

**Architecture:** Keep human-readable domain suffixes on `main`; validate and compile them with GitHub Actions; publish only generated artifacts to `release`. Reference the artifact from `/Applications/mihomo/my_config.yaml` through a domain rule-provider placed before broader GitHub and Google rules.

**Tech Stack:** POSIX shell, GitHub Actions, mihomo CLI, YAML, Git, GitHub CLI

## Global Constraints

- Repository is public at `yidianyidian/mihomo-rules`.
- Policy group name is exactly `🌍 外网下载`.
- Do not store credentials, subscription URLs, or tokens in the repository.
- Do not alter existing proxy subscriptions or current selections.

---

### Task 1: Rule source and validation

**Files:**
- Create: `rules/foreign-download.list`
- Create: `scripts/validate.sh`
- Create: `tests/validate.sh`

**Interfaces:**
- Consumes: one domain suffix per non-comment line in `rules/foreign-download.list`
- Produces: exit status 0 for sorted unique domains; non-zero for invalid, duplicate, or unsorted input

- [ ] **Step 1: Write the failing validator test**

Create `tests/validate.sh` that writes valid, duplicate, invalid, and unsorted fixtures under a temporary directory. It must require valid input to pass and every invalid fixture to fail.

- [ ] **Step 2: Run the test and verify the validator is missing**

Run: `bash tests/validate.sh`
Expected: non-zero with `scripts/validate.sh: No such file or directory`.

- [ ] **Step 3: Implement the validator**

Create `scripts/validate.sh` with `set -euo pipefail`. Ignore blank and `#` comment lines; require lowercase ASCII domain suffixes matching `^[a-z0-9][a-z0-9.-]*[a-z0-9]$`; reject duplicates; require `LC_ALL=C sort -c` ordering.

- [ ] **Step 4: Add the curated domains**

Populate the source with labeled sections for GitHub, Docker Hub, npm, PyPI, Maven/Gradle, Hugging Face/Xet, and Google downloads. Include registry authentication and CDN hosts needed to complete downloads, but exclude broad browser-only domains such as `github.com` unless a download API requires them.

- [ ] **Step 5: Run tests**

Run: `bash tests/validate.sh && bash scripts/validate.sh rules/foreign-download.list`
Expected: both commands exit 0 and print validation success.

- [ ] **Step 6: Commit**

Run: `git add rules scripts tests && git commit -m "feat: add foreign download domain rules"`.

### Task 2: Automated MRS publishing and documentation

**Files:**
- Create: `.github/workflows/build.yml`
- Create: `README.md`
- Create: `LICENSE`

**Interfaces:**
- Consumes: validated `rules/foreign-download.list`
- Produces: `foreign-download.mrs` on orphan branch `release`

- [ ] **Step 1: Add a workflow syntax test**

Use Ruby's YAML parser after disabling aliases: `ruby -e 'require "yaml"; YAML.load_file(".github/workflows/build.yml", aliases: true)'`.
Expected before the workflow exists: non-zero file-not-found result.

- [ ] **Step 2: Implement the workflow**

Trigger on pushes to `main` that affect the rule, validator, or workflow, plus `workflow_dispatch`. Validate the source, download the latest official mihomo Linux amd64 binary from the GitHub API, run `mihomo convert-ruleset domain text rules/foreign-download.list foreign-download.mrs`, and force-push an orphan `release` branch containing the MRS file and source checksum. Grant only `contents: write`.

- [ ] **Step 3: Document usage**

Document the source format, covered services, update process, artifact URLs, and complete mihomo `rule-providers` example. Add the GPL-3.0 license to match the referenced MetaCubeX project.

- [ ] **Step 4: Validate locally**

Run the YAML parse command and `bash tests/validate.sh`.
Expected: both exit 0.

- [ ] **Step 5: Commit**

Run: `git add .github README.md LICENSE && git commit -m "ci: publish compiled mihomo rules"`.

### Task 3: Publish and verify GitHub repository

**Files:**
- No new local files

**Interfaces:**
- Consumes: committed local `main`
- Produces: public `yidianyidian/mihomo-rules`, successful build workflow, downloadable release artifact

- [ ] **Step 1: Create and push the repository**

Run: `gh repo create yidianyidian/mihomo-rules --public --source=. --remote=origin --push`.
Expected: repository URL and pushed `main` branch.

- [ ] **Step 2: Watch the build**

Run: `gh run list --repo yidianyidian/mihomo-rules --workflow build.yml --limit 1`, then `gh run watch <run-id> --repo yidianyidian/mihomo-rules --exit-status`.
Expected: completed success.

- [ ] **Step 3: Verify artifacts**

Run: `curl -fsSLo /tmp/foreign-download.mrs https://raw.githubusercontent.com/yidianyidian/mihomo-rules/release/foreign-download.mrs`.
Expected: non-empty file and HTTP success.

### Task 4: Integrate and verify local mihomo

**Files:**
- Modify: `/Applications/mihomo/my_config.yaml`

**Interfaces:**
- Consumes: published `foreign-download.mrs`
- Produces: loaded `foreign_download` provider routed to `🌍 外网下载`

- [ ] **Step 1: Back up and establish the failing configuration check**

Copy the current config to a timestamped file in `/Applications/mihomo/clash_back/`. Confirm `rg 'foreign_download|🌍 外网下载' /Applications/mihomo/my_config.yaml` has no matches.

- [ ] **Step 2: Add the policy group**

Add a select group named `🌍 外网下载` with the existing region smart groups first, followed by fallback groups, region selectors, all nodes, and direct.

- [ ] **Step 3: Add the rule provider and routing rule**

Add `foreign_download` with `type: http`, `behavior: domain`, `format: mrs`, `interval: 86400`, a unique local path, and jsDelivr URL. Insert `RULE-SET,foreign_download,🌍 外网下载` before the existing GitHub and Google rules.

- [ ] **Step 4: Validate in an isolated home directory**

Copy `GeoSite.dat` and the edited config into a fresh temporary directory, then run `/Applications/mihomo/mihomo-smart -t -d <temp> -f <temp>/config.yaml`.
Expected: `test is successful` and exit 0.

- [ ] **Step 5: Reload and verify runtime state**

Reload through the authenticated local controller or restart the managed process. Query `/providers/rules` and `/proxies`; require `foreign_download` with a non-zero rule count and `🌍 外网下载` with members.

- [ ] **Step 6: Verify representative matches**

Use controller connection metadata while requesting representative GitHub Release, Docker Registry, PyPI, npm, Maven, Hugging Face, and Google download hosts through `127.0.0.1:7890`. Confirm the chain contains `🌍 外网下载`.

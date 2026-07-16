# mihomo-rules

Personal download-domain rules for [mihomo](https://github.com/MetaCubeX/mihomo).

The `main` branch keeps the reviewed text source. GitHub Actions validates it,
compiles `foreign-download.mrs`, and publishes generated files to the `release`
branch.

## Coverage

- GitHub releases, archives, raw files, and GitHub Container Registry
- Docker Hub registry, authentication, and image CDN
- npm and Yarn registries
- PyPI and Python package files
- Maven Central, Google Maven, and Gradle downloads
- Hugging Face model, LFS, and Xet downloads
- Google developer tools and software downloads

The list intentionally targets download dependencies and avoids broad website
domains where possible.

## Artifact URLs

GitHub Raw:

```text
https://raw.githubusercontent.com/yidianyidian/mihomo-rules/release/foreign-download.mrs
```

jsDelivr:

```text
https://cdn.jsdelivr.net/gh/yidianyidian/mihomo-rules@release/foreign-download.mrs
```

## Mihomo configuration

```yaml
rule-providers:
  foreign_download:
    type: http
    behavior: domain
    format: mrs
    interval: 86400
    url: https://cdn.jsdelivr.net/gh/yidianyidian/mihomo-rules@release/foreign-download.mrs
    path: ./rule_provider/foreign_download

rules:
  - RULE-SET,foreign_download,🌍 外网下载
```

Place the rule before broader GitHub, Google, GFW, and `geolocation-!cn` rules.

## Reusable proxy groups

[`snippets/my-favorites.yaml`](snippets/my-favorites.yaml) contains an
independent Smart proxy group that selects only the configured frequently used
nodes. Copy the list item into the `proxy-groups` section of a Mihomo
configuration.

The snippet contains only a node-name filter and health-check settings. It does
not contain subscription URLs, server addresses, credentials, or controller
secrets.

## Updating

1. Edit `rules/foreign-download.list` using lowercase Clash domain syntax.
2. Keep non-comment entries unique and sorted with `LC_ALL=C`.
3. Run:

   ```bash
   bash tests/validate.sh
   bash scripts/validate.sh rules/foreign-download.list
   ```

4. Push to `main`; the workflow updates the `release` branch.

## License

GPL-3.0. The project structure and rule format are informed by
[`MetaCubeX/meta-rules-dat`](https://github.com/MetaCubeX/meta-rules-dat).

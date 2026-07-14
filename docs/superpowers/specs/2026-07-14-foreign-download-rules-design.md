# Mihomo 外网下载规则设计

## 目标

为个人 mihomo 配置增加 `🌍 外网下载` 策略组，并在公开 GitHub 仓库 `yidianyidian/mihomo-rules` 中维护下载域名规则。

## 覆盖范围

- GitHub Release 与 GitHub Container Registry
- Docker Hub Registry、认证服务与镜像 CDN
- npm Registry
- PyPI 与文件 CDN
- Maven Central 与 Gradle 下载
- Hugging Face 模型、LFS 与 Xet 下载
- Google Chrome、Android、Cloud SDK 等软件下载

规则包含完成下载所需的认证、元数据和 CDN 域名，但避免把普通网页浏览整体纳入下载策略。

## 架构

`main` 分支保存可审阅的 `rules/foreign-download.list`。GitHub Actions 校验规则、去重，并使用 mihomo 转换为 `foreign-download.mrs`，随后发布到 `release` 分支。

本机新增 `foreign_download` rule-provider 和 `🌍 外网下载` select 策略组。下载规则位于 GitHub、Google、GFW 和 `geolocation-!cn` 等宽泛规则之前。

## 边界

- 不改动现有节点订阅。
- 不改变现有 GitHub、Google等普通策略组的选择。
- 不在仓库中保存订阅链接、Token 或其他凭证。


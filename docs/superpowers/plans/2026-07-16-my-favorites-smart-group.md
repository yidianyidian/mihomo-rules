# “我的常用” Smart 策略组实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在公开仓库维护“我的常用” Smart 策略组片段，并安全同步到本机和 `172.18.1.17`。

**Architecture:** 仓库只新增无敏感信息的 YAML 片段和使用说明；两台机器分别以现有实际配置为基线插入同一策略组。两端独立校验、备份、热重载并通过控制 API 验证候选节点。

**Tech Stack:** Mihomo YAML、Bash、Git、systemd、Mihomo REST API

## Global Constraints

- 策略组名称必须是 `我的常用`，类型必须是 `smart`。
- 只匹配 `Pro-新加坡-BGP-02` 和 `Pro-新加坡-BGP-03`，允许节点名称带 `|` 版本后缀。
- 策略组保持独立，不加入任何现有业务组或路由规则。
- 仓库不得包含订阅 URL、Mihomo 密钥或机器登录信息。
- 同步时不得覆盖本机与远端现有端口、TUN、网卡等差异。

---

### Task 1: 仓库策略组片段

**Files:**
- Create: `snippets/my-favorites.yaml`
- Modify: `README.md`

**Interfaces:**
- Consumes: Mihomo `proxy-groups` 列表项格式。
- Produces: 可复制到任意 Mihomo `proxy-groups` 下的单个 Smart 组。

- [ ] **Step 1: 创建精确过滤的策略组片段**

```yaml
- name: "我的常用"
  type: smart
  include-all: true
  interval: 180
  filter: "(?i)Pro-新加坡-BGP-(02|03)(?:\\||$)"
  url: https://cp.cloudflare.com/generate_204
```

- [ ] **Step 2: 在 README 中记录片段用途和复制方式**

新增“Reusable proxy groups”小节，明确该文件不含节点凭证，且应复制到 `proxy-groups` 下。

- [ ] **Step 3: 运行仓库校验**

Run:

```bash
bash tests/validate.sh
bash scripts/validate.sh rules/foreign-download.list
```

Expected: `All validator tests passed` 和 `Validated 45 domains`。

- [ ] **Step 4: 用 Mihomo 校验包含片段的本机候选配置**

Run: 使用隔离临时目录执行 `mihomo-smart -t`。

Expected: `configuration file ... test is successful`。

- [ ] **Step 5: 提交并推送仓库**

```bash
git add snippets/my-favorites.yaml README.md
git commit -m "feat: add my favorites smart group"
git push origin main
```

### Task 2: 同步本机配置

**Files:**
- Modify: `/Applications/mihomo/my_config.yaml`

**Interfaces:**
- Consumes: Task 1 的策略组片段。
- Produces: 本机运行时 `我的常用` Smart 策略组。

- [ ] **Step 1: 创建带时间戳的本机配置备份**

```bash
cp -a /Applications/mihomo/my_config.yaml /Applications/mihomo/my_config.yaml.bak-<timestamp>
```

- [ ] **Step 2: 将片段插入本机 `proxy-groups`，不修改现有组和规则**

插入内容必须与 `snippets/my-favorites.yaml` 完全一致。

- [ ] **Step 3: 在隔离目录执行配置校验**

Run: `/Applications/mihomo/mihomo-smart -t`，使用临时 home 和本机 `GeoSite.dat`。

Expected: `configuration file ... test is successful`。

- [ ] **Step 4: 通过本机控制接口热重载**

Run: `PUT http://127.0.0.1:9090/configs?force=true`，配置路径为 `/Applications/mihomo/my_config.yaml`。

Expected: HTTP 204。

- [ ] **Step 5: 验证运行组**

通过 `/proxies` 确认：`type=Smart`、`alive=true`、候选列表恰好包含 02 和 03。

### Task 3: 同步远端配置

**Files:**
- Modify: `root@172.18.1.17:/root/opt/mihomo/my_config.yaml`

**Interfaces:**
- Consumes: Task 1 的策略组片段。
- Produces: 远端运行时 `我的常用` Smart 策略组。

- [ ] **Step 1: 下载远端最新配置并创建候选文件**

候选文件必须以远端最新配置为基线，只增加 Task 1 的策略组。

- [ ] **Step 2: 比较候选文件**

Expected: diff 只显示新增 `我的常用` 组，不包含端口、TUN、网卡或控制接口变化。

- [ ] **Step 3: 远端隔离校验并备份**

使用远端 `mihomo-linux-smart -t` 和独立临时目录；成功后备份为 `my_config.yaml.bak-<timestamp>`。

- [ ] **Step 4: 替换配置并热重载**

Run:

```bash
systemctl reload mihomo.service
```

Expected: `systemctl is-active mihomo.service` 输出 `active`，PID 保持不变。

- [ ] **Step 5: 验证远端运行组**

通过远端 `/proxies` 确认：`type=Smart`、`alive=true`、候选列表恰好包含 02 和 03；最近日志无 `error`、`fatal` 或 `panic`。

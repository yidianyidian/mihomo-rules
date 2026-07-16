# “我的常用” Smart 策略组设计

## 目标

在 `mihomo-rules` 仓库维护一个可复用的 Mihomo 策略组片段，并将它同步到本机与 `172.18.1.17` 的实际配置中。

## 仓库内容

新增 `snippets/my-favorites.yaml`，只保存以下独立策略组，不保存完整 Mihomo 配置、订阅地址、控制密钥或其他机器专属信息：

```yaml
- name: "我的常用"
  type: smart
  include-all: true
  interval: 180
  filter: "(?i)Pro-新加坡-BGP-(02|03)(?:\\||$)"
  url: https://cp.cloudflare.com/generate_204
```

过滤规则只接受名称中包含 `Pro-新加坡-BGP-02` 或 `Pro-新加坡-BGP-03`，且编号后必须是名称结尾或 `|` 版本后缀，避免误匹配 `020`、`031` 等节点。

## 配置同步

将同一策略组加入：

- 本机 `/Applications/mihomo/my_config.yaml`
- 远端 `root@172.18.1.17:/root/opt/mihomo/my_config.yaml`

该组保持独立，不加入默认代理、GitHub、AI、外网下载等现有业务组，也不修改任何规则路由。

同步时保留两端原有差异，包括远端 Linux TUN、网卡、监听端口和控制接口配置。

## 验证与回滚

1. 运行仓库现有校验脚本。
2. 分别对本机和远端候选配置执行 Mihomo 隔离配置校验。
3. 修改前分别创建带时间戳的配置备份。
4. 热重载两端 Mihomo。
5. 通过控制 API 确认 `我的常用` 类型为 Smart、状态正常，并且候选节点恰好为 02 和 03。
6. 如校验或重载失败，恢复对应备份并重新加载。


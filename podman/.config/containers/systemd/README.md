# Podman Containers with Quadlet

使用 [Quadlet](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html) 以 systemd user unit 的方式管理容器，无需 podman compose。

系统以及 Podman 版本信息：
```text
> cat /etc/os-release
PRETTY_NAME="Debian GNU/Linux 13 (trixie)"
NAME="Debian GNU/Linux"
VERSION_ID="13"
VERSION="13 (trixie)"
VERSION_CODENAME=trixie
DEBIAN_VERSION_FULL=13.6
ID=debian
HOME_URL="https://www.debian.org/"
SUPPORT_URL="https://www.debian.org/support"
BUG_REPORT_URL="https://bugs.debian.org/"
> podman --version
podman version 5.4.2
```

## 目录结构

| 文件 | 用途 | 是否入库 |
| --- | --- | --- |
| `<name>.container` | Quadlet 单元定义 | ✅ 按需入库 |
| `<name>.env.example` | 环境变量模板，需自行复制为 `<name>.env` | ✅（仅模板） |
| `<name>.env` | 真实环境变量 | ❌ 被 `.gitignore` 的 `*.env` 忽略 |
| `<name>_data.volume` | 命名卷声明 | ✅ 按需入库 |
| `<name>.conf.d/` | 挂载进容器的配置目录 | ❌ 仅有 `.gitkeep` 占位 |
| `10_26_0_1.network` | 容器网络定义（子网 `10.26.0.0/16`） | ✅ |

`.container`、`.volume`、`.network` 三类需要**按需强制添加**：它们是 Quadlet 单元文件，
本身不含密钥，如需纳入版本管理就要强制添加，本地测试容器就不纳入版本管理了。
新增服务时至少要有 `<name>.container`；需要持久化的服务还要配套的 `<name>_data.volume`；
所有容器统一接入 `10_26_0_1.network`。

本目录的 `.gitignore` 以 `*` 忽略所有文件，因此添加上述单元文件时必须使用 `-f`：

```bash
git add -f podman/.config/containers/systemd/<name>.container
```

`-f` 仅在**首次纳入**时需要。文件一旦进入索引，后续修改按常规 `git add` 即可，
`.gitignore` 对已跟踪文件不再生效。

相对地，`<name>.env` 与 `<name>.conf.d/` 的内容一律不入库，
如需入库必须删除敏感信息后命名为 `<name>.env.example` 或 `<name>.conf.example` 后入库。

### Volume 标志：`U` 与 `Z` / `z`

所有容器以 rootless 模式运行，`Volume=` 末尾的标志按下面两条规则使用。

#### `:U` —— 修复非 root 容器的属主

`:U` 会递归地将卷内容属主改为与容器进程用户一致，解决镜像以非 root 运行时
因宿主机 uid/gid 不匹配导致的权限问题（命名卷与 bind mount 均适用）。

判断依据就是容器进程是否为 root：

- 显式设置了非 root `User=`（如 `User=70:70`）→ **加 `:U`**
- 显式设置为 `User=0:0`，或未设 `User=` 而镜像默认以 root 运行 → **不加 `:U`**
- 不加的原因：属主本就匹配，加 `:U` 只会多一次递归 chown，卷越大启动越慢

本目录的实际用法与此一致：

| 容器 | `User=` | 是否用 `:U` |
| --- | --- | --- |
| postgres | `70:70` | ✅ `U,Z` |
| valkey | `999:1000` | ✅ `U,Z` |
| searxng | `977:977` | ✅ `U,Z` |
| grafana / loki / memos | `0:0` | ❌ 仅 `Z` |
| 其余未设 `User=` 的容器 | root | ❌ 仅 `Z` |

#### `:Z` 与 `:z` —— SELinux 标签范围

两者都用于在 SELinux 环境下对卷重新打标签，区别在于打的是**私有**还是**共享**标签：

| 标志 | 标签类型 | 可访问范围 |
| --- | --- | --- |
| `:Z` | 私有 | 仅当前容器可访问 |
| `:z` | 共享 | 多个容器可共同访问 |

因此默认一律用 `:Z`，**只有确实需要跨容器共享时才降级为 `:z`**。本目录唯一的 `:z` 用例是
`code-server`，其 `dotfiles`、`workspace` 等共享目录会同时挂载给多个 code-server 容器
（详见 [code-server](#code-server)）：

```conf
Volume=code-server_data.volume:/root:Z
Volume=%h/workspace:/root/workspace:z
```

同一份数据混用 `:Z` 与 `:z` 会导致后者覆盖前者的标签，使私有标签失效——共享同一目录时，
相关容器必须统一使用 `:z`。

注意：`:Z` / `:z` 仅在 SELinux 处于 enforcing 或 permissive 模式时才有效果。
在未启用 SELinux 的系统（如默认使用 AppArmor 的 Debian）上这两个标志会被忽略，
保留不影响可移植性。

### 开机自启

`<name>.container` 中的：
```conf
[Install]
WantedBy=default.target
```
会让容器开机自动启动，但首次创建 `<name>.container` 后还是得
`systemctl --user start <name>.service` 才能启动容器。

以下是相关命令，按**验证 → 重载 → 启动**的顺序执行：

### 1. 验证

```bash
/usr/lib/systemd/system-generators/podman-system-generator --user --dryrun 2>&1
```

手动以 dry-run 方式运行 Quadlet 生成器，只输出将要生成的单元内容而不写盘。用于排查单元文件的语法错误——生成器失败时默认是静默的，不这样跑看不到具体报错原因。

### 2. 重载

```bash
systemctl --user daemon-reload
```

新增或修改任何 Quadlet 文件（`.container` / `.volume` / `.network`）后**必须**执行。重载会触发 `podman-system-generator` 重新生成对应的 `.service` 单元；不执行的话改动不会生效，直接 `start` 会报 `Unit ... not found`。

### 3. 启动

```bash
systemctl --user start anki-sync
```

启动容器。省略 unit 类型时 systemd 默认按 `.service` 处理，因此下面这条与之完全等价：

```bash
systemctl --user start anki-sync.service
```

显式写出 `.service` 后缀的等价写法，两者无差别。

## 服务清单

所有服务均只监听 `127.0.0.1`，经上层反向代理暴露。固定 IP 由 `10_26_0_1.network` 分配，
容器间通过 DNS 名称互访（如 `http://searxng:8888`）。

宿主端口为 4 位数，按 `AB CD` 拆成两组，前两位映射为 IP 第三字节、后两位映射为第四字节，
即 `ABCD` -> `10.26.AB.CD`。例如 `1030` -> `10.26.10.30`、`1210` -> `10.26.12.10`。

端口从 1030 开始，每个服务预留 10 个端口便于扩展；服务不同但关联性特别强时可共用同一段，
如 `searxng`（1120）与 `mcp-searxng`（1129）。

表中 CPU / 内存为**单容器上限**，用于防止个别容器耗尽宿主资源，不代表容量规划，
各服务上限之和可以超过宿主实际配置。

| 服务 | 宿主端口 | IP | 镜像 | CPU / 内存 |
| --- | --- | --- | --- | --- |
| anki-sync | 1030 | 10.26.10.30 | `quay.io/honbey/anki-sync:26.8.8-39e4b0b4` | 1 / 256m |
| code-server | 1040 | 10.26.10.40 | `quay.io/honbey/playground:26.8.28-code-server` | 6 / 12g |
| valkey | 1050 | 10.26.10.50 | `docker.io/valkey/valkey:9-alpine` | 2 / 2g |
| authelia | 1060 | 10.26.10.60 | `docker.io/authelia/authelia:master` | 2 / 2g |
| dufs | 1070 | 10.26.10.70 | `docker.io/sigoden/dufs:latest` | 1 / 1g |
| clash | 1080 | 10.26.10.80 | `quay.io/honbey/playground:clash-1.18` | 0.5 / 256m |
| memos | 1090 | 10.26.10.90 | `docker.io/neosmemo/memos:stable` | 1 / 1g |
| ntfy | 1100 | 10.26.11.0 | `docker.io/binwiederhier/ntfy:latest` | 1 / 256m |
| tuwunel | 1110 | 10.26.11.10 | `docker.io/jevolk/tuwunel:main` | 1 / 512m |
| searxng | 1120 | 10.26.11.20 | `docker.io/searxng/searxng:2026.8.16-b2da6b90f` | 2 / 2g |
| mcp-searxng | 1129 | 10.26.11.29 | `docker.io/isokoliuk/mcp-searxng:latest` | 0.5 / 256m |
| vaultwarden | 1130 | 10.26.11.30 | `docker.io/vaultwarden/server:latest` | 1 / 1g |
| rustfs | 1140 / 1141 | 10.26.11.40 | `docker.io/rustfs/rustfs:1.0.0-rc.4` | 2 / 2g |
| postgres | 1150 | 10.26.11.50 | `docker.io/library/postgres:18-alpine` | 2 / 2g |
| nanobot-t | 1160 | 10.26.11.60 | `quay.io/honbey/nanobot:26.8.8-bd8d3ad5` | 1 / 1g |
| victoria-metrics | 1170 | 10.26.11.70 | `docker.io/victoriametrics/victoria-metrics:v1.150.0` | 2 / 2g |
| victoria-logs | 1180 | 10.26.11.80 | `docker.io/victoriametrics/victoria-logs:v1.52.0` | 4 / 4g |
| loki | 1190 | 10.26.11.90 | `docker.io/grafana/loki:3.7.7` | 4 / 4g |
| grafana | 1200 | 10.26.12.0 | `docker.io/grafana/grafana:13.2-slim` | 4 / 4g |
| vector | 1210 | 10.26.12.10 | `docker.io/timberio/vector:0.58.X-debian` | 2 / 1g |

### 启动依赖

- `mcp-searxng` → `searxng`
- `grafana` → `loki`
- `vector` → `loki`、`victoria-logs`、`victoria-metrics`

### code-server

半隔离的远程开发环境。镜像基于 `docker.io/codercom/code-server:latest` 自定义构建，
集成了 Rust、C、Python、Node、Go 语言环境，以及 DeepSeek Harness、AtomCode、OpenCode 等辅助编程工具。

用途有两点：

1. 作为 WebIDE，方便远程开发
2. 为 AI agent 辅助编程提供隔离环境

之所以是“半隔离”是因为容器直接共享宿主机的部分目录（语言工具链与缓存），
而不是各自复制一份以便减少重复文件占用磁盘空间。

| 类别 | 目录 | 标志 |
| --- | --- | --- |
| 私有 | `code-server_data.volume:/root` | `Z` |
| 共享 | `%h/dotfiles`、`%h/workspace`、`%h/resources` | `z` |
| 共享（工具链） | `%h/.cargo`、`%h/.rustup`、`%h/.go`、`%h/.npm` | `z` |
| 共享（LSP） | `%h/.local/share/nvim/mason/packages` | `z` |
| 共享（其他） | `%h/.cache`、`/home/linuxbrew` | `z` |

`dotfiles`、`workspace` 等目录会同时挂载给多个 code-server 容器，因此必须使用共享标签 `:z`，
这也是本目录唯一使用 `:z` 的场景。资源限制为 6 核 / 12G（宿主机为 8C32G），是本机分配资源最多的容器服务。

## 部署

### 1. 链接配置

仓库根目录的 `install.sh` 已包含 `podman` 包，也可单独执行：

```bash
stow podman -t ~
```

### 2. 生成环境变量

```bash
cd ~/.config/containers/systemd
for f in *.env.example; do cp -n "$f" "${f%.example}"; done
```

然后按需填写 `<name>.env` 中的空值。

### 3. 创建 Authelia secrets

以文件方式注入，避免密钥进入单元文件和 git 仓库：

```bash
mkdir -p "$HOME/.config/containers/systemd/authelia.conf.d/secrets"
# add secrets by editor ...
export AUTHELIA_SECRETS_DIR="$HOME/.config/containers/systemd/authelia.conf.d/secrets"
podman secret create authelia-jwt-secret      "${AUTHELIA_SECRETS_DIR}/jwt_secret"
podman secret create authelia-session-secret  "${AUTHELIA_SECRETS_DIR}/session_secret"
podman secret create authelia-storage-key     "${AUTHELIA_SECRETS_DIR}/storage_key"
podman secret create authelia-smtp-password   "${AUTHELIA_SECRETS_DIR}/smtp_password"
podman secret create authelia-oidc-hmac       "${AUTHELIA_SECRETS_DIR}/oidc_hmac"

# 可选：确认已备份后删除宿主机上的明文副本
# 警告：STORAGE_ENCRYPTION_KEY 丢失后，已加密数据无法恢复
/bin/rm -ri "${AUTHELIA_SECRETS_DIR}"
```

### 4. 补齐 `*.conf.d/` 配置

`authelia`、`clash`、`grafana`、`loki`、`nanobot-t`、`tuwunel`、`vector` 需要真实配置文件，仓库中仅保留 `.gitkeep`。

TODO: 配置文件脱敏后以 `*.conf.example` 形式加入 git 仓库追踪

### 5. 启动

```bash
systemctl --user daemon-reload
systemctl --user start <name>.service
```

## 注意事项

- `code-server` 以 `--auth=none` 运行，且挂载了宿主 `dotfiles`、`workspace`、`~/.cargo`、`~/.npm` 等目录，依赖上层代理 Nginx 配合 Authelia 认证。
- `dufs` 默认以 `-A` 匿名可写方式运行，需要鉴权时应改用 `Exec=` 中的注释行并配置 `ADMIN` / `SYNC1` / `USER1`，依赖上层代理 Nginx 配合 Authelia 认证。
- `vector` 读取宿主 `/var/log/journal`（用户日志，系统日志无权限）及 `~/app/nginx/logs` 采集日志。

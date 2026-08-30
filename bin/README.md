# .local/bin

这个文件夹保存自己写的一些脚本或自定义命令。

可以通过 `stow` 链接到 `$HOME` 目录，不过因为有些第三方工具会创建软链接或脚本到这个目录，
所以 `.gitignore` 设置 `*` 默认忽略所有文件，通过 `!files` 追踪需要被 `git` 管理的文件。

## 约定

- 文件命名采用 snake_case
- bash 函数定义 `function fun() {...}` 形式

## rm_dangling_links

删除失效的文件链接（dangling symbolic links），扫描后端优先使用 `fd`，无 `fd` 时回退到 `find`。

- `-d DIR, --directory DIR`：扫描目录（默认 `.`，支持 `~` 展开）
- `-D N, --max-depth N`：最大扫描深度（默认 1）
- `-n, --dry-run`：仅列出不删除
- `-h, --help`：查看帮助

## install_brew

安装 Homebrew（缺失时）及脚本内定义的软件包列表。包列表原先放在仓库根目录的 `brew/` 下，
现已合并进本脚本，`brew/Dockerfile` 不再需要（Linuxbrew 镜像由其他仓库维护）。

安装前会做两层判断，命中任一即跳过，避免与系统自带的版本冲突：

1. 已由 Homebrew 安装
2. 对应命令已存在于 Homebrew prefix 之外（由系统包管理器或 cargo/npm 等工具链提供）

因此同一台机器上重复执行是安全的。

分组规则：

| 分组 | 安装条件 |
| --- | --- |
| common | 总是安装 |
| macos | 仅 macOS |
| optional | 需 `-a/--all` |
| casks | macOS GUI 应用，需 `-c/--casks` 且为 macOS（其他系统会警告跳过） |

条目格式为 `formula[:bin1,bin2]`，`bin` 默认为 formula 名；部分包在不同发行版下的命令名不同
（如 Debian 的 `fd` 为 `fdfind`、`ripgrep` 为 `rg`），需显式列出备用名。

- `-a, --all`：同时安装 optional 分组
- `-c, --casks`：安装 macOS casks（仅 macOS）
- `-n, --dry-run`：仅打印不安装
- `-v, --verbose`：输出被跳过（已存在）的包
- `-h, --help`：查看帮助

```bash
install_brew            # Homebrew + common
install_brew -a         # 含 optional
install_brew -a -c      # 全部（含 macOS 应用）
```

`install.sh --first-run` 现在只负责安装 Homebrew，装包通过调用本脚本完成。

## new_container

快速生成 Podman Quadlet 容器配置（`<name>.container`、`*.env`），省去从现有单元文件复制改写的麻烦。

模板取本仓库 20 个单元文件中**最常使用的配置项**，其余可选项以注释形式输出，按需取消注释即可：

- 直接生成：`Description`、`After`、`StartLimit*`、`Image`、`ContainerName`、`EnvironmentFile`、
  `PublishPort`、`Network`、`PodmanArgs`、`LogDriver`、`StopTimeout`、`Health*`、
  `Restart`、`RestartSec`、`WantedBy`
- 注释形式：`Exec`、`StopSignal`、`User`、`HealthStartPeriod`、`Secret`、`Tmpfs`、`Volume`

`*.env` 默认只写入 `TZ=Asia/Shanghai`。

`_data.volume` 与 `.conf.d/` **默认不生成**，对应的 `Volume=` 行以注释输出；需生成时传 `-V` / `-C`，
此时 Volume 行会自动启用并创建文件（`.conf.d/` 带 `.gitkeep`）。

网络 IP 沿用仓库约定：`-p` 指定的 4 位宿主端口 `ABCD` 映射为 `10.26.AB.CD`，
例如 `-p 1040` 得到 `ip=10.26.10.40`；未指定 `-p` 时 `PublishPort` / `Network` 以注释加占位符输出。

选项需写在 NAME 之前（与 `install.sh` 一致）。

- `-i IMAGE, --image IMAGE`：容器镜像（默认 `docker.io/library/NAME:latest`）
- `-D DESC, --description DESC`：Unit 描述（默认 `NAME container service`）
- `-p PORT, --port PORT`：宿主端口，4 位数字，同时用于推导网络 IP
- `-P PORT, --container-port PORT`：容器端口（默认 8080）
- `-I IP, --ip IP`：手动指定 IP，覆盖 `-p` 推导结果
- `-c N, --cpus N`：CPU 限制（默认 1）
- `-m SIZE, --memory SIZE`：内存上限（默认 256m）
- `-r SIZE, --memory-reservation SIZE`：内存软限制（默认 16m）
- `-u USER, --user USER`：容器用户 `uid:gid`
- `-V, --volume`：生成 `<name>_data.volume` 并启用对应 Volume 行
- `-C, --conf-d`：生成 `<name>.conf.d/` 并启用对应 Volume 行
- `-d DIR, --dir DIR`：输出目录（默认 `~/.config/containers/systemd`，支持 `~` 展开）
- `-f, --force`：覆盖已存在文件
- `-n, --dry-run`：仅打印不写入
- `-v, --verbose`：写入时同时打印内容
- `-h, --help`：查看帮助

```bash
new_container -i docker.io/neosmemo/memos:stable -p 1090 -P 5230 -V memos
new_container -p 1200 -P 3000 -c 4 -m 4g -V -C grafana
```

生成后需执行 `systemctl --user daemon-reload` 才能启动。

## backup_home

我已经把数据从 /opt/data 完全迁移到了 `$HOME`，顺便弄个备份脚本。

脚本功能：备份用户的家（`$HOME`）目录：tar 打包选定路径，再由 7-zip 压缩为加密 `.7z` 归档。

备份策略：

1. 本地离线设备（例如可移动硬盘，非 FAT32 文件格式）保存 tar 备份文件
2. 选择 1 ~ 3 个云盘保存 7z 加密备份文件，保留最近 3 个全量备份
3. 每天最多备份一次（同日期覆盖）

增量链的保存说明：增量备份相互依赖——恢复最新状态需要首个全量备份、之后
的每一个增量备份及对应快照。云盘端没有增量概念，保存策略必须与本地一致
（完整保留备份链，不要单独清理中间文件），任一环节缺失都会导致后续无法
完整恢复。

基于 GNU tar 增量模式（`-g/--listed-incremental`）：首次运行生成全量备份与快照，
之后每次只打包变化内容。

- `-F, --first-run`：首次全量备份（创建快照；快照已存在时拒绝执行）
- `-C, --force-full`：强制全量备份（输出目录已有备份时，在 `<日期>` 子目录开启新备份链）
- `-o DIR, --output-dir DIR`：输出目录（默认 `.`，支持 `~` 展开，自动创建）
- `-l N, --mx-level N`：7z 压缩级别 0-9（默认 1）
- `-s SIZE, --split-size SIZE`：7z 分卷，必须带大小（单位 `b/k/m/g`，如 `4g`；默认不分卷）
- `-g, --generate-excluded`：生成 `~/.backup_excluded` 模板后退出（已存在时拒绝）
- `-G, --generate-metadata`：生成 `~/.backup_metadata` 后退出（需 root/sudo，已存在时拒绝）
- `-h, --help`：查看帮助

产出文件（以 `root` 用户，machine-id `f85ba416` 为例）：

- `home_root-f85ba416-20260806.tar`：tar 归档（不压缩）
- `home_root-f85ba416-20260806.7z`：加密 7z 归档（分卷时为 `.7z.001`、`.7z.002`…）
- `home_root-f85ba416.snap`：增量快照（每次运行更新）
- `home_root-f85ba416-20260806.snap`：快照副本（与归档同 base，供恢复）

恢复（按时间从最旧开始，先解压对应 `.7z`）：

```
tar --listed-incremental=<date>.snap -xf <date>.tar
```

分卷归档解压（自动读取全部分卷）：

```
7zz x home_root-f85ba416-20260806.7z.001
```

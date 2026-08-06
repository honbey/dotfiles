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

## backup_home

我已经把数据从 /opt/data 完全迁移到了 `$HOME`，顺便弄个备份脚本。

脚本功能：备份用户的家（`$HOME`）目录：tar 打包选定路径，再由 7-zip 压缩为加密 `.7z` 归档。

备份策略：

1. 本地离线设备（例如可移动硬盘，非 FAT32 文件格式）保存 tar 备份文件
2. 选择 1 ~ 3 个云盘保存 7z 加密备份文件，保留最近 3 个
3. 每天最多备份一次（同日期覆盖）

基于 GNU tar 增量模式（`-g/--listed-incremental`）：首次运行生成全量备份与快照，
之后每次只打包变化内容。

- `-f, --first-run`：首次全量备份（创建快照；快照已存在时拒绝执行）
- `-o DIR, --output-dir DIR`：输出目录（默认 `.`，支持 `~` 展开，自动创建）
- `-l N, --mx-level N`：7z 压缩级别 0-9（默认 1）
- `-s SIZE, --split-size SIZE`：7z 分卷，方便上传到云盘
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

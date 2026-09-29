# tests

`bin/.local/bin` 下脚本的回归测试，与脚本同级；`stow bin` 后位于 `~/.local/bin/tests/`，
可从任意位置调用（脚本会跟随软链接定位仓库，见下方约定）。

| 测试 | 被测脚本 | 覆盖 |
| --- | --- | --- |
| `test_backup_home` | `backup_home` | 参数解析与拒绝路径、`-g`/`-G` 生成器、全量/增量归档内容与排除规则、7z 头部加密与成员构成、两级链恢复（权限/符号链接/硬链接/删除语义）、`-d` 时间点恢复、分卷、旧格式（无快照副本）归档、含 `-` 的前缀、输出目录变体 |
| `test_bg_run` | `bg_run` | 选项位置（程序名前后）、程序参数透传、PID 文件生命周期、陈旧 PID 处理、含空格参数、shebang 脚本（解释器占 argv[0]） |

```bash
bin/.local/bin/tests/test_backup_home       # 全绿时清理临时目录
bin/.local/bin/tests/test_backup_home -k    # 保留临时目录
bin/.local/bin/tests/test_bg_run
```

约定：

- 仓库根目录由测试文件自身位置推导，并用 `readlink -f` 跟随软链接，因此 `~/.local/bin/tests/…`
  这种 stow 链接同样可用
- 在临时目录里用假 `$HOME` 运行，不碰真实环境；`bg_run` 的测试退出时会清掉自己启动的进程
- 成功自动清理临时树，失败保留现场、列出失败项并返回非 0
- 退出码：`0` 全绿 / `1` 有用例失败 / `2` 环境问题（缺依赖、临时目录不合法）
- 被测脚本与临时目录可用环境变量覆盖：`BACKUP_HOME_SCRIPT`、`BACKUP_HOME_TEST_DIR`、
  `BG_RUN_SCRIPT`、`BG_RUN_TEST_DIR`
- 暂未接入 CI

# Shell Exec Rule 001

**优先级**：**CRITICAL（致命级）**
**适用范围**：所有 shell 命令执行、进程管理、服务重启/停止操作。

## 1. 核心禁令（绝对禁止）

**严禁**在 `sh`、`bash`、`zsh` 或任何子 shell 环境中，使用 **`pgrep -f`** 配合 **`pkill`** 或 **`kill`** 命令来结束进程。

**禁止的模式包括但不限于：**

- `pkill -f "process_name"`
- `kill $(pgrep -f "process_name")`
- `pgrep -f "process_name" | xargs kill`
- 任何将 `pgrep -f` 的输出作为 PID 参数传递给终止指令的操作。

## 2. 禁止原因（Why）

`-f` 参数匹配的是**完整的命令行**（包括参数和路径），而不是仅匹配进程名（`comm`）。

- **自噬风险**：如果 `"process_name"` 匹配到了当前 Agent 运行时的父 Shell、子 Shell 或脚本解释器（如 `python`、`java`、`bash script.sh`），执行命令会导致 **Agent 主进程被杀死**，任务直接中断且无法恢复。
- **误杀连锁**：该命令会匹配所有含该字符串的进程，极大概率同时杀掉多个无关服务，造成系统级故障。

## 3. 强制安全替代方案（Do this instead）

Agent 在执行进程终止操作时，**必须**按以下优先级选择其一：

| 优先级 | 方案 | 命令示例 | 适用场景 |
| :--- | :--- | :--- | :--- |
| **最优** | **使用 PID 文件** | `kill $(cat /var/run/app.pid)` | 标准服务（Nginx/Java/Node） |
| **次优** | **精确匹配进程名（无 -f）** | `pkill -x "process_name"` <br> 或 `kill $(pgrep -x "process_name")` | `process_name` 为二进制文件名（如 `nginx`） |
| **安全兜底** | **先列表，后筛选（防误杀）** | `pgrep -f "specific/unique/path/app.jar" \| grep -v $$ \| xargs kill` <br> **（必须结合 `grep -v $$` 排除当前 Shell PID）** | 必须使用全路径匹配时 |

**命令执行原则**：**宁可终止失败（返回错误码），也绝不使用模糊匹配强行终止进程。** 当不确定 PID 时，必须向用户请求确认。

## 4. 强制前置校验（Check before kill）

在执行任何 `kill` 操作前，Agent **必须**先执行以下心理检查或代码逻辑：

1. **预览输出**：先单独执行 `pgrep -a "process_name"`（带 `-a` 显示完整参数），人工/模型确认返回的 PID 列表。
2. **排除自身**：若无法避免使用 `-f`，代码逻辑中必须执行 `grep -v $$` 排除当前 Shell 的 PID。
3. **计数确认**：若返回结果数量 **> 1**，必须中止操作并向用户澄清，绝对不允许批量全部 kill。

## 5. 违规示例（绝对不要生成）

```bash
# ❌ 高危操作：严禁生成此类命令
pgrep -f "mysql" && pkill -f "mysql"

# ❌ 高危操作：严禁生成此类命令
kill -9 $(pgrep -f "backend.jar")
```

## 6. 合规示例（请生成此类）

```bash
# ✅ 方案一：精确匹配（最推荐）
pkill -x "redis-server"

# ✅ 方案二：基于 PID 文件
kill $(cat /tmp/backend.pid)

# ✅ 方案三：迫不得已用 -f 时必须排除当前 shell 并二次确认
PIDS=$(pgrep -f "java.*backend.jar" | grep -v $$)
[ -n "$PIDS" ] && echo "$PIDS" | xargs kill
```

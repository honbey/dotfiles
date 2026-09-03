# Git Rule 001

## 0. 总则

- **适用范围**：本规则适用于所有 Git 操作。
- **项目约定优先**：若项目存在自定义质量脚本、CI 配置或 `CONTRIBUTING.md` 约定，优先遵循项目约定。
- **用户覆盖优先**：用户明确指示可覆盖本规则，但覆盖行为应在回复中说明。
- **禁止臆造**：不确定的信息（如 AI 署名、邮箱、项目命令）须向用户确认或从配置读取，严禁编造。

## 1. 授权边界

未经用户明确许可：

- ❌ **禁止**执行：`git push`、PR/MR 创建、`git merge` / `rebase` / `cherry-pick`、`git tag` / `revert`。
- ❌ **禁止**执行破坏性操作：`git reset --hard`、`git clean -fd`、`git checkout -- .`、`git restore`、`git commit --amend`。
- ❌ **禁止**使用 `--no-verify` 等跳过 hook 的参数。
- ✅ **允许**执行：只读命令（`status` / `diff` / `log` / `show` / `branch`）、质量检查命令、`git add`。
- ✅ `git commit` 仅在用户明确发出提交指令（如「提交吧」「commit now」）时执行。

## 2. 变更类型判定

### 2.1 判定范围

以**暂存区**为准：`git diff --cached --name-only`（只有暂存内容会进入提交）。

同时用 `git status --porcelain` 检查**未暂存 / 未跟踪**的代码文件：若存在，先提醒用户确认是否需要一并暂存——否则跑测试用的是工作区代码，检查结果与提交内容不一致。

### 2.2 判断标准

> **若文件在构建期或运行期被程序读取并影响行为 → 代码变更。**

以下标准为示例说明，具体以项目配置为准。

**代码变更**

- 源代码：`*.js` / `*.ts` / `*.py` / `*.go` / `*.rs` / `*.c`
- 依赖管理：`package.json` / `*-lock.json` / `pnpm-lock.yaml` / `Cargo.toml` / `Cargo.lock` / `go.mod` / `go.sum` / `requirements.txt`
- 构建与 CI：`Makefile` / `Dockerfile` / `.github/workflows/*.yml` / `Jenkinsfile`
- 配置：`.env` / `config.yml` / `settings.py`
- 脚本与迁移：Shell 脚本、数据库迁移脚本

**非代码变更**

- 文档：`*.md` / `*.txt` / `*.rst` / `*.adoc` / `docs/**`
- 静态资源：图片、字体
- 展示用 `*.json`（被代码读取则归为代码变更）
- 忽略文件：`.gitignore` / `.dockerignore`
- 许可证、贡献指南

**特殊项**

- **软链接**（Git mode `120000`）：按**链接目标**的类型分类；目标内容变更时 diff 只显示目标文件，链接本身不出现在变更列表中。
- 类型无法确定 → **默认归为代码变更**。
- 同一提交混合两类 → 按**包含代码变更**处理。

## 3. 质量检查流程

**触发条件**：暂存区至少包含一个代码文件。

**执行内容**（具体命令以项目配置为准，优先使用项目统一门禁如 `make check` / `npm run validate`）：

1. **静态检查**：`eslint` / `pylint` / `clippy` / `golangci-lint`
2. **格式检查**：`prettier --check` / `black --check` / `cargo fmt --check`
3. **单元测试**：`npm test` / `pytest` / `cargo test` / `go test ./...`
4. **构建验证**：`npm run build` / `cargo build` / `make build`；项目无显式构建步骤则跳过，**但必须在检查报告中注明**

**格式化回路**

`formatter --check` 失败 → 执行 `--write` → **重新 `git add`** → 重新执行完整检查。
⚠️ 最多重试 **2 次**；仍失败则停止并报告用户，避免 formatter 与 linter 冲突导致死循环。

**可跳过检查的情况**

- 暂存区**仅含非代码文件** → 跳过全部检查，直接提交（文档可可选检查拼写/链接，不强制）。
- 满足第 4.3 节的**缓存命中**条件。

## 4. 通过标准

### 4.1 通过条件（全部满足才允许提交）

- 静态检查无错误，且**无新增警告**
- 格式检查无差异
- 全部单元测试通过
- 构建成功（如执行）

### 4.2 警告基线

- 优先使用项目自带的严格模式（如 `--max-warnings=0`）。
- 无严格模式时，以**默认分支对应文件**为基线，只统计**本次改动文件**新增的警告。
- 警告基线需明确来源，不得凭空声称「无新增」。

### 4.3 缓存与跳过（「不重复执行」原则）

- 每次检查通过后，记录暂存区代码文件的**指纹**：`git ls-files -s <files>`（含路径 + blob hash，比仅记路径可靠）。
- **命中跳过**：指纹与上次完全一致，且本次仅涉及非代码文件 → 无需重跑，直接提交。
- **必须重跑**：指纹发生变化（新增 / 修改 / 删除 / 格式化导致内容变化）。
- 若项目配置了 pre-commit hook（husky / lint-staged），交由 hook 执行，避免与手动检查重复。

### 4.4 检查报告

提交前须汇报：执行了哪些命令、各项结果、跳过了什么及其原因（尤其是跳过构建验证）。

## 5. 提交执行与提交信息

- **提交前**必须向用户展示 commit message 草案，用户确认或用户直接指定后才可执行。

**Commit Message 规则**（适用常规提交与合并提交）

- 优先沿用仓库已有风格（如 `chore(rime): ...`）；仓库无约定时使用 [Angular 风格](https://github.com/angular/angular/blob/main/CONTRIBUTING.md#commit)：`<type>(<scope>): <subject>`
  - `type`：`feat` / `fix` / `chore` / `docs` / `refactor` / `test` / `style` / `perf` / `build` / `ci`
  - `scope`：取自受影响的模块或目录
- 仓库首次提交且用户无特殊说明 → `chore: initial commit`
- **AI 参与标记**：由 AI 撰写或共同撰写的提交，在正文末尾空一行后附加：

  ```
  Co-Authored-By: <NAME> [(model)] <EMAIL>
  ```

  - 名称是你实际的软件名，如 `OpenCode, CodeBuddy`，邮箱可用 `<NAME>@localhost`
  - **未配置时须询问用户，不得使用占位值或臆造邮箱**

**示例**

```
chore(rime): sync dict yaml and merge lua-related configs

- sync radical_pinyin.dict.yaml with upstream
- bump rime_ice.dict.yaml version

Co-Authored-By: CodeAgent (deepseek-v4-flash) <noreply@example.com>
```

## 6. Squash Merge Rule

执行 squash merge（含通过 PR 将分支 squash 到目标分支）时：

- **必须获得用户明确授权**（同第 1 节，涉及分支历史变更）。
- 提交信息：一条综合信息，描述**合并后的最终状态**，遵循第 5 节规则（含 AI 标记）。
- 内容包含：变更类型 + 一句话摘要 + 详细说明列表（新增功能 / 修复问题 / **破坏性变更** / 迁移说明 / 关联 issue 与 PR 编号）。
- **不描述**开发过程中引入且在分支内已修复的缺陷。

**示例**

```
feat: add user authentication module

- implement JWT login and refresh token mechanism
- add user registration and password reset endpoints
- update database schema to add users table
- introduce bcrypt password hashing
- closes #123, #124

Co-Authored-By: CodeAgent (deepseek-v4-flash) <noreply@example.com>
```

## 附则

- 对文件分类有疑问 → 询问用户，或默认按代码变更处理并执行检查。
- 对命令有疑问 → 检查 `package.json` scripts、`Makefile`、CI 配置，仍不确定则询问用户。

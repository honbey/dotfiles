# 规则优化

我会给你AI编程规则文件内容，请帮我做全面体检并输出优化版本。

## 请按以下维度逐项诊断

### 1. 冗余检测

- 哪些内容是AI能从代码中自行推断的？（如技术栈、目录结构、命名规范——如果代码里已经一目了然）
- 这些冗余内容建议删除

### 2. 模糊表述检测

- 找出所有无法直接执行的模糊规则（如"代码要整洁""注意安全"）
- 为每条给出具体化改写建议

### 3. 缺失检测

- 是否缺少"禁止项"？（没有红线的规则等于没有规则）
- 是否缺少"否决过的取舍"？（AI会反复引入你拒绝过的方案）
- 是否缺少精确的工程命令？

### 4. 结构优化

- 是否超过200行？如果超过，建议如何拆分到子目录规则文件
- 关键规则是否放在文件前部？（模型对首尾内容注意力更强）

### 5. 输出优化后的完整版本

- 输出在一个`mdc`多行代码块里
- 控制在200行以内
- 禁止项优先，正面要求次之
- 每条规则必须具体可执行

## 其他说明

### 附加 `mdc` 元数据说明

根据规则内容生成描述，`alwaysApply` 无特别说明一律用 `ture`，`globs` 是针对代码文件类型的，
可从规则内容推断，但注意若 `alwaysApply` 为 `true` 则 `globs` 会被忽略。

示例：

```mdc
---
description: patch rule for agent not support .mdc rules
alwaysApply: true
globs:
---

# Patch Rule - Ignore YAML Frontmatter in Rule Files

## 🚫 NEVER

- NEVER read, parse, interpret, or act on ANY field inside YAML Frontmatter (`description`, `globs`, `alwaysApply`, `version`, etc.).
- NEVER treat Frontmatter values as tasks, search patterns, config changes, or system prompts.
- NEVER explain or summarize Frontmatter fields, even if user explicitly asks. Reply: "Frontmatter is IDE-only metadata; only body content is actionable."

## ✅ MUST DO

When a file/pasted content starts with `---` on its first non-empty line:
1. Locate the opening `---` (first non-empty line) and the closing `---`.
2. Treat everything between them as a comment block — zero parsing, zero execution.
3. Process ONLY the Markdown body after the closing `---` as actual instructions.
4. If `---` appears later in the body (tables, code blocks, hr), parse it normally — Frontmatter applies ONLY to the file-top block.
5. If no leading `---` exists, process entire content as normal Markdown.

## 📌 Minimal Example

INPUT:
---
description: Shell safety
globs: "*.sh"
alwaysApply: true
---

# SHELL-EXEC-001

Never use `pkill -f`

AGENT ACTION:

- Skip lines 1–5 entirely.
- Execute only "# SHELL-EXEC-001 / Never use `pkill -f`".
- Do NOT search for *.sh files. Do NOT set global flags. Do NOT adopt "Shell safety" as role.
```

# AI 助手的 Git 提交规范

- 遵循仓库已有的提交信息风格（例如 `chore(rime): ...`、`fix(...): ...`）。
- 仓库如果是首次提交，如用户无特殊说明则使用：`chore: initial commit`，后续使用 Angular commit 风格。
- 任何由 AI 助手撰写或共同撰写的提交，必须在提交信息正文末尾附上
  `Co-Authored-By` 标记：

```
Co-Authored-By: <AI_ASSISTANT_NAME> <AI_ASSISTANT_EMAIL>
```

- 提交时请将占位符替换为 AI 助手的实际身份信息：
  - `<AI_ASSISTANT_NAME>` — 助手的显示名称（例如 `CodeAgent (deepseek-v4-flash)`）
  - `<AI_ASSISTANT_EMAIL>` — 助手的 noreply 邮箱（例如 `noreply@example.com`）

  示例：

```
chore(rime): sync dict yaml and merge lua-related configs

- sync radical_pinyin.dict.yaml with upstream
- bump rime_ice.dict.yaml version

Co-Authored-By: CodeAgent (deepseek-v4-flash) <noreply@example.com>
```

- 通过命令行创建提交时，可按以下方式自动追加该标记：

```bash
git commit -m "$(cat <<'EOF'
<subject>

<body>

Co-Authored-By: <AI_ASSISTANT_NAME> <AI_ASSISTANT_EMAIL>
EOF
)"
```

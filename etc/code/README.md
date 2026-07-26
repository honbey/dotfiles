# Code Server

## Custom Fonts

[Reference](https://github.com/coder/code-server/issues/1374)

```bash
find /usr/lib/code-server -name workbench.html

cp -r fonts /urs/lib/code-server/lib/vscode/out/vs/code/browser/workbench

vi /usr/lib/code-server/lib/vscode/out/vs/code/browser/workbench/workbench.html

# add you fonts `<link>` to `workbench.html` (modify xxx to release id)
<link rel="stylesheet" href="https://code.freewisdom.cn:9090/stable-xxx/static/out/vs/code/browser/workbench/fonts/style.css">
```

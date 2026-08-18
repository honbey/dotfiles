# Code Server

基于 [Coder](https://coder.com/) 的 [code-server](https://github.com/coder/code-server) 制作的自定义镜像，安装了一些开发工具，
Code Server 前方有 Nginx 和 Authelia，需通过 Authelia 双因素鉴权才能使用。

几个常用端口通过 `code-{{port}}` 访问，nginx 层面默认 `deny all;`，访问时通过
`allow 192.192.192.192;` 单独控制。

## Custom Fonts

[Reference](https://github.com/coder/code-server/issues/1374)

```bash
find /usr/lib/code-server -name workbench.html

cp -r fonts /urs/lib/code-server/lib/vscode/out/vs/code/browser/workbench

vi /usr/lib/code-server/lib/vscode/out/vs/code/browser/workbench/workbench.html

# add you fonts `<link>` to `workbench.html` (modify xxx to release id)
<link rel="stylesheet" href="https://code.freewisdom.cn:9090/stable-xxx/static/out/vs/code/browser/workbench/fonts/style.css">
```

不知道上述方式还行不行，目前我用 Brave 浏览器，只需把 **阻止指纹识别** 关闭即可，
如果是 Brave 1.93.136 (Chromium 151.0) 还可以只单独关闭 **字体** 。

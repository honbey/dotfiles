# Supabase (Self-hosting by Podman)

暂时不用 Supabase，不太符合我的需求，多项目就要多个 Supabase，32G 内存也承受不住，
而且我的项目规模都很小，有点小题大做的倾向，后面去试用下其免费的云服务就行了。

.supabase-version:

```
ref=self-hosted/v0.7.2
```

使用 Podman 部署的 Supabase，改动了 `docker-compose.yml, docker-compose.logs.yml, docker-compose.rustfs.yml`，
主要是将日志 driver 改成 `k8s-file`，并将其持久化到宿主机的日志目录方便 `vector` 采集，
`vector.yml` 适应 Podman 的 ctr 日志进行适配改动从而可以正确解析日志。

## .env.example 以及 CONFIG.md

这两个文件包含一些示例的敏感信息，会被 CNB 误报，我已将其从历史提交中删除，
需要的话从 [Supabase](https://github.com/supabase/supabase) 仓库中再拉取。

## supabase-analytics auth_logs 返回 500

原因是 [Supabase PR#46851](https://github.com/supabase/supabase/pull/46851) 中使用了本地 PostgreSQL 不支持的 `IFNULL`，
将代码中的 `IFNULL` 替换成 `COALESCE` 再构建 studio 镜像，之后使用新镜像就不会出现 500 错误了。

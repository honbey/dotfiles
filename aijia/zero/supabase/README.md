# Supabase (Self-hosting by Podman)

.supabase-version:

```
ref=self-hosted/v0.7.2
```

使用 Podman 部署的 Supabase，改动了 `docker-compose.yml, docker-compose.logs.yml, docker-compose.rustfs.yml`，
主要是将日志 driver 改成 `k8s-file`，并将其持久化到宿主机的日志目录方便 `vector` 采集，
`vector.yml` 适应 Podman 的 ctr 日志进行适配改动从而可以正确解析日志。

## supabase-analytics auth_logs 返回 500

原因是 [Supabase PR#46851](https://github.com/supabase/supabase/pull/46851) 中使用了本地 PostgreSQL 不支持的 `IFNULL`，
将代码中的 `IFNULL` 替换成 `COALESCE` 再构建 studio 镜像，之后使用新镜像就不会出现 500 错误了。

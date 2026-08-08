# Supabase (Self-hosting by Podman)

.supabase-version:

```
ref=self-hosted/v0.7.2
```

使用 Podman 部署的 Supabase，改动了 `docker-compose.yml, docker-compose.logs.yml, docker-compose.rustfs.yml`，
主要是将日志 driver 改成 `k8s-file`，并将其持久化到宿主机的日志目录方便 `vector` 采集，
`vector.yml` 适应 Podman 的 ctr 日志进行适配改动从而可以正确解析日志。

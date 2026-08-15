# Kanidm

记录下 Kanidm 容器配置和一些命令行操作。

## `kanidm` (CLI)

获取 admin 和 idm_admin 的密码：

```bash
podman exec kanidm kanidmd recover-account admin
podman exec kanidm kanidmd recover-account idm_admin
```

编辑 `~/.config/kanidm` 以便简化 `kanidm` 命令：

```toml
uri = "https://idm.example.com:8443"
verify_ca = true
```

如果没有 uri 配置则需使用 `kanidm -H https://idm.example.com:8443` 进行操作。

使用 `kanidm-mail-sender` 前先创建一个 service account 再获取 token 以便查询邮件队列：

```bash
kanidm login -D idm_admin
kanidm service-account create mail-sender "Mail Sender" idm_admin
kanidm group add-members idm_message_senders mail-sender
kanidm service-account api-token generate mail-sender "mail sender token" --readwrite
```

发送测试邮件(`-c` 相当于指定上面的 `~/.config/kanidm`)：

```bash
kanidm-mail-sender -c /config/kanidm.toml -m /config/mail-sender.toml -t honbey@qq.com
```

创建用户：

```bash
kanidm login -D idm_admin
kanidm person create zhang "Admin Zhang"
kanidm person credential create-reset-token zhang

kanidm group add-members idm_people_self_mail_write zhang --name idm_admin
```

开启账户恢复功能（使用 `admin` 账号）：

```bash
kanidm login -D admin
kanidm system domain set-allow-account-recovery true
```

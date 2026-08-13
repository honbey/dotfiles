# Agents

AI Agent with Large Models.

## Nanobot

- [Project Page](https://nanobot.wiki)
- [Source Code](https://github.com/HKUDS/nanobot)

### Memos

Builds podman/docker image:

```bash
podman build -t nanobot:tag -f Dockerfile nanobot
```

Generates config & workspace:

```bash
podman-compose run --rm nanobot-test onboard --config /nanobot/config.json --workspace /nanobot/workspace
```

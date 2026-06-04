FROM debian:trixie-slim

ARG USE_PROXY="false"
ARG PROXY_IP="host.containers.internal"
ARG PROXY_PORT=1080

RUN --mount=type=cache,target=/var/cache/apt \
  --mount=type=cache,target=/var/lib/apt/lists \
  mv /etc/apt/sources.list.d/debian.sources /etc/apt/sources.list.d/debian.sources.bak && \
  echo "Types: deb deb-src" > /etc/apt/sources.list.d/debian.sources && \
  echo "URIs: http://mirrors.ustc.edu.cn/debian" >> /etc/apt/sources.list.d/debian.sources && \
  echo "Suites: trixie trixie-updates trixie-backports" >> /etc/apt/sources.list.d/debian.sources && \
  echo "Components: main contrib non-free non-free-firmware" >> /etc/apt/sources.list.d/debian.sources && \
  echo "Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg" >> /etc/apt/sources.list.d/debian.sources && \
  echo "" >> /etc/apt/sources.list.d/debian.sources && \
  echo "Types: deb deb-src" >> /etc/apt/sources.list.d/debian.sources && \
  echo "URIs: http://mirrors.ustc.edu.cn/debian-security" >> /etc/apt/sources.list.d/debian.sources && \
  echo "Suites: trixie-security" >> /etc/apt/sources.list.d/debian.sources && \
  echo "Components: main contrib non-free non-free-firmware" >> /etc/apt/sources.list.d/debian.sources && \
  echo "Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg" >> /etc/apt/sources.list.d/debian.sources && \
  apt-get update && \
  apt-get install -y --no-install-recommends build-essential curl ca-certificates file git && \
  apt-get install -y --no-install-recommends locales && \
  sed -i '/^# *en_US.UTF-8 /s/^# //' /etc/locale.gen && \
  locale-gen && \
  useradd -m -s /bin/bash linuxbrew && \
  echo 'linuxbrew ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

ENV LANG=en_US.UTF-8 \
  LC_ALL=en_US.UTF-8

USER linuxbrew
WORKDIR /home/linuxbrew

RUN if [ "$USE_PROXY" = "true" ]; then \
    ( \
      export all_proxy=http://${PROXY_IP}:${PROXY_PORT}; \
      export http_proxy=http://${PROXY_IP}:${PROXY_PORT}; \
      export https_proxy=http://${PROXY_IP}:${PROXY_PORT}; \
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
    ); \
  else \
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
  fi; touch .linuxbrew/.homebrewdocker

ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}" \
  HOMEBREW_PREFIX=/home/linuxbrew/.linuxbrew \
  HOMEBREW_CELLAR=/home/linuxbrew/.linuxbrew/Cellar \
  HOMEBREW_REPOSITORY=/home/linuxbrew/.linuxbrew/Homebrew \
  XDG_CACHE_HOME=/home/linuxbrew/.cache

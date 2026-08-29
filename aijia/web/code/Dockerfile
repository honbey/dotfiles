FROM codercom/code-server:latest

USER root

RUN mv /etc/apt/sources.list.d/debian.sources /etc/apt/sources.list.d/debian.sources.bak && \
    echo 'Types: deb\n\
URIs: http://mirrors.ustc.edu.cn/debian\n\
Suites: trixie trixie-updates trixie-backports\n\
Components: main contrib non-free non-free-firmware\n\
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg' > /etc/apt/sources.list.d/debian.sources && \
    echo 'Types: deb\n\
URIs: http://mirrors.ustc.edu.cn/debian-security\n\
Suites: trixie-security\n\
Components: main contrib non-free non-free-firmware\n\
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg' > /etc/apt/sources.list.d/debian-security.sources && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends file libicu76 lsof && \
    apt-get install -y --no-install-recommends llvm clang libclang-dev && \
    apt-get install -y --no-install-recommends tmux && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

WORKDIR /root

EXPOSE 8080 22

ENTRYPOINT ["/usr/bin/entrypoint.sh", "--bind-addr", "0.0.0.0:8080", "."]

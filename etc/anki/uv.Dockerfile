FROM ghcr.io/astral-sh/uv:python3.14-trixie-slim

USER root
ENV HOME=/root \
    PIP_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple \
    PIP_TRUSTED_HOST=pypi.tuna.tsinghua.edu.cn \
    UV_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple

WORKDIR /data

RUN uv pip install --no-cache --system anki

COPY uv.entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV SYNC_BASE=/data \
    SYNC_HOST=0.0.0.0 \
    SYNC_PORT=8080

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]

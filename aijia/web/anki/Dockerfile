FROM rust:1.92.0-alpine3.23 AS builder

ARG ANKI_VERSION

RUN apk update && apk add --no-cache build-base protobuf && rm -rf /var/cache/apk/*

ARG http_proxy
ARG https_proxy

RUN cargo install --git https://ghfast.top/https://github.com/ankitects/anki.git \
--tag ${ANKI_VERSION} \
--root /anki-server  \
--locked \
anki-sync-server

FROM alpine:3.23

COPY --from=builder /anki-server/bin/anki-sync-server /usr/local/bin/anki-sync-server


RUN apk update && apk add --no-cache bash su-exec && rm -rf /var/cache/apk/*

USER root

ENV SYNC_BASE=/data \
    SYNC_HOST=0.0.0.0 \
    SYNC_PORT=8080

CMD ["anki-sync-server"]

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget -qO- http://127.0.0.1:8080/health || exit 1

VOLUME /data

EXPOSE 8080

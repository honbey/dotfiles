#!/bin/sh
set -eu

# code-server entrypoint.sh
eval "$(fixuid -q)"

if [ -d "${ENTRYPOINTD}" ]; then
  find "${ENTRYPOINTD}" -type f -executable -print -exec {} \;
fi

exec dumb-init /usr/bin/code-server "$@"

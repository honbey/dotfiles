if command -v podman &>/dev/null; then
  function pexec() {
    podman exec -it ${1} ${2:-/bin/bash}
  }

  function plog() {
    podman logs --follow --tail="${2:-10}" ${1}
  }
fi

# need Nginx and export NGINX_HOME in ~/.local.zsh
if command -v nginx &>/dev/null && declare -p NGINX_HOME &>/dev/null; then
  alias nginx="nginx -c ${NGINX_HOME}"
  alias ngx="nginx -c ${NGINX_HOME}"
  alias ng="nginx -c ${NGINX_HOME}"
fi

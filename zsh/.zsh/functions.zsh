# Update local snippets.
#   *return null
function update_local_snippets() {
  if [[ -z ${ZSH_HOME} ]]; then
    ZSH_HOME="${HOME}/.zsh"
  fi
  local ZI_SNIPPETS_PATH
  ZI_SNIPPETS_PATH=${ZSH_HOME#/}
  ZI_SNIPPETS_PATH=${ZI_SNIPPETS_PATH//\//--}
  for i in $(ls ${ZSH_HOME}/[^_]*.zsh); do
    zinit update "${ZI_SNIPPETS_PATH}/$(basename ${i})"
  done
}

# Use rsync to implement cp and scp, like OMZ's cpv.
#   $@ string: file or directory
#   *return null
function rcp() {
  rsync -ahv --backup-dir="/tmp/rsync-${USERNAME}" --progress "$@"
}
compdef _files rcp
function scp() {
  rsync -ahv -z --progress "$@"
}
compdef _files scp

# Set or unset proxy environment.
#   $1 string: proxy protocol, default http
#   $2 string: proxy address, default 127.0.0.1
#   $3 int: proxy port, default 1080
#   *return null
function set_proxy() {
  export ALL_PROXY="${1:-http}://${2:-127.0.0.1}:${3:-1080}"
  export HTTP_PROXY="${ALL_PROXY}"
  export HTTPS_PROXY="${ALL_PROXY}"
}
function unset_proxy() {
  unset ALL_PROXY HTTP_PROXY HTTPS_PROXY
}

function check_proxy() {
  if [[ -n ${ALL_PROXY} || -n ${HTTP_PROXY} || -n ${HTTPS_PROXY} ]]; then
    echo "Proxy: ALL=${ALL_PROXY}, HTTP=${HTTP_PROXY}, HTTPS=${HTTPS_PROXY}"
  else
    echo "Not set proxy."
  fi
}

# Emacs-like keymaps
bindkey -e
# let Ctrl+U clear the text before cursor
bindkey "^U" backward-kill-line
# No 0.4s wait for a second key after ESC (default 40).
KEYTIMEOUT=1

# bare directory name = cd
setopt autocd
setopt nobeep
# complete mid-word
setopt completeinword
setopt alwaystoend
setopt no_auto_remove_slash

# Aliases
alias cp='cp -iv'
alias diff='diff --color=auto'
# `..` is covered by autocd; `...` is not a directory, so keep the alias.
# `mv` is `smart_mv -v`, aliased in wait1-functions.zsh where the function lives.
alias ...='cd ../..'
alias :q='exit' :wq='exit'

# ENV
[[ -f "${HOME}/.env" ]] && source "${HOME}/.env"
# Custom config for specific machine
[[ -f "${HOME}/.local.zsh" ]] && source "${HOME}/.local.zsh"

### Functions
# Add path to PATH, like fish's `add_user_path`.
#   $1 string: directory path
#   $2 string: "tail" or null, control whether to append the path to the end of PATH
#   * return int
function add_path() {
  [[ -d "$1" ]] || return -1

  local new_path
  new_path="$1"

  if [[ ":${PATH}:" == *":${new_path}:"* ]]; then
    return 0
  fi

  if [[ "$2" == "tail" ]]; then
    export PATH="${PATH}:${new_path}"
    return 0
  else
    export PATH="${new_path}:${PATH}"
    return 0
  fi
}
# .local/bin
[[ -d "${HOME}/.local/bin" ]] && add_path "${HOME}/.local/bin"

function add_fpath() {
  [[ -d "$1" ]] || return -1

  local new_fpath
  new_fpath="$1"

  if [[ ":${FPATH}:" == *":${new_fpath}:"* ]]; then
    return 0
  fi

  export FPATH="${new_fpath}:${FPATH}"
  return 0
}

# Beautify the output of PATH and FPATH.
#   *return null
function show_path() {
  echo ${PATH//:/\\n}
}
function show_fpath() {
  echo ${FPATH//:/\\n}
}

# eval
function _cached_eval() {
  local tool_name="$1"
  local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
  local cache_file="$cache_dir/${tool_name}.zsh"
  if [[ ! -s "$cache_file" ]] || [[ "${commands[$tool_name]}" -nt "$cache_file" ]]; then
    mkdir -p "$cache_dir"
    shift
    # Temp file: a failed init must not poison the cache.
    local tmp="${cache_file}.$$"
    if "$@" >"$tmp" 2>/dev/null && [[ -s "$tmp" ]]; then
      command mv -f "$tmp" "$cache_file"
    else
      command rm -f "$tmp"
      [[ -s "$cache_file" ]] || return 1
    fi
  fi
  source "$cache_file"
}

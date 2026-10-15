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
  if [[ ! -f "$cache_file" ]] || [[ "$(command -v "$tool_name")" -nt "$cache_file" ]]; then
    mkdir -p "$cache_dir"
    shift
    "$@" >"$cache_file"
  fi
  source "$cache_file"
}

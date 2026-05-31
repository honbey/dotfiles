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

# Beautify the output of PATH and FPATH.
#   *return null
function show_path() {
  echo ${PATH//:/\\n}
}
function show_fpath() {
  echo ${FPATH//:/\\n}
}

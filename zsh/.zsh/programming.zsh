### Python
# Acticate Python virtual environments.
#   $1 string: name of venv
#   $2 string: path of venv
#   *return null
function ap() {
  if [[ -z "$1" ]]; then
    if [[ -d ./venv ]]; then
      source "./venv/bin/activate"
    elif [[ -d ./.venv ]]; then
      source "./.venv/bin/activate"
    else
      echo "No virtual env!"
    fi
    return
  fi
  if [[ -z "$2" ]]; then
    PYVENV_PATH="${DATA_DIR}/pyvenv"
  else
    PYVENV_PATH="$2"
  fi
  source "${PYVENV_PATH}/$1/bin/activate"
}
_ap() {
  local -a venvs
  local venvs=($(find ${HOME}/.venv -mindepth 1 -maxdepth 1 -type d |
    awk -v FS='/' '{printf "%s\n", $NF}'))
  _describe 'virtual environments' venvs
}
compdef _ap ap
# Pip
# Use mirror to speed pip.
#   $1 string: name of mirrors
#   $2... string: other params to pip
#   *return null
function pipm() {
  if [[ -z "$1" ]]; then
    pip3 -i https://pypi.tuna.tsinghua.edu.cn/simple "$@"
  else
    shift
    if [[ "$1" == 'tsinghua' ]]; then
      pip3 -i https://pypi.tuna.tsinghua.edu.cn/simple "$@"
    elif [[ "$1" == 'ustc' ]]; then
      pip3 -i https://mirrors.ustc.edu.cn/pypi/simple "$@"
    elif [[ "$1" == 'ali' ]]; then
      pip3 -i https://mirrors.aliyun.com/pypi/simple "$@"
    fi
  fi
}
alias pip='pip3'

### Rust
if type rustup &>/dev/null; then
  export CARGO_HOME="${HOME}/.cargo"
  export RUSTUP_HOME="${HOME}/.rustup"
  add_path "${CARGO_HOME}/bin"
fi

### Golang
if type go &>/dev/null; then
  export GOPATH="${HOME}/.go"
  add_path "${GOPATH}/bin"
fi

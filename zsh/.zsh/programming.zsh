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
  export CARGO_NET_GIT_FETCH_WITH_CLI=true
  export CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse
  if [[ -f "${CARGO_HOME}/bin/sccache" ]]; then
    export CARGO_BUILD_RUSTC_WRAPPER="${CARGO_HOME}/bin/sccache"
  fi
  if [[ -d "${RUSTUP_HOME}/toolchains/stable-x86_64-unknown-linux-gnu" && "${OSTYPE}" == "linux-gnu" ]]; then
    add_path "${RUSTUP_HOME}/toolchains/stable-x86_64-unknown-linux-gnu/bin"
  fi
  add_path "${CARGO_HOME}/bin"

  # Set mirror of Rust to escalate download speed.
  #   $1 string: mirror's name, support lists: ["official"(default), "rsproxy", "tuna", "ustc", "ali"]
  #   *return null
  function rust_mirror_on() {
    local mirror="${1:-official}"
    case "${mirror}" in
    official)
      ln -sfn "config.toml.official" "${HOME}/.cargo/config.toml"
      unset RUSTUP_DIST_SERVER RUSTUP_UPDATE_ROOT
      ;;
    rsproxy)
      ln -sfn "config.toml.rsproxy" "${HOME}/.cargo/config.toml"
      export RUSTUP_DIST_SERVER="https://rsproxy.cn"
      export RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"
      ;;
    tuna)
      ln -sfn "config.toml.tuna" "${HOME}/.cargo/config.toml"
      export RUSTUP_DIST_SERVER="https://mirrors.tuna.tsinghua.edu.cn/rustup"
      export RUSTUP_UPDATE_ROOT="https://mirrors.tuna.tsinghua.edu.cn/rustup"
      ;;
    ustc)
      ln -sfn "config.toml.ustc" "${HOME}/.cargo/config.toml"
      export RUSTUP_DIST_SERVER="https://mirrors.ustc.edu.cn/rust-static"
      export RUSTUP_UPDATE_ROOT="https://mirrors.ustc.edu.cn/rust-static"
      ;;
    ali)
      ln -sfn "config.toml.ali" "${HOME}/.cargo/config.toml"
      ;;
    *)
      echo 'Please provide mirror name, only support "official", "rsproxy", "tuna", "ustc" or "ali" now.'
      ;;
    esac
  }

  # Switch Rust back to official sources.
  #   *return null
  function rust_mirror_off() {
    rust_mirror_on official
  }

  rust_mirror_on rsproxy
fi

### Golang
if type go &>/dev/null; then
  export GOPATH="${HOME}/.go"
  add_path "${GOPATH}/bin"
fi

### OpenCode
if type opencode &>/dev/null; then
  export OPENCODE_DISABLE_LSP_DOWNLOAD=true
  export OPENCODE_DISABLE_CLAUDE_CODE=1
fi

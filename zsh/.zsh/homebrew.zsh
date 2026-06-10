### Homebrew
# manual `brew shellenv`
if [[ -d /opt/homebrew/bin ]]; then # macOS
  export HOMEBREW_PREFIX="/opt/homebrew"
  export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
  export HOMEBREW_REPOSITORY="/opt/homebrew/Homebrew"
  add_path "/opt/homebrew/sbin"
  add_fpath "/opt/homebrew/share/zsh/site-functions"
  add_path "/opt/homebrew/opt/coreutils/libexec/gnubin"
  add_path "/opt/homebrew/opt/gnu-sed/libexec/gnubin"
  [ -z "${MANPATH-}" ] || export MANPATH=":${MANPATH#:}"
  export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"
elif [[ -d /home/linuxbrew/.linuxbrew ]]; then
  export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
  export HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar"
  export HOMEBREW_REPOSITORY="/home/linuxbrew/.linuxbrew/Homebrew"
  add_path "/home/linuxbrew/.linuxbrew/sbin"
  add_fpath "/home/linuxbrew/.linuxbrew/share/zsh/site-functions"
  [ -z "${MANPATH-}" ] || export MANPATH=":${MANPATH#:}"
  export INFOPATH="/home/linuxbrew/.linuxbrew/share/info:${INFOPATH:-}"
fi

# Set mirror of Homebrew to escalate download speed.
#   $1 string: mirror's name, support lists: ["tsinghua", "ustc", "ali"]
#   *return null
function set_brew_mirror() {
  type brew &>/dev/null || (echo "Please install Homebrew!" && return)
  export HOMEBREW_INSTALL_FROM_API=1
  if [[ "$1" == "tsinghua" ]]; then
    export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
    export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
    export HOMEBREW_PIP_INDEX_URL="https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple"
  elif [[ "$1" == "ustc" ]]; then
    export HOMEBREW_API_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles/api"
    export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"
  elif [[ "$1" == "ali" ]]; then
    export HOMEBREW_API_DOMAIN="https://mirrors.aliyun.com/homebrew-bottles/api"
    export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.aliyun.com/homebrew/homebrew-bottles"
  else
    echo 'Please provide mirror name, only support "tsinghua", "ustc" or "ali" now.'
  fi
}

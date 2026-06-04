### Homebrew
if [[ -d /opt/homebrew/bin ]]; then # macOS
  add_path "/opt/homebrew/opt/coreutils/libexec/gnubin"
  add_path "/opt/homebrew/opt/gnu-sed/libexec/gnubin"
fi

# Set mirror of Homebrew to escalate download speed.
# Because the Tsinghua mirror can not be accessed in some public WiFi.
# The HOMEBREW_BREW_GIT_REMOTE's PATH is different in different mirror.
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

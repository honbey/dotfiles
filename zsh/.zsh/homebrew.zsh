### Homebrew
if [[ -d /opt/homebrew || -d /home/linuxbrew ]]; then
  export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
  export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
  export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
  #export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
  export HOMEBREW_PIP_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple"

  if [[ -d /opt/homebrew/bin ]]; then # macOS
    add_path "/opt/homebrew/opt/coreutils/libexec/gnubin"
    add_path "/opt/homebrew/opt/gnu-sed/libexec/gnubin"
  fi
fi

# Change the mirror of Homebrew to escalate download speed.
# Because the Tsinghua mirror can not be accessed in some public WiFi.
# The HOMEBREW_BREW_GIT_REMOTE's PATH is different in different mirror.
#   $1 string: mirror's name, support lists: ["ustc", "ali"]
#   *return null
function change_brew_mirror() {
  type brew &>/dev/null || (echo "Please install Homebrew!" && return)
  local MIRROR_URL
  if [[ "$1" == "ustc" ]]; then
    MIRROR_URL='https://mirrors.ustc.edu.cn'
    export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"
    #export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.ustc.edu.cn/homebrew-core.git"
  elif [[ "$1" == "ali" ]]; then
    MIRROR_URL='https://mirrors.aliyun.com'
    export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.aliyun.com/homebrew/brew.git"
    #export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.aliyun.com/homebrew/homebrew-core.git"
  else
    echo 'Please provide mirror name, only support "ustc" or "ali" now.'
  fi
  export HOMEBREW_API_DOMAIN="${MIRROR_URL}/homebrew-bottles/api"
  export HOMEBREW_BOTTLE_DOMAIN="${MIRROR_URL}/homebrew-bottles"
  export HOMEBREW_PIP_INDEX_URL="${MIRROR_URL}/pypi/simple"
}

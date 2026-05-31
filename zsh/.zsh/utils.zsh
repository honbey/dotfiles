### GnuPG
if type gpg &>/dev/null; then
  # aliases
  alias gnupg='gpg'

  [[ -d "${HOME}/.gnupg" ]] || mkdir ${HOME}/.gnupg

  # GPG-Agent
  # Reference:
  #   https://www.gnupg.org/documentation/manuals/gnupg/Agent-Options.html
  #   https://wiki.archlinux.org/title/GnuPG#SSH_agent
  #   https://github.com/NeogitOrg/neogit/blob/master/doc/neogit.txt#L323
  if ! pgrep -x -u "${USER}" gpg-agent >/dev/null 2>&1; then
    gpg-connect-agent /bye >/dev/null 2>&1
  fi

  # Set SSH to use gpg-agent
  unset SSH_AGENT_PID
  if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  fi
  # gpgconf --launch gpg-agent

  export GPG_TTY="$(tty)"

  # Refresh gpg-agent tty in case user switches into an X session
  gpg-connect-agent updatestartuptty /bye >/dev/null

  if ! [[ -f "${HOME}/.gnupg/gpg.conf" ]]; then
    echo -e 'pinentry-mode loopback' >"${HOME}/.gnupg/gpg.conf"
  fi
  if ! [[ -f "${HOME}/.gnupg/gpg-agent.conf" ]]; then
    if [[ -d /opt/homebrew ]]; then
      echo -e "enable-ssh-support\npinentry-program /opt/homebrew/bin/pinentry-tty\nallow-loopback-pinentry" \
        >"${HOME}/.gnupg/gpg-agent.conf"
    elif [[ -d /home/linuxbrew ]]; then
      echo -e "enable-ssh-support\npinentry-program /home/linuxbrew/.linuxbrew/bin/pinentry-tty\nallow-loopback-pinentry" \
        >"${HOME}/.gnupg/gpg-agent.conf"
    fi
  fi
fi

### Git
# aliases
alias g='git'
alias ga='git add'
alias gc='git commit'
alias gca='git commit --amend'
alias gcs='git commit -S'
alias gcsa='git commit -S --amend'
alias gp='git push'
alias gl='git pull'
alias gpm='git push origin main'
alias glm='git pull origin main'
alias gst='git status'
alias glog='git log'
alias glogc='git logc'
alias gck='git checkout'
alias gb='git branch'
alias gt='git tag'
alias gd='git diff'

### Vim/NeoVim
if type nvim &>/dev/null; then
  alias vi='nvim' vim='nvim'
  export EDITOR=nvim
  [[ -d "${HOME}/.local/share/nvim/mason/bin" ]] && add_path "${HOME}/.local/share/nvim/mason/bin"
elif type vim &>/dev/null; then
  alias vi='vim' vim='vim'
  export EDITOR=vim
fi

### rm-improved
# Safe rm
alias del="rip -i --graveyard /opt/data/graveyard" trash="rip -i --graveyard /opt/data/graveyard"
alias rm="echo Use 'del', or the full path i.e. '/bin/rm'."

### FZF
type fzf &>/dev/null && eval "$(fzf --zsh)"

### Zoxide
type zoxide &>/dev/null && eval "$(zoxide init zsh | sed 's/function zi()/function zd()/')"

### Yazi
# Provide the ability to change the current working directory when exiting Yazi.
# Reference: [yazi - quick-start](https://yazi-rs.github.io/docs/quick-start).
#   *return null
# function y() {
#   local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
#   yazi "$@" --cwd-file="${tmp}"
#   IFS= read -r -d '' cwd <"${tmp}"
#   [ -n "${cwd}" ] && [ "${cwd}" != "${PWD}" ] && builtin cd -- "${cwd}"
#   rm -f -- "${tmp}"
# }

# Use yazi to browser directory and file.
#   *return null
function y() {
  yazi "$@"
}

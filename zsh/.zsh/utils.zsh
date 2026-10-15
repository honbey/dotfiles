### GnuPG
if command -v gpg &>/dev/null; then
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
    if [[ -f /opt/homebrew/bin/pinentry-tty ]]; then
      echo -e "enable-ssh-support\npinentry-program /opt/homebrew/bin/pinentry-tty\nallow-loopback-pinentry" \
        >"${HOME}/.gnupg/gpg-agent.conf"
    elif [[ -f /usr/bin/pinentry ]]; then
      echo -e "enable-ssh-support\npinentry-program /usr/bin/pinentry\nallow-loopback-pinentry" \
        >"${HOME}/.gnupg/gpg-agent.conf"
    elif [[ -f /home/linuxbrew/.linuxbrew/bin/pinentry-tty ]]; then
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
if command -v nvim &>/dev/null; then
  alias vi='nvim' vim='nvim'
  export EDITOR=nvim
  [[ -d "${HOME}/.local/share/nvim/mason/bin" ]] && add_path "${HOME}/.local/share/nvim/mason/bin"
elif command -v vim &>/dev/null; then
  alias vi='vim' vim='vim'
  export EDITOR=vim
fi

### rm-improved
# Safe rm
alias del="rip -i --graveyard ${HOME}/.graveyard" trash="rip -i --graveyard ${HOME}/.graveyard"
alias rm="echo Use 'del', or the full path i.e. '/bin/rm'."

### FZF
(($+commands[fzf])) && _cached_eval fzf fzf --zsh

### Zoxide
if command -v zoxide &>/dev/null; then
  # Patterns are separated by colons (zoxide 0.10 parses them with
  # env::split_paths; space-separated values silently disable exclusion).
  export _ZO_EXCLUDE_DIRS="\
/tmp:/var:/proc:/sys:\
${HOME}/.cache:${HOME}/.npm:${HOME}/.cargo:${HOME}/.rustup:\
${HOME}/**/target:${HOME}/**/node_modules:${HOME}/**/dist:${HOME}/**/build:"
  (($+commands[zoxide])) && _cached_eval zoxide zoxide init zsh
fi

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

### ls/eza
if command -v eza &>/dev/null; then
  alias ls='eza --group-directories-first'
  alias la='eza -A --group-directories-first'
  alias ll='eza -Alh --group-directories-first --git'
  alias l.='eza -d .*'
  alias l='eza -alF --group-directories-first'
else
  alias ls='ls --color=auto'
  alias la='ls -A'
  alias ll='ls -Ahl'
  alias l.='ls -d .*'
  alias l='ls -alF'
fi

#alias ls='ls --color=auto' la='ls -A' ll='ls -Ahl' l.='ls -d .*' l='ls -alF'
### grep/ripgrep
if command -v rg &>/dev/null; then
  alias grep='rg --no-line-number --no-heading --with-filename'
else
  alias grep='grep --color=auto'
fi

### dl: du/dust
if command -v dust &>/dev/null; then
  alias dl='dust -d 1'
else
  alias dl='du -h --max-depth=1'
fi

### calculator
function c() {
  local scale="${BC_SCALE:-10}"
  bc -l <<<"scale=$scale; $*"
}

### GnuPG
# Write the gpg config files once.
#   *return null
function gpg_init_conf() {
  local dir="${GNUPGHOME:-${HOME}/.gnupg}"
  local pinentry

  [[ -f "${dir}/gpg.conf" ]] ||
    print -r -- 'pinentry-mode loopback' >"${dir}/gpg.conf"

  [[ -f "${dir}/gpg-agent.conf" ]] && return 0
  for pinentry in /opt/homebrew/bin/pinentry-tty \
    /usr/bin/pinentry /home/linuxbrew/.linuxbrew/bin/pinentry-tty; do
    [[ -f "${pinentry}" ]] && break
    pinentry=""
  done
  [[ -n "${pinentry}" ]] || return 0
  print -r -- "enable-ssh-support
pinentry-program ${pinentry}
allow-loopback-pinentry" >"${dir}/gpg-agent.conf"
}

# Point ssh at the agent socket and refresh its tty for this shell.
# Reference:
#   https://www.gnupg.org/documentation/manuals/gnupg/Agent-Options.html
#   https://wiki.archlinux.org/title/GnuPG#SSH_agent
#   *return null
function gpg_agent_setup() {
  local dir="${GNUPGHOME:-${HOME}/.gnupg}"
  local ssh_socket

  [[ -d "${dir}" ]] || command mkdir -p "${dir}"
  [[ -f "${dir}/gpg.conf" && -f "${dir}/gpg-agent.conf" ]] || gpg_init_conf

  # Default path; ask gpgconf only when the socket is elsewhere.
  ssh_socket="${dir}/S.gpg-agent.ssh"
  if [[ ! -S "${ssh_socket}" ]]; then
    ssh_socket="$(gpgconf --list-dirs agent-ssh-socket 2>/dev/null)"
  fi

  unset SSH_AGENT_PID
  [[ -n "${ssh_socket}" ]] && export SSH_AUTH_SOCK="${ssh_socket}"

  export GPG_TTY="${TTY:-$(tty 2>/dev/null)}" # $TTY: no fork, unlike `tty`

  # Also starts the agent if needed.
  [[ -t 0 && -n "${GPG_TTY}" ]] &&
    gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1
}

if (( $+commands[gpg] )); then
  alias gnupg='gpg'
  gpg_agent_setup
fi


### Podman
if (( $+commands[podman] )); then
  function pexec() {
    podman exec -it "${1}" "${2:-/bin/bash}"
  }

  function plog() {
    podman logs --follow --tail="${2:-10}" "${1}"
  }
fi

### Nginx
# need Nginx and export NGINX_HOME in ~/.local.zsh
if (( $+commands[nginx] )) && declare -p NGINX_HOME &>/dev/null; then
  alias nginx="nginx -c ${NGINX_HOME}"
  alias ngx="nginx -c ${NGINX_HOME}"
  alias ng="nginx -c ${NGINX_HOME}"
fi

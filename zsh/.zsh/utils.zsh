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
if (( $+commands[nvim] )); then
  alias vi='nvim' vim='nvim'
  export EDITOR=nvim
  [[ -d "${HOME}/.local/share/nvim/mason/bin" ]] && add_path "${HOME}/.local/share/nvim/mason/bin"
elif (( $+commands[vim] )); then
  alias vi='vim' vim='vim'
  export EDITOR=vim
fi

### rm-improved
# Safe rm
alias del="rip -i --graveyard ${HOME}/.graveyard" trash="rip -i --graveyard ${HOME}/.graveyard"
alias rm="echo Use 'del', or the full path i.e. '/bin/rm'."

### FZF
(( $+commands[fzf] )) && _cached_eval fzf fzf --zsh

### Zoxide
if (( $+commands[zoxide] )); then
  # Patterns are separated by colons (zoxide 0.10 parses them with
  # env::split_paths; space-separated values silently disable exclusion).
  export _ZO_EXCLUDE_DIRS="\
/tmp:/var:/proc:/sys:\
${HOME}/.cache:${HOME}/.npm:${HOME}/.cargo:${HOME}/.rustup:\
${HOME}/**/target:${HOME}/**/node_modules:${HOME}/**/dist:${HOME}/**/build:"
  _cached_eval zoxide zoxide init zsh
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
if (( $+commands[eza] )); then
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

### grep/ripgrep
# Translate the grep flags rg spells differently, hand the rest to real grep.
function grep() {
  emulate -L zsh
  if (( ! $+commands[rg] )); then
    command grep "$@"
    return
  fi
  local -a args
  local arg cleaned
  for arg in "$@"; do
    case "$arg" in
    (-E|--extended-regexp|-r|-R|--recursive) ;; # rg's defaults
    (-[A-Za-z]*)
      case "$arg" in
      (*h*) command grep "$@"; return ;; # grep -h: no filename
      (*)
        cleaned="${arg//[ErR]/}" # -E/-r/-R differ in rg
        [[ "$cleaned" == "-" ]] || args+=("$cleaned")
        ;;
      esac
      ;;
    (--*) command grep "$@"; return ;; # long options differ, let grep parse
    (*) args+=("$arg") ;;
    esac
  done
  command rg --no-line-number --no-heading --with-filename "${args[@]}"
}

### dl: du/dust
if (( $+commands[dust] )); then
  alias dl='dust -d 1'
else
  alias dl='du -h --max-depth=1'
fi

### calculator
function c() {
  local scale="${BC_SCALE:-10}"
  bc -l <<<"scale=$scale; $*"
}

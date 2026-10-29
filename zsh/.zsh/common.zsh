export LANG=C.UTF-8
export LC_ALL=C.UTF-8
export LANGUAGE=C.UTF-8

# Emacs-like keymaps
bindkey -e
# let Ctrl+U clear the text before cursor
bindkey "^U" backward-kill-line
# No 0.4s wait for a second key after ESC (default 40).
KEYTIMEOUT=1

setopt autocd          # bare directory name = cd
setopt nobeep
setopt completeinword  # complete mid-word
setopt alwaystoend
setopt no_auto_remove_slash

# Aliases
alias cp='cp -iv'
alias diff='diff --color=auto'
# `..` is covered by autocd; `...` is not a directory, so keep the alias.
# `mv` is `smart_mv -v`, aliased in wait1-functions.zsh where the function lives.
alias ...='cd ../..'
alias :q='exit' :wq='exit'

# ENV
[[ -f "${HOME}/.env" ]] && source "${HOME}/.env"
# Custom config for specific machine
[[ -f "${HOME}/.local.zsh" ]] && source "${HOME}/.local.zsh"
# .local/bin
[[ -d "${HOME}/.local/bin" ]] && add_path "${HOME}/.local/bin"

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Emacs-like keymaps
bindkey -e
# let Ctrl+U clear the text before cursor
bindkey "^U" backward-kill-line

# Aliases
alias ls='ls --color=auto' la='ls -A' ll='ls -Ahl' l.='ls -d .*' l='ls -alF'
alias mv='mv -v' cp='cp -iv'
alias grep='grep --color=auto' diff='diff --color=auto'
alias ..='cd ..' ...='cd ../..'
alias :q='exit' :wq='exit'
alias dl='du -h --max-depth=1'

# History
setopt inc_append_history
setopt hist_find_no_dups
setopt hist_ignore_all_dups
setopt hist_reduce_blanks
setopt hist_save_no_dups

# Custom config for specific machine
[[ -f "${ZSH_HOME}/.zsh.local" ]] && source "${ZSH_HOME}/.zsh.local"

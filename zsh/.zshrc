# Install zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[[ ! -d "${ZINIT_HOME}" ]] && mkdir -p "$(dirname ${ZINIT_HOME})"
[[ ! -d "${ZINIT_HOME}/.git" ]] && git clone https://github.com/zdharma-continuum/zinit.git "${ZINIT_HOME}"
source "${ZINIT_HOME}/zinit.zsh"

### My configs
# Specific zsh config's directory
ZSH_HOME="${HOME}/.zsh"
# The function need loaded as soon as possible
zinit ice lucid
zinit snippet "${ZSH_HOME}/99-functions.zsh"

# Homebrew/Linuxbrew
[[ -d /opt/homebrew/bin ]] && add_path "/opt/homebrew/bin"
[[ -d /home/linuxbrew/.linuxbrew/bin ]] && add_path "/home/linuxbrew/.linuxbrew/bin"

# Load starship theme
(($+commands[starship])) && _cached_eval starship starship init zsh

# Sourced early: locale, keymap and aliases are needed at the first prompt.
source "${ZSH_HOME}/common.zsh"

# Turbo mode
zinit wait lucid is-snippet for \
  nocompletions \
  "${ZSH_HOME}/utils.zsh" \
  "${ZSH_HOME}/homebrew.zsh" \
  "${ZSH_HOME}/functions.zsh" \
  "${ZSH_HOME}/programming.zsh"

# Wait~
zinit wait'1' lucid is-snippet for \
  nocompletions \
  "${ZSH_HOME}/wait1-functions.zsh" \
  "${ZSH_HOME}/wait1a-functions.zsh"
# Functions need to be executed
zinit wait'2' lucid is-snippet for \
  nocompletions \
  "${ZSH_HOME}/wait2-functions.zsh"

### Plugins(wait 0)
# Init completion here so Tab works at the first prompt; FSH only replays.
zicompinit

zinit wait lucid light-mode depth'1' for \
  atinit"zicdreplay" \
  zdharma-continuum/fast-syntax-highlighting \
  atload"_zsh_autosuggest_start" \
  zsh-users/zsh-autosuggestions \
  blockf atpull'zinit creinstall -q .' \
  zsh-users/zsh-completions \
  pick'autopair.zsh' \
  hlissner/zsh-autopair \
  has'fzf' \
  Aloxaf/fzf-tab

zinit pack for ls_colors

# Must be ready before the first prompt: autosuggestions reads $history.
# No inc_append_history: share_history already appends each command.
zinit lucid light-mode for \
  atinit"HIST_STAMPS=yyyy-mm-dd" \
  OMZL::history.zsh

setopt hist_find_no_dups
setopt hist_ignore_all_dups
setopt hist_reduce_blanks
setopt hist_save_no_dups

zinit wait lucid light-mode for \
  OMZL::clipboard.zsh \
  OMZL::compfix.zsh \
  OMZL::completion.zsh \
  OMZL::functions.zsh \
  OMZL::spectrum.zsh \
  OMZL::termsupport.zsh

### Plugins(wait 1)
zinit wait'1' lucid light-mode depth'1' for \
  voronkovich/gitignore.plugin.zsh

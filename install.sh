#!/usr/bin/env bash
set -euo pipefail

# INFO: PACKAGES NEED BE INSTALLED
# or use: ` stow pkg -t ~`
# stow # stow itself individually
PACKAGES+=(
  zsh ssh tmux ghostty
  git sqlite podman
  vim nvim
  python node
)
# Default settings
DOTFILES_DIR="${DOTFILES_DIR:-${HOME}/dotfiles}"
FIRST_RUN=false
DRY_RUN=false
VERBOSE=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

function info() { echo -e "${GREEN}[INFO]${NC}  $*"; }
function warn() { echo -e "${YELLOW}[WARN]${NC}  $*"; }
function err() { echo -e "${RED}[ERROR]${NC} $*"; }
function step() { echo -e "${CYAN}[STEP]${NC}  $*"; }

# Usage
function usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS] [STOW_PACKAGE...]

Bootstrap a machine with dotfiles and optional system provisioning.

Options:
  --first-run, -F    Install Homebrew (Tsinghua mirror) and packages via install_brew
  -d DIR, --dir DIR  Dotfiles directory (default: \${HOME}/dotfiles)
  -n, --dry-run      Dry run: pass -n to stow; also skip system changes
  -v, --verbose      Verbose: pass -v to stow; also print more details
  -h, --help         Show this help

Stow packages:
  If packages are given, only those are linked. Otherwise everything inside
  the dotfiles directory is linked.

Examples:
  $(basename "$0") --first-run          # Full setup
  $(basename "$0") -F                   # Same as above
  $(basename "$0") bash vim             # Only link bash and vim
EOF
}

# Map long options to short ones before getopts.
# An array keeps values containing spaces intact; `set -- $(...)` would
# word-split them, e.g. --dir="/path with space" would break.
args=()
for arg in "$@"; do
  case "${arg}" in
  --first-run) args+=(-F) ;;
  --dry-run) args+=(-n) ;;
  --verbose) args+=(-v) ;;
  --help) args+=(-h) ;;
  --dir=*) args+=(-d "${arg#*=}") ;;
  --dir) args+=(-d) ;;
  *) args+=("${arg}") ;;
  esac
done
# Guard the empty case: on bash < 4.4 a bare "${args[@]}" under `set -u` errors.
if [[ ${#args[@]} -gt 0 ]]; then
  set -- "${args[@]}"
else
  set --
fi

while getopts "Fd:nvh" opt; do
  case "${opt}" in
  F) FIRST_RUN=true ;;
  d) DOTFILES_DIR="${OPTARG}" ;;
  n) DRY_RUN=true ;;
  v) VERBOSE=true ;;
  h)
    usage
    exit 0
    ;;
  *)
    usage
    exit 1
    ;;
  esac
done
shift $((OPTIND - 1))

# Expand a leading ~ so that --dir=~/dotfiles works (the shell only expands an
# unquoted ~ outside of an assignment-style argument).
DOTFILES_DIR="${DOTFILES_DIR/#\~/$HOME}"

# Packages given on the command line take precedence over the default list,
# as documented in the usage text.
if [[ $# -gt 0 ]]; then
  PACKAGES=("$@")
fi

# Dependency checks
if ! command -v stow &>/dev/null && [[ ${FIRST_RUN} == false ]]; then
  err "GNU Stow is required but not found. Run with --first-run to install prerequisites."
  exit 1
fi

# Detect operating system
detect_os() {
  case "$(uname -s)" in
  Darwin) echo "macos" ;;
  Linux) echo "linux" ;;
  *)
    err "Unsupported OS: $(uname -s)"
    exit 1
    ;;
  esac
}

# First‑run provisioning
function first_run() {
  local os
  os=$(detect_os)
  step "Detected OS: ${os}"

  if ! command -v git &>/dev/null; then
    err "Git command not found."
    err 'Please install it using `sudo apt install git` (Debian GNU/Linux) or `xcode-select --install` (macOS).'
    exit 1
  fi

  if command -v brew &>/dev/null; then
    info "Homebrew is already installed, skipping installation."
  else
    step "Installing Homebrew via Tsinghua mirror for ${os}..."

    if ${DRY_RUN}; then
      info "[dry-run] Would clone and run Homebrew install script."
    else
      git clone --depth=1 https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/install.git /tmp/brew-install
      bash /tmp/brew-install/install.sh
      rm -rf /tmp/brew-install
    fi

    # Add Homebrew to PATH
    if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    elif [[ -x /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    info "Homebrew installed and added to PATH."
  fi

  if ! command -v brew &>/dev/null; then
    err "Brew command not found after installation. Please check your PATH and try again."
    exit 1
  fi

  # Package installation is delegated to install_brew, which owns the package
  # list and skips anything already provided by the OS or by Homebrew.
  local brew_script="${DOTFILES_DIR}/bin/.local/bin/install_brew"
  if [[ -x "${brew_script}" ]]; then
    step "Installing packages with install_brew..."
    local brew_args=()
    ${DRY_RUN} && brew_args+=("-n")
    ${VERBOSE} && brew_args+=("-v")
    "${brew_script}" "${brew_args[@]}"
  else
    warn "install_brew not found at ${brew_script}; skipping package installation"
    warn "run it manually after bootstrap: install_brew"
  fi

  info "First‑run provisioning completed."
}

# Optional shell change
function setup_shell() {
  if ${FIRST_RUN}; then
    step "Changing default shell to zsh (if not already)..."
    if [[ ${SHELL} != "$(which zsh)" ]]; then
      if ${DRY_RUN}; then
        info "[dry-run] Would run: chsh -s $(which zsh)"
      else
        chsh -s "$(which zsh)" || warn "Failed to change shell. You may need to do it manually."
      fi
    else
      info "Default shell is already zsh."
    fi
  fi
}

# Link dotfiles using stow
function link_dotfiles() {
  step "Linking dotfiles from ${DOTFILES_DIR} to ${HOME}"

  local stow_args=()
  ${DRY_RUN} && stow_args+=("-n")
  ${VERBOSE} && stow_args+=("--verbose=2")

  stow_args+=(-t "${HOME}" "${PACKAGES[@]}")

  # stow resolves package names against the current directory, so run it from
  # the dotfiles directory regardless of where this script was invoked from.
  # A subshell keeps the caller's working directory untouched.
  (
    cd "${DOTFILES_DIR}"
    stow "-D" "${stow_args[@]}"
    stow "${stow_args[@]}"
  )
}

# Main
function main() {
  info "Dotfiles Bootstrap ..."
  info "Dotfiles directory: ${DOTFILES_DIR}"
  ${FIRST_RUN} && info "First-run mode:     enabled"
  ${DRY_RUN} && info "Dry-run mode:       enabled"

  if [[ ! -d "${DOTFILES_DIR}" ]]; then
    err "dotfiles directory not found: ${DOTFILES_DIR}"
    exit 1
  fi

  if ${FIRST_RUN}; then
    first_run
  fi

  setup_shell
  link_dotfiles

  info "Bootstrap finished."
  if ${DRY_RUN}; then
    info "This was a dry run. No changes were made."
  fi
}

main "$@"

#!/usr/bin/env bash
set -euo pipefail

# Default settings
DOTFILES_DIR="${DOTFILES_DIR:-${HOME}/dotfiles}"
FIRST_RUN=false
DRY_RUN=false
VERBOSE=false
PACKAGES=()

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
  --first-run, -F    Install Homebrew (Tsinghua mirror) and essential packages
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

# Map long options to short ones before getopts
set -- $(
  for arg in "$@"; do
    case "${arg}" in
    --first-run) echo "-F" ;;
    --dir) echo "-d" ;;
    --dry-run) echo "-n" ;;
    --verbose) echo "-v" ;;
    --help) echo "-h" ;;
    *) echo "${arg}" ;;
    esac
  done
)

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

  step "Installing essential packages with Homebrew..."
  local common_packages=(git curl jq stow zsh)
  local mac_packages=(gnu-sed coreutils)

  for pkg in "${common_packages[@]}"; do
    if brew list --formula "${pkg}" &>/dev/null; then
      ${VERBOSE} && info "Package ${pkg} already installed, skipping."
    else
      if ${DRY_RUN}; then
        echo "[dry-run] brew install ${pkg}"
      else
        brew install "${pkg}"
      fi
    fi
  done

  if [[ ${os} == "macos" ]]; then
    for pkg in "${mac_packages[@]}"; do
      if brew list --formula "${pkg}" &>/dev/null; then
        ${VERBOSE} && info "Package ${pkg} already installed, skipping."
      else
        if ${DRY_RUN}; then
          echo "[dry-run] brew install ${pkg}"
        else
          brew install "${pkg}"
        fi
      fi
    done
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
  ${FIRST_RUN} && stow_args+=("-f")

  PACKAGES+=("zsh git nvim python ghostty")
  stow_args+=(-t "${HOME}" ${PACKAGES[@]})

  stow "-D" "${stow_args[@]}"
  stow "${stow_args[@]}"
}

# Main
function main() {
  info "Dotfiles Bootstrap ..."
  info "Dotfiles directory: ${DOTFILES_DIR}"
  ${FIRST_RUN} && info "First-run mode:     enabled"
  ${DRY_RUN} && info "Dry-run mode:       enabled"

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

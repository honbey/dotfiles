#!/usr/bin/env bash
set -euo pipefail

# Colors for output (matching the style of the root install.sh)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

TMUX_VERSION="3.6b"
PREFIX="${HOME}/.local"

function info() { echo -e "${GREEN}[INFO]${NC}  $*"; }
function warn() { echo -e "${YELLOW}[WARN]${NC}  $*"; }
function err() { echo -e "${RED}[ERROR]${NC} $*"; }
function step() { echo -e "${CYAN}[STEP]${NC}  $*"; }

function usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Build and install tmux ${TMUX_VERSION} (default 3.6b: the latest tmux 3.7
makes the neovim cursor blink constantly) to ${PREFIX}/bin (or --prefix DIR).

Options:
  --version VER  tmux release version to build (default: ${TMUX_VERSION})
  --prefix DIR   Install prefix (default: ${PREFIX})
  -h, --help     Show this help
EOF
}

for arg in "$@"; do
  case "${arg}" in
  --prefix=*) PREFIX="${arg#*=}" ;;
  --prefix)
    err "--prefix requires a value (e.g. --prefix=\$HOME/.local)"
    exit 1
    ;;
  --version=*) TMUX_VERSION="${arg#*=}" ;;
  --version)
    err "--version requires a value (e.g. --version=3.6b)"
    exit 1
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *) ;;
  esac
done

if [[ -x "${PREFIX}/bin/tmux" ]] && "${PREFIX}/bin/tmux" -V | grep -q "tmux ${TMUX_VERSION}"; then
  info "tmux ${TMUX_VERSION} already installed at ${PREFIX}/bin/tmux"
  exit 0
fi

if [[ "$(id -u)" -ne 0 ]]; then
  err "installing build dependencies needs root; rerun with sudo: sudo $(basename "$0")"
  exit 1
fi

step "Installing build dependencies"
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential bison pkg-config libevent-dev libncurses-dev

BUILD_DIR="$(mktemp -d /tmp/build-tmux.XXXXXX)"
trap 'rm -rf "${BUILD_DIR}"' EXIT

step "Downloading tmux-${TMUX_VERSION}.tar.gz"
curl -fL "https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz" -o "${BUILD_DIR}/tmux-${TMUX_VERSION}.tar.gz"

step "Extracting"
tar xf "${BUILD_DIR}/tmux-${TMUX_VERSION}.tar.gz" -C "${BUILD_DIR}"

step "Configuring with prefix ${PREFIX}"
(
  cd "${BUILD_DIR}/tmux-${TMUX_VERSION}"
  ./configure --prefix="${PREFIX}"
)

step "Building with $(nproc) jobs"
(
  cd "${BUILD_DIR}/tmux-${TMUX_VERSION}"
  make -j"$(nproc)"
)

step "Installing to ${PREFIX}"
(
  cd "${BUILD_DIR}/tmux-${TMUX_VERSION}"
  make install
)

info "Done: $("${PREFIX}/bin/tmux" -V) at ${PREFIX}/bin/tmux"
info "Note: system tmux at /usr/bin/tmux is kept; ~/.local/bin takes precedence in PATH."

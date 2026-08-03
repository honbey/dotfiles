#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Rime 配置准备脚本
#
#   ./install.sh                # 更新全部字典 + 生成 custom_phrase.txt
#   ./install.sh dicts [cn|en]  # 只更新字典（可只更新中文/英文）
#   ./install.sh custom_phrase  # 只生成 custom_phrase.txt
#   ./install.sh export         # 打包配置为 rime-<时间戳>.tar.gz
#   ./install.sh -h             # 查看帮助
#
# 环境变量:
#   RIME_ICE_BASE  字典源地址前缀，默认 GitHub raw（可换镜像/代理）
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

RIME_ICE_BASE="${RIME_ICE_BASE:-https://raw.githubusercontent.com/iDvel/rime-ice/refs/heads/main}"

# Colors for output（与仓库根 install.sh 风格一致）
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

function info() { echo -e "${GREEN}[INFO]${NC}  $*"; }
function err() { echo -e "${RED}[ERROR]${NC} $*"; }
function step() { echo -e "${CYAN}[STEP]${NC}  $*"; }

function usage() {
  cat <<EOF
Usage: $(basename "$0") [COMMAND]

Commands:
  dicts [cn|en]    Download/update dicts from rime-ice
  custom_phrase    Generate custom_phrase.txt (not tracked by git)
  export           Pack configs into rime-<timestamp>.tar.gz (no build dir)
  all              Run dicts then custom_phrase (default)
  -h, --help       Show this help

Env:
  RIME_ICE_BASE   Dict source URL prefix (default: GitHub raw of rime-ice main)

Examples:
  $(basename "$0")            # update all dicts
  $(basename "$0") dicts cn   # update Chinese dicts only
  RIME_ICE_BASE=https://ghproxy.com/... $(basename "$0")
EOF
}

# ---------- 字典下载 ----------

# 文件清单：仅覆盖上游 rime-ice 维护的文件，本地的 custom/ext 不受影响
CN_DICTS=(8105.dict.yaml base.dict.yaml others.dict.yaml)
EN_DICTS=(cn_en.txt en.dict.yaml en_ext.dict.yaml)

# 下载单个文件：fetch <子目录> <文件名>
function fetch() {
  local dir="$1" file="$2"
  local url="${RIME_ICE_BASE}/${dir}/${file}"
  if curl -fsSL --connect-timeout 10 --max-time 300 --retry 3 --retry-delay 1 \
      -o "${dir}/${file}" "${url}" 2>/dev/null; then
    info "downloaded ${dir}/${file}"
  else
    err "failed: ${dir}/${file} (${url})"
    return 1
  fi
}

function update_dicts() {
  local scope="${1:-all}"
  command -v curl >/dev/null || { err "curl is required but not found."; exit 1; }
  mkdir -p cn_dicts en_dicts

  step "Downloading dicts from ${RIME_ICE_BASE}"
  local pids=() failed=0
  case "${scope}" in
    cn)
      for f in "${CN_DICTS[@]}"; do fetch cn_dicts "$f" & pids+=("$!"); done
      ;;
    en)
      for f in "${EN_DICTS[@]}"; do fetch en_dicts "$f" & pids+=("$!"); done
      ;;
    all)
      for f in "${CN_DICTS[@]}"; do fetch cn_dicts "$f" & pids+=("$!"); done
      for f in "${EN_DICTS[@]}"; do fetch en_dicts "$f" & pids+=("$!"); done
      ;;
    *)
      usage
      exit 1
      ;;
  esac

  # 等待全部完成并汇总失败，单个失败不中断其余下载
  for p in "${pids[@]}"; do
    wait "$p" || failed=1
  done

  if ((failed)); then
    err "Some dicts failed to download. Please check network and retry."
    exit 1
  fi
  info "All dicts are up to date."
}

# ---------- custom_phrase 生成 ----------

# custom_phrase.txt 不被 git 追踪，克隆仓库后不存在，由本脚本生成。
# 注意：词条行必须以 Tab 分隔（heredoc 中为真实 Tab），行尾为 LF，不要混入 CR。
function gen_custom_phrase() {
  cat > custom_phrase.txt <<'EOF'
# Rime table
# coding: utf-8
#@/db_name	custom_phrase.txt
#@/db_type	tabledb
#
# version: "2026-08-03"
#
# no comment

Rime	rime	4
鼠须管	rime	3
https://rime.im/	rime	2
Squirrel	rime	1
EOF
  info "generated custom_phrase.txt"
}

# ---------- 配置导出 ----------

# 将 rime 目录下的配置打包为 rime-<时间戳>.tar.gz
# 排除 build 目录、.git 及历史归档
# 先打包到临时文件再移回，避免归档自身被 tar 读取（file changed as we read it）
function export_config() {
  local ts archive tmp_archive
  ts="$(date +%s)"
  archive="rime-${ts}.tar.gz"
  tmp_archive="$(mktemp)"
  tar -czf "${tmp_archive}" \
      --exclude='build' \
      --exclude='.git' \
      --exclude='*.tar.gz' \
      -C "${SCRIPT_DIR}" .
  mv "${tmp_archive}" "${SCRIPT_DIR}/${archive}"
  info "exported ${archive} ($(du -h "${archive}" | cut -f1))"
}

function main() {
  local cmd="${1:-all}"
  case "${cmd}" in
    dicts) update_dicts "${2:-all}" ;;
    custom_phrase) gen_custom_phrase ;;
    export) export_config ;;
    all)
      update_dicts "${2:-all}"
      gen_custom_phrase
      ;;
    -h|--help|help) usage ;;
    *)
      err "Unknown command: ${cmd}"
      usage
      exit 1
      ;;
  esac
}

main "$@"

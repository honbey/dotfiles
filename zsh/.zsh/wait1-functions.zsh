# Generate random passphrase
#   $1 int: passphrase length
#   $2 string: charset preset (safe|alnum|symbols, default safe) or a custom charset
#   $3 string: whether to hash passphrase
#   $4 string: provide specfic salt
#   *return string: passphrase or hashed
function generate_passwd() {
  local length charset hashed salt openssl_existed
  length="${1:-16}"
  # Presets: safe = unambiguous letters+digits (default),
  # alnum = full letters+digits, symbols = letters+digits+symbols.
  # Any other value is used as a custom charset directly.
  case "${2:-safe}" in
  safe) charset="23456789ABCDEFGHJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz" ;;
  alnum) charset="A-Za-z0-9" ;;
  symbols) charset="A-Za-z0-9!@#$%^&*()_+{}[]|:;<>,.?~" ;;
  *) charset="$2" ;;
  esac
  type openssl &>/dev/null && openssl_existed=true || openssl_existed=""
  [[ -n "$3" && "${openssl_existed}" ]] && hashed=true || hashed=""
  [[ -n "$4" && "${hashed}" ]] && salt="$4" || salt=""
  passphrase=$(LC_ALL=C tr -dc "${charset}" </dev/urandom | head -c "${length}")
  echo -n "Plain: ${passphrase}"
  if [[ -n "${hashed}" ]]; then
    if [[ -n "${salt}" ]]; then
      openssl passwd -5 -salt "${salt}" "${passphrase}"
    else
      openssl passwd -5 "${passphrase}"
    fi
  else
    echo
  fi
}
alias generate_password='generate_passwd'
alias generate_passphrase='generate_passwd'

# Timestamp to datetime or inversely.
#   $@ int or string
#   *return string or int
function ts() {
  if [[ "$1" =~ ^[0-9]{10}$ ]]; then
    date -d "@$1" '+%Y-%m-%d %H:%M:%S'
  elif [[ "$1" =~ ^[0-9]{13}$ ]]; then
    date -d "@${1:0:10}" "+%Y-%m-%d %H:%M:%S.${1:10:13}"
  else
    date -d "$1" "+%s"
  fi
}

# Customize jq depth to show.
#   $1 int: depth, default 1
#   * return null
function jqd() {
  # echo "Usage: jqd <depth> [input-file]"
  local depth
  if [[ $# -lt 1 ]]; then
    depth=1
  else
    depth=$1
  fi

  local input_file=${2:-/dev/stdin}

  jq --argjson depth "$depth" 'def truncate($depth):
        if $depth <= 0 then
            if type == "object" then "{...}"
            elif type == "array" then "[...]"
            else .
            end
        else
            if type == "object" then
                . as $in | reduce keys[] as $key ({}; .[$key] = ($in[$key] | truncate($depth-1)))
            elif type == "array" then
                map(truncate($depth-1))
            else
                .
            end
        end;
    truncate($depth)' "$input_file"
}

# Transale English word to Chinese.
# I find a wonderful dictionary from [skywind3000](https://skywind.me/).
# The author's recommand way to use is use [GoldenDict](https://github.com/goldendict/goldendict)
# But it has no official universal releases for macOS, I choose to use sqlite3 at present.
# Dictionary from https://github.com/skywind3000/ECDICT-ultimate/releases/tag/1.0.0
#   $1 string: English word, default China
#   $2 string: "full" or null, control whether to query all column by sqlite3
#   *return string
function t() {
  if [[ $2 == "full" ]]; then
    sqlite3 --init /dev/null "${RESOURCES}/EC-DICT-Ultimate.db" \
      "select * from stardict where word like '${1:-China}'"
  else
    sqlite3 --init /dev/null "${RESOURCES}/EC-DICT-Ultimate.db" \
      "select word,phonetic,definition,exchange,translation from stardict where word like '${1:-China}'"
  fi
}

# smart_mv - `mv` that transparently uses `git mv` for git-tracked files.
#
# Install in ~/.zshrc:
#   smart_mv() { ... }
#   alias mv='smart_mv'
#
# `git mv` is used only when every one of these holds, otherwise the arguments
# are forwarded verbatim to `mv`, so the alias is always safe:
#   * at least two operands (source... destination)
#   * only options `git mv` understands are given (-f/--force, -v/--verbose, --)
#   * cwd is inside a git working tree
#   * every source is tracked, is not a submodule and holds no untracked
#     (non-ignored) files below it
#   * the destination stays inside the same working tree and is not a submodule
smart_mv() {
  if [ "$#" -eq 0 ]; then
    command mv
    return $?
  fi

  # --- split leading options --------------------------------------------
  # -i/-n/-b/-t/-T/-u/-S/--backup/... have no `git mv` equivalent, `-n` even
  # means the opposite (`--dry-run`), so they fall back to `mv`.
  local arg rest
  local force="" verbose="" unsupported="" endopts=0 optc=0
  for arg in "$@"; do
    if [ "$endopts" -eq 0 ]; then
      case "$arg" in
      --) endopts=1 ;;
      --force) force=1 ;;
      --verbose) verbose=1 ;;
      -[A-Za-z]*)
        case "$arg" in *f*) force=1 ;; esac
        case "$arg" in *v*) verbose=1 ;; esac
        rest="${arg#-}"
        [ -n "${rest//[fv]/}" ] && unsupported=1
        ;;
      -*) unsupported=1 ;;
      *) break ;;
      esac
      optc=$((optc + 1))
      continue
    fi
    break
  done

  # --- collect operands --------------------------------------------------
  local -a operands
  local i=0
  for arg in "$@"; do
    i=$((i + 1))
    [ "$i" -gt "$optc" ] && operands+=("$arg")
  done

  if [ -n "$unsupported" ] || [ "$#" -le "$optc" ] || [ "$(($# - optc))" -lt 2 ]; then
    command mv "$@"
    return $?
  fi

  # --- can `git mv` handle it? -------------------------------------------
  local count=$(($# - optc))
  local dest="${operands[-1]}"
  local -a srcs
  local n=0
  for arg in "${operands[@]}"; do
    n=$((n + 1))
    [ "$n" -lt "$count" ] && srcs+=("$arg")
  done

  local use_git=1
  (
    local src top dst_abs
    command -v git >/dev/null 2>&1 || exit 1
    [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ] || exit 1
    top=$(git rev-parse --show-toplevel 2>/dev/null) || exit 1
    [ -n "$top" ] || exit 1

    case "$dest" in
    /*) dst_abs="$dest" ;;
    *) dst_abs="$PWD/$dest" ;;
    esac
    case "$dst_abs/" in "$top"/*) ;; *) exit 1 ;; esac

    # a submodule is not a directory you can move files into
    case "$(git ls-files -s -- ":(literal)$dest" 2>/dev/null)" in 160000*) exit 1 ;; esac

    for src in "${srcs[@]}"; do
      # untracked source
      git ls-files --error-unmatch -- ":(literal)$src" >/dev/null 2>&1 || exit 1
      # submodule (gitlink)
      case "$(git ls-files -s -- ":(literal)$src" 2>/dev/null)" in 160000*) exit 1 ;; esac
      # `git mv` refuses to move a tree holding untracked files
      [ -z "$(git ls-files --others --exclude-standard -- ":(literal)$src" 2>/dev/null)" ] || exit 1
    done
  ) || use_git=

  if [ -z "$use_git" ]; then
    command mv "$@"
    return $?
  fi

  # `mv` overwrites an existing destination by default, `git mv` needs -f
  [ -e "$dest" ] && force=1

  set -- "${operands[@]}"
  [ -n "$verbose" ] && set -- -v "$@"
  [ -n "$force" ] && set -- -f "$@"
  [ "$endopts" -eq 1 ] && set -- -- "$@"
  git mv "$@"
  return $?
}

alias mv='smart_mv'

# Alias tips - nudge you when the command you just ran already has an alias.
#
# A standalone replacement for `djui/alias-tips` /
# `MichaelAquilina/zsh-you-should-use`, hooked on `preexec`:
#
#     $ ls -Ahl
#     Alias: ll
#
# On top of what those two do, a command typed with a leading space is never
# nagged about - exactly like a leading space keeps it out of the history - so
# there is always a quick way to opt out of the tip.
#
# Tunables (all optional, set them before this file is sourced):
#   ALIAS_TIP_ENABLED=0       # 0 switches the whole feature off
#   ALIAS_TIP_WRAPPERS=1      # also tip wrapping aliases, e.g. ls='ls --color=auto'
#   ALIAS_TIP_IGNORE=(ll la)  # alias names that should never be suggested
#   ALIAS_TIP_PREFIX="..."    # text printed in front of the tip
#   * return null
(( ${+ALIAS_TIP_IGNORE} )) || typeset -ga ALIAS_TIP_IGNORE=()

function _alias_tip_preexec() {
  emulate -L zsh

  (( ${ALIAS_TIP_ENABLED:-1} )) || return 0
  # `$aliases` comes from zsh/parameter, without it there is nothing to compare.
  (( ${+aliases} )) || zmodload zsh/parameter 2>/dev/null || return 0

  local typed="$1"

  # A leading space keeps a command out of the history, so it must keep it out
  # of the tips as well.  zsh also hands `preexec` an empty string when the line
  # was dropped from the history buffer (HIST_IGNORE_SPACE / HISTORY_IGNORE);
  # that ends up here as the very same thing: no reliable line, no tip.
  [[ -n "${typed}" ]] || return 0
  [[ "${typed}" != [[:space:]]* ]] || return 0

  # Trim the trailing whitespace, then split into shell words (quotes respected).
  typed="${typed%"${typed##*[![:space:]]}"}"
  local -a words
  words=("${(@Q)${(z)typed}}")
  (( ${#words} )) || return 0

  # Look for the alias covering the longest prefix of the typed command.
  # Only `$aliases` is scanned, so global (`alias -g`) and suffix (`alias -s`)
  # aliases are never suggested.
  local name value best_name="" prefix
  local -a awords
  local i n best_len=0 hit=0
  for name in ${(k)aliases}; do
    (( ${ALIAS_TIP_IGNORE[(I)${name}]} )) && continue
    value="${aliases[${name}]}"
    # cheap pre-filter: the alias has to start with the same command
    [[ "${words[1]}" == "${value%%[[:space:]]*}" ]] || continue
    awords=("${(@Q)${(z)value}}")
    n=${#awords}
    (( n > 0 && n <= ${#words} )) || continue
    # `ls='ls --color=auto'` only appends flags, tipping it is pure noise
    (( ${ALIAS_TIP_WRAPPERS:-0} )) || [[ "${name}" != "${awords[1]}" ]] || continue
    hit=1
    for ((i = 1; i <= n; i++)); do
      [[ "${words[i]}" == "${awords[i]}" ]] || hit=0
      (( hit )) || break
    done
    (( hit && n > best_len )) || continue
    best_len=${n}
    best_name="${name}"
  done
  [[ -n "${best_name}" ]] || return 0

  prefix="${ALIAS_TIP_PREFIX:-Alias:}"
  print -r -- "${prefix} ${best_name}"
}

# Register only once, re-sourcing this file must not stack duplicate hooks.
if (( ${preexec_functions[(I)_alias_tip_preexec]:-0} == 0 )); then
  preexec_functions+=(_alias_tip_preexec)
fi

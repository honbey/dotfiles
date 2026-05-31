# Generate random passphrase
#   $1 int: passphrase length
#   $2 string: passphrase charset
#   $3 string: whether to hash passphrase
#   $4 string: provide specfic salt
#   *return string: passphrase or hashed
function generate_passwd() {
  local length charset hashed salt openssl_existed
  length="${1:-16}"
  charset="${2:-A-Za-z0-9!&^._}" # A-Za-z0-9!@#$%^&*()_+{}[]|:;<>,.?~
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

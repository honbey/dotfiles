# Count the disk space occupied by the recycling bin directory `graveyard`
# by `rip(rm-improved)` and notify when space more than 3GB automatically.
#    * return null
function _count_graveyard() {
  local size=$(du --summarize --bytes /opt/data/graveyard | awk '{print $1}')
  if [[ ${size} -gt 3221225472 ]]; then
    echo -e "\nThe graveyard space has exceeded 3GB.\nPlease clean it up!"
  elif [[ $1 == "run" ]]; then
    echo -e "Graveyard size: $((${size} / (2 ** 20)))MB."
  fi
}

# Add extra completions which not installed by `brew` on macOS.
#    * return null
function _extra_complement() {
  [[ -d "/opt/homebrew" ]] || return
  local BREW_MACOS
  BREW_MACOS="/opt/homebrew"
  # curl's complement not load on macOS.
  if [[ -d "${BREW_MACOS}/opt/curl/share/zsh/site-functions" ]]; then
    [[ -f "${BREW_MACOS}/share/zsh/site-functions/_curl" ]] ||
      ln -s "${BREW_MACOS}/opt/curl/share/zsh/site-functions/_curl" \
        "${BREW_MACOS}/share/zsh/site-functions/_curl"
  fi
}

# Those functions need be processed.
_count_graveyard
_extra_complement

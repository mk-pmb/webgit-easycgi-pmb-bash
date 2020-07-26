#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function wg_cgi () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local SELFPATH="$(readlink -m -- "$BASH_SOURCE"/..)"
  # cd -- "$SELFPATH" || return $?

  local SUB_URL="$PATH_INFO"
  SUB_URL="${SUB_URL%%\?*}" # redundant on compliant servers
  [[ "$(declare -p CFG 2>/dev/null)" == 'declare -A ='* ]] || local -A CFG=()
  wg_load_config || return $?
  [ -z "${CFG[rc]}" ] || source -- "${CFG[rc]}" || return $?

  [ "$REQUEST_METHOD" == GET ] || wg_fail 405 'Method Not Allowed'
  case "$SUB_URL" in
    *./* | \
    */.* | \
    *..* | \
    *//* ) wg_fail 403 'Access Denied' 'Suspicious sub URL.';;
    /* ) SUB_URL="${SUB_URL#/}";;
    * ) wg_fail 500 '' 'Unexpected sub URL prefix.';;
  esac

  local RGX='^('"${CFG[repo_name_rgx]}"')(/[A-Za-z0-9/.-]*|)$'
  [[ "$SUB_URL" =~ $RGX ]] || wg_fail 404 'Not Found' \
    'Unexpected URL structure or invalid repo name.'
  local REPO_NAME="${BASH_REMATCH[1]}"
  SUB_URL="${SUB_URL:${#REPO_NAME}}"

  # URL schemas required for cloning:
  # /repo-name/info/refs?service=git-upload-pack
  # /repo-name/objects/info/packs
  # /repo-name/objects/pack/pack-hexhex.idx
  # /repo-name/objects/pack/pack-hexhex.pack
  # /repo-name/objects/65/hexhex

  [ -d "$REPO_NAME"/../refs/heads ] \
    || wg_fail 404 'Not Found' 'Repository does not exist or has no heads.'
  local REPO_ABS="$(readlink -m -- "$REPO_NAME" 2>/dev/null)"
  [ -n "$REPO_ABS" ] || wg_fail 404 'Not Found' \
    "Cannot resolve the repository's objects directory."
  cd -- "$REPO_ABS" || wg_fail 404 'Not Found' \
    "Cannot access the repository's objects directory."
  cd .. || wg_fail 404 'Not Found' \
    "Cannot access the repository's git directory."

  case "$SUB_URL" in
    '' )
      wg_header 302 Found "Location: $SCRIPT_NAME/$REPO_NAME/" \
        '' 'Redirecting.'
      return 0;;
    / ) wg_repo_hello; return $?;;
    /HEAD ) wg_suggest_head; return $?;;
    /info/refs ) wg_info_refs; return $?;;
    /objects/* )
      wg_header 302 Found "Location: $(dirname -- "$SCRIPT_NAME"
        )/$REPO_NAME/${SUB_URL#*/*/}" '' 'Redirecting.'
      return 0;;
  esac

  wg_fail 404 'Not Found' 'Unsupported sub URL structure.' "[$SUB_URL]"
}


function wg_header () {
  local CODE="${1:-500}"; shift
  local MSG="${1:-Internal Server Error}"; shift
  local EOL="${CFG[eol]:-\n}"
  [ "$EOL" == CRLF ] && EOL='\r\n'
  printf "%s$EOL" "Status: $CODE $MSG" \
    'Content-Type: text/plain; charset=UTF-8' \
    "$@"
}


function wg_fail () {
  local CODE="$1"; shift
  local MSG="$1"; shift
  wg_header "$CODE" "$MSG" '' "HTTP/$CODE $MSG" "$@"
  exit 0
}


function wg_load_config () {
  local -A DF_CFG=()
  source -- "$SELFPATH"/cfg.defaults.rc || return $?
  local KEY= VAL=
  for KEY in "${!CFG[@]}"; do
    unset DF_CFG["$KEY"]
  done
  for KEY in "${!DF_CFG[@]}"; do
    VAL=
    eval 'VAL="$wg_'"$KEY"'"'
    CFG["$KEY"]="${VAL:-${DF_CFG[$KEY]}}"
  done
}


function wg_repo_hello () {
  local URL="${REQUEST_SCHEME:-http}://$HTTP_HOST$REQUEST_URI"
  local SUSP="${URL//[A-Za-z0-9_\/.:-]/}"
  [ -z "$SUSP" ] || URL="$("$SELFPATH"/aposquote.sed <<<"$URL")"

  wg_header 200 OK '' "
  Hello. :-)

  Would you like to clone this repository?
  The command would be${SUSP:+ (but heed the warning below)}:

  git clone -- $URL"
  [ -z "$SUSP" ] || echo "
  However, the URL contains characters that could maybe have
  special effects in some shells. The quotes shown should work in
  Almquist-like shells, but please double-check for your shell."
}


function wg_suggest_head () {
  wg_header 200 OK ''
  GIT_DIR=. git rev-parse "${CFG[fake_head]}"
}


function wg_info_refs () {
  wg_header 200 OK ''
  GIT_DIR=. git branch --verbose --no-abbrev \
    | tr -s '* \t' '\t' | cut -sf 2-3 | sed -re 's~\t~\n&~' | grep \
    --regexp="${CFG[branch_grep_rgx]}" \
    ${CFG[branch_grep_opt]} \
    --line-number \
    --after-context=1 \
    | sed -nrf <(echo '
    /^[0-9]+:/{
      N
      s~^[0-9]*:(\S+)\n[0-9]*\-\t(\S*)~\2\trefs/heads/\1~p
    }')
}










wg_cgi "$@"; exit $?

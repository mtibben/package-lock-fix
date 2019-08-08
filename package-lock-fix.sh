#!/bin/bash
#
# This script attempts to fix npm "extraneous" and "missing" errors
#

set -euo pipefail

export npm_config_audit=false
export npm_config_loglevel=error
export NODE_ENV=development

echo_eval() {
  echo + $*
  eval $*
}

find_missing_deps() {
  npm ls 2>&1 1>/dev/null | grep "npm ERR! missing:" | sed -E "s/.* missing: (.*),.*/\1/"  || true
}

fix_dependencies() {
  local missing_deps="$(find_missing_deps)"
  if [[ "$missing_deps" != "" ]] ; then
    echo_eval "npm install --no-save '$missing_deps'"
    return 0
  fi
  return 1
}

echo_npm_ls_errors() {
  local header="$1"
  local issues="$(npm ls 2>&1 1>/dev/null)"
  echo
  echo "$header"
  echo
  echo "$issues"
  echo
}

dedupe_prune_fix_missing() {
  local sha=
  local fixes_applied="true"
  while [[ "$sha" != "$(shasum package*.json)" ]] || $fixes_applied ; do
    sha="$(shasum package*.json)"
    echo_eval npm dedupe
    echo_eval npm prune || true
    fix_dependencies && fixes_applied="true" || fixes_applied="false"
  done
}

has_displayed_issues="false"
sha=
while [[ "$sha" != "$(shasum package*.json)" ]] ; do
  sha="$(shasum package*.json)"
  echo_eval "npm ci &>/dev/null"
  $has_displayed_issues || echo_npm_ls_errors "Current issues:"
  has_displayed_issues="true"
  dedupe_prune_fix_missing
done

echo_npm_ls_errors "Finished. The following issues remain:"

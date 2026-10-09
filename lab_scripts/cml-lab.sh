#!/usr/bin/env bash
# Start/stop/status CML labs whose title starts with a given prefix.
# Usage: cml-lab.sh {start|stop|status} [-w|--wait] [-v|--verbose]
#
# Required env vars:
#   CML_USER            CML username
#   CML_PASS            CML password
# Optional env vars:
#   CML_HOST            default: 10.10.10.20
#   CML_LAB_PREFIX      default: "CCIE Automation"
#   CML_WAIT_TIMEOUT    seconds to wait with -w, default: 600

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -f "$SCRIPT_DIR/.env" ]] && source "$SCRIPT_DIR/.env"

CML_HOST="${CML_HOST:-10.10.10.20}"
CML_LAB_PREFIX="${CML_LAB_PREFIX:-CCIE Automation}"
CML_WAIT_TIMEOUT="${CML_WAIT_TIMEOUT:-600}"
VERBOSE=0
WAIT=0

usage() {
  echo "Usage: $(basename "$0") {start|stop|status} [-w|--wait] [-v|--verbose]" >&2
  exit 1
}

[[ $# -ge 1 ]] || usage
ACTION="$1"; shift
case "$ACTION" in start|stop|status) ;; *) usage ;; esac

while [[ $# -gt 0 ]]; do
  case "$1" in
    -w|--wait) WAIT=1 ;;
    -v|--verbose) VERBOSE=1 ;;
    *) usage ;;
  esac
  shift
done

command -v curl >/dev/null || { echo "curl is required" >&2; exit 1; }
command -v jq >/dev/null || { echo "jq is required" >&2; exit 1; }

if [[ -z "${CML_USER:-}" || -z "${CML_PASS:-}" ]]; then
  echo "Error: CML_USER and CML_PASS must be set (export them, or put them in $SCRIPT_DIR/.env)" >&2
  exit 1
fi

log() { [[ $VERBOSE -eq 1 ]] && echo "[debug] $*" >&2; }

cml_auth() {
  local resp
  resp=$(curl -sk -X POST "https://${CML_HOST}/api/v0/authenticate" \
    -H 'Content-Type: application/json' \
    -d "{\"username\":\"${CML_USER}\",\"password\":\"${CML_PASS}\"}")
  log "auth response: $resp"
  TOKEN="${resp//\"/}"
  if [[ -z "$TOKEN" || "$TOKEN" == "null" ]]; then
    echo "Error: CML authentication failed. Response: $resp" >&2
    exit 1
  fi
}

# cml_api METHOD PATH [JSON_DATA]
cml_api() {
  local method="$1" path="$2" data="${3:-}"
  local args=(-sk -X "$method" "https://${CML_HOST}/api/v0${path}" -H "Authorization: Bearer ${TOKEN}" -H 'Content-Type: application/json')
  [[ -n "$data" ]] && args+=(-d "$data")
  local resp
  resp=$(curl "${args[@]}")
  log "$method $path -> $resp"
  echo "$resp"
}

# Populates two parallel arrays: LAB_IDS, LAB_TITLES for labs matching prefix
find_matching_labs() {
  LAB_IDS=()
  LAB_TITLES=()
  local ids id detail title
  ids=$(cml_api GET "/labs" | jq -r '.[]')
  while IFS= read -r id; do
    [[ -z "$id" ]] && continue
    detail=$(cml_api GET "/labs/${id}")
    title=$(echo "$detail" | jq -r '.lab_title // empty')
    if [[ "$title" == "${CML_LAB_PREFIX}"* ]]; then
      LAB_IDS+=("$id")
      LAB_TITLES+=("$title")
    fi
  done <<< "$ids"
}

lab_state() {
  local id="$1"
  cml_api GET "/labs/${id}/state" | tr -d '"'
}

wait_for_state() {
  local id="$1" target="$2" elapsed=0
  while true; do
    local state
    state=$(lab_state "$id")
    [[ "$state" == "$target" ]] && return 0
    elapsed=$((elapsed + 5))
    if [[ $elapsed -ge $CML_WAIT_TIMEOUT ]]; then
      echo "  (timed out after ${CML_WAIT_TIMEOUT}s waiting for $target, last state: $state)" >&2
      return 1
    fi
    sleep 5
  done
}

cml_auth
find_matching_labs

if [[ ${#LAB_IDS[@]} -eq 0 ]]; then
  echo "No labs found with title prefix '${CML_LAB_PREFIX}' on ${CML_HOST}"
  exit 0
fi

case "$ACTION" in
  status)
    for i in "${!LAB_IDS[@]}"; do
      id="${LAB_IDS[$i]}"
      title="${LAB_TITLES[$i]}"
      state=$(lab_state "$id")
      echo "${title} (${id}): ${state}"
    done
    ;;
  start)
    for i in "${!LAB_IDS[@]}"; do
      id="${LAB_IDS[$i]}"
      title="${LAB_TITLES[$i]}"
      echo "Starting '${title}' (${id})..."
      cml_api PUT "/labs/${id}/start" >/dev/null
      if [[ $WAIT -eq 1 ]]; then
        wait_for_state "$id" "STARTED" && echo "  -> STARTED"
      fi
    done
    ;;
  stop)
    for i in "${!LAB_IDS[@]}"; do
      id="${LAB_IDS[$i]}"
      title="${LAB_TITLES[$i]}"
      echo "Stopping '${title}' (${id})..."
      cml_api PUT "/labs/${id}/stop" >/dev/null
      if [[ $WAIT -eq 1 ]]; then
        wait_for_state "$id" "STOPPED" && echo "  -> STOPPED"
      fi
    done
    ;;
esac

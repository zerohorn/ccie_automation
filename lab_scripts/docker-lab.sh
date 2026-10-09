#!/usr/bin/env bash
# Start/stop/status docker-compose lab projects living under LAB_INFRA_DIR.
# Runs locally if LAB_INFRA_DIR exists on this machine,
# otherwise transparently runs the same commands over SSH on LAB_HOST.
#
# Usage: docker-lab.sh {start|stop|status} [-p|--password] [project ...]
#   With no project names given, operates on every project directory found
#   (each one is a subdirectory of LAB_INFRA_DIR containing a compose file).
#   -p/--password : use SSH password auth instead of keys (requires sshpass).
#                   Uses LAB_PASS if set, otherwise prompts for the password.
#
# Optional env vars:
#   LAB_INFRA_DIR   default: /home/user/code/ccie_automation/lab_infra
#   LAB_HOST        default: 10.10.10.10
#   LAB_USER        default: your_host_username
#   LAB_PASS        SSH password for LAB_USER; if set, password auth is used
#                   automatically (no -p needed)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -f "$SCRIPT_DIR/.env" ]] && source "$SCRIPT_DIR/.env"

LAB_INFRA_DIR="${LAB_INFRA_DIR:-/home/user/code/ccie_automation/lab_infra}"
LAB_HOST="${LAB_HOST:-10.0.0.241}"
LAB_USER="${LAB_USER:-mhorn}"
USE_PASSWORD=0
[[ -n "${LAB_PASS:-}" ]] && USE_PASSWORD=1

usage() {
  echo "Usage: $(basename "$0") {start|stop|status} [-p|--password] [project ...]" >&2
  exit 1
}

[[ $# -ge 1 ]] || usage
ACTION="$1"; shift
case "$ACTION" in start|stop|status) ;; *) usage ;; esac

PROJECTS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -p|--password) USE_PASSWORD=1 ;;
    -*) usage ;;
    *) PROJECTS+=("$1") ;;
  esac
  shift
done

is_local() { [[ -d "$LAB_INFRA_DIR" ]]; }

# Password auth only matters when we're going over SSH
if [[ $USE_PASSWORD -eq 1 ]] && ! is_local; then
  command -v sshpass >/dev/null || { echo "sshpass is required for password auth (brew install sshpass / apt install sshpass)" >&2; exit 1; }
  if [[ -z "${LAB_PASS:-}" ]]; then
    read -rsp "SSH password for ${LAB_USER}@${LAB_HOST}: " LAB_PASS
    echo >&2
  fi
  # sshpass -e reads the password from SSHPASS, keeping it out of the process list
  export SSHPASS="$LAB_PASS"
fi

# run_remote SCRIPT_STRING : executes a bash script either locally or over ssh
run_remote() {
  local script="$1"
  if is_local; then
    bash -c "$script"
  elif [[ $USE_PASSWORD -eq 1 ]]; then
    sshpass -e ssh -o PubkeyAuthentication=no -o PreferredAuthentications=password,keyboard-interactive \
      "${LAB_USER}@${LAB_HOST}" "bash -s" <<< "$script"
  else
    ssh -o BatchMode=yes "${LAB_USER}@${LAB_HOST}" "bash -s" <<< "$script"
  fi
}

discover_projects() {
  run_remote "find '${LAB_INFRA_DIR}' -mindepth 2 -maxdepth 2 \
    \( -name 'docker-compose.yml' -o -name 'docker-compose.yaml' -o -name 'compose.yml' -o -name 'compose.yaml' \) \
    -exec dirname {} \; | sort -u"
}

# Resolve the list of project directories (full paths) to act on
resolve_project_dirs() {
  if [[ ${#PROJECTS[@]} -eq 0 ]]; then
    discover_projects
  else
    for p in "${PROJECTS[@]}"; do
      echo "${LAB_INFRA_DIR}/${p}"
    done
  fi
}

DIRS="$(resolve_project_dirs)"
if [[ -z "$DIRS" ]]; then
  echo "No compose projects found under ${LAB_INFRA_DIR} on ${LAB_HOST}" >&2
  exit 1
fi

# Build one combined remote script so we only pay the SSH round-trip once
build_script() {
  local compose_cmd="$1"
  local out=""
  while IFS= read -r dir; do
    [[ -z "$dir" ]] && continue
    out+="echo '== ${dir} =='; cd '${dir}' && docker compose ${compose_cmd}; echo; "
  done <<< "$DIRS"
  echo "$out"
}

case "$ACTION" in
  status) run_remote "$(build_script 'ps')" ;;
  start)  run_remote "$(build_script 'up -d')" ;;
  stop)   run_remote "$(build_script 'stop')" ;;
esac

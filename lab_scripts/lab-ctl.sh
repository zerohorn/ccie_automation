#!/usr/bin/env bash
# Combined control: starts/stops the CML lab and the docker compose projects together.
# Usage: lab-ctl.sh {start|stop|status} [-w|--wait]
#   start : starts the CML lab first, then the docker containers
#   stop  : stops the docker containers first, then the CML lab
#   -w/--wait is passed through to cml-lab.sh (wait for STARTED/STOPPED state)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  echo "Usage: $(basename "$0") {start|stop|status} [-w|--wait]" >&2
  exit 1
}

[[ $# -ge 1 ]] || usage
ACTION="$1"; shift
case "$ACTION" in start|stop|status) ;; *) usage ;; esac

CML_ARGS=()
for a in "$@"; do
  case "$a" in
    -w|--wait) CML_ARGS+=(-w) ;;
  esac
done

case "$ACTION" in
  start)
    echo "### CML lab ###"
    "$SCRIPT_DIR/cml-lab.sh" start "${CML_ARGS[@]}"
    echo
    echo "### Docker containers ###"
    "$SCRIPT_DIR/docker-lab.sh" start
    ;;
  stop)
    echo "### Docker containers ###"
    "$SCRIPT_DIR/docker-lab.sh" stop
    echo
    echo "### CML lab ###"
    "$SCRIPT_DIR/cml-lab.sh" stop "${CML_ARGS[@]}"
    ;;
  status)
    echo "### CML lab ###"
    "$SCRIPT_DIR/cml-lab.sh" status
    echo
    echo "### Docker containers ###"
    "$SCRIPT_DIR/docker-lab.sh" status
    ;;
esac

#!/usr/bin/env bash
# Cron entry point: unconditionally stops the docker containers and the CML lab,
# logging what happened. Intended to run nightly via cron.
#
# Example crontab line (stop everything every night at 11pm):
#   0 23 * * * /home/user/code/lab_scripts/nightly-shutdown.sh
#
# (crontab has no interactive shell env, so this script sources .env itself
#  via lab-ctl.sh/cml-lab.sh/docker-lab.sh -- make sure SCRIPT_DIR/.env is filled in)

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${LOG_DIR:-$SCRIPT_DIR/logs}"
LOG_FILE="$LOG_DIR/nightly-shutdown.log"
mkdir -p "$LOG_DIR"

{
  echo "===== $(date '+%Y-%m-%d %H:%M:%S') : nightly shutdown starting ====="
  "$SCRIPT_DIR/lab-ctl.sh" stop
  echo "===== $(date '+%Y-%m-%d %H:%M:%S') : nightly shutdown finished (exit $?) ====="
} >> "$LOG_FILE" 2>&1

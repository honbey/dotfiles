#!/bin/bash
set -e

if [ -z "$SYNC_USER" ] || [ -z "$SYNC_PASS" ]; then
  echo "ERROR: SYNC_USER and SYNC_PASS must be set."
  exit 1
fi

export SYNC_USER1="${SYNC_USER}:${SYNC_PASS}"

echo "=========================================="
echo " Anki Sync Server Starting..."
echo " User:    ${SYNC_USER}"
echo " Listen:  ${SYNC_HOST}:${SYNC_PORT}"
echo " Data:    /data"
echo "=========================================="

#exec python -m anki.syncserver
python -m anki.syncserver &
trap "kill -TERM $PID; wait $PID; exit 0" SIGTERM SIGINT
wait $PID

#!/bin/bash
# health-check.sh - checks containers, disk, RAM, tailscale status
# runs every 15 min via systemd timer

set -euo pipefail

LOG="/opt/scripts/logs/health.log"
ALERT_DISK=85
ALERT_RAM=90

mkdir -p "$(dirname "$LOG")"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG"
}

log "Health check START"

CONTAINERS=("immich_server" "immich_postgres" "immich_redis")
for c in "${CONTAINERS[@]}"; do
  if docker ps --format '{{.Names}}' | grep -q "^$c$"; then
    log "OK: $c running"
  else
    log "NOT OK: $c is DOWN"
  fi
done

DISK_USAGE=$(df / | awk 'NR==2{print $5}' | tr -d '%')
if [ "$DISK_USAGE" -ge "$ALERT_DISK" ]; then
  log "NOT OK: disk usage ${DISK_USAGE}%"
else
  log "OK: disk usage ${DISK_USAGE}%"
fi

RAM_USED=$(free | awk '/Mem:/{printf "%.0f", $3/$2*100}')
if [ "$RAM_USED" -ge "$ALERT_RAM" ]; then
  log "NOT OK: ram usage ${RAM_USED}%"
else
  log "OK: ram usage ${RAM_USED}%"
fi

if tailscale status &>/dev/null; then
  log "OK: tailscale connected"
else
  log "NOT OK: tailscale disconnected"
fi

log "Health check END"
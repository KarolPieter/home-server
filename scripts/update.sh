#!/bin/bash
# update.sh - backup, then apt security updates, then docker images
# run manually only, not automated, BECAUSE immich can have breaking changes.
# CHECK. RELEASE. NOTES. FIRST. https://github.com/immich-app/immich/releases

set -euo pipefail

DATE=$(date +%Y%m%d_%H%M%S)
LOG="/opt/scripts/logs/update.log"
mkdir -p "$(dirname "$LOG")"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG"
}

log "update START $DATE"

log "running backup first"
/opt/scripts/backup.sh

log "apt security updates"
sudo apt-get update -qq

apt-get --just-print upgrade 2>/dev/null | grep "^Inst" | grep security | awk '{print $2}' > /tmp/security_pkgs.txt

if [ -s /tmp/security_pkgs.txt ]; then
  sudo apt-get --only-upgrade install -y $(cat /tmp/security_pkgs.txt)
else
  log "no security updates"
fi

rm -f /tmp/security_pkgs.txt

sudo apt autoremove -y --purge

log "pulling up docker images"
cd /opt/immich
docker compose pull
docker compose up -d
docker image prune -f

log "update END $DATE"
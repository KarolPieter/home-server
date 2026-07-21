#!/bin/bash
# backup.sh - backup immich db + config
# runs every night at 2:00 via systemd timer

set -euo pipefail

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/opt/backups"
IMMICH_DIR="/opt/immich"
LOG="/opt/scripts/logs/backup.log"
KEEP_DAYS=7

mkdir -p "$BACKUP_DIR" "$(dirname "$LOG")"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG"
}

log "backup START. $DATE"
DB_FILE="$BACKUP_DIR/immich_db_$DATE.sql.gz"
docker exec immich_postgres pg_dumpall -U postgres | gzip > "$DB_FILE"
log "db saved: $DB_FILE"

CONFIG_FILE="$BACKUP_DIR/config_$DATE.tar.gz"
tar -czf "$CONFIG_FILE" \
  "$IMMICH_DIR/docker-compose.yml" \
  "$IMMICH_DIR/.env" \
  /opt/scripts/ \
  2>/dev/null || true
log "config saved: $CONFIG_FILE"

find "$BACKUP_DIR" -name "*.gz" -mtime +$KEEP_DAYS -delete
log "old backups cleaned up."

# TODO: rsync photos to external drive ... once I get one.
# PHOTOS_SRC="/opt/immich/library"
# PHOTOS_DST="/mnt/backup/immich-library"
# if mountpoint -q /mnt/backup; then
#   rsync -av --delete "$PHOTOS_SRC/" "$PHOTOS_DST/"
# fi

log "backup END. $DATE"
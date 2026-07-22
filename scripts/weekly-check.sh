#!/bin/bash
# weekly-check.sh - checks disk, RAM, containers, tailscale status,
# immich backup log (automatic and mine), smart disk health
# performed manually every week, mostly to see the disk status and space

echo "Disk:"
df -h /

echo "RAM:"
free -h

echo "Containers:"
docker ps --format "table {{.Names}}\t{{.Status}}"

echo "Tailscale:"
tailscale status

echo "Backup (Immich):"
ls -lht /opt/immich/library/backups/ | head -3

echo "Backup (my script):"
ls -lht /opt/backups/ | head -3

echo "S.M.A.R.T disk health:"
sudo smartctl -H /dev/sda
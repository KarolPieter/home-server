# Maintenance schedule

## Automatic (runs without me)

The `backup.sh` script runs automatically at 2:00 via a systemd timer,
creating a backup of the Immich database and config.

The `health-check.sh` script runs every 15 minutes via the same
method. It checks containers, disk, RAM, and Tailscale status, and
logs everything to `/opt/scripts/logs/health.log`.

Example output:

```
[2026-07-22 02:00:03] Health check START 20260722_020003
[2026-07-22 02:00:03] OK: immich_server running
[2026-07-22 02:00:03] OK: immich_postgres running
[2026-07-22 02:00:03] OK: immich_redis running
[2026-07-22 02:00:03] OK: disk usage 42%
[2026-07-22 02:00:03] OK: ram usage 61%
[2026-07-22 02:00:04] OK: tailscale connected
[2026-07-22 02:00:04] Health check END 20260722_020003
```

Immich also keeps its own automatic database backups in
`/opt/immich/library/backups/`, separate from the backup created by
my own script.

Only Debian security patches are downloaded and installed
automatically, since they're critical for the server's safety. See
[docs/security.md](security.md#automatic-security-updates) for details.

## Weekly manual check

`weekly-check.sh` covers the disk, RAM, containers, Tailscale, both
backup locations, and disk health. This is different from
`health-check.sh`: that one runs automatically every 15 minutes and
only logs to a file, this one I run by hand once a week to actually
look at the full picture.

```bash
#!/bin/bash
# weekly-check.sh - checks disk, RAM, containers, tailscale status,
# immich backup log (automatic and mine), smart disk health,
# temperatures, uptime, reboot status
# performed manually every week, mostly to see the disk status and space

echo "Disk:"
df -h /

echo "RAM:"
free -h

echo "Uptime:"
uptime

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

echo "Temperatures:"
sensors

echo "Reboot required?"
cat /var/run/reboot-required 2>/dev/null || echo "No"
```

## Monthly maintenance

Every month I perform a stable channel Debian release update, after
reading the changelog if available:

```
sudo apt update && sudo apt full-upgrade -y
sudo apt autoremove -y --purge
```

Check if a reboot is needed:

```
cat /var/run/reboot-required 2>/dev/null && echo "REBOOT NEEDED"
```

Then I clean up old, unused data. Docker images and containers that
are no longer used:

```
docker image prune -f
docker system prune -f
```

Old backups, older than 30 days:

```
find /opt/backups -name "*.gz" -mtime +30 -delete
```

Trim old system logs:

```
sudo journalctl --vacuum-size=200M
```

Read the logs, then perform a full disk checkup:

```
sudo smartctl -t long /dev/sda
```

Check the result after about 30 minutes:

```
sudo smartctl -l selftest /dev/sda
```

## update.sh, separate from all of this

`update.sh` is a different thing from the automatic security patches
above. I run it manually, whenever I want to update Immich, not on a
fixed schedule.

It backs up first, then installs any pending apt security patches (in
case `unattended-upgrades` missed something), then pulls and restarts
the Docker containers, then cleans up old images. I always read
Immich's release notes first, since it can have breaking changes
between versions.

## Before every Immich update

Immich can have breaking changes between versions, so this is a
fixed procedure, not optional:

- [ ] Read the release notes: https://github.com/immich-app/immich/releases
- [ ] Manual database backup:
  ```
  docker exec immich_postgres pg_dumpall -U postgres | gzip > /opt/backups/pre-update-$(date +%Y%m%d).sql.gz
  ```
- [ ] Check the backup was created:
  ```
  ls -lh /opt/backups/pre-update-*.sql.gz
  ```
- [ ] Run the update:
  ```
  cd /opt/immich && docker compose pull && docker compose up -d
  ```
- [ ] Check the logs after update:
  ```
  docker compose logs --tail 30
  ```
- [ ] Open the Tailscale address on port 2283 and check it works
- [ ] Remove old images:
  ```
  docker image prune -f
  ```

## Quarterly physical maintenance

Check idle temperatures:

```
sensors
```

- Below 40°C: OK, no need to clean
- Above 55°C idle: clean the fan with compressed air
- Above 70°C idle: replace the thermal paste

Check the battery:

```
sudo tlp-stat -b
```

Battery health: capacity, cycles, health%. If health drops below 70%,
the battery is aging.

```
cat /sys/class/power_supply/BAT0/capacity
```

Current battery charge level, in %.

Every 3 to 6 months, physically check the battery isn't swelling
(bottom of the laptop case deforming). A swollen battery needs
immediate replacement, it's a fire risk.

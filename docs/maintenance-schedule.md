# Maintenance schedule

## Automatic (runs without me)

The `backup.sh` script runs automatically at 2:00 via a systemd timer,
creating a backup of the Immich database and configuration files.

The `health-check.sh` script runs every 15 minutes via another
systemd timer. It checks containers, disk, RAM and Tailscale status and
logs everything to `/opt/scripts/logs/health.log`.

Example output:

```
[2026-07-22 01:37:33] Health check START
[2026-07-22 01:37:33] OK: immich_server running
[2026-07-22 01:37:33] OK: immich_postgres running
[2026-07-22 01:37:33] OK: immich_redis running
[2026-07-22 01:37:33] OK: disk usage 66%
[2026-07-22 01:37:33] OK: ram usage 39%
[2026-07-22 01:37:33] OK: tailscale connected
[2026-07-22 01:37:33] Health check END
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

Full script: [scripts/weekly-check.sh](../scripts/weekly-check.sh)

## Monthly maintenance

Every month I update the system packages after checking the Debian
changelog, if available:

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

Backups older than 30 days:

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

## update.sh (manual updates)

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

- [ ] Read the [Immich release notes](https://github.com/immich-app/immich/releases)
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
- Above 70°C idle: investigate cooling (dust buildup, fan operation, thermal paste)

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
immediate replacement. It's a fire risk.
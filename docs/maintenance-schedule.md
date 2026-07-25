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
automatically, since they're critical for the server's safety.
See [docs/security-hardening.md](security-hardening.md#automatic-security-updates) for details.

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

## Troubleshooting and diagnostics

Once something goes wrong, I need to know how to fix it. So far
there's never been a major issue, only small ones caused by my own
mistakes, but it's still important to practice skills like reading
logs, in case a real emergency happens one day.

### SSH connection fails

Since UFW only allows traffic from the Tailscale IP range, the first
thing I check is Tailscale's status. If the `tailscale status` command
doesn't work at all, my own computer isn't connected, and reconnecting
it resolves the issue. If the command works but the server doesn't
show up as connected, the problem is on the server's side.

One time I simply forgot that I also need Tailscale running on my own
computer to get through the firewall. I fixed this by setting it to
autostart on boot, so it won't happen again.

Another time, I forgot my own SSH key, which meant connecting the
laptop to an external monitor and setting up a new key for my PC.
The external monitor is my fallback for any situation where remote
access isn't possible, whether that's the server losing its Tailscale
connection or, like here, having no valid SSH key.

### Practicing log-based diagnosis

Beyond these two cases, I try to practice diagnosing issues before
they actually happen, since knowing how to read logs and trace a
problem matters as much as fixing it. For services like Immich, this
means checking `docker compose logs`, and for system-level issues,
`journalctl -u <service>`.
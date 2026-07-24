# home-server

Self-hosted home server on Debian 13: Docker, Immich, Tailscale VPN,
automated backups. Full architecture and security documentation
included.

![Server hardware](docs/images/server-hardware.jpg)

**Stack:**
- Operating system: Debian 13 (Trixie)
- Container runtime: Docker Engine + Compose
- VPN: Tailscale
- Applications: Immich (Photos), PostgreSQL, Redis

## Scripts

| Script | Runs | What it does |
|--------|------|--------------|
| [`backup.sh`](scripts/backup.sh) | automatic, 2:00 daily | Backs up the Immich database and config |
| [`health-check.sh`](scripts/health-check.sh) | automatic, every 15 min | Checks containers, disk, RAM, Tailscale |
| [`weekly-check.sh`](scripts/weekly-check.sh) | manual, weekly | Full check: disk, RAM, containers, backups, SMART, temps |
| [`update.sh`](scripts/update.sh) | manual | Backup, security patches, then updates Docker containers |

## Documentation

| Document | Description |
|----------|-------------|
| [docs/architecture.md](docs/architecture.md) | Design decisions, hardware choices, networking diagram |
| [docs/security-hardening.md](docs/security-hardening.md) | SSH hardening, firewall rules |
| [docs/maintenance-schedule.md](docs/maintenance-schedule.md) | Update cadence, backup schedule, monitoring |

## Repository structure

```
.
├── .env.example
├── .gitignore
├── config
│   ├── systemd
│   │   ├── homeserver-backup.service
│   │   ├── homeserver-backup.timer
│   │   ├── homeserver-health.service
│   │   └── homeserver-health.timer
│   └── ufw-rules.md
├── docker-compose.yml
├── docs
│   ├── architecture.md
│   ├── images
│   │   ├── architecture-diagram.png
│   │   └── server-hardware.jpg
│   ├── maintenance-schedule.md
│   └── security-hardening.md
├── README.md
└── scripts
    ├── backup.sh
    ├── health-check.sh
    ├── update.sh
    └── weekly-check.sh
```

## Roadmap

- [x] Initial setup (Docker, Immich, PostgreSQL, Redis)
- [x] Security hardening (SSH keys, UFW)
- [x] Automated backups and health checks
- [ ] More automation for weekly/monthly maintenance tasks
- [ ] Learning Python through my DevOps course, might use it for future scripts
- [ ] Monitoring (Prometheus + Grafana, after RAM upgrade)
- [ ] External drive backup (no fixed timeline, depends on hardware purchase)

> **Note:** Personal DevOps learning project. Documented to demonstrate
> architecture understanding for job applications.
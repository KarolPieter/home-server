# home-server

Self-hosted home server on Debian 13: Docker, Immich, Tailscale VPN,
automated backups. Full architecture and security documentation
included.

**Stack:**
- Operating system: Debian 13 (Trixie)
- Container runtime: Docker Engine + Compose
- VPN: Tailscale
- Applications: Immich (Photos), PostgreSQL, Redis

## Documentation

| Document | Description |
|----------|-------------|
| [docs/architecture.md](docs/architecture.md) | Design decisions, hardware choices, networking diagram |
| [docs/security.md](docs/security.md) | SSH hardening, firewall rules |
| [docs/maintenance-schedule.md](docs/maintenance-schedule.md) | Update cadence, backup schedule, monitoring |

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
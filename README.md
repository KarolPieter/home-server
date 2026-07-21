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
| [docs/security.md](docs/security.md) | SSH hardening, firewall rules, fail2ban |
| [docs/maintenance-schedule.md](docs/maintenance-schedule.md) | Update cadence, backup schedule, monitoring |

## Roadmap

- [x] Initial setup (Docker, Immich, PostgreSQL, Redis)
- [x] Security hardening (SSH keys, UFW, fail2ban)
- [x] Automated backups and health checks
- [ ] External drive backup (waiting for hardware purchase)
- [ ] Monitoring (Prometheus + Grafana, after RAM upgrade)

> **Note:** Personal DevOps learning project. Documented to demonstrate
> architecture understanding for job applications.
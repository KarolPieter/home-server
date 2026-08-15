# Security hardening

Defense-in-depth: several independent layers, so a failure or bypass
of one doesn't mean the whole server is compromised.

## SSH

I use SSH to connect to and administrate the home server. It's more
secure than the now obsolete Telnet, which sent everything unencrypted.

Password authentication is turned off (`PasswordAuthentication no`),
since I verify my connection using ED25519 keys instead, which
already makes password brute-force attacks irrelevant.

Direct root login is also turned off (`PermitRootLogin no`). Even if
someone got hold of my key, they still couldn't log in directly as
root, they would need to escalate from a regular account first.

## fail2ban

fail2ban is an anti brute-force mechanism. I considered installing it,
but decided against it for now.

SSH passwords are already turned off and replaced with key
verification, so brute-forcing a password isn't possible anyway. On
top of that, the whole server isn't exposed to the public internet at
all, only reachable through Tailscale.

If I ever expose a web service publicly (like a login page), fail2ban
will become worth adding then.

## UFW (firewall)

The firewall is configured to deny all incoming traffic by default,
only allowing connections from the authorized Tailscale range.

On my computer, Tailscale runs automatically in the background. On my
phone, I connect manually through the app when I need access.

Full rules in [config/ufw-rules.md](../config/ufw-rules.md).

## Docker + UFW

Not all allowed traffic comes from Tailscale. Adding the Zabbix agent
required one exception.

The Zabbix agent runs on the host, not inside Docker, and listens on
port 10050. The zabbix-server container initiates the connection to
the agent to pull data, which is called a "passive check" in Zabbix
terminology. UFW denies all traffic by default, so I had to add a new
rule allowing this specific traffic, coming from Docker's internal
network instead of Tailscale.

## Docker publishing ports vs UFW

I discovered that anyone on my local network had access to Immich, no
matter if they used Tailscale or not. While Immich uses its own
account system, this wasn't a big security issue, but I still prefer
to make it accessible only through Tailscale.

By default, Docker ignores UFW rules and manages incoming traffic
through its own set of `iptables` rules, which meant my "Tailscale
only" rule had no effect on container ports. I installed
[ufw-docker](https://github.com/chaifeng/ufw-docker), which made it
possible to actually restrict container traffic to Tailscale.

`ufw-docker`'s default rules still allowed traffic from entire private
network ranges, not just Tailscale. I commented those out and kept
only the rule allowing my Tailscale range.

While fixing Immich, I noticed that Zabbix Web didn't have any UFW
rule at all. I added an `ALLOW FWD` rule for it, restricted to
Tailscale, the same way as Immich.

## Tailscale

Tailscale is the only way to reach the server from outside my home
network. There are no open ports, so the server is invisible from the
public internet.

Full reasoning behind choosing Tailscale in
[docs/architecture.md](architecture.md#tailscale-instead-of-port-forwarding).

This comes at a cost: if either the server or my computer loses its
Tailscale connection, there's no remote way to fix it. A manual fix on
the laptop itself becomes necessary. More on fixing this in
[docs/maintenance-schedule.md](maintenance-schedule.md#troubleshooting-and-diagnostics).

## Automatic security updates

Only Debian security patches are downloaded and installed
automatically, since they're critical for the server's safety.

Regular package updates are left for later, reviewed manually before
installing. They might bring changes that break something in my
setup, so I don't want them applied without checking first.

The same applies to other services like Docker, Immich, and Tailscale.
Their updates can bring unintended changes, so I review release notes
before updating them manually.

## The pg_hba.conf accident

`pg_hba.conf` controls which users can connect to a PostgreSQL
database, from which hosts, and how they authenticate. While checking
it, I found a broad rule: `host all all all scram-sha-256`, allowing
any user to connect from anywhere. It looked unnecessary, and I try to
keep my network rules as strict as possible, so I removed it.

This broke Zabbix. The web dashboard started showing "Database error",
because that rule was what allowed the `zabbix` user, used by both the
dashboard and the `zabbix-server` container, to connect to the
database at all.

I checked the database container's logs instead of guessing, and
found the exact cause:

```
FATAL: no pg_hba.conf entry for host, user "zabbix"
```

I added the rule back, but narrower than the original: limited to
Docker's internal subnet instead of any address.

## What I intentionally kept simple

This setup doesn't have an IDS/IPS (like CrowdSec), no centralized log
monitoring (SIEM), and no 2FA on SSH beyond the key itself.

For a home server with one service and traffic limited to Tailscale,
none of this is urgent. I already have Zabbix running for
infrastructure monitoring, but I'd still like to try Prometheus and
Grafana later, mainly to understand how they work rather than because
this setup needs another monitoring stack.
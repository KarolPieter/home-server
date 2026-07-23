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

## Tailscale

Tailscale is the only way to reach the server from outside my home
network. There are no open ports, so the server is invisible from the
public internet.

Full reasoning behind choosing Tailscale in
[docs/architecture.md](architecture.md#tailscale-instead-of-port-forwarding).

## Automatic security updates

Only Debian security patches are downloaded and installed
automatically, since they're critical for the server's safety.

Regular package updates are left for later, reviewed manually before
installing. They might bring changes that break something in my
setup, so I don't want them applied without checking first.

The same applies to other services like Docker, Immich, and Tailscale.
Their updates can bring unintended changes, so I review release notes
before updating them manually.

## What I intentionally kept simple

This setup doesn't have an IDS/IPS (like CrowdSec), no centralized log
monitoring (SIEM), and no 2FA on SSH beyond the key itself.

For a home server with one service and traffic limited to Tailscale,
none of this is urgent. I'm aware of these tools and plan to learn
them eventually, the same way I plan to add Prometheus and Grafana
later, mainly to understand how they work rather than because this
setup needs them right now.
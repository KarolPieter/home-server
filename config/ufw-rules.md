# UFW rules

Default policy: deny all incoming traffic. Only the rules below are
allowed, everything else is blocked.

To check the current rules on the server:

```
sudo ufw status numbered
```

```
Status: active

     To                         Action      From
     --                         ------      ----
[ 1] 22                         ALLOW IN    100.x.x.x/x
[ 2] 2283                       ALLOW IN    100.x.x.x/x
```

| Port | Service | Source         |
|------|---------|----------------|
| 22   | SSH     | Tailscale only |
| 2283 | Immich  | Tailscale only |

Both rules only allow traffic from the Tailscale IP range
(`100.x.x.x/x`), never from the public internet. See
[docs/security.md](../docs/security.md#tailscale) for the full
reasoning behind this setup.
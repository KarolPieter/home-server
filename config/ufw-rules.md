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
[ 1] 10050/tcp                  ALLOW IN    172.16.238.0/24           
[ 2] 2283/tcp                   ALLOW FWD   100.64.0.0/10             
[ 3] 22/tcp                     ALLOW IN    100.64.0.0/10             
[ 4] 8080/tcp                   ALLOW FWD   100.64.0.0/10  
```

| Port  | Service     | Source         |
|-------|-------------|----------------|
| 10050 | Zabbix agent| Docker bridge  |
| 2283  | Immich      | Tailscale only |
| 22    | SSH         | Tailscale only |
| 8080  | Zabbix web  | Tailscale only |


Zabbix agent works outside of docker conteiner to gather all the
data about server. Port 10050 is open to allow the Zabbix container to send
query to Zabbix agent which waits passsively to send the information
Rest of the rules only allow traffic from the Tailscale IP range
(`100.x.x.x/x`), never from the public internet. See
[docs/security-hardening.md](../docs/security-hardening.md#tailscale) for the full
reasoning behind this setup.
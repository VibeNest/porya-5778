# VibeNest deployment notes for 3X-UI

This copy keeps the upstream 3X-UI source and Docker build, with two deployment
defaults adjusted for a hosted container platform:

- Web panel port: `8080` via `XUI_PORT=8080`
- Fail2ban: disabled by default because hosted containers may not have the
  `NET_ADMIN` / `NET_RAW` capabilities required to enforce iptables bans.

## VibeNest

1. Put this repository on your GitHub account.
2. In VibeNest, create a project from the GitHub repository.
3. Select the **Dockerfile** build method.
4. Deploy the service and attach persistent storage to `/etc/x-ui`.
5. If VibeNest asks for the service port, use `8080`.

## Important networking limitation

A working 3X-UI web panel does **not** automatically mean that Xray proxy
inbounds will be reachable from the public Internet.

3X-UI normally needs publicly reachable TCP/UDP ports for the proxy inbounds.
A PaaS platform that only exposes the web service through its HTTPS route may
therefore let the panel work while preventing VLESS/VMess/Trojan/WireGuard/etc.
inbounds from accepting direct client traffic.

Before using this for proxy traffic, verify that the VibeNest plan/runtime
provides the required public TCP/UDP port exposure. Do not assume that the
HTTPS web-service port is equivalent to arbitrary TCP/UDP forwarding.

## Persistence

The 3X-UI database and panel state live under `/etc/x-ui`. Use persistent
storage there so redeploys do not reset the panel state.

## Security

Set a strong panel username/password immediately after deployment. Do not put
secrets, private keys, or an existing database into a public Git repository.

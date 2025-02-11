# WireGuard Monitor

This script monitors WireGuard peers and checks their handshake status. If any peer has an outdated handshake or has never handshaked, it will reset the peer's endpoint based on the configuration defined in `/etc/wireguard/wg*.conf` files.

## Description

The `wg-monitor.pl` script performs the following tasks:

- Checks all WireGuard interfaces (`wg*.conf` files) in `/etc/wireguard/`.
- Extracts the peer information (public key and endpoint) from each WireGuard configuration file.
- Checks the handshake status of each peer.
  - If the handshake has never occurred or if it exceeds a maximum timeout, the script will reset the peer's endpoint.
  
The script is designed to run periodically with the help of a `systemd` timer.

## Installation

1. Clone or download the repository.

2. Install the script and systemd units (timer and service):

```bash
sudo make install
```

This will:

- Install the wg-monitor.pl script to /usr/local/bin/.
- Install the wg-monitor.timer and wg-monitor.service systemd unit files to /etc/systemd/system/.
- Enable and start the systemd timer (wg-monitor.timer).

## Uninstallation

To uninstall the script and systemd units, run:

```bash
sudo make uninstall
```

## Systemd Timer Status

To check the status of the wg-monitor.timer, you can use the following command:

```bash
systemctl status wg-monitor.timer
```

To see the last run time and the next scheduled run, use:

```bash
sudo systemctl list-timers
```

## License

Creative Commons Attribution 4.0 International License (CC BY 4.0)
See LICENSE.md for details.
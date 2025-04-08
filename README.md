# NOOK VPN Utilities

A complete solution for setting up a home network with WireGuard VPN, Pi-hole ad-blocking, and other useful services on a mini PC running Ubuntu.

## Services Included

- **WireGuard VPN** - Secure VPN tunnel for remote access to your home network
- **Pi-hole** - Network-wide ad blocking DNS server
- **Portainer** - Docker container management GUI
- **Uptime Kuma** - Monitor your services and receive alerts
- **Homer Dashboard** - A sleek dashboard to access all your services
- **n8n** - Powerful workflow automation tool

## Requirements

- Ubuntu-based mini PC
- Internet connection
- Router with port forwarding capability (for remote access)

## Quick Start

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/NOOK-VPN-Utilities.git
   cd NOOK-VPN-Utilities
   ```

2. Run the setup script:
   ```bash
   ./scripts/setup.sh
   ```

3. Follow the prompts to configure your services.

4. Access your services:
   - Homer Dashboard: http://your-server-ip:8081
   - Pi-hole: http://your-server-ip:8080/admin
   - Portainer: http://your-server-ip:9000
   - Uptime Kuma: http://your-server-ip:3001
   - n8n: http://your-server-ip:5678

## Enabling Autostart on System Boot

To make all services start automatically when your system boots:

1. Run the autostart setup script with sudo:
   ```bash
   sudo ./scripts/enable-autostart.sh
   ```

2. The script will:
   - Create a systemd service file
   - Enable the service to start at boot
   - Start the service immediately

3. To check the status:
   ```bash
   sudo systemctl status nook-vpn.service
   ```

4. To disable autostart:
   ```bash
   sudo systemctl disable nook-vpn.service
   ```

## Manual Setup

If you prefer to set up manually:

1. Update the IP address in `docker-compose.yml` and `dashboard/config/config.yml` to match your server IP
2. Create required directories:
   ```bash
   mkdir -p wireguard/config pihole/etc-pihole pihole/etc-dnsmasq.d portainer/data uptime-kuma/data dashboard/config n8n/data
   ```
3. Start the services:
   ```bash
   docker-compose up -d
   ```

## WireGuard VPN Setup

After installation, WireGuard configuration files for your clients will be available in the `wireguard/config` directory. The names will be in the format `peer1`, `peer2`, etc.

For mobile devices:
1. Install the WireGuard app on your device
2. Scan the QR code displayed in the WireGuard UI or import the configuration file

For desktop:
1. Install the WireGuard client
2. Import the appropriate configuration file

## Remote Access

To enable remote access to your VPN:

1. Forward UDP port 51820 on your router to your mini PC's IP address
2. Update the `SERVERURL` environment variable in `docker-compose.yml` to your public IP or a dynamic DNS address

## n8n Workflow Automation

n8n is a powerful workflow automation tool that allows you to connect various services and automate tasks.

After installation:
1. Access n8n at http://your-server-ip:5678
2. Login with the credentials you set during setup
3. Start creating workflows by connecting different nodes

Some example use cases:
- Send notifications when new devices connect to your network
- Automate backups of your configurations
- Schedule system updates
- Monitor and alert on system metrics

## Backup and Restore

### Creating a Backup

Run the backup script to create a timestamped backup of all configurations:
```bash
./scripts/backup.sh
```

The script will create a backup file in the `backups/` directory with the format `nook_vpn_backup_YYYYMMDD_HHMMSS.tar.gz`.

### Restoring from Backup

To restore from a backup:
```bash
./scripts/restore.sh backups/nook_vpn_backup_YYYYMMDD_HHMMSS.tar.gz
```

This will restore all configurations and restart the services.

## Customization

- Edit `docker-compose.yml` to modify service configurations
- Update `dashboard/config/config.yml` to customize your Homer dashboard
- Add more services as needed

## Maintenance

- Update all containers:
  ```bash
  docker-compose pull
  docker-compose up -d
  ```

- View logs:
  ```bash
  docker-compose logs -f [service_name]
  ```

## Troubleshooting

- **Can't connect to WireGuard**:
  - Check port forwarding on your router
  - Verify that your server is reachable from the internet
  - Check WireGuard logs: `docker-compose logs wireguard`

- **Pi-hole not blocking ads**:
  - Make sure your devices are using Pi-hole as their DNS server
  - Check Pi-hole logs: `docker-compose logs pihole`

- **n8n workflows not running**:
  - Check if webhooks are accessible from the internet (if used)
  - Verify connectivity to external services
  - Check n8n logs: `docker-compose logs n8n`

- **Services not starting on boot**:
  - Check systemd service status: `sudo systemctl status nook-vpn.service`
  - Check logs: `journalctl -u nook-vpn.service`
  - Ensure Docker is set to start on boot: `sudo systemctl enable docker`

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [linuxserver.io](https://linuxserver.io/) for the WireGuard Docker image
- [Pi-hole](https://pi-hole.net/) for the amazing ad-blocking solution
- [Portainer](https://www.portainer.io/) for container management
- [Uptime Kuma](https://github.com/louislam/uptime-kuma) for monitoring
- [Homer](https://github.com/bastienwirtz/homer) for the dashboard
- [n8n](https://n8n.io/) for workflow automation 
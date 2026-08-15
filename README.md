# Self-Hosted Server

Infrastructure-as-code for provisioning and managing a personal self-hosted Linux server with Ansible.

The project automates the server's operating system, Docker environment, networking, storage, security and self-hosted services through modular Ansible roles.

## Repository Structure

### `bootstrap.yml`

Initial server provisioning.

### `main.yml`

Main server configuration playbook.

### `roles/`

Each major component is implemented as an independent Ansible role.

The current stack includes:
- Common system configuration
- Linux server configuration
- Backup management
- System maintenance
- Docker host
- Local DNS
- Reverse proxy
- Portainer
- Docker update notifications
- System monitoring
- Homepage dashboard
- Cloudflare integration
- Node-RED
- Code Server
- Speedtest Tracker
- Password manager
- VPN client
- Media downloader
- Media server
- YouTube downloader

## Configuration

Host-specific and sensitive configuration is separated from the reusable roles.

Secrets are managed locally using **Ansible Vault**.

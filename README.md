# Self-Hosted Server

Ansible configuration for provisioning and managing a personal Linux self-hosted server.

The project uses a modular set of Ansible roles to automate system configuration, Docker, networking, reverse proxying, backups, monitoring, and self-hosted services.

## Overview

The server is managed as infrastructure-as-code using Ansible.

The configuration is organized around reusable roles, allowing individual services and system components to be enabled, configured, and maintained independently.

### Main components

* **Ubuntu Linux** server
* **Ansible** for configuration management
* **Docker** for containerized services
* **Traefik** for reverse proxy and HTTPS
* **Cloudflare** for DNS integration
* **Local DNS** services
* **Portainer** for Docker management
* **Automated backups**
* **System maintenance and monitoring**
* **VPN connectivity**
* **Media and download services**
* **Web-based development tools**

## Ansible Playbooks

### `bootstrap.yml`

Used for the initial provisioning of a host.

### `main.yml`

The main configuration playbook.

It applies the common system configuration first and then configures the Linux server and its services through individual roles.

The current stack includes:

* Common system configuration
* Linux server configuration
* Backup management
* System maintenance
* Docker host
* Local DNS
* Reverse proxy
* Portainer
* Docker update notifications
* System monitoring
* Homepage dashboard
* Cloudflare integration
* Node-RED
* Code Server
* Speedtest Tracker
* Password manager
* VPN client
* Media downloader
* Media server
* YouTube downloader

## Storage

The server configuration supports separate system and data storage.

Additional drives are defined through host variables and can be assigned dedicated filesystems and mount points.

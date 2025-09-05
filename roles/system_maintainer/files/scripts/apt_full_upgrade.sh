#!/bin/bash
set -euo pipefail

echo "[APT Full Upgrade] Starting full-upgrade..."

apt update

DEBIAN_FRONTEND=noninteractive apt full-upgrade -y

echo "[APT Full Upgrade] Completed successfully."

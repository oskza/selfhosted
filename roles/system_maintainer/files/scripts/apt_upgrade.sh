#!/bin/bash
set -euo pipefail

echo "[APT Upgrade] Starting upgrade..."

apt update
apt upgrade -y

echo "[APT Upgrade] Completed successfully."

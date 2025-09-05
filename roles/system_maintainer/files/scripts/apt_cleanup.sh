#!/bin/bash
# Simple APT cleanup script
# Προσοχή: τρέχει με root

set -euo pipefail

echo "[APT Cleanup] Starting cleanup..."
apt-get autoremove --purge -y
apt-get autoclean -y
echo "[APT Cleanup] Completed successfully."

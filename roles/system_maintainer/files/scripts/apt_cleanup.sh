#!/bin/bash
set -euo pipefail

echo "[APT Cleanup] Starting cleanup..."
apt-get autoremove --purge -y
apt-get autoclean -y
echo "[APT Cleanup] Completed successfully"

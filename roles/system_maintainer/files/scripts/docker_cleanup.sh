#!/bin/bash
# Docker cleanup script (safe defaults: images + networks)
# Προσοχή: ΜΗΝ βάλεις full prune by default

set -euo pipefail

echo "[Docker Cleanup] Starting cleanup..."

# Remove dangling images
docker image prune -f

# Remove unused networks
docker network prune -f

# Προαιρετικά: uncomment αν θέλεις να καθαρίζει και volumes
# docker volume prune -f

echo "[Docker Cleanup] Completed successfully."

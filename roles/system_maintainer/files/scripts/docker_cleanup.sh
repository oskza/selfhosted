#!/bin/bash
set -euo pipefail

echo "[Docker Cleanup] Starting cleanup..."
docker image prune -f
docker network prune -f
echo "[Docker Cleanup] Completed successfully"

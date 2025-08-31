#!/usr/bin/env bash
set -euo pipefail

[[ $# -ge 1 && $# -le 2 ]] || { echo "Usage: $0 <volume_name> [<backup_folder>|latest]"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/shared/docker_helpers.sh"

VOLUME_NAME="$1"
BACKUP_ARG="${2:-latest}"

USER_NAME=$(whoami)

BACKUP_BASE_DIR="${BACKUP_DIR:-/backups}/volumes"
BACKUP_FILE="${VOLUME_NAME}.backup.tar"

stopped_containers=()
trap '_cleanup_stopped_containers stopped_containers' EXIT INT

if [[ "$BACKUP_ARG" == "latest" ]]; then
    BACKUP_FOLDER=$(find "$BACKUP_BASE_DIR" -mindepth 1 -maxdepth 1 -type d \
        -exec test -f "{}/$BACKUP_FILE" ';' -print \
        | sort -r | head -n1)
    [[ -n "$BACKUP_FOLDER" ]] || { echo "❌ No backups found for volume '$VOLUME_NAME'"; exit 1; }
elif [[ -d "$BACKUP_BASE_DIR/$BACKUP_ARG" ]]; then
    BACKUP_FOLDER="$BACKUP_BASE_DIR/$BACKUP_ARG"
    [[ -f "$BACKUP_FOLDER/$BACKUP_FILE" ]] || { echo "❌ Backup file not found in '$BACKUP_ARG'"; exit 1; }
else
    echo "❌ Backup folder '$BACKUP_ARG' not found"
    exit 1
fi

echo -e "\n\e[1m\U1F504 Starting restore of volume '\e[4m$VOLUME_NAME\e[0m\e[1m' from backup folder '\e[4m$BACKUP_FOLDER\e[0m\e[1m'\e[0m\n"

mapfile -t containers_running < <(docker ps --format '{{.Names}}')

used_by=()
_get_containers_using_volume "$VOLUME_NAME" containers_running used_by

if [[ ${#used_by[@]} -gt 0 ]]; then
    _stop_containers used_by stopped_containers
fi

echo -e "\U0001F4BE Restoring data to volume → \e[1m$VOLUME_NAME\e[0m from \e[3m$BACKUP_FOLDER/$BACKUP_FILE\e[0m"

docker run --rm \
    -v "${VOLUME_NAME}:/data" \
    -v "${BACKUP_FOLDER}:/backup:ro" \
    alpine \
    sh -c "rm -rf /data/* && tar xf /backup/${BACKUP_FILE} -C /data && chown -R $(id -u):$(id -g) /data"

if [[ ${#used_by[@]} -gt 0 ]]; then
    _start_containers used_by stopped_containers
fi

echo -e "\n✅ Restore completed for volume '\e[1m$VOLUME_NAME\e[0m'.\n"

trap - EXIT INT

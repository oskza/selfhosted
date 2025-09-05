#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shared/docker_helpers.sh"

CONFIG_FILE="/etc/docker-backup.conf"
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
fi

: "${BACKUP_VOLUMES_DIR:=/backups/volumes}"
BACKUP_TARGET_DIR="$BACKUP_VOLUMES_DIR/$(date +%F_%H-%M)"

stopped_containers=()
trap '_cleanup_stopped_containers stopped_containers' EXIT INT

_should_exclude_volume() {
    local vol="$1"

    for pattern in ${EXCLUDE_VOLUMES:-}; do
        [[ "$vol" == $pattern ]] && return 0
    done
    return 1
}

_backup_volume() {
    local volume=$1
    local backup_dir=$2

    local backup_file="${volume}.backup.tar"
    printf '\U0001F4CB Archiving volume data → \e[1m%s\e[0m\n' "$backup_file"
    docker run --rm \
        -v "${volume}:/data:ro" \
        alpine \
        tar cf - -C /data . > "${backup_dir}/${backup_file}"
}

printf "\n\e[1m\U1F680 Launching Docker Volumes Backup\e[0m...\n\n"

mkdir -p "$BACKUP_TARGET_DIR"

volumes=$(docker volume ls -q)

mapfile -t containers_running < <(docker ps --format '{{.Names}}')

for volume in $volumes; do
    if _should_exclude_volume "$volume"; then
        echo -e "⏩ Skipping volume: \e[1m$volume\e[0m\n"
        continue
    fi
    printf '\U0001F4E6 Backing up volume → \e[1m%s\e[0m\n' "$volume"
    used_by=()
    _get_containers_using_volume "$volume" containers_running used_by
    if [[ ${#used_by[@]} -gt 0 ]]; then
        _stop_containers used_by stopped_containers
    fi
    _backup_volume "$volume" "$BACKUP_TARGET_DIR"
    if [[ ${#used_by[@]} -gt 0 ]]; then
        _start_containers used_by stopped_containers
    fi
    echo -e "✅ Backup saved successfully\n"
done

printf '\U0001F389 All volumes backed up successfully! Files saved to: \e[3m%s\e[0m\n' "$BACKUP_TARGET_DIR"

: "${RETENTION_DAYS:=14}"
echo "🧹 Cleaning up backups older than $RETENTION_DAYS days..."
find "$BACKUP_VOLUMES_DIR" -maxdepth 1 -mindepth 1 -type d -mtime +"$RETENTION_DAYS" -exec rm -rf {} \;

trap - EXIT INT

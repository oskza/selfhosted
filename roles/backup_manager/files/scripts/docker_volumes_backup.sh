#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/shared/docker_helpers.sh"

EXCLUDE_FILE="$SCRIPT_DIR/shared/exclude_volumes.txt"
BACKUP_TARGET_DIR="${BACKUP_DIR:-/backups}/volumes/$(date +%F_%H-%M)"
USER_NAME=$(whoami)

exclude_patterns=()
stopped_containers=()
trap '_cleanup_stopped_containers stopped_containers' EXIT INT

_should_exclude_volume() {
    local vol="$1"

    for pattern in "${exclude_patterns[@]}"; do
        if [[ "$vol" == $pattern ]]; then
            return 0
        fi
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

if [[ -f "$EXCLUDE_FILE" ]]; then
    while IFS= read -r line; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        exclude_patterns+=("$line")
    done < "$EXCLUDE_FILE"
else
    echo "⚠️  Warning: File '$EXCLUDE_FILE' not found. All volumes will be backed up."
fi

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

trap - EXIT INT

#!/usr/bin/env bash
set -euo pipefail

_stop_containers() {
  local -n containers="$1"
  local -n stopped_ref="$2"

  for c in "${containers[@]}"; do
    echo -e "⏸️  Stopping container → \e[1m$c\e[0m"
    docker stop "$c" > /dev/null 2>&1 || echo "⚠️ Failed to stop $c"
    stopped_ref+=("$c")
  done
}

_start_containers() {
  local -n containers="$1"
  local -n stopped_ref="$2"

  for c in "${containers[@]}"; do
    echo -e "▶️  Starting container → \e[1m$c\e[0m"
    docker start "$c" > /dev/null 2>&1 || echo "⚠️ Failed to start $c"
    for i in "${!stopped_ref[@]}"; do
      if [[ "${stopped_ref[i]}" == "$c" ]]; then
        unset 'stopped_ref[i]'
        break
      fi
    done
  done
}

_get_containers_using_volume() {
  local volname="$1"
  local -n containers_ref="$2"
  local -n result_ref="$3"

  result_ref=()
  for container in "${containers_ref[@]}"; do
    local mounts
    mounts=$(docker inspect "$container" \
        --format '{{range .Mounts}}{{if eq .Type "volume"}}{{printf "%s\n" .Name}}{{end}}{{end}}' \
        2>/dev/null) || continue

    while IFS= read -r name; do
      [[ -z "$name" ]] && continue
      if [[ "$name" == "$volname" ]]; then
        result_ref+=("$container")
        break
      fi
    done <<< "$mounts"
  done
}

_cleanup_stopped_containers() {
  local -n stopped_ref="$1"
  echo "🔄 Restarting stopped containers..."
  for c in "${stopped_ref[@]}"; do
    docker start "$c" > /dev/null 2>&1 || echo "⚠️ Failed to restart $c"
  done
}

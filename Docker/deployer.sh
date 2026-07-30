#!/bin/bash
set -euo pipefail

while [ $# -gt 0 ]; do
  case "$1" in
    --image=*)
      IMAGE="${1#*=}"
      ;;
    --container-port=*)
      CONTAINER_PORT="${1#*=}"
      ;;
    --system-port=*)
      SYSTEM_PORT="${1#*=}"
      ;;
    --registry-token=*)
      REGISTRY_TOKEN="${1#*=}"
      ;;
    --registry-host=*)
      REGISTRY_HOST="${1#*=}"
      ;;
    --container-name=*)
      CONTAINER_NAME="${1#*=}"
      ;;
    --registry-user=*)
      REGISTRY_USER="${1#*=}"
      ;;
    *)
      printf "***************************\n"
      printf "* Error: Invalid argument.*\n"
      printf "***************************\n"
      exit 1
  esac
  shift
done


for required in IMAGE CONTAINER_NAME CONTAINER_PORT SYSTEM_PORT REGISTRY_HOST REGISTRY_USER REGISTRY_TOKEN; do
  if [ -z "${!required:-}" ]; then
    printf "Error: --%s is required.\n" "$(echo "$required" | tr '[:upper:]_' '[:lower:]-')" >&2
    exit 1
  fi
done

docker container prune -f
printf '%s' "$REGISTRY_TOKEN" | docker login "$REGISTRY_HOST" -u "$REGISTRY_USER" --password-stdin
docker pull "$IMAGE"
echo "Clean temp Container"

# `docker ps -q` prints nothing when no container matches, so test the output,
# not the exit status (docker exits 0 either way).
if [ -n "$(docker ps -aq --filter "name=^${CONTAINER_NAME}$")" ]; then
  docker stop "$CONTAINER_NAME"
  docker rm -f "$CONTAINER_NAME"
fi
docker run -d -p "$SYSTEM_PORT:$CONTAINER_PORT" --restart=always --name "$CONTAINER_NAME" "$IMAGE"

!/bin/bash
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


echo y | docker container prune
echo $REGISTRY_TOKEN | docker login $REGISTRY_HOST  -u $REGISTRY_USER --password-stdin
docker pull $IMAGE
echo "Clean temp Container"

if $(docker ps | awk -v CONTAINER_NAME="$CONTAINER_NAME" 'NR > 1 && $NF == CONTAINER_NAME{ret=1; exit} END{exit !ret}' ); then
  docker stop "$CONTAINER_NAME" 
  docker rm -f "$CONTAINER_NAME"
fi
docker run -d -p $SYSTEM_PORT:$CONTAINER_PORT --restart=always --name $CONTAINER_NAME $IMAGE

#!/bin/bash

set -Eeuo pipefail

source "${BASH_SOURCE%/*}/set_envs.bash"

echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

docker push "$image"
if [ -d passenger ]; then
  docker push "$image-passenger"
fi

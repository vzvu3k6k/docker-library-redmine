#!/bin/bash

set -Eeuo pipefail

source "${BASH_SOURCE%/*}/set_envs.bash"

# Remove old tags
TOKEN=$(curl -sS -H "Content-Type: application/json" -X POST -d '{"username": "'${DOCKER_USRNAME}'", "password": "'${DOCKER_PASSWORD}'"}' https://hub.docker.com/v2/users/login/ | jq -r .token)
AUTH="Authorization: JWT ${TOKEN}"

IMAGE_TAGS=$(curl -s -H "$AUTH" 'https://hub.docker.com/v2/repositories/vzvu3k6k/redmine/tags?page_size=100&n=2&ordering=-last_updated' | jq -r '.results|.[]|.name')

for tag in ${IMAGE_TAGS}; do
  curl -s -H "$AUTH" -X DELETE "https://hub.docker.com/v2/repositories/vzvu3k6k/redmine/tags/${tag}/"
done

# Push new tags
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
docker push "$image_name"

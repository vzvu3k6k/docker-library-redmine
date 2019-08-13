#!/bin/bash

SAVED_OPTIONS=$(set +o)

set -Eeuo pipefail
set -x

if [ -f .revision ]; then
  revision="$(cat .revision)"
else
  revision="$(svn info http://svn.redmine.org/redmine/trunk | grep -o -P "^Revision: \K(\d+)$")"
  echo "$revision" > .revision
fi
export revision

export image_name="$DOCKER_USERNAME/redmine"

tag="${VERSION//\//-}"
if [ $TRAVIS_BRANCH = "deploy-test" ]; then
  tag="deploy-test-${tag}"
fi
revision_tag="${tag/trunk/r$revision}"

export trunk_image="${image_name}:${tag}"
export revision_image="${image_name}:${revision_tag}"

eval "$SAVED_OPTIONS"

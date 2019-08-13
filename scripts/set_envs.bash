#!/bin/bash

SAVED_OPTIONS=$(set +o)

set -Eeuo pipefail
set -x

export revision=$(svn info http://svn.redmine.org/redmine/trunk | grep -o -P "^Revision: \K(\d+)$")

image="$DOCKER_USERNAME/redmine:${VERSION//\//-}"
image="${image/trunk/r$revision}"
if [ $TRAVIS_BRANCH = "deploy-test" ]; then
  image="${image}-deploy-test"
fi
export image

eval "$SAVED_OPTIONS"

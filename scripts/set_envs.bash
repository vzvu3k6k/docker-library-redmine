#!/bin/bash

SAVED_OPTIONS=$(set +o)

set -Eeuo pipefail
set -x

export revision=$(svn info http://svn.redmine.org/redmine/trunk | grep -o -P "^Revision: \K(\d+)$")

image="$DOCKER_USERNAME/redmine:${VERSION//\//-}"
export image="${image/trunk/r$revision}"

eval "$SAVED_OPTIONS"

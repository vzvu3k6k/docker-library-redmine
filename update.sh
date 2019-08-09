#!/usr/bin/env bash
set -Eeuo pipefail

# see https://www.redmine.org/projects/redmine/wiki/redmineinstall
rubyVersion='2.6'

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

passenger="$(wget -qO- 'https://rubygems.org/api/v1/gems/passenger.json' | sed -r 's/^.*"version":"([^"]+)".*$/\1/')"

travisEnv=

echo "trunk (ruby $rubyVersion; passenger $passenger)"

cp docker-entrypoint.sh "trunk/"
sed -e 's/%%RUBY_VERSION%%/'"$rubyVersion"'/' \
	Dockerfile-debian.template > "trunk/Dockerfile"

mkdir -p "trunk/passenger"
sed -e 's/%%PASSENGER_VERSION%%/'"$passenger"'/' \
	Dockerfile-passenger.template > "trunk/passenger/Dockerfile"

mkdir -p "trunk/alpine"
cp docker-entrypoint.sh "trunk/alpine/"
sed -i -e 's/gosu/su-exec/g' "trunk/alpine/docker-entrypoint.sh"
sed -e 's/%%RUBY_VERSION%%/'"$rubyVersion"'/' \
	Dockerfile-alpine.template > "trunk/alpine/Dockerfile"

travisEnv='\n  - VERSION='"trunk/alpine$travisEnv"
travisEnv='\n  - VERSION='"trunk$travisEnv"

travis="$(awk -v 'RS=\n\n' '$1 == "env:" { $0 = "env:'"$travisEnv"'" } { printf "%s%s", $0, RS }' .travis.yml)"
echo "$travis" > .travis.yml

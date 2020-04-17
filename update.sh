#!/usr/bin/env bash
set -Eeuo pipefail

# see https://www.redmine.org/projects/redmine/wiki/redmineinstall
rubyVersion='2.6'

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

passenger="$(wget -qO- 'https://rubygems.org/api/v1/gems/passenger.json' | sed -r 's/^.*"version":"([^"]+)".*$/\1/')"

travisEnv=

echo "trunk (ruby $rubyVersion; passenger $passenger)"

commonSedArgs+=(
	-r
	-e 's/%%RUBY_VERSION%%/'"$rubyVersion"'/'
	-e 's/%%PASSENGER_VERSION%%/'"$passenger"'/'
	-e '/imagemagick-dev/d'
	-e '/libmagickcore-dev/d'
	-e '/libmagickwand-dev/d'
)

alpineSedArgs=()

cp docker-entrypoint.sh "trunk/"
sed "${commonSedArgs[@]}" Dockerfile-debian.template > "trunk/Dockerfile"

mkdir -p "trunk/passenger"
sed "${commonSedArgs[@]}" Dockerfile-passenger.template > "trunk/passenger/Dockerfile"

mkdir -p "trunk/alpine"
cp docker-entrypoint.sh "trunk/alpine/"
sed -i -e 's/gosu/su-exec/g' "trunk/alpine/docker-entrypoint.sh"
sed "${commonSedArgs[@]}" "${alpineSedArgs[@]}" Dockerfile-alpine.template > "trunk/alpine/Dockerfile"

travisEnv='\n  - VERSION='"trunk/alpine$travisEnv"
travisEnv='\n  - VERSION='"trunk$travisEnv"

travis="$(awk -v 'RS=\n\n' '$1 == "env:" { $0 = "env:'"$travisEnv"'" } { printf "%s%s", $0, RS }' .travis.yml)"
echo "$travis" > .travis.yml

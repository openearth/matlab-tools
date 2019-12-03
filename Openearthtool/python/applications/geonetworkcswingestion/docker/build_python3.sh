#!/usr/bin/env bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
# svn repository url
SVN_REPOS=${1:-$(svn info "$DIR" --show-item repos-root-url)}

echo "repository server: $SVN_REPOS"

if [ -z "$SVN_USERNAME" ]; then
    # prompt for username
    echo -n "SVN Username: "
    read -p "" SVN_USERNAME
else
    echo "Username: $SVN_USERNAME"
fi

if [ -z "$SVN_PASSWORD" ]; then
    echo -n "Password: "
    read -s -p "" SVN_PASSWORD
    echo ""
fi

if [ -z "$GN_URL" ]; then
    echo -n "Geonetwork URL: "
    read -p "" GN_URL
    echo ""
fi

if [ -z "$GN_USERNAME" ]; then
    echo -n "Geonetwork Username: "
    read -p "" GN_USERNAME
    echo ""
fi

if [ -z "$GN_PASSWORD" ]; then
    echo -n "Geonetwork Password: "
    read -s -p "" GN_PASSWORD
    echo ""
fi

# build docker image
docker build \
  --tag geocswing_python3.6.5 \
  --build-arg SVN_REPOS=$SVN_REPOS \
  --build-arg SVN_USERNAME=$SVN_USERNAME \
  --build-arg SVN_PASSWORD=$SVN_PASSWORD \
  --build-arg GN_URL=$GN_URL \
  --build-arg GN_USERNAME=$GN_USERNAME \
  --build-arg GN_PASSWORD=$GN_PASSWORD \
  .

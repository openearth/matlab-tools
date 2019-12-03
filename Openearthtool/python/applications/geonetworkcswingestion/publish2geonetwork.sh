#!/usr/bin/env bash

# script to run on docker host
# call script with data-directory to publish to geonetwork as first argument
# example ./publish2geonetwork.sh


DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)

# svn repository url
# Provide repository url as first argument. (fall back to current repository)
SVN_REPOS=${1:-$(svn info "$DIR" | awk '/^Repository Root:/{ print $NF}')}
# Provide dataset path (relative to repository url) as second argument. (if not provided, the whole repository will be crawled)
SVN_DATASET=${2:-}

echo "$#"

if [ "$#" -lt 3 ]; then
    # PRODUCTION Run docker container to add metadata to geonetwork.
    docker run --rm \
        --env SVN_DATASET=$SVN_DATASET \
        --env SVN_REPOS=$SVN_REPOS \
        geocswing_python3.6.5
else
    # DEVELOPMENT Run docker container to add metadata to geonetwork.
    docker run --rm \
        --env SVN_DATASET=$SVN_DATASET \
        --env SVN_REPOS=$SVN_REPOS \
        -v $(pwd):/data/tools \
        geocswing_python3.6.5 dev
fi
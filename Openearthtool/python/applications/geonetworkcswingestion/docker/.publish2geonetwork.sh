#!/usr/bin/env bash

# Script to run inside docker container

# Set all inputh paths for checkout in python script
REPOS_URL="$SVN_REPOS"
CHECKOUT_DIR_REPOS="/data/rawdata"
CHECKOUT_DIR_TOOLS="/data/tools"

if [ ! -d "$CHECKOUT_DIR_TOOLS" ]; then
    # checkout tools
    svn checkout "https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/geonetworkcswingestion" "$CHECKOUT_DIR_TOOLS"
fi

# Checkout dataset
svn checkout "$REPOS_URL" $CHECKOUT_DIR_REPOS --depth empty

# Run python script to push metadata to geonetwork
if [ -z "$SVN_DATASET" ]; then
    # use crawler option (-c) if dataset is not provided
    python $CHECKOUT_DIR_TOOLS/metadata2gn.py -w $CHECKOUT_DIR_REPOS -u $GN_URL -n $GN_USERNAME -p $GN_PASSWORD -c
else
    # run for specified dataset
    python $CHECKOUT_DIR_TOOLS/metadata2gn.py -w $CHECKOUT_DIR_REPOS -d $SVN_DATASET -u $GN_URL -n $GN_USERNAME -p $GN_PASSWORD
fi

# Check if any dataset_details.cfg is modified
$(svn status $CHECKOUT_DIR_REPOS | grep -q "^M.*dataset_details\.cfg")
# capture exit status (0 if anything found, 1 otherwise)
MODIFIED=$?

# Commit if dataset_details.cfg is modified. Otherwise do nothing
if [[ $MODIFIED = 0 ]]; then
    echo "dataset_details.cfg is modified, commit the changes"
    svn commit -m "uuid geonetwork updated in dataset_details.cfg" "$CHECKOUT_DIR_REPOS"
else
    echo "dataset_details.cfg file didn't change, nothing to do"
fi

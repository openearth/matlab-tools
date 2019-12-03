#!/bin/sh
NAME=python-dateutil
VENDOR="Tomi Pievilaeinen"
CATEGORY="Development/Language"
ITERATION=4
export PATH=/opt/python2.7/bin:$PATH
export PYTHONHOME=/opt/python2.7
fpm --verbose -s python -t rpm \
    --vendor "$VENDOR" \
    --category "$CATEGORY" \
    --iteration="$ITERATION" \
    -d python27 \
    -d python27-setuptools \
    --after-install after-install.sh \
    --python-package-name-prefix python27 \
    $NAME





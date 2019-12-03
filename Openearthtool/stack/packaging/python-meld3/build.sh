#!/bin/sh
VENDOR="Mike Naberezny"
CATEGORY="Development/Language"
ITERATION=2
export PATH=/opt/python2.7/bin:$PATH
fpm -s python -t rpm \
    --vendor "$VENDOR" \
    --category "$CATEGORY" \
    --iteration="$ITERATION" \
    -d python27 \
    -d python27-setuptools \
    --python-package-name-prefix python27 \
    meld3


#!/bin/sh
VENDOR="SciPy Developers"
CATEGORY="Development/Language"
ITERATION=2
export PATH=/opt/python2.7/bin:$PATH
export PYTHONHOME=/opt/python2.7
fpm -s python -t rpm \
    --vendor "$VENDOR" \
    --category "$CATEGORY" \
    --iteration="$ITERATION" \
    -d atlas \
    -d python27 \
    -d python27-setuptools \
    -d python27-numpy \
    --python-package-name-prefix python27 \
    scipy


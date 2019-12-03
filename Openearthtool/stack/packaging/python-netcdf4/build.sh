#!/bin/sh
NAME=netCDF4
VENDOR="Jeff Whitaker"
CATEGORY="Development/Language"
ITERATION=3
export PATH=/opt/python2.7/bin:$PATH
export PYTHONHOME=/opt/python2.7
fpm --verbose -s python -t rpm \
    --vendor "$VENDOR" \
    --category "$CATEGORY" \
    --iteration="$ITERATION" \
    -d python27 \
    -d python27-setuptools \
    -d netcdf \
    -d python27-numpy \
    --python-package-name-prefix python27 \
    $NAME\<1.0.5


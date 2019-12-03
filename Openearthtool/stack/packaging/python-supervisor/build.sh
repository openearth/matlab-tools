#!/bin/sh
VENDOR="Mike Naberezny"
CATEGORY="Development/Language"
ITERATION=11

export PATH=/opt/python2.7/bin:$PATH
srcdir=$(pwd)
fpm -s python -t rpm \
    --vendor "$VENDOR" \
    --category "$CATEGORY" \
    --iteration="$ITERATION" \
    --before-install ${srcdir}/before-install.sh \
    -d python27 \
    -d python27-setuptools \
    --python-package-name-prefix python27 \
    supervisor

# This rpm also creates these files, not sure how to add them.
# --directories /etc/python27-supervisor.conf.d \
# --config-files /etc/python27-supervisor.conf \

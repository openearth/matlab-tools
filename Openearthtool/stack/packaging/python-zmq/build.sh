#!/bin/sh
VENDOR="PyZMQ Developers"
CATEGORY="Development/Language"
ITERATION=1
export PATH=/opt/python2.7/bin:$PATH
export PYTHONHOME=/opt/python2.7

# TODO: how can we add     --zmq=bundled, to avoid warnings
fpm -s python -t rpm \
    --vendor "$VENDOR" \
    --category "$CATEGORY" \
    --iteration="$ITERATION" \
    -d python27 \
    -d python27-setuptools \
    --python-package-name-prefix python27 \
    pyzmq


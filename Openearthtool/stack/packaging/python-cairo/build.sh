#!/bin/sh
VENDOR="Cairo Graphics"
CATEGORY="Development/Language"
ITERATION=1
NAME=python27-cairo
export PATH=/opt/python2.7/bin:$PATH
export PYTHONHOME=/opt/python2.7
VERSION=1.10.0

DOWNLOADURL=http://cairographics.org/releases/py2cairo-$VERSION.tar.bz2

wget -c $DOWNLOADURL
tar -xjf py2cairo-$VERSION.tar.bz2
pushd py2cairo-$VERSION


./waf configure --prefix=opt/python27
 # use --prefix and --libdir if necessary
# --prefix=/usr --libdir=/usr/lib64  for Fedora 64-bit
./waf build
#./waf install
popd

# TODO: how can we add     --zmq=bundled, to avoid warnings
fpm -s dir -t rpm \
    --vendor "$VENDOR" \
    --category "$CATEGORY" \
    --iteration="$ITERATION" \
    -n $NAME \
    -d python27 \
    -d python27-setuptools \
    --python-package-name-prefix python27 \
    build


#!/bin/sh
NAME=setuptools
VERSION=1.1.6
DESCRIPTION=$(cat <<EOF
Setuptools with easy_install and other useful stuff...
EOF
)
URL="https://pypi.python.org/pypi/setuptools"
VENDOR="Python Packaging Authority"
CATEGORY="Development/Language"
SUMMARY="Easily download, build, install, upgrade, and uninstall Python packages"
LICENSE=Python
ITERATION=2
DOWNLOADURL="https://pypi.python.org/packages/source/s/setuptools/setuptools-$VERSION.tar.gz"

export PATH=/opt/python2.7/bin:$PATH 
cd ~/download/
wget -c $DOWNLOADURL
tar -xzf ./setuptools-$VERSION.tar.gz
fpm \
    -s python \
    -t rpm \
    -v "$VERSION" \
    --url "$URL" \
    --license "$LICENSE" \
    --vendor "$VENDOR" \
    --category "$CATEGORY" \
    --description "$SUMMARY" \
    --python-package-name-prefix python27 \
    --iteration="$ITERATION" \
    -d python27 \
    setuptools-$VERSION/setup.py
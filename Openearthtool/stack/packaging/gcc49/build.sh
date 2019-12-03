#!/bin/sh
NAME=gcc48
REVISION=1
VERSION=4.8.2
DESCRIPTION=$(cat <<EOF 
Version 4.8.2 of the GNU compiler collection
EOF
)
LICENSE=GPLv3+
CATEGORY="Applications/Development"
ITERATION=3
# This file is encoded in UTF-8.  -*- coding: utf-8 -*-
SUMMARY="GNU Compiler Collection"
URL="http://gcc.gnu.org/"
DOWNLOADURL=ftp://ftp.mirror.nl/pub/mirror/gnu/gcc/gcc-${VERSION}/gcc-${VERSION}.tar.gz
DESTDIR=~/installdir/gcc4.8.2

VENDOR="Free Software Foundation"
DEPENDENCIES=<<EOF
EOF

cd ~/download/
wget -c $DOWNLOADURL
tar -xvf gcc-${VERSION}.tar.gz
cd gcc-${VERSION}
source ./contrib/download_prerequisites
cd ..
mkdir gcc-${VERSION}-build
cd gcc-${VERSION}-build

../gcc-${VERSION}/configure --prefix=/opt/gcc48 --enable-languages=fortran --disable-multilib 
make
make install DESTDIR=$DESTDIR
#libtool --finish /opt/gcc48/lib/../lib64 #dit zag ik na make install...
fpm -s dir -t rpm -C "$DESTDIR" \
    -n "$NAME" -v "$VERSION" \
    --url "$URL" \
    --license "$LICENSE" \
    --vendor "$VENDOR" \
    --category "$CATEGORY" \
    --description "$SUMMARY" \
    --iteration="$ITERATION" \
    opt/gcc48/bin opt/gcc48/lib opt/gcc48/lib64 opt/gcc48/share

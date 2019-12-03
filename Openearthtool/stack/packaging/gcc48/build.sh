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
ITERATION=7
# This file is encoded in UTF-8.  -*- coding: utf-8 -*-
SUMMARY="GNU Compiler Collection"
URL="http://gcc.gnu.org/"
DOWNLOADURL=ftp://ftp.mirror.nl/pub/mirror/gnu/gcc/gcc-${VERSION}/gcc-${VERSION}.tar.gz
DESTDIR=~/installdir/gcc4.8.2

VENDOR="Free Software Foundation"
DEPENDENCIES=<<EOF
EOF

pushd ~/download/
wget -c $DOWNLOADURL
tar -xvf gcc-${VERSION}.tar.gz
pushd gcc-${VERSION}
source ./contrib/download_prerequisites
popd
mkdir gcc-${VERSION}-build
pushd gcc-${VERSION}-build

../gcc-${VERSION}/configure --prefix=/opt/gcc48 --enable-languages=fortran,c,c++,lto --disable-multilib 
make
make install DESTDIR=$DESTDIR
popd
popd

#install system configuration files
pushd ${DESTDIR}
mkdir -p etc/ld.so.conf.d
mkdir -p etc/profile.d
popd

cp -f gcc-4.8.2.conf ${DESTDIR}/etc/ld.so.conf.d/
cp -f gcc48.sh ${DESTDIR}/etc/profile.d/
chmod a+x ${DESTDIR}/etc/profile.d/gcc48.sh
. /etc/profile

fpm -s dir -t rpm -C "$DESTDIR" \
    -n "$NAME" -v "$VERSION" \
    --url "$URL" \
    --license "$LICENSE" \
    --vendor "$VENDOR" \
    --category "$CATEGORY" \
    --description "$SUMMARY" \
    --iteration="$ITERATION" \
    opt/${NAME} \
    etc/ld.so.conf.d/gcc-4.8.2.conf \
    etc/profile.d/gcc48.sh

#!/bin/sh
NAME=python27
VERSION=2.7.6
DESCRIPTION=$(cat <<EOF
Python is an interpreted, interactive, object-oriented programming
language often compared to Tcl, Perl, Scheme or Java. Python includes
modules, classes, exceptions, very high level dynamic data types and
dynamic typing. Python supports interfaces to many system calls and
libraries, as well as to various windowing systems (X11, Motif, Tk,
Mac and MFC).

Programmers can write new built-in modules for Python in C or C++.
Python can be used as an extension language for applications that need
a programmable interface. This package contains most of the standard
Python modules, as well as modules for interfacing to the Tix widget
set for Tk and RPM.

Note that this version is installed in /opt/pythonX.X,
so multiple versions can coexist.
EOF
)
URL="http://www.python.org"
VENDOR="Python Software Foundation"
CATEGORY="Development/Language"
SUMMARY="An interpreted, interactive, object-oriented programming language"
DESTDIR=$(pwd)/pkg
LICENSE=Python
ITERATION=4
DOWNLOADURL="http://www.python.org/ftp/python/$VERSION/Python-$VERSION.tgz"
wget -c $DOWNLOADURL
tar -xzf ./Python-$VERSION.tgz
cd Python-$VERSION
./configure --prefix=/opt/python2.7 --enable-shared
mkdir -p $DESTDIR
make
make -i install DESTDIR=$DESTDIR
make install DESTDIR=$DESTDIR

fpm \
    -s dir \
    -t rpm \
    -C "$DESTDIR" \
    -n "$NAME" \
    -v "$VERSION" \
    --url "$URL" \
    --license "$LICENSE" \
    --vendor "$VENDOR" \
    --category "$CATEGORY" \
    --description "$SUMMARY" \
    --iteration="$ITERATION" \
    -d libffi \
    -d openssl \
    -d sqlite \
    -d ncurses \
    -d readline \
    -d zlib \
    -d db4 \
    -d gdbm \
    -d bzip2 \
    opt/python2.7/bin \
    opt/python2.7/lib \
    opt/python2.7/share


fpm \
    -s dir \
    -t rpm \
    -C "$DESTDIR" \
    -n "$NAME-devel" \
    -v "$VERSION" \
    --url "$URL" \
    --license "$LICENSE" \
    --vendor "$VENDOR" \
    --category "$CATEGORY" \
    --description "$SUMMARY" \
    --iteration="$ITERATION" \
    -d libffi-devel \
    -d openssl-devel \
    -d sqlite-devel \
    -d ncurses-devel \
    -d readline-devel \
    -d zlib-devel \
    -d db4-devel \
    -d gdbm-devel \
    -d bzip2-devel \
    -d python27 \
    opt/python2.7/include

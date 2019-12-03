#!/bin/sh
NAME=boost-snapshot
REVISION=1
VERSION=1.55.0
DESCRIPTION=$(cat <<EOF
Boost
EOF
)
LICENSE=GPLv3+
CATEGORY="Applications/Editors"
ITERATION=2
SUMMARY="GNU Emacs text editor"
URL="http://www.gnu.org/software/emacs/"
DOWNLOADURL=http://sourceforge.net/projects/boost/files/boost/$VERSION/boost_1_55_0.tar.bz2/download

VENDOR="Boost"
DESTDIR=boost_1_55_0

srcdir=$(pwd)

wget -U openearth -c $DOWNLOADURL
tar -xjf boost_1_55_0.tar.bz2
pushd $DESTDIR
# jam based make environment
./bootstrap.sh --with-python-root=/opt/python2.7 --with-python=/opt/python2.7/bin/python --prefix=opt/boost
# build and install into prefix, q stops at error
./b2 -q install
popd

[[ -d $DESTDIR/etc/ld.so.conf.d ]] || mkdir -p $DESTDIR/etc/ld.so.conf.d

cat > $DESTDIR/etc/ld.so.conf.d/boost-snapshot.conf <<EOF
/opt/boost/lib
EOF
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
    -d python27 \
    --after-install ${srcdir}/after-install.sh \
    etc/ld.so.conf.d/boost-snapshot.conf \
    opt/boost/lib

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
    -d boost-snapshot \
    -d python27 \
    opt/boost/include

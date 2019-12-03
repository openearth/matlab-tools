#!/bin/sh
NAME=mapnik
VERSION=2.2.0
DESCRIPTION=$(cat <<EOF
Toolkit for developing mapping applications.
EOF
)
URL="http://mapnik.org"
VENDOR="Mapnik"
CATEGORY="Development/Language"
SUMMARY=""
LICENSE=LGPLv2
ITERATION=1
# Specify a port on which it runs
DOWNLOADURL=https://github.com/mapnik/$NAME/archive/v$VERSION.tar.gz


# yum install freetype-devel
# yum install libtool-ltdl-devel
# yum install build-essentials
# yum install libpng-devel
# yum install libtiff-devel
# yum install libjpeg-devel
# yum install gcc-c++
# yum install libicu-devel
# yum install python27-devel
# yum install bzip2-devel


# yum install libtool-ltdl-devel libpng-devel libtiff-devel libjpeg-devel gcc-c++ libicu-devel python27-devel bzip2-devel gdal-devel boost-devel

wget --content-disposition -c "$DOWNLOADURL"

tar -xzf $NAME-$VERSION.tar.gz

pushd $NAME-$VERSION
PATH=/opt/python27/bin:$PATH ./configure BOOST_INCLUDES=/opt/boost/include BOOST_LIBS=/opt/boost/lib
popd

fpm \
    -s dir \
    -t rpm \
    -n "$NAME" \
    -v "$VERSION" \
    -C $NAME-$VERSION \
    --url "$URL" \
    --license "$LICENSE" \
    --vendor "$VENDOR" \
    --category "$CATEGORY" \
    --description "$SUMMARY" \
    --iteration="$ITERATION" \
    -d proj \
    -d freetype \
    -d libpng \
    -d libtiff \
    -d libjpeg \
    -d libicu \
    -d python27 \
    -d boost-snapshot-devel \
    -d boost-snapshot \
    -d bzip2 \
    mapnik

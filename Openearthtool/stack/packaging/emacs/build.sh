#!/bin/sh
NAME=emacs
REVISION=1
VERSION=24.3
DESCRIPTION=$(cat <<EOF 
Emacs is a powerful, customizable, self-documenting, modeless text
editor. Emacs contains special code editing features, a scripting
language (elisp), and the capability to read mail, news, and more
without leaving the editor.
EOF
)
LICENSE=GPLv3+
CATEGORY="Applications/Editors"
ITERATION=1
# This file is encoded in UTF-8.  -*- coding: utf-8 -*-
SUMMARY="GNU Emacs text editor"
URL="http://www.gnu.org/software/emacs/"
DOWNLOADURL=ftp://ftp.gnu.org/gnu/emacs/emacs-${VERSION}.tar.xz
DESTDIR=~/installdir/python2.7.5

# build
# atk-devel cairo-devel freetype-devel fontconfig-devel dbus-devel giflib-devel glibc-devel libpng-devel
# libjpeg-devel libtiff-devel libX11-devel libXau-devel libXdmcp-devel libXrender-devel libXt-devel
# libXpm-devel ncurses-devel xorg-x11-proto-devel zlib-devel gnutls-devel
# librsvg2-devel m17n-lib-devel libotf-devel ImageMagick-devel libselinux-devel
# GConf2-devel alsa-lib-devel gpm-devel liblockfile-devel libxml2-devel
# bzip2 cairo texinfo gzip desktop-file-utils
# gtk3-devel python2-devel 



VENDOR="Free Software Foundation"
DEPENDENCIES=<<EOF
libreadline
libcurses
libz
libgdbm
EOF

cd ~/download/
wget -c $DOWNLOADURL
tar -xJf emacs-${VERSION}.tar.xz
cd emacs-${VERSION}

# Build GTK+ binary
mkdir build-gtk && cd build-gtk
ln -s ../configure .

./configure --with-dbus --with-gif --with-jpeg --with-png --with-rsvg \
           --with-tiff --with-xft --with-xpm --with-x-toolkit=gtk --with-gpm=no \
           --prefix=/opt/emacs24
make install DESTDIR=$DESTDIR
fpm -s dir -t rpm -C $DESTDIR \
    -n $NAME -v $VERSION \
    --url $URL \
    --license $LICENSE \
    --vendor $VENDOR \
    --category $CATEGORY \
    --description "$SUMMARY" \
    --iteration=$ITERATION \
    opt/emacs24/bin opt/emacs24/lib opt/emacs24/share

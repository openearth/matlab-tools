#!/bin/sh
NAME=geoserver
VERSION=2.4.4
DESCRIPTION=$(cat <<EOF
GeoServer is a Java-based software server that allows users to view and edit geospatial data. Using open standards set forth by the Open Geospatial Consortium (OGC), GeoServer allows for great flexibility in map creation and data sharing.
EOF
)
URL="http://www.geoserver.org"
VENDOR="GeoServer"
CATEGORY="Applications/Internet"
SUMMARY="An OGC compliant Geospatial Data Web Server"
LICENSE=GPLv2
ITERATION=2
DOWNLOADURL="http://sourceforge.net/projects/geoserver/files/GeoServer/2.4.4/geoserver-2.4.4-war.zip/download"
USER=tomcat
GROUP=tomcat
srcdir=$(pwd)
# specify a user agent otherwise we get a download.html
wget -U openearth -c --content-disposition "$DOWNLOADURL"


[[ -d ${NAME} ]] && rm -r ${NAME}
unzip ${NAME}-${VERSION}-war.zip ${NAME}.war
unzip ${NAME}.war -d ${NAME}

fpm --verbose \
    -s dir -t rpm \
    -n $NAME -v $VERSION \
    --url $URL \
    -a all \
    -d tomcat6 \
    -d tomcat6-webapps \
    -d tomcat6-admin-webapps \
    -d java-1.7.0-openjdk \
    --license $LICENSE \
    --vendor $VENDOR \
    --category $CATEGORY \
    --prefix /usr/share/tomcat6/webapps \
    --description "$SUMMARY" \
    --iteration $ITERATION \
    --after-install ${srcdir}/after-install.sh \
    --before-remove ${srcdir}/before-remove.sh \
    --after-remove ${srcdir}/after-remove.sh \
    --rpm-user=$USER \
    --rpm-group=$GROUP \
    --directories ${NAME} \
    geoserver

#EOF



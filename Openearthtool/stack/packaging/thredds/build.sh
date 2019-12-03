#!/bin/sh
NAME=thredds
VERSION=4.3
DESCRIPTION=$(cat <<EOF
The THREDDS Data Server (TDS) is a web server that provides metadata and data access for scientific datasets, using a variety of remote data access protocols.
EOF
)
URL="http://www.unidata.ucar.edu/software/thredds"
VENDOR="Unidata"
CATEGORY="Applications/Internet"
SUMMARY="An opendap server that also provides WCS/WMS and download access."
LICENSE=UCAR
ITERATION=25
DOWNLOADURL=ftp://ftp.unidata.ucar.edu/pub/thredds/4.3/current/thredds.war
USER=root
GROUP=tomcat
srcdir=$(pwd)
wget -c $DOWNLOADURL

[[ -d ${NAME} ]] && rm -r ${NAME}
unzip ${NAME}.war -d ${NAME}
# Add custom configs to the startup dir
cp threddsConfig.xml thredds/WEB-INF/altContent/startup/threddsConfig-OpenEarth.xml
cp catalog.xml thredds/WEB-INF/altContent/startup/catalog-OpenEarth.xml
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
    --rpm-user=$USER \
    --rpm-group=$GROUP \
    thredds


#     --after-remove ${srcdir}/after-remove.sh \



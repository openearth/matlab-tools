#!/bin/bash
NAME=pgstudio
VERSION=1.0
DESCRIPTION=$(cat <<EOF
Run PostgreSQL queries, and manage your database.
EOF
)
URL="http://www.postgresqlstudio.org/"
VENDOR="openscg"
CATEGORY="Applications/Internet"
SUMMARY="PostgreSQL Studio gives you the power to perform essential PostgreSQL database development tasks from a web-based console. With more and more PostgreSQL databases running in a Cloud environment, PostgreSQL Studio let’s you work with your databases without the need to open firewalls."
LICENSE="PostgreSQL License"
ITERATION=1
DOWNLOADURL='http://www.postgresqlstudio.org/?ddownload=837'
USER=root
GROUP=tomcat
srcdir=$(pwd)
wget --content-disposition -c $DOWNLOADURL
tar -xjf ${NAME}_${VERSION}.tar.bz2
# remove old directory if it exists
[[ -d ${NAME} ]] && rm -r ${NAME}
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
    --license "$LICENSE" \
    --vendor "$VENDOR" \
    --category "$CATEGORY" \
    --prefix /usr/share/tomcat6/webapps \
    --description "$SUMMARY" \
    --iteration "$ITERATION" \
    --after-install ${srcdir}/after-install.sh \
    --rpm-user="$USER" \
    --rpm-group="$GROUP" \
    pgstudio

# --after-install ${srcdir}/after-install.sh \
# --after-remove ${srcdir}/after-remove.sh \



#!/bin/sh
NAME=s1tbx
VERSION=1.1.0
DESCRIPTION=$(cat <<EOF
Sentinel 1 Toolbox
EOF
)
URL="https://sentinel.esa.int/web/sentinel/toolboxes/sentinel-1"
VENDOR="ESA"
CATEGORY="Applications/EarthScience"
SUMMARY="Sentinel 1 Toolbox"
LICENSE=GPL
ITERATION=1
DOWNLOADURL=http://sentinel1.s3.amazonaws.com/1.0/s1tbx_1.1.0_Linux64_installer.sh
srcdir=$(pwd)


wget -c $DOWNLOADURL -O ${NAME}.sh
sh ${NAME}.sh -q -dir /opt/${NAME}
rm ${NAME}.sh

fpm \
    -s dir \
    -t rpm \
    -n "$NAME" \
    -v "$VERSION" \
    --url "$URL" \
    --license "$LICENSE" \
    --vendor "$VENDOR" \
    --category "$CATEGORY" \
    --description "$SUMMARY" \
    --iteration="$ITERATION" \
    /opt/$NAME \

rm -r /opt/${NAME}





#!/bin/sh
NAME=elveqs
VERSION=0.1
DESCRIPTION=$(cat <<EOF
Web application for elveqs
EOF
)
URL="https://www.deltares.nl"
VENDOR="Deltares"
CATEGORY="Development/Language"
SUMMARY="Elveqs website"
LICENSE=GPL
ITERATION=8
# Specify a port on which it runs
PORT=6006

export PATH=/opt/python2.7/bin:$PATH
virtualenv /opt/venvs/$NAME
# replace symlinks because of an error in ruby file handling
# --always-copy does not work...
for l in $(find /opt/venvs/$NAME -type l );
do
    src="$(readlink $l)"
    pushd "$(dirname $l)" > /dev/null
    rm "$(basename $l)"
    cp -R  "$src" "$(basename $l)"
    popd > /dev/null
done


. /opt/venvs/$NAME/bin/activate

pip install "pyramid<1.5a"
# For running
pip install gunicorn

# Setup the app in it's own directory

svn export https://repos.deltares.nl/repos/ELVEQO/deliverables/software/website /var/www/apps/$NAME
cd /var/www/apps/$NAME
# Add it to the virtualenv
pip install -e /var/www/apps/$NAME
pip freeze > requirements.txt
# Not using the requirements at the moment, as we're packing it anyway
cat requirements.txt
cd -

# TODO install all requirements

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
    --python-package-name-prefix python27 \
    --iteration="$ITERATION" \
    -d python27 \
    -d python27-virtualenv \
    -d python27-setuptools \
    -d python27-supervisor \
    -d gcc48 \
    --after-install after-install.sh \
    --after-remove after-remove.sh \
    /opt/venvs/$NAME \
    /var/www/apps/$NAME \

deactivate
rm -rf /opt/venvs/$NAME
rm -rf /var/www/apps/$NAME

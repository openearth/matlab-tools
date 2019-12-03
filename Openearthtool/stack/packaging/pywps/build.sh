#!/bin/sh
NAME=PyWPS
VERSION=0.1
DESCRIPTION=$(cat <<EOF
PyWPS (Python Web Processing Service) is an implementation of the Web processing Service standard from Open Geospatial Consortium.
EOF
)
URL="http://pywps.wald.intevation.org/"
VENDOR="geopython"
CATEGORY="Development/Language"
SUMMARY="Web Processing Service"
LICENSE=GPL
ITERATION=1
# Specify a port on which it runs
PORT=6004



export PATH=/opt/python2.7/bin:$PATH
#  Use system numpy, pandas, netcdf....
virtualenv --system-site-packages /opt/venvs/$NAME


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

# Requires

# libxml2-devel
# libxslt-devel
pip install lxml
# This one does not work if installed using develop

# For running
pip install gunicorn
pip install CouchDB


# no equivalent in git, so we'll just use the svn export
svn export https://github.com/geopython/PyWPS.git/trunk /var/www/apps/$NAME

cd /var/www/apps/$NAME
# Add it to the virtualenv
python setup.py develop
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
    -d libxml2 \
    -d libxslt \
    -d python27 \
    -d python27-numpy \
    -d python27-pandas \
    -d python27-pytz \
    -d python27-dateutil \
    -d python27-matplotlib \
    -d python27-virtualenv \
    -d python27-setuptools \
    /opt/venvs/$NAME \
    /var/www/apps/$NAME \

# TODO add after-remove cleanup of:
# /opt/venvs/$NAME \
#     /var/www/apps/$NAME


deactivate
rm -rf /opt/venvs/$NAME
rm -rf /var/www/apps/$NAME

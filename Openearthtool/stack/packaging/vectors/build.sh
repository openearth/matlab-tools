#!/bin/sh
NAME=vectors
VERSION=0.1
DESCRIPTION=$(cat <<EOF
Web application for vectors
EOF
)
URL="https://www.openearth.nl"
VENDOR="Deltares"
CATEGORY="Development/Language"
SUMMARY="Vectors website"
LICENSE=GPL
ITERATION=1
# Specify a port on which it runs
PORT=6002

export PATH=/opt/python2.7/bin:$PATH
virtualenv /opt/venvs/$NAME

. /opt/venvs/$NAME/bin/activate

# Requires
# libxml2-devel
# libxslt-devel
pip install lxml

# This one does not work if installed using develop
# Works faster with blas/atlas installed
pip install numpy

# requires geos
# requires geos-devel
pip install shapely

pip install simplekml

# requires postgresql
# requires postgresql-devel
pip install psycopg2

# requires:
# from epel
# hdf5-devel
# hdf5
# netcdf-devel
# netcdf
pip install "netCDF4<1"

pip install pandas

# Requires ....
pip install matplotlib

# Make sure we don't get an alpha version of 1.5
pip install "pyramid<1.5a"
# For running
pip install gunicorn

# Setup the app in it's own directory
svn export https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/$NAME /var/www/apps/$NAME
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
    -d python27-virtualenv \
    -d python27-setuptools \
    /opt/venvs/$NAME \
    /var/www/apps/$NAME \

# TODO add after-remove cleanup of:
# /opt/venvs/$NAME \
#     /var/www/apps/$NAME


deactivate
rm -r /opt/venvs/$NAME
rm -r /var/www/apps/$NAME

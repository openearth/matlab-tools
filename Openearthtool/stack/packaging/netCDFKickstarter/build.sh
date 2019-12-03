#!/bin/sh
NAME=netCDFKickstarter
VERSION=0.1
DESCRIPTION=$(cat <<EOF
Web application for people who like making netcdf files
EOF
)
URL="https://www.openearth.nl"
VENDOR="TU Delft"
CATEGORY="Development/Language"
SUMMARY="Setup netcdf files"
LICENSE=GPL
ITERATION=5
# Specify a port on which it runs
PORT=6001



export PATH=/opt/python2.7/bin:$PATH
virtualenv /opt/venvs/$NAME

. /opt/venvs/$NAME/bin/activate

# Requires

# libxml2-devel
# libxslt-devel
pip install lxml
# This one does not work if installed using develop
pip install numpy

# requires:
# from http://wiki.centos.org/AdditionalResources/Repositories/RPMForge
# hdf5-devel
# hdf5
# netcdf-devel
# netcdf
pip install "netCDF4<1"
pip install pandas

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
    --after-install after-install.sh \
    /opt/venvs/$NAME \
    /var/www/apps/$NAME \

# TODO add after-remove cleanup of:
# /opt/venvs/$NAME \
#     /var/www/apps/$NAME


deactivate
rm -r /opt/venvs/$NAME
rm -r /var/www/apps/$NAME

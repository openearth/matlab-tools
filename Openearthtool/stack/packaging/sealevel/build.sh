#!/bin/sh
NAME=sealevel
VERSION=0.1
DESCRIPTION=$(cat <<EOF
Web application for sealevel calculations
EOF
)
URL="https://www.openearth.nl"
VENDOR="Deltares"
CATEGORY="Development/Language"
SUMMARY="Sea level calculations"
LICENSE=GPL
ITERATION=10
# Specify a port on which it runs
PORT=6003

# Build requires python27-devel to be installed and 
# /var/www/apps and /opt/venvs to be writable and empty

export PATH=/opt/python2.7/bin:$PATH
virtualenv  /opt/venvs/$NAME
# use system packages
rm /opt/venvs/sealevel/lib/python2.7/no-global-site-packages.txt
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


# Requires


# dependencies
# R
# R-devel
pip install rpy2
pip install xlwt
# Make sure we don't get an alpha version of 1.5
pip install "pyramid"
# For running
pip install gunicorn
pip install jinja2
pip install pygments
pip install ipython
pip install pyproj
sleep 5
# Setup the app in it's own directory
svn export https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/$NAME /var/www/apps/$NAME
cd /var/www/apps/$NAME
# Add it to the virtualenv
python setup.py develop
pip freeze > requirements.txt
# Not using the requirements at the moment, as we're packing it anyway
cat requirements.txt
cd -


# dependencies wget & make for downloading data
cd /var/www/apps/$NAME/sealevel/static/data

export R_LIBS_SITE=/opt/R/3/x86_64
sleep 5
make
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
    -d R \
    -d r-cran \
    -d python27 \
    -d python27-virtualenv \
    -d python27-setuptools \
    -d python27-numpy \
    -d python27-pyzmq \
    -d python27-pandas \
    -d python27-netcdf4 \
    -d python27-scipy \
    --after-install after-install.sh \
    /opt/venvs/$NAME \
    /var/www/apps/$NAME \


# TODO add after-remove cleanup of:
# /opt/venvs/$NAME \
#     /var/www/apps/$NAME


deactivate
rm -r /opt/venvs/$NAME
rm -r /var/www/apps/$NAME

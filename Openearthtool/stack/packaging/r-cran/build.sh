#!/bin/sh
NAME=r-cran
VERSION=0.1
DESCRIPTION=$(cat <<EOF
Packages from CRAN
EOF
)
URL="http://cran.r-project.org"
VENDOR="Various"
CATEGORY="Development/Language"
SUMMARY="Extra R packages"
LICENSE="Varying"
ITERATION=6

PACKAGES=$(cat <<EOF
plyr
stringr
reshape2
ggplot2
rjson
ncdf4
ncdf
circular
foreach
EOF
)

RDIR="opt/R/3/$(uname -i)"
RMIRROR="http://cran-mirror.cs.uu.nl"
mkdir -p $RDIR
for package in $PACKAGES
do
    echo "install.packages(\"$package\", lib=\"$RDIR\", repos=\"$RMIRROR\")" | R --no-save
done

echo "install.packages(\"sealevel\", lib=\"$RDIR\", repos=\"http://r-forge.r-project.org\")" | R --no-save


fpm \
    -s dir \
    -t rpm \
    -n $NAME \
    -v "$VERSION" \
    --url "$URL" \
    --license "$LICENSE" \
    --vendor "$VENDOR" \
    --category "$CATEGORY" \
    --description "$SUMMARY" \
    --iteration="$ITERATION" \
    -d R \
    -d netcdf \
    opt/R

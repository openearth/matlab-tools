#!/usr/bin/env bash

SVN_URL="${1:-https://svn.oss.deltares.nl/repos/openearthtools/trunk}"
SVN_DIR="${2:-openearthtools}"

sed -i -e "s,https:\/\/svn.oss.deltares.nl\/repos\/openearthtools\/trunk,$SVN_URL,g" svn_manual.tex
sed -i -e "s,openearthtools,$SVN_DIR,g" svn_manual.tex

latexmk

svn revert svn_manual.tex

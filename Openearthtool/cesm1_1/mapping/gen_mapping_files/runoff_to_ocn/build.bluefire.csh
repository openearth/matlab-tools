#!/bin/csh
#===============================================================================
# SVN $Id: build.bluefire.csh 35698 2012-03-22 23:59:57Z kauff $
# SVN $URL: https://svn-ccsm-models.cgd.ucar.edu/tools/mapping/trunk_tags/mapping_121113b/gen_mapping_files/runoff_to_ocn/build.bluefire.csh $
#===============================================================================
# 
# Notes:
# - will build the CCSM runoff correcting/smoothing code in ./obj
# - must specify location of src code, Makefile, Macros file, dependancy generator 
#===============================================================================

setenv SRCDIR `pwd`/src

echo source dir: $SRCDIR

if !(-d obj) mkdir obj
cd obj

cc -o makdep $SRCDIR/makdep.c

echo $SRCDIR  >! Filepath

gmake VPFILE=Filepath THREAD=TRUE -f $SRCDIR/Makefile MACFILE=$SRCDIR/Macros.bluefire || exit -1

cd ..
rm              runoff_map
ln -s obj/a.out runoff_map


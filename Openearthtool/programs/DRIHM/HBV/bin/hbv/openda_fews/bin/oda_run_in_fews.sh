#! /bin/bash
#
# Purpose : startup script for OpenDaInFews
#
#
# Note    : To run OpenDaInFews using a specific Java runtime environment (JRE) folder,
#           first run the following two commands before running this script.
#           Here the folder "/fews/jre" is used as an example (replace this with your own JRE folder):
#               export JAVA_HOME=/fews/jre
#               export PATH=$JAVA_HOME/bin:$PATH
#
#
# Args for OpenDA application run:
#           -f
#           <FEWS pi run file path relative to working dir>
#           -a
#           <OpenDA application config file (.oda file) path relative to working dir>
#
# Args for single model run:
#           -f
#           <FEWS pi run file path relative to working dir>
#           -m
#           <modelFactory or stochModelFactory full className>
#           <modelFactory or stochModelFactory config file path relative to pi run file dir>
#
# Examples: ./oda_run_in_fews.sh -f run_info.xml -a enkf_run.oda
#           ./oda_run_in_fews.sh -f run_info.xml -m org.openda.blackbox.wrapper.BBModelFactory waquaModel.xml
#
#
# Author  : D. Twigt
# License : GPL

# read local settings
if [ -z "$OPENDADIR" ];then
   echo "OPENDADIR not set! Run settings_local.sh to fix this"
   exit 1;
fi
if [ ! -z "$OPENDALIB" ]; then
   echo "setting path for OPENDALIB"
   export LD_LIBRARY_PATH=$OPENDALIB:$LD_LIBRARY_PATH
fi

# java options
if [ -z "$ODA_JAVAOPTS" ]; then
	export ODA_JAVAOPTS='-Xmx1024m'
fi

# check if fews_openda.jar is available
fewsOpendaJarFile=$OPENDADIR/fews_openda.jar
if [ ! -f $fewsOpendaJarFile ]; then
   echo "OpenDaInFews jar file $fewsOpendaJarFile not found"
   exit 1
fi

# append all jars in opendabindir to java classpath
for file in $OPENDADIR/*.jar ; do
   if [ -f "$file" ] ; then
       export CLASSPATH=$CLASSPATH:$file
   fi
done

# starting from bin-directory is necessary for *.so loading now TODO fix this
# OpenDaInFews always needs at least 4 arguments
if [ $# -ge 4 ]; then

   logfile="openda_logfile.txt"

   echo "========================================================================="
   echo Starting "nl.deltares.openda.fews.OpenDaInFews $1 $2 $3 $4 $5 $6 $7 > $logfile  2>&1"

   # start timing
   STARTRUN=`date +%s`
   date "+%F, %H:%M:%S" >> $logfile 2>&1

   # run application
   java $ODA_JAVAOPTS nl.deltares.openda.fews.OpenDaInFews $1 $2 $3 $4 $5 $6 $7 > $logfile  2>&1

   # end timing
   date "+%F, %H:%M:%S" >> $logfile 2>&1
   ENDRUN=`date +%s` 
   declare -i DURATION
   DURATION=($ENDRUN-$STARTRUN)
   echo DURATION, "$DURATION" >> $logfile 2>&1

   echo "Run finished"
   echo "========================================================================="

else
   echo ""
   echo "Usage for OpenDA application run: ./oda_run_in_fews.sh -f <FEWS pi run file path relative to working dir> -a <OpenDA application config file (.oda file) path relative to working dir>"
   echo ""
   echo "Usage for single model run: ./oda_run_in_fews.sh -f <FEWS pi run file path relative to working dir> -m <modelFactory or stochModelFactory full className> <modelFactory or stochModelFactory config file path relative to pi run file dir>"
   echo ""
   echo "Example of usage: ./oda_run_in_fews.sh -f run_info.xml -a enkf_run.oda"
   echo ""
fi


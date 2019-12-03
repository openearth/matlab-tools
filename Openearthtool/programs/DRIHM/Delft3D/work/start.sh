#!/bin/bash

##################################################################
#                                                                #
# start.sh                                                       #
#                                                                #
# This start-script was written in context of the DRIHM-project  #
#   for more information, please refer to http://www.drihm.eu    #
#                                                                #
# Version 3.0                                                    #
# Modified for use on Delft3D Virtual Machine                    #
#                                                                #
##################################################################

#
# Adjust settings here...
#

#
# Debugging and testing environment settings
#

# debug-level
#   0: off
#   1: a few debug/status info
#   2: verbose debug information
#   3: even more verbose debug output
DEBUG=2

# Use this script for a test-run only?
#   0: regular execution
#   1: no input file mandatory, no model execution
TESTRUN=0

# Do not clean up after finishing
# -> useful for debugging and development
#   0: deletes temporary files
#   1: keeps everything 
NOTIDY=1


##################################################################
#                                                                #
# Unless you are a developer and know exactly what you are doing #
#                                                                #
#          DON'T TOUCH ANYTHING BELOW THIS LINE!!!               #
#                                                                #
##################################################################


#
# helper variables
# if you want to apply any change here, you better know what you're doing...
#
MYDIR=$(pwd)
VMROOT=/home/drihmuser/drihm
LIBDIR=$VMROOT/lib/
BINDIR=$VMROOT/bin/
MODELDIR=$VMROOT/modelScripts/
MODELSCRIPT=$1
JOBID=$2
REMOTEINPUT=$3
REMOTEOUTPUT=$4
TIDYOUTPUT=0

#
# these files have to come with the job as they are mandatory for the execution
#
PRIVKEY=$MYDIR/id_rsa
KNOWNHOSTS=$MYDIR/known_hosts
INPUTFILE=$MYDIR/input.tgz


#
# these variables are ommitted in case of a test-run
#
JOBDIR=$MYDIR/$1
OUTPUTFILE=$MYDIR/output.$2.tgz

#
# some debug output, if desired
#
if [[ $DEBUG -ge 1 ]] ; then
  /bin/echo "Debug level is set to $DEBUG"
  /bin/echo "Hostname:          $(hostname --long)"
  /bin/echo "Application call:  $0 $1 $2 $3 $4"
  if [[ $DEBUG -ge 2 ]] ; then
    /bin/echo "Path:   $PATH"
    /bin/echo "Shell:  $SHELL"
    /bin/echo "PWD:    $(pwd)"
    /bin/echo "HOME:   $HOME"
    /bin/echo "whoami: $(whoami)"
    /bin/echo "uname:  $(uname -a)"
    if [[ $DEBUG -ge 3 ]] ; then
      /bin/echo ""
      /bin/echo "cpuinfo:"
      /bin/echo "$(cat /proc/cpuinfo)"
      /bin/echo ""
      /bin/echo "meminfo:"
      /bin/echo "$(cat /proc/meminfo)"
      /bin/echo ""
    fi
  fi
fi


#
# Output error if parameters for model execution are not sufficient
#
function printUsage {
  echo "Usage: $0 <type> <JOB_ID> [<input-data> <output-data>]" >> /dev/stderr;
  echo "       type: Select the type of job you want to execute." >> /dev/stderr;
  echo "             type may be one value of..." >> /dev/stderr;
  echo "             - helloWorld for a \"hello World!\" in test-mode" >> /dev/stderr;
  echo "             - delft3d for Delft3D" >> /dev/stderr;
  echo "       JOB_ID: <JOB_ID> is needed to wirte an unique output-file." >> /dev/stderr;
  echo "               Usually, <JOB_ID> can be passed by the scheduler." >> /dev/stderr;
  echo "       input-data & output-data:" >> /dev/stderr;
  echo "               if given (both not empty), input-data will be fetched from" >> /dev/stderr;
  echo "               (prior to the execution of a model) and output-data will" >> /dev/stderr;
  echo "               be stored on the global DRIHM storage after the execution" >> /dev/stderr;
  echo "               of the model" >> /dev/stderr;
  echo "               if any of the two parameters is left empty, the copy" >> /dev/stderr;
  echo "               steps will be skipped" >> /dev/stderr;
}


#
# my very own implementation of the well-known "which"-command as a function
#
function myWhich () {
  if test -n "$KSH_VERSION"; then
    puts() {
      print -r -- "$*"
    }
  else
    puts() {
      printf '%s\n' "$*"
    }
  fi
  
  ALLMATCHES=0
  
  while getopts a whichopts
  do
    case "$whichopts" in
      a) ALLMATCHES=1 ;;
      ?) puts "Usage: $0 [-a] args"; return 2 ;;
    esac
  done
  shift $(($OPTIND - 1))
  
  if [ "$#" -eq 0 ]; then
    ALLRET=1
  else
    ALLRET=0
  fi
  case $PATH in
    (*[!:]:) PATH="$PATH:" ;;
  esac
  for PROGRAM in "$@"; do
    RET=1
    IFS_SAVE="$IFS"
    IFS=:
    case $PROGRAM in
      */*)
        if [ -f "$PROGRAM" ] && [ -x "$PROGRAM" ]; then
          puts "$PROGRAM"
          RET=0
        fi
        ;;
      *)
        for ELEMENT in $PATH; do
          if [ -z "$ELEMENT" ]; then
            ELEMENT=.
          fi
          if [ -f "$ELEMENT/$PROGRAM" ] && [ -x "$ELEMENT/$PROGRAM" ]; then
            puts "$ELEMENT/$PROGRAM"
            RET=0
            [ "$ALLMATCHES" -eq 1 ] || break
          fi
        done
        ;;
    esac
    IFS="$IFS_SAVE"
    if [ "$RET" -ne 0 ]; then
      ALLRET=1
    fi
  done
  
  return "$ALLRET"
}


#
# check parameters etc.
#
function doChecks {

  # --------------------------------------------------------------
  # Environment-specific adaptations
  # This area can be extend for other environments (e.g. PRACE)
  # --------------------------------------------------------------

  #
  #
  # helloWorld
  #
  if [[ $1 == "helloWorld" ]] ; then
    TESTRUN=1;
    if [[ $DEBUG -ge 1 ]] ; then
      echo "Info: Running \"helloWorld\" in test-mode only.";
    fi
  fi
  #
  # End helloWorld
  #

  if [[ $TESTRUN -eq 0 ]] ; then
    # Test if a valid model name was provided
    if [[ $1 == "delft3d" ]] ; then
      # Check if second parameter is provided
      if [[ $2 == "" ]] ; then
        echo "Error. Unsufficient numbers of parameters given." >> /dev/stderr;
        printUsage;
        exit -1;
      elif [[ ! -r $INPUTFILE ]] ; then
        echo "Error. File $INPUTFILE is not readable. Aborting." >> /dev/stderr;
        exit -1;
      elif [[ -r $OUTPUTFILE ]] ; then
        echo "Error. The output-file $OUTPUTFILE already exists. Aborting." >> /dev/stderr;
        exit -1;
      elif [[ -d $JOBDIR ]] ; then
        echo "Error. The execution directory $JOBDIR already exists. Aborting." >> /dev/stderr;
        exit -1;
      fi
    else
       # No valid call parameter was found, so print error and quit execution
      echo "Error. No model \"$1\" found for execution." >> /dev/stderr;
      printUsage;
      exit -1;
    fi
  # Test-mode only
  elif [[ $DEBUG -ge 1 ]] ; then
    echo "ATTENTION: running script in test-mode only!";
    echo "           No model execution will take place.";
  fi
}


#
# implements an environment-dependand copy function
# usage: myCopy <FETCH|PUT> <src|dst>
#        FETCH  fetches $src and stores it at $INPUTFILE
#        PUT    copies $OUTPUTFILE to $dst
#
function myCopy {

  # SCP settings
  MYUSERPATH="rsync-user@drihm-tools.pub.lab.nm.ifi.lmu.de:/home/rsync-user/data-store/"
  MYSCP="scp -o UserKnownHostsFile=${KNOWNHOSTS} -i ${PRIVKEY}"

  # do nothing in test-mode
  if [[ $TESTRUN -eq 1 ]] ; then
    if [[ $DEBUG -ge 1 ]] ; then echo "Test-mode enabled: Skipping \"myCopy\"..."; fi
    return;
  fi

  # beginning of copy
  if [[ $DEBUG -ge 1 ]] ; then echo "Starting \"myCopy\"..."; fi

  # fetch data
  if [[ $1 == "FETCH" && -n $2 ]] ; then
    MYSCPCMD="$MYSCP $MYUSERPATH/$2 $INPUTFILE"
    if [[ $DEBUG -ge 2 ]] ; then echo "$MYSCPCMD"; fi
    $MYSCPCMD
    ERR=$?

  # store data
  elif [[ $1 == "PUT" && -n $2 ]] ; then
    MYSCPCMD="$MYSCP $OUTPUTFILE $MYUSERPATH/$2"
    if [[ $DEBUG -ge 2 ]] ; then echo "$MYSCPCMD"; fi
    $MYSCPCMD
    ERR=$?

  # No copy desired or error...
  else
    if [[ $DEBUG -ge 1 ]] ; then echo "Attention: myCopy was called with at least one invalid or empty parameter:"; fi
    if [[ $DEBUG -ge 2 ]] ; then echo "           myCopy \"$1\" \"$2\""; fi
    if [[ $DEBUG -ge 1 ]] ; then echo "Skipping..."; fi
  fi

  # exit with failure in case of error
  if [[ $ERR != 0 ]] ; then
    echo "Error in myCopy: exit code \"$ERR\" while executing";
    echo "$MYSCPCMD";
    exit $ERR;
  fi

  if [[ $DEBUG -ge 1 ]] ; then echo "done."; fi
}


#
# This function maps/selects files from $INPUTFILE
# and forms a new $INPUTFILE instead of the old one
# according to the mapping given by $MAPPINGFILE
#
function repackInput {
  if [[ $TESTRUN -eq 0 ]] ; then

    # preparations as mapping-file is included in an archive as given by the portal
    if [[ $DEBUG -ge 1 ]] ; then echo "Function repackInput() started."; fi
    cd $JOBDIR
    CONFIGARCHIVE="$MYDIR/configuration.tgz"
    if [[ -r $CONFIGARCHIVE ]] ; then
      tar -xzf $CONFIGARCHIVE
    fi
    MAPPINGFILE="$JOBDIR/mapping.txt";
  
    # mapping file found! Start working...
    if [[ -r $MAPPINGFILE ]] ; then
      if [[ $DEBUG -ge 1 ]] ; then echo "Function repackInput(): Mapping file found, starting re-packaging..."; fi
  
      # create a temporary directories
      cd $JOBDIR
      MYTMPINPUTDIR=$(mktemp --directory --tmpdir="$JOBDIR" -t mytmp_XXXXXXXXXX)
      MYTMPOUTPUTDIR=$(mktemp --directory --tmpdir="$JOBDIR" -t mytmp_XXXXXXXXXX)
  
      # extract "old" input-file
      cd $MYTMPINPUTDIR
      tar -xzf $INPUTFILE
  
      # move files according to given mapping 
      while read -a line ; do
        INPUTSRC=${line[0]}
        OUTPUTDST=${line[1]}
        mkdir -p $(echo "$MYTMPOUTPUTDIR/$OUTPUTDST" | sed -e 's/\(.*\)\/.*$/\1/')
        if [[ -r "$MYTMPINPUTDIR/$INPUTSRC" ]] ; then
          if [[ $DEBUG -ge 2 ]] ; then echo "Function repackInput(): mv -T \"$MYTMPINPUTDIR/$INPUTSRC\" \"$MYTMPOUTPUTDIR/$OUTPUTDST\""; fi
          mv -T "$MYTMPINPUTDIR/$INPUTSRC" "$MYTMPOUTPUTDIR/$OUTPUTDST"
        else
          if [[ $DEBUG -ge 1 ]] ; then echo "Warning: Function repackInput(): File \"$MYTMPINPUTDIR/$INPUTSRC\" not found. Skipping..."; fi
        fi
      done < $MAPPINGFILE;
  
      # generate new tar-archive
      rm -f $INPUTFILE
      cd $MYTMPOUTPUTDIR
      tar -czf $INPUTFILE .
      cd $JOBDIR
      rm -rf $MYTMPINPUTDIR
      rm -rf $MYTMPOUTPUTDIR
  
      if [[ $DEBUG -ge 1 ]] ; then echo "Function repackInput(): done."; fi
  
    # in case no mapping file ca be read, nothing will happen
    else
      if [[ $DEBUG -ge 1 ]] ; then echo "Function repackInput(): No mapping file \"$MAPPINGFILE\" found, no action taken."; fi
    fi

  # do nothing in test-mode!
  else
    if [[ $DEBUG -ge 1 ]] ; then echo "Function repackInput(): skipping due to test-mode."; fi
  fi
}


#
# prepare job-dir and configure some environment variables
# -> perfectly be done _after_ rsync'ing the software repositories!
#
function prepare-environment {
  #
  # set PATH-variable
  #
  export PATH=$PATH:$BINDIR:/usr/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
  if [[ -d $BINDIR ]] ; then
    for i in $(find $BINDIR -maxdepth 2 -type d) $(find $BINDIR -name bin -type d) ; do
      export PATH=$PATH:$i
    done
  fi
  if [[ $DEBUG -ge 2 ]] ; then echo "NEW PATH = $PATH"; fi
  #
  # copy binaries to job-dir, if not in test-mode
  #
  prepare-environment-cp-bin $1
  #
  # set path to libraries
  #
  export LD_LIBRARY_PATH=$BINDIR/python/current/lib/;
  for i in $LIBDIR/*/*/lib ; do
    export LD_LIBRARY_PATH=$i:$LD_LIBRARY_PATH;
  done
  if [[ $DEBUG -ge 2 ]] ; then echo "NEW LD_LIBRARY_PATH = $LD_LIBRARY_PATH"; fi
}
function prepare-environment-cp-bin {
  #
  # copy binaries to job-dir, if not in test-mode
  # -> remember to reflect special situations in tidy() function, too!
  #
  if [[ $TESTRUN -eq 0 ]] ; then
    # "wrf-parallel" and "wrf" use the same binaries!
    if [[ $1 == "wrf-parallel" || $1 == "wrf" ]] ; then
      # wrf needs to be a symlink to wrf-bin/run/ only
      mkdir -p $MYDIR/wrf-bin
      cp -r $BINDIR/wrf-bin/ $MYDIR/
      cd $MYDIR && ln -s ./wrf-bin/run/ wrf
      cp -r $BINDIR/wrf-bridge/* $JOBDIR
    # "wrf-nmm" uses 2 directories
    elif [[ $1 == "wrf-nmm" ]] ; then
      mkdir -p $MYDIR/wrf-nmm-bin
      cp -r $BINDIR/wrf-nmm-bin/ $MYDIR/
      cd $MYDIR && ln -s ./wrf-nmm-bin/run/ wrf-nmm
      cp -r $BINDIR/wrf-nmm-bridge/* $JOBDIR
    # "meso-nh" has a special bridge to copy
    elif [[ $1 == "meso-nh" ]] ; then
      cp -r $BINDIR/$1 $JOBDIR
      cp -r $BINDIR/meso-nh-bridge/* $JOBDIR
    # demo chains
    elif [[ $1 == "demoChain01" || $1 == "demoChain02" || $1 == "demoChain03" ]] ; then
      if [[ $DEBUG -ge 1 ]] ; then echo "Info: Running demo chain \"$1\"."; fi
      mkdir -p $JOBDIR
    else
      cp -r $BINDIR/$1 $JOBDIR
    fi
  fi
}


#
# this functions implements a mechanism for blocking the execution until a (parallel) job has finished
# supported schedulers:
# - slurm
# parameters:
# - $1: type of scheduler [slurm]
# - $2: Job-ID as given by the scheduler
# - $3: Timeout in seconds
# - potentially, some schedulers need additional information
#   see below for information on the schedulers
#	SLURM
#	- $4: Cluster name to issue the command to. For LRZ, usually "mpp1"
#
function waitFor {
  if [[ $DEBUG -ge 1 ]] ; then echo "Function waitFor() called for scheduler \"$1\" and job-ID \"$2\" (timeout: \"$3\" sec.)."; fi

  if [[ $2 == "" ]] ; then
    echo "Function waitFor() called with insufficient number of arguments." > /dev/stderr
    exit -1;
  fi
  if [[ $3 -le 0 ]] ; then
    echo "Function waitFor() called without or too small timeout value." > /dev/stderr
    exit -1;
  fi

  # "endless" loop
  MYWAITINGTIME=0;
  MYFINISHEDFLAG=0;
  MYSCHEDULEROUT="";
  while [[ $MYFINISHEDFLAG -eq 0 && $MYWAITINGTIME -le $3 ]] ; do

    # slurm
    if [[ $1 == "slurm" ]] ; then
      MYSCHEDULEROUT=$(scontrol --details --clusters=$4 show job $2)
      if [[ $(echo $MYSCHEDULEROUT | grep "JobState=COMPLETED") != "" ]] ; then MYFINISHEDFLAG=1; fi
      if [[ $(echo $MYSCHEDULEROUT | grep "JobState=CANCELLED") != "" ]] ; then MYFINISHEDFLAG=-1; fi
      if [[ $(echo $MYSCHEDULEROUT | grep "JobState=FAILED") != "" ]] ; then MYFINISHEDFLAG=-2; fi
      if [[ $(echo $MYSCHEDULEROUT | grep "JobState=NODE_FAIL") != "" ]] ; then MYFINISHEDFLAG=-3; fi
      if [[ $(echo $MYSCHEDULEROUT | grep "JobState=TIMEOUT") != "" ]] ; then MYFINISHEDFLAG=-4; fi

    # error
    else
      echo "Failure in function waitFor(). Unknown scheduler \"$1\"."
    fi

    if [[ $MYFINISHEDFLAG -eq 0 ]] ; then 
      if [[ $DEBUG -ge 2 ]] ; then echo "Polling scheduler \"$1\" and job-ID \"$2\" (already waited $MYWAITINGTIME sec.)..."; fi
      sleep 5s;
    fi
    let MYWAITINGTIME=$MYWAITINGTIME+5;
    if [[ $DEBUG -ge 1 && $MYWAITINGTIME -gt $3 ]] ; then echo "Function waitFor(): timeout exceeded."; fi
  # end while
  done

  if [[ $MYFINISHEDFLAG -le 0 ]] ; then echo $MYSCHEDULEROUT > /dev/stderr; fi
}


#
# clean up
#
function tidy {
  if [[ $NOTIDY -eq 0 ]] ; then
    if [[ $DEBUG -ge 1 ]] ; then echo -n "Cleaning up... "; fi
    if [[ $DEBUG -ge 2 ]] ; then echo ""; fi
    if [[ $DEBUG -ge 2 ]] ; then echo "Executing \"rm -rf $JOBDIR $INPUTFILE $MYDIR/rsync $MYDIR/id_rsa.pub $MYDIR/id_rsa $MYDIR/known_hosts\"..."; fi
    rm -rf $JOBDIR $INPUTFILE $MYDIR/rsync $MYDIR/id_rsa.pub $MYDIR/id_rsa $MYDIR/known_hosts

    if [[ -e "$MYDIR/configuration.tgz" ]] ; then
      if [[ $DEBUG -ge 2 ]] ; then echo "Executing \"rm -rf $MYDIR/configuration.tgz\"..."; fi
      rm -rf $MYDIR/configuration.tgz
    fi
    
    if [[ $TIDYOUTPUT -eq 1 ]] ; then
      if [[ $DEBUG -ge 2 ]] ; then echo "Executing \"rm -rf $OUTPUTFILE\"..."; fi
      rm -rf $OUTPUTFILE
    fi
    if [[ $DEBUG -ge 1 ]] ; then echo "done."; fi
  elif [[ $DEBUG -ge 1 ]] ; then
    echo "ATTENTION: Skipping deletion of temporary files, please clean up manually!";
    echo "           Check configuration of $0, if automatic clean-up should be desired.";
  fi
}


#
# exit with tidy
#
trap tidy exit


#
# main
#

  # copy input data?
  chmod 600 $PRIVKEY
  if [[ -n $3 && -n $4 ]] ; then
    myCopy "FETCH" $3
  fi

  # basic checks for (parameter) correctness
  # and if input data exists, and output data doesn't
  # -> check _after_ fetching potential input data!
  doChecks $1 $2;

  # set environment variables
  prepare-environment $1;

  # execute modell
  #
  # ATTENTION: parallel jobs may only return/exit, if and only if the parallel job has finished!
  #            successfully submitting a job only is not sufficient due to obvious reasons
  #            -> one may use the function waitFor(), if suitable
  #
  if [[ $TESTRUN -eq 0 ]] ; then
    repackInput
    . $MODELDIR/${1}.sh
  else
    . $MODELDIR/helloWorld.sh
  fi

  # copy output data?
  if [[ -n $3 && -n $4 ]] ; then
    myCopy "PUT" $4
    TIDYOUTPUT=1
  fi
  # potentially copy $MYDIR in high debug level!
  if [[ $DEBUG -ge 3 ]] ; then
    MYSCPCMD="scp -o UserKnownHostsFile=${KNOWNHOSTS} -i ${PRIVKEY} -r ${MYDIR} rsync-user@drihm-tools.pub.lab.nm.ifi.lmu.de:/home/rsync-user/data-store/"
    echo "Debug level \"$DEBUG\" set: copying ${MYDIR} for debugging purposes...";
    echo "$MYSCPCMD";
    $MYSCPCMD
    echo "done.";
  fi

  # clean up and exit
  exit 0;

#
# END
#


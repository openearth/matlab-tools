#
# Version 1.0 of delft3d.sh:
# DRIHM modelScript for
# Deltares Delft3D-FLOW (structured grid version)
#
  export MODELENGINE=Delft3D-FLOW
  export JOBID=$(echo $OUTPUTFILE | cut -d '.' -f 2)
  export JOBDIRSTR=`echo $JOBDIR | sed "s/\//\\\\\\\\\//g"`

#
# The $BINDIR/delft3d folder has been copied to the $JOBDIR by start.sh
# Set environment settings
#

  if [[ $DEBUG -ge 2 ]] ; then echo "Make sure that we are in the $JOBDIR"; fi
  cd $JOBDIR 
  
  ORG_LD_LIBRARY_PATH=$LD_LIBRARY_PATH

#
# prepare input
#
  
  if [[ $DEBUG -ge 1 ]] ; then echo "Preparing input files for Delft3D... "; fi

  if [[ -f "schematization.tgz" ]] ; then
    if [[ $DEBUG -ge 2 ]] ; then echo "Unpacking model schematization (schematization.tgz)"; fi
    tar -xpvzf schematization.tgz
    nMDF=`ls *.mdf | grep -c .`
    nDDB=`ls *.ddb | grep -c .`
    if [[ nMDF -eq 1 ]] ; then
      export simType=mdf    
      CASE=`ls *.$simType | cut -d "." -f 1`
      if [[ $DEBUG -ge 2 ]] ; then echo "Found case $CASE.$simType"; fi
    elif [[ nDDB -eq 1 ]] ; then
      simType=ddb    
      CASE=`ls *.$simType | cut -d "." -f 1`
      if [[ $DEBUG -ge 2 ]] ; then echo "Found case $CASE.$simType"; fi
    else
      simType=unknown
      CASE=undefined
      echo "ERROR: unable to identify mdf or ddb file"
    fi
  else
    echo "ERROR: Missing schematization.tgz"
  fi

  if [[ $DEBUG -ge 2 ]] ; then echo "Unpacking forcing data ($INPUTFILE)"; fi
  tar -xpvzf $INPUTFILE
  cp drihm_config/*.py .
  python insert_DRIHM_boundary.py
  
  if [[ ! -f "config_d_hydro.xml" ]] ; then
    if [[ $DEBUG -ge 2 ]] ; then echo "Preparing default config_d_hydro.xml"; fi
    cp drihm_config/config_d_hydro.xml .
    sed -i "s/INPUT_FILE_SPECIFICATION/<${simType}File>${CASE}.mdf<\/${simType}File>/g" config_d_hydro.xml 
  else
    if [[ $DEBUG -ge 2 ]] ; then echo "Using case specific config_d_hydro.xml"; fi
  fi

  if [[ $DEBUG -ge 1 ]] ; then echo "done."; fi 

# 
# Run simulation
#

  if [[ $DEBUG -ge 1 ]] ; then echo "Preparing environment variables... "; fi

  export EXEDIR=flow2d3d/bin 
  export LD_LIBRARY_PATH=$EXEDIR:$LD_LIBRARY_PATH  

  if [[ $DEBUG -ge 1 ]] ; then echo "done."; fi 

  if [[ $DEBUG -ge 1 ]] ; then echo "Running Deltares Delft3D-FLOW... "; fi

  $EXEDIR/d_hydro.exe config_d_hydro.xml

  if [[ -f tri-diag.$CASE ]] ; then
    a=`grep -c -e "*** Simulation finished" tri-diag.$CASE`
    if [[ $a -eq 1 ]] ; then
      if [[ $DEBUG -ge 1 ]] ; then echo "Application Successful"; fi
      exitcode=0
    else
      if [[ $DEBUG -ge 1 ]] ; then echo "Application Failed"; fi
      exitcode=1
    fi
  else
    if [[ $DEBUG -ge 1 ]] ; then echo "Application Failed"; fi
    exitcode=1
  fi

  if [[ $DEBUG -ge 1 ]] ; then echo "done."; fi 

#
# Generate output-file
#

  if [[ $DEBUG -ge 1 ]] ; then echo "Collecting generated output for Delft3D-FLOW... "; fi

  if [[ $DEBUG -ge 2 ]] ; then echo "Creating and moving to results directory... "; fi
  mkdir results_dir
  cd results_dir

  if [[ $DEBUG -ge 2 ]] ; then echo "Moving model output... "; fi
  mv ../td-diag.* .
  mv ../tri-diag.* .
  mv ../trim-*.nc .
  mv ../trih-*.nc .

  if [[ $DEBUG -ge 2 ]] ; then echo "Moving back to $JOBDIR... "; fi
  cd $JOBDIR

  if [[ $DEBUG -ge 2 ]] ; then echo "Packing all files into $OUTPUTFILE... "; fi
  tar -czf $OUTPUTFILE results_dir/*

  if [[ $DEBUG -ge 1 ]] ; then echo "done."; fi 
  
  if [[ $DEBUG -ge 2 ]] ; then echo "Resetting LD_LIBRARY_PATH... "; fi
  export LD_LIBRARY_PATH=$ORG_LD_LIBRARY_PATH

  if [[ $exitcode -eq 1 ]] ; then
    if [[ $DEBUG -ge 2 ]] ; then echo "Triggering exit code ... "; fi
    exit $exitcode
  fi

# Simulation Management Tool
# Run scripts library and tools 
#    Copyright (C) 2016  Deltares
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Lesser General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/SMT/trunk/run.py $ 
# $Id: run.py 13137 2017-01-20 13:34:50Z ottevan $ 
# 
#===================================================================
# Import modules
#===================================================================
import sys,os,glob,string,time,adaptsrc

timeformat = '%a %d %b %Y %H:%M:%S'

#===================================================================
# Define subfunctions
#===================================================================
def runexe(workdir,prog):
  os.chdir(workdir)
  #os.spawnv(os.P_WAIT,prog,[])
  os.system(prog)
  os.chdir('..')

def copy(src,trgt):
  if os.name == 'nt':
    os.system('copy /Y '+src+' '+trgt)
  elif os.name == 'posix':
    os.system('cp -R '+src+' '+trgt)
  else:
    print 'ERROR: Copy statement not implemented for OS "'+os.name+'"'
    sys.stdout.flush()
    os._exit(1)

def move(src,trgt):
  if os.name == 'nt':
    os.system('move /Y '+src+' '+trgt)
  elif os.name == 'posix':
    os.system('mv '+src+' '+trgt)
  else:
    print 'ERROR: Move statement not implemented for OS "'+os.name+'"'
    sys.stdout.flush()
    os._exit(1)

def less(src,prefix=''):
  for line in open(src,'r').readlines():
    print prefix+line[:-1]
    sys.stdout.flush()

def fancyless(src):
  print ' .-----------------------------'
  sys.stdout.flush()
  less(src,' |')
  print ' `-----------------------------'
  sys.stdout.flush()

def count(src,substr):
  nc = 0
  for line in open(src,'r').readlines():
    nc = nc + string.count(line,substr)
  return nc
  
def guaranteedir(mydir):
  if not os.path.isdir(mydir):
    print 'Creating subdirectory '+mydir+' ...'
    sys.stdout.flush()
    os.mkdir(mydir)
    if not os.path.isdir(mydir):
      print 'Cannot create subdirectory '+mydir
      sys.stdout.flush()
      os._exit(1)

def qdbstore(QdbaseExe,workdir,RunIDs,simfil,dbases,Disch):
  print
  cmd = 'STORE OVERWRITE'
  for dbase in dbases:
    print 'Storing to '+dbase+'* ...'
    sys.stdout.flush()
    worksep = workdir + os.sep
    for runid in RunIDs:
      qdbfile=open(worksep+'qdb.cmd','w')
      qdbfile.write(cmd+'\n')
      qdbfile.write(str(Disch)+'\n')
      qdbfile.write(simfil+runid+'\n')
      qdbfile.write(dbase+runid+'\n')
      qdbfile.close()
      runexe(workdir,QdbaseExe)
      ChkFil = worksep+'qdb.log'
      if os.path.exists(ChkFil):
        Normal = count(ChkFil,'Normal end')
        if Normal == 0:
          fancyless(ChkFil)
          print 'ERROR: QDB store command not successfull ...'
          sys.stdout.flush()
          os._exit(1)
        else:
          os.remove(ChkFil)
      else:
        print 'ERROR: "'+ChkFil+'" not found'
        sys.stdout.flush()
        os._exit(1)
    cmd = 'STORE DON\'T OVERWRITE'

def qdbretrieve(QdbaseExe,workdir,RunIDs,simfil,dbases,Disch):
  print
  cmd = 'RETRIEVE FREE MATCH'
  for i in range(len(dbases)):
    dbase = dbases[i]
    print 'Retrieving from '+dbase+'* ...'
    sys.stdout.flush()
    worksep = workdir + os.sep
    for runid in RunIDs:
      qdbfile=open(worksep+'qdb.cmd','w')
      qdbfile.write(cmd+'\n')
      qdbfile.write(str(Disch)+'\n')
      qdbfile.write(simfil+runid+'\n')
      qdbfile.write(dbase+runid+'\n')
      qdbfile.close()
      runexe(workdir,QdbaseExe)
      ChkFil = worksep+'qdb.log'
      if os.path.exists(ChkFil):
        Normal = count(ChkFil,'Normal end')
        if Normal == 1:
          os.remove(ChkFil)
          print 'Discharge found in database: '+dbase+runid
          sys.stdout.flush()
          return i
        else:
          fancyless(ChkFil)
          os.remove(ChkFil)
    cmd = 'RETRIEVE'
  print 'Discharge not found in any database'
  sys.stdout.flush()
  return len(dbases)

def qdbcopy(QdbaseExe,workdir,RunIDs,groups,fromfil,fromidx,tofil,toidx):
  print
  cmd = 'COPY'
  for grp in groups:
    print 'Retrieving '+grp+' from '+fromfil+'* ...'
    sys.stdout.flush()
    worksep = workdir + os.sep
    for runid in RunIDs:
      qdbfile=open(worksep+'qdb.cmd','w')
      qdbfile.write(cmd+'\n')
      qdbfile.write(grp+'\n')
      qdbfile.write(str(fromidx)+'\n')
      qdbfile.write(str(toidx)+'\n')
      qdbfile.write(fromfil+runid+'\n')
      qdbfile.write(tofil+runid+'\n')
      qdbfile.close()
      runexe(workdir,QdbaseExe)
      ChkFil = worksep+'qdb.log'
      if os.path.exists(ChkFil):
        Normal = count(ChkFil,'Normal end')
        if Normal == 0:
          fancyless(ChkFil)
          print 'Copy of '+grp+' failed!'
          print 'source file: %s (index %i)' % (fromfil+runid,fromidx)
          print 'target file: %s (index %i)' % (tofil+runid,toidx)
          sys.stdout.flush()
          os._exit(1)
        os.remove(ChkFil)


def getrefplane(Trim2DepExe,workdir,RunIDs,fromfil,fromidx,tofil):
    print 'Copy of trim2dep'
    worksep = workdir + os.sep
    for runid in RunIDs:
      print 'source file: %s (index %s)' % (fromfil+runid,str(fromidx))
      print 'target file: %s ' % (tofil+runid+'.dep')
      sys.stdout.flush()
      trim2depfile=open(worksep+'trim2dep.cmd','w')
      trim2depfile.write(fromfil+runid+'\n')
      trim2depfile.write(tofil+runid+'.dep'+'\n')
      if os.path.exists(worksep+tofil+runid+'.dep'):
        move(worksep+tofil+runid+'.dep',worksep+tofil+runid+'.old')
      trim2depfile.write('map-series'+'\n')
      trim2depfile.write('S1'+'\n')
      trim2depfile.write(str(fromidx)+'\n')
      trim2depfile.write('-999')
      trim2depfile.close()
      runexe(workdir,Trim2DepExe)
      ChkFil = worksep+'trim2dep.log'
      if os.path.exists(ChkFil):
        Normal = count(ChkFil,'Normal end')
        if Normal == 0:
          fancyless(ChkFil)
          print 'Copy of trim2dep failed!'
          print 'source file: %s (index %i)' % (fromfil+runid,fromidx)
          print 'target file: %s ' % (tofil+runid+'.dep')
          sys.stdout.flush()
          os._exit(1)
        os.remove(ChkFil)
        
def getduneheight(Trim2DepExe,workdir,RunIDs,fromfil,fromidx,tofil):
    print 'Copy of trim2dune'    
    worksep = workdir + os.sep
    for runid in RunIDs:
      print 'source file: %s (index %s)' % (fromfil+runid,str(fromidx))
      print 'target file: %s ' % (tofil+runid+'.dep')
      sys.stdout.flush()
      trim2depfile=open(worksep+'trim2dep.cmd','w')
      trim2depfile.write(fromfil+runid+'\n')
      trim2depfile.write(tofil+runid+'.dep'+'\n')
      if os.path.exists(worksep+tofil+runid+'.dep'):
        move(worksep+tofil+runid+'.dep',worksep+tofil+runid+'.old')
      trim2depfile.write('map-sed-series'+'\n')
      trim2depfile.write('DUNEHEIGHT'+'\n')
      trim2depfile.write(str(fromidx)+'\n')
      trim2depfile.write('-999')
      trim2depfile.close()
      runexe(workdir,Trim2DepExe)
      ChkFil = worksep+'trim2dep.log'
      if os.path.exists(ChkFil):
        Normal = count(ChkFil,'Normal end')
        if Normal == 0:
          fancyless(ChkFil)
          print 'Copy of trim2dep failed!'
          print 'source file: %s (index %i)' % (fromfil+runid,fromidx)
          print 'target file: %s ' % (tofil+runid+'.dep')
          sys.stdout.flush()
          os._exit(1)
        os.remove(ChkFil)


#===================================================================
# Main function
#===================================================================
def run(RunIDs,TrisimParameters,TStart,TStop,Disch,Src,OLA):
  print 'run',TStart,TStop,Disch,Src
  sys.stdout.flush()
  workdir     = 'work'
  outputdir   = 'output'
  restartfile = 'restart-trim-'
  qdependent  = 'q_dependent'
  
  TraceBackInfo = adaptsrc.getTraceBackInfo()
  # TraceBackInfo: 0: move only NEFIS files temporarily to output directory
  #                1: move all files temporarily to output directory, delete
  #                   all files after successful next step
  #                2: move all files temporarily to output directory, delete
  #                   all NEFIS files after successful next step
  #                3: move all files temporarily to output directory, delete
  #                   all NEFIS except restart-files after successful next step
  #                4: move all files temporarily to output directory, keep
  #                   all files
  
  FromBackUp = outputdir+os.sep+str(TStart)+'.min'
  ToBackUp   = outputdir+os.sep+str(TStop)+'.min'
  #if OLA == 'Y':
  #  ToBackUp = 'ola_'+ToBackUp

  InitialRun = not os.path.isdir(FromBackUp)
  
  #-----------------------------------------------------------------
  # Set path and executable variables
  #-----------------------------------------------------------------
  arch = os.environ['ARCH']
  
  up = '..'+os.sep
  worksep = workdir+os.sep
  
  qdbname = 'qdb-'
  centralqdb = up+'central_database'
  localqdb = 'local_database'
  dbases = [up+localqdb+os.sep+qdbname,up+centralqdb+os.sep+qdbname]
  execpath = os.environ['D3D_HOME']+os.sep+arch+os.sep+'flow2d3d'+os.sep+'bin'+os.sep
  #execpath = up+up+'executables_swc_h5'+os.sep+arch+os.sep+'bin'+os.sep
  
  FlowExe = execpath+'d_hydro.exe'
  QdbaseExe = execpath+'qdb.exe'
  Trim2DepExe = execpath+'trim2dep.exe'
  
  #-----------------------------------------------------------------
  # Verify existence of executables
  #-----------------------------------------------------------------
  Executables = [FlowExe,QdbaseExe,Trim2DepExe]
  for exe in Executables:
    print exe, os.path.isfile(exe)
    if not os.path.isfile(exe):
      print 'pwd = ' + os.getcwd()
      print 'hostname = ' + os.environ['HOSTNAME']
      print 'dirlist = '
      print os.listdir(execpath)
      print 'Cannot find executable: %s!' % exe
      sys.stdout.flush()
      os._exit(1)
    elif InitialRun:
      print 'Using: %s' % exe
      sys.stdout.flush()
  
  #-----------------------------------------------------------------
  # Create workdirectory for simulation files
  #-----------------------------------------------------------------
  guaranteedir(workdir)
  guaranteedir(centralqdb)
  guaranteedir(localqdb)
  guaranteedir(outputdir)
  SimulationRunFailure = 0
 
  #-----------------------------------------------------------------
  # Do some initial checking and cleaning
  #-----------------------------------------------------------------
  if os.path.exists(ToBackUp):
    if not os.path.isdir(ToBackUp):
      #
      # Determine time shift!
      # 'SHIFTED TO: <newTStop>'
      #
      print 'Time shift file '+ToBackUp+' found.'
      print 'Reading time shift from file ...'
      sys.stdout.flush()
      file = open(ToBackUp,'r')
      TimeString = file.readline()[:-1].split(':')[1]
      file.close()
      newTStop = eval(TimeString)
      ToBackUp = outputdir+os.sep+str(newTStop)+'.min'
      #if OLA == 'Y':
      #   ToBackUp = 'ola_'+ToBackUp
      if not os.path.isdir(ToBackUp):
        print 'Cannot find time shifted backup directory '+ToBackUp
        sys.stdout.flush()
        os._exit(1)
    else:
      #
      # Simple no time shift case.
      #
      newTStop = TStop
    print 'Backup directory '+ToBackUp+' exists.'
    print 'Skipping',TStart,'till',newTStop,'...'
    sys.stdout.flush()
    return newTStop
  else:
    print ' '
    print 'Simulation period',TStart,'till',TStop,'...'
    sys.stdout.flush()
    workfiles = glob.glob(worksep+'*')
    if len(workfiles)>0:
      print 'Clearing work directory ...'
      sys.stdout.flush()
      for file in workfiles:
        os.remove(file)
    if InitialRun:
      print 'Starting ...'
      sys.stdout.flush()
      RestartLevel = 9
    else:
      print 'Restarting ...'
      sys.stdout.flush()
      for runid in RunIDs:
        RestartLevel = qdbretrieve(QdbaseExe,workdir,[runid],
          restartfile,dbases,Disch) 
      qdbcopy(QdbaseExe,workdir,RunIDs,
        ['map-info-series','map-sed-series','map-infsed-serie'],
        up+FromBackUp+os.sep+'trim-',-1,restartfile,1)
      print 'RestartLevel=',RestartLevel
      sys.stdout.flush()
  
  #-----------------------------------------------------------------
  # Copy source files
  #-----------------------------------------------------------------
  print 'Copying input files from source directory "'+Src+'" ...'
  if not os.path.isdir(Src):
    print 'Source directory "'+Src+'" not found!'
    sys.stdout.flush()
    os._exit(1)
  else:
    files = Src+os.sep+'*.*'
    filesexpanded = glob.glob(files)
    if len(filesexpanded)==0:
      print 'Source directory is empty!'
      sys.stdout.flush()
      os._exit(1)
    else:
      copy(files,workdir)

  #-----------------------------------------------------------------
  # Copy reference plane
  #-----------------------------------------------------------------
  if not InitialRun:
    worksep = workdir + os.sep
    for runid in RunIDs:
      refplanefiles = glob.glob(FromBackUp+os.sep+'refplane'+runid+'.dep')
      for file in refplanefiles:
        if os.path.exists(worksep+'refplane'+runid+'.dep'):
          move(worksep+'refplane'+runid+'.dep',worksep+'refplane'+runid+'.old')
        print 'Copying Reference Plane for domain "'+runid+'" to work directory.'
        sys.stdout.flush()
        copy(file,workdir)
    
  #-----------------------------------------------------------------
  # Copy initial duneheight
  #-----------------------------------------------------------------
  if not InitialRun:
    worksep = workdir + os.sep
    for runid in RunIDs:
      duneheightfiles = glob.glob(FromBackUp+os.sep+'duneheight'+runid+'.dep')
      for file in duneheightfiles:
        if os.path.exists(worksep+'duneheight'+runid+'.dep'):
          move(worksep+'duneheight'+runid+'.dep',worksep+'duneheight'+runid+'.old')
        print 'Copying Initial Duneheight for domain "'+runid+'" to work directory.'
        sys.stdout.flush()
        copy(file,workdir)
  #-----------------------------------------------------------------
  # Copy discharge dependent files from qdb directory
  #-----------------------------------------------------------------
  if os.path.isdir(qdependent):
    files = qdependent+os.sep+'*Q'+str(Disch)+'.*'
    filesexpanded = glob.glob(files)
    if len(filesexpanded)>0:
      print 'Copying files from '+qdependent\
        +' for Q='+str(Disch)+' m^3/s ...'
      sys.stdout.flush()
      copy(files,workdir)
  
  #-----------------------------------------------------------------
  # Change source files
  #-----------------------------------------------------------------
  newTStop = adaptsrc.adaptsrc(worksep,RunIDs,TStart,TStop,Disch,
    RestartLevel=RestartLevel,RestartFile=restartfile)
  if newTStop == None:
    print 'WARNING: no adjusted TStop returned by adaptsrc, assuming no change.'
    sys.stdout.flush()
    newTStop = TStop

  #-----------------------------------------------------------------
  # Run delftflow for all domains together ...
  #-----------------------------------------------------------------
  print
  print 'Running simulation (DELFTFLOW) ...'
  NOW = time.strftime(timeformat,time.localtime(time.time()))
  print 'Simulation started ... ('+NOW+')'
  sys.stdout.flush()
  # ---------> run trisim
  runexe(workdir,FlowExe+' '+TrisimParameters+' >> simulate.out')
  #
  NOW = time.strftime(timeformat,time.localtime(time.time()))
  print 'Simulation stopped ... ('+NOW+')'
  sys.stdout.flush()

  #-----------------------------------------------------------------
  # Do some error checking
  #-----------------------------------------------------------------
  Error = 0
  checkfiles = [['simulate.out','exited abnormally']]
  for runid in RunIDs:
    checkfiles.append(['tri-diag.'+runid,'ERROR'])
  for file in checkfiles:
    ChkFil = worksep+file[0]
    ErrStr = file[1]
    if os.path.exists(ChkFil):
      Error = count(ChkFil,ErrStr)
      if Error != 0:
        print 'ERROR: "'+ErrStr+'" message encountered in '+ChkFil
        sys.stdout.flush()
        os._exit(1)
    else:
      print 'ERROR: "'+ChkFil+'" not found'
      sys.stdout.flush()
      os._exit(1)

  checkfiles = ['TMP*']
  for runid in RunIDs:
    checkfiles.append('td-diag.'+runid)
  for filemask in checkfiles:
    for file in glob.glob(worksep+filemask):
      print 'ERROR: "'+file+'" found.'
      sys.stdout.flush()
      os._exit(1)
  
  #-----------------------------------------------------------------
  # Store flow field in database
  #-----------------------------------------------------------------
  qdbstore(QdbaseExe,workdir,RunIDs,'trim-',dbases,Disch)

  #-----------------------------------------------------------------
  # Update Reference Plane
  #-----------------------------------------------------------------
  if OLA == 'Y': 
    getrefplane(Trim2DepExe,workdir,RunIDs,'trim-','-1','refplane')
    
  #-----------------------------------------------------------------
  # Update Initial Duneheight
  #-----------------------------------------------------------------
  getduneheight(Trim2DepExe,workdir,RunIDs,'trim-','-1','duneheight')
  
  #-----------------------------------------------------------------
  # Create subdirectory for simulation files
  #-----------------------------------------------------------------
  if newTStop<>TStop:
    file = open(ToBackUp,'w')
    file.write('SHIFTED TO: '+str(newTStop)+'\n')
    file.write('Don\'t delete! This file is needed to find the\n')
    file.write('directories associated with results after this\n')
    file.write('time step.\n')
    file.close()
    ToBackUp   = outputdir+os.sep+str(newTStop)+'.min'
    #if OLA == 'Y':
    #  ToBackUp = 'ola_'+ToBackUp
  guaranteedir(ToBackUp)
  
  #-----------------------------------------------------------------
  # Move input and output files to the created directory as desired
  # and remove everything else
  #-----------------------------------------------------------------
  print 'Saving results to directory '+ToBackUp
  if TraceBackInfo == 0:
    checkfiles = []
    for runid in RunIDs:
      checkfiles.append('*-'+runid+'.dat')
      checkfiles.append('*-'+runid+'.def')
      checkfiles.append('tri-diag.'+runid)
  else:
    checkfiles = ['*']
  for filemask in checkfiles:
    for file in glob.glob(worksep+filemask):
      move(file,ToBackUp)
  for file in glob.glob(worksep+'*'):
    os.remove(file)
  
  #-----------------------------------------------------------------
  # Since this run was successful remove some or all output files of
  # previous run
  #-----------------------------------------------------------------
  if not InitialRun:
    if TraceBackInfo == 1:
      filetype = 'all files'
      files = glob.glob(FromBackUp+os.sep+'*')
    elif TraceBackInfo == 2:
      filetype = 'all NEFIS dat/def pairs'
      files = []
      for file in glob.glob(FromBackUp+os.sep+'*.dat'):
        if os.path.isfile(file[:-4]+'.def'):
          files.append(file)
          files.append(file[:-4]+'.def')
    elif TraceBackInfo == 3:
      filetype = 'all (non restart) NEFIS dat/def pairs'
      files = []
      for file in glob.glob(FromBackUp+os.sep+'*.dat'):
        if os.path.isfile(file[:-4]+'.def') and file.find(restartfile)<0:
          files.append(file)
          files.append(file[:-4]+'.def')
    else:
      files = []
    if len(files)>0:
      print 'Removing '+filetype+' from '+FromBackUp+' ...'
      sys.stdout.flush()
      for file in files:
        os.remove(file)

  #-----------------------------------------------------------------
  # Return the adjusted end time to the calling routine
  #-----------------------------------------------------------------
  return newTStop

#===================================================================
# Code if module is run as script
#===================================================================
if __name__ == '__main__':
  RunIDs = [sys.argv[1]]
  TStart = eval(sys.argv[2])
  TStop = eval(sys.argv[3])
  Src = eval(sys.argv[4])
  run(RunIDs,'',TStart,TStop,Disch,Src)
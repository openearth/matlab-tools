# Simulation Management Tool
# Adapts source files to perform a multi-discharge simulation
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
# Read.me
# using this file to manage multi-discharge simulation in the following way:
# LINE 21 : set the RunID(s)
# LINE 42 : set TraceBackInfo as explained in LINE 33
# LINE 82 : set InitialPeriod as explained in the preceeding lines 
#         : applicable for lines :89 - 96 - 104
# LINE 147: set OutputOption (for writing map-file) as explained in the preceeding lines
# LINE 149: set NOutput (if OutputOption = 1)
# LINE 195 - 203: added some changes in writing ststments --> make sure to modifiey in dredging simulations
# LINE 208: here you can change the value of any keyword as a function of discharge
#
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/SMT/trunk/adaptsrc.py $ 
# $Id: adaptsrc.py 13300 2017-05-02 09:18:41Z ottevan $ 
#
#===================================================================
# Import modules
#===================================================================
import os,string,re

#===================================================================
# RunIDs and trisim command line parameters (ddbound)
#===================================================================
def getRunIDs():
   RunIDs = ['bem','mw1','mw2','mam','dom','nod','nr2','hos','nim']
   return RunIDs

def getTrisimParameters():
   TrisimParameters = 'config_d_hydro_dd.xml'
   return TrisimParameters

def getOLADischarge():
   OLA_Discharge = 1020
   return OLA_Discharge

#===================================================================
# RunIDs and trisim command line parameters (ddbound)
#===================================================================
def getTraceBackInfo():
  # TraceBackInfo: 0: move only NEFIS and tri-diag files to output directory
  #                1: move all files temporarily to output directory, delete
  #                   all files after successful next step
  #                2: move all files temporarily to output directory, delete
  #                   all NEFIS files after successful next step
  #                3: move all files temporarily to output directory, delete
  #                   all NEFIS except restart-files after successful next step
  #                4: move all files temporarily to output directory, keep
  #                   all files
  TraceBackInfo = 4
  return TraceBackInfo

#===================================================================
# Define subfunctions
#===================================================================
def getstringvalue(s):
  s = s.replace('\n','')
  parts = s.split('#')
  if len(parts)>=2:
    return parts[1]
  else:
    return s

def getval(dictionary,keyword,default=None):
  if dictionary.has_key(keyword):
    return dictionary[keyword]
  else:
    return default

def comparekeyword(s1,s2): 
    return s1.lower() == s2.lower()

#===================================================================
# Main function
#===================================================================
def adaptsrc(worksep,RunIDs,TStart,TStop,Disch,**dict):
  RestartLevel = getval(dict,'RestartLevel')
  restartfile  = getval(dict,'RestartFile')
  #-----------------------------------------------------------------
  # Update stop time
  #-----------------------------------------------------------------
  InitialPeriod = 0
  if RestartLevel==0:
    #
    # flow field from local database:
    #   minor adjustment needed
    #
    #   No adjustment may be required at all, namely
    #   if two successive periods use the same discharge.
    #   However, in general we will not split the simulation
    #   at such points (exception: Monte Carlo simulations).
    #
    InitialPeriod = 745
    #
  elif RestartLevel==1:
    #
    # flow field from central database:
    #   significant adjustment may be needed
    #
    InitialPeriod = 745
    #
  elif RestartLevel==2:
    #
    # non-matching restart file:
    #   long adjustment may be needed
    #
    InitialPeriod = 745
    #
  elif RestartLevel==9:
    #
    # no restart file:
    #   either long adjustment needed (cold-start startup)
    #   or no adjustment needed (start from optimal tri-rst)
    #
    InitialPeriod = 745
    #
  if InitialPeriod>0:
    TStop = TStop + InitialPeriod
    print 'Startup period of '+str(InitialPeriod)+' minute(s) added'

  for runid in RunIDs: 
    if len(RunIDs)>1:
      print 'Updating input files for domain',runid,'...'
    else:
      print 'Updating input files for simulation',runid,'...'

    Filmor = ''
    
    #-----------------------------------------------------------------
    # Edit mdf
    #-----------------------------------------------------------------
    filename = worksep+runid+'.mdf'
    print 'Processing',filename,'...'
    inputfile = open(filename,'r')
    lines = inputfile.readlines()
    inputfile.close()
    for i in range(len(lines)):
      line = lines[i]
      #
      A = re.split('\s*=\s*',line,1)
      if len(A)<2:
        keyword = ''
        value = A[0]
      else:
        keyword = A[0].lstrip()
        value   = A[1]
      if keyword=='Tstart':
        line = 'Tstart = %0.1f\n' % TStart
      elif keyword=='Tstop':
        line = 'Tstop  = %0.1f\n' % TStop
      elif keyword=='Dt':
        Dt = eval(value)
      elif keyword=='Flmap':
        #
        # OutputOption = 1 : NOutput equally spaced time steps ending at final time step of simulation
        #                2 : time step equal to time step already specified in MDF file; TStartMap adjusted
        #                3 : recording start after spin-up perion (same as OutputOption = 2)
        #                4 : recording start after spin-up perion (same as OutputOption = 1)
        OutputOption = 4
        # if OutputOption = 1 --> NOutput = number of output records on map file
        NOutput = 5
        #
        if OutputOption==1:
          #
          # NOutput equally spaced time steps ending at final time step of simulation
          #
          NDtMap = int((TStop-TStart)/(NOutput*Dt))
          TStartMap = TStop - NOutput*NDtMap*Dt
          if NDtMap==0:
            NDtMap = 1
          DtMap = NDtMap*Dt
        elif OutputOption==2:
          #
          # time step equal to time step already specified in MDF file; TStartMap adjusted
          #
          times = value.split()
          DtMap = eval(times[1])
          TStartMap = eval(times[0])
          N = int((TStop - TStartMap)/DtMap)
          TStartMap = TStop - N*DtMap
        elif OutputOption==3:
          #
          # time step equal to time step already specified in MDF file 
          # starting after spin-up period and ending at final time step of simulation
          #
          times = value.split()
          DtMap = eval(times[1])
          TStartMap = eval(times[0])
          TStartMap = TStartMap + InitialPeriod
          N = int((TStop - TStartMap)/DtMap)
          TStartMap = TStop - N*DtMap
        elif OutputOption==4:
          #
          # NOutput equally spaced time steps ending at final time step of simulation
          # starting after spin-up period and ending at final time step of simulation
          #
          NDtMap = int((TStop-TStart-InitialPeriod)/(NOutput*Dt))
          TStartMap = TStop - NOutput*NDtMap*Dt
          if NDtMap==0:
            NDtMap = 1
          DtMap = NDtMap*Dt          
        line = 'Flmap  = %0.1f %0.1f %0.1f\n' % (TStartMap,DtMap,TStop)
      elif comparekeyword(keyword,'Flpp'):
          TStartFlpp = TStop - 10*Dt
          line = 'Flpp   = %0.1f %0.1f %0.1f\n' % (TStartMap,DtMap,TStop)
      elif comparekeyword(keyword,'Flhis'):
      	  vals = value.split()
      	  DtHis = float(vals[1])
          # for dredging simulations the TStartFlhis should be set to at least TStartMap
          line = 'Flhis = %0.1f %0.1f %0.1f\n' % (TStart,DtHis,TStop)      
      elif keyword=='Restid':
        if RestartLevel<9:
          line = 'Restid= #'+restartfile+runid+'#\n'
        else:
          line = string.replace(line,'DischQ',str(Disch))          
      else:
        line = string.replace(line,'DischQ',str(Disch))
      if Disch==30:
        if comparekeyword(keyword,'BdfT_H'):
          line = 'BdfT_H= 172800\n'
      if Disch==209:
        if comparekeyword(keyword,'BdfT_H'):
          line = 'BdfT_H= 172800\n'
      #  elif keyword=='keyw2'
      #    line = 'keyw2 = value2'
      #elif Disch==2222:
      #  if keyword=='BdfT_H':
      #    line = 'BdfT_H= 2'
      #  elif keyword=='keyw2'
      #    line = 'keyw2 = value2'
      if comparekeyword(keyword,'Filmor'):
        A = re.split('\s*=\s*',line,1)
        if len(A)<2:
          keyword = ''
          value = A[0]
        else:
          keyword = A[0].lstrip()
          value   = A[1]
        Filmor = getstringvalue(value)
      if comparekeyword(keyword,'Filsed'):
        A = re.split('\s*=\s*',line,1)
        if len(A)<2:
          keyword = ''
          value = A[0]
        else:
          keyword = A[0].lstrip()
          value   = A[1]
        Filsed = getstringvalue(value)
      #
      lines[i] = line
    inputfile = open(filename,'w')
    inputfile.writelines(lines)
    inputfile.close()
    
    #-----------------------------------------------------------------
    # Edit mor
    #-----------------------------------------------------------------
    filename = worksep+Filmor
    print 'Processing',filename,'...'
    inputfile = open(filename,'r')
    lines = inputfile.readlines()
    inputfile.close()
    for i in range(len(lines)):
      line = lines[i]
      #
      A = re.split('\s*=\s*',line,1)
      if len(A)<2:
        keyword = ''
        value = A[0]
      else:
        keyword = A[0].lstrip()
        value   = A[1]
      #
      if comparekeyword(keyword,'MorStt'):
        line = 'MorStt= '+str(InitialPeriod)+'\n'
      else:
        line = string.replace(line,'DischQ',str(Disch))
      #
      lines[i] = line
    inputfile = open(filename,'w')
    inputfile.writelines(lines)
    inputfile.close()
    #-----------------------------------------------------------------
    # Edit sed
    #-----------------------------------------------------------------
    filename = worksep+Filsed
    print 'Processing',filename,'...'
    inputfile = open(filename,'r')
    lines = inputfile.readlines()
    inputfile.close()
    for i in range(len(lines)):
      line = lines[i][:-1]
      #
      A = re.split('\s*=\s*',line,1)
      if len(A)<2:
        keyword = ''
        value = A[0]
      else:
        keyword = A[0].lstrip()
        value   = A[1]
      #
      line = string.replace(line,'DischQ',str(Disch))
      #
      lines[i] = line+'\n'
    inputfile = open(filename,'w')
    inputfile.writelines(lines)
    inputfile.close()    
  
  #-----------------------------------------------------------------
  # Return actual stop time
  #-----------------------------------------------------------------
  return TStop

#===================================================================
# Code if module is run as script
#===================================================================
if __name__ == '__main__':
  if len(sys.argv) < 2:
    print 'Usage: adaptsrc.py <workdir> <runid> <TStart> <TStop> <Disch> <RstLevel>'
    print
    print '<workdir> = work directory relative to current directory, e.g. \'work\''
    print '<runid>   = runid of the simulation file to process'
    print '<TStart>  = start time in minutes'
    print '<TStop>   = stop time in minutes'
    print '<Disch>   = discharge in m^3/s'
  else:
    nargin = len(sys.argv)
    worksep = sys.argv[1]
    if worksep[-1]<>os.sep:
      worksep = worksep+os.sep
    RunIDs  = [sys.argv[2]]
    TStart  = sys.argv[3]
    TStop   = sys.argv[4]
    Disch   = sys.argv[5]
    TStopFinal = adaptsrclist(worksep,RunIDs,TStart,TStop,Disch)
    if TStopFinal<>TStop:
      print 'TStop has been adjusted from',TStop,'to',TStopFinal

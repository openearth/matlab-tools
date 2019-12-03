# Simulation Management Tool 
# Top level file to run simulation
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
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/SMT/trunk/runsim.py $ 
# $Id: runsim.py 12786 2016-06-28 08:11:21Z ottevan $ 
# 
#===================================================================
# Import modules
#===================================================================
import os, time, sys, run, adaptsrc, fileinput

#===================================================================
# Set some constants
#===================================================================
timeformat = '%a %d %b %Y %H:%M:%S'
Time = 0
Rrun = 0
#Qseries = sys.stdin
print 'opening Qseries'
Qseries = open('Qseries','r')
print 'opening Qseries done'
sys.stdout.flush()

#===================================================================
# Set runid's of the simulation
#===================================================================
RunIDs = adaptsrc.getRunIDs()
TrisimParameters = adaptsrc.getTrisimParameters()
OLA_Discharge = adaptsrc.getOLADischarge()

print 'SIMULATION STARTED AT'
print time.strftime(timeformat+' %Z',time.localtime(time.time()))
print 
print 'Simulation composed of domains:'
print
for runid in RunIDs:
  print ' *',runid
print
print '============================================'
sys.stdout.flush()

#===================================================================
# If Qseries file exists, start processing it ...
#===================================================================
LineNr = 0
while 1:
  LineNr = LineNr + 1
  line = Qseries.readline()
  if len(line)==0: break
  #print 'Line',LineNr,': "'+line[:-1]+'"'
  #-------------------------------------------------------
  # For each line in Qseries ...
  #-------------------------------------------------------
  #
  values = line.split()
  #
  # skip empty lines ...
  #
  if len(values)==0: continue
  #
  # skip comment lines ...
  #
  if values[0][0]=='*': continue
  #
  Discharge = eval(values[0])
  Period = eval(values[1])
  TimeEnd = Time+Period
  #
  Error = 0
  #
  print time.strftime(timeformat,time.localtime(time.time()))
  print 'Period from',Time,'until',TimeEnd
  print ' * Discharge =',Discharge,'m^3/s'
  print '--------------------------------------------'
  sys.stdout.flush()
  #print 'run',Time,TimeEnd,Discharge 
  if Discharge == OLA_Discharge:
    newTimeEnd = run.run(RunIDs,TrisimParameters,Time,TimeEnd,OLA_Discharge,'source','Y')
    print 'OLA Computation -- Updating Reference Plane'
  else:
    newTimeEnd = run.run(RunIDs,TrisimParameters,Time,TimeEnd,Discharge,'source','N')
  if newTimeEnd <> TimeEnd:
    TimeEnd = newTimeEnd
    print '--------------------------------------------'
    print 'Corrected simulation period information'
    print 'Period from',Time,'until',TimeEnd
    print ' * Discharge =',Discharge,'m^3/s'
  print '============================================'
  sys.stdout.flush()
  Time = TimeEnd
  Rrun = 1
  #
  if Error != 0: break

print 'SIMULATION FINISHED AT'
print time.strftime(timeformat,time.localtime(time.time()))
print '============================='

if (Qseries != sys.stdin):
  Qseries.close()

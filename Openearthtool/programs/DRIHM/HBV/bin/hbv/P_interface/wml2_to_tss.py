import xml.etree.ElementTree as etree
import glob
import os
import time
import calendar
from datetime import datetime
import sys         
import shutil

# get info from namelist.txt
for line in open('work/namelist.txt'):
  if 'start_date' in line:
    start_date=line.split('=')
    sd=start_date[1].strip()
    print sd
  if 'end_date' in line:
    end_date=line.split('=')
    ed=end_date[1].strip()
    print ed

putanja='work/river_case/river_hbv/meteo_prepare'
os.chdir(putanja)

# creates temporary folder
directory = 'Temp'
if not os.path.exists(directory):
  os.makedirs(directory)     

val=[]
i=0

# dates of the beggining and the end of simulation with observations from the namelist.txt
sbegin_time=sd
sbegin_date=time.strptime(sbegin_time,'%Y-%m-%dT%H:%M:%S')
s_begin=calendar.timegm(sbegin_date)

send_time=ed
send_date=time.strptime(send_time,'%Y-%m-%dT%H:%M:%S')
s_end=calendar.timegm(send_date)


# path to directory with observations & count the number of files in it
directory='observed_rain/'
number_of_files = len([item for item in os.listdir(directory) if os.path.isfile(os.path.join(directory, item))])
path = 'observed_rain/*.xml'   
files=glob.glob(path)  
print number_of_files

# creation of the files with station lat/lon data and file with observations
f1=open('stations.txt','w')
f2=open('P.tss','w')
f2.write('observed precipitation\n')
f2.write(str(number_of_files+1) +'\n')
f2.write('timesteps\n')


for number in range(1,number_of_files+1):
  f2.write(str(number)+'\n')

for file in files: 
  i=i+1   
  tree=etree.parse(file)
  root=tree.getroot()
  
  # read data timeframe in file
  datum_start=root[0][0][0].text
  date_start,UTC_off=datum_start.split('+')
  date_start=time.strptime(date_start,'%Y-%m-%dT%H:%M:%S')
  obs_begin=calendar.timegm(date_start)
  
  datum_end=root[0][0][1].text
  date_start,UTC_off=datum_end.split('+')
  date_end=time.strptime(date_start,'%Y-%m-%dT%H:%M:%S')
  obs_end=calendar.timegm(date_end)
  
  
  # check is data range OK
  if not(s_begin>=obs_begin and s_end<=obs_end):
    sys.exit('Data out of range :)') 

  # read station coordinates and write to stations.txt file
  coordinate=root[1][0][0][0][0].text
  lat,lon=coordinate.split()
  f1.write(str(lat)+' '+str(lon)+' '+str(i)+'\n')
  
  # timesteps
  step_one=(s_begin-obs_begin)/3600
  step_two=(s_end-s_begin)/3600
  step_all=(obs_end-obs_begin)/3600
  
  # creation of the temp directory and temp files  
  os.chdir('Temp') 
  name='temp'+str(i)+'.txt' 
  
  f=open(name,'w')

  # parsing of the WaterML2 files
  for step in range(0,step_two):
    value=root[2][0][1][0][step+step_one+1][0][1].text
    val.append(0.0)
    if str(value)=='None':
      vallue=-9999
    else:
      vallue=value
    val[step]=vallue
    f.write(str(val[step])+'\n')
  f.close()
  os.chdir('..')

os.chdir('Temp')
# read data from temp.txt files and creation of the P.tss file
for l in range(0,step_two):
  f2.write(str(l+1))
  for f in range(1,number_of_files+1):
    filename='temp'+str(f)+'.txt'
    ff=open(filename,'r')
    row=ff.readlines()
    ff.close()
    erow=row[l].strip()
    f2.write(' '+str(erow))    
  f2.write('\n')  

# close all opened files
f2.close
f1.close
print 'kraj wml_to_tss'

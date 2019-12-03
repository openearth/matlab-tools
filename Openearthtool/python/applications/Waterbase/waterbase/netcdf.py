#
# Module to read Waterbase data into a colection of netCDF files
#
# Author: Bas Hoonhout <bas.hoonhout@deltares.nl>
#
# TODO: * add coordinate conversion
#       * add meta data from conversion table
#       * add header data
#       * add loop over all observations
#

from netCDF4 import Dataset
from waterbase import Waterbase
import time, os, re
import numpy as np
import json
from datetime import datetime
import sys
import timetuple
import standardnames

STANDARD_NAMES_FILE = 'rws_waterbase_name2standard_name'
STANDARD_NAMES_JSON = '%s.json' % STANDARD_NAMES_FILE
STANDARD_NAMES_XLS  = '%s.xls' % STANDARD_NAMES_FILE

standard_names = []
if not os.path.exists(STANDARD_NAMES_JSON):
    if os.path.exists(STANDARD_NAMES_XLS):
    	d = standardnames.read(STANDARD_NAMES_XLS)
    	standardnames.write(d, STANDARD_NAMES_JSON)
if os.path.exists(STANDARD_NAMES_JSON):
    f = open(STANDARD_NAMES_JSON,'r')
    standard_names = json.load(f)
    f.close()
    
w = Waterbase(language='en')

def add_to_netcdf(filename, data):

  if not os.path.exists(filename):
    ncfile = Dataset(filename, 'w', format='NETCDF4')
  
    # create dimensions
    ncfile.createDimension('locations', None)
    ncfile.createDimension('time', None)
    
    # create variables
    ncfile.createVariable('platform_id',str,('locations',))
    ncfile.createVariable('platform_name',str,('locations',))
    ncfile.createVariable('lon','f4',('locations',))
    ncfile.createVariable('lat','f4',('locations',))
    ncfile.createVariable('x','f4',('locations',))
    ncfile.createVariable('y','f4',('locations',))
    ncfile.createVariable('z','f4',('locations',))
    ncfile.createVariable('wgs84','i4',())
    ncfile.createVariable('epsg','i4',())
    ncfile.createVariable('time','f8',('time',))
    
    ncfile.variables['epsg'] = 7415
    ncfile.variables['wgs84'] = 4326
    
    # create attributes
    ncfile.institution  = 'Rijkswaterstaat'
    ncfile.description  = ''
    ncfile.history      = 'Created ' + time.ctime(time.time())
    ncfile.source       = ''
    
  else:
    ncfile = Dataset(filename, 'a')
  
  standard_name = get_standard_name(data['observation_type'])
  timestamps = get_timestamps(data)
  
  if not standard_name in ncfile.variables.keys():
    var = ncfile.createVariable(standard_name,'f4',('locations','time',))
    var.description = data['observation_type']
    
  n_stations = len(ncfile.variables['platform_name'][:])
  if data['location'] not in ncfile.variables['platform_name']:
    ncfile.variables['platform_name'][n_stations] = np.array([data['location']],object)
    ncfile.variables['platform_id'][n_stations] = np.array([data['location']],object)
    
    if data['epsg'] == 7415:
      ncfile.variables['x'][n_stations] = data['x_lat']
      ncfile.variables['y'][n_stations] = data['y_long']
      ncfile.variables['lat'][n_stations] = 0
      ncfile.variables['lon'][n_stations] = 0
    elif data['epsg'] == 4326:
      ncfile.variables['x'][n_stations] = 0
      ncfile.variables['y'][n_stations] = 0
      ncfile.variables['lat'][n_stations] = data['x_lat']
      ncfile.variables['lon'][n_stations] = data['y_long']
      
    ncfile.variables['z'][n_stations] = 0
  
  station_id = list(ncfile.variables['platform_name'][:]).index(data['location'])
  
  t = ncfile.variables['time'][:]
  nt = len(t)
  
  time_id1 = [np.where(t==x)[0][0] for x in timestamps if x in t]
  time_id2 = nt + np.cumsum([1 for x in timestamps if x not in t]) - 1
  time_id  = np.concatenate((time_id1, time_id2)).astype('int')
  
  ncfile.variables['time'][time_id2] = [x for x in timestamps if x not in t]
    
  if type(data['value']) == list or type(data['value']) == np.ndarray:
    ncfile.variables[standard_name][station_id,time_id] = [str2int(v) for v in data['value']]
  else:
    if not type(np.asscalar(data['value'])) is str:
      ncfile.variables[standard_name][station_id,time_id] = data['value']
  
  ncfile.close()
  
def get_standard_name(name):
  for standard_name in standard_names:
    if standard_name['DONAR']['WNS_OMS'].strip() == name.strip():
      return standard_name['STANDARD_NAME']
  
def get_timestamps(data):
  timestamps = []
  
  datetimes = zip(data['date'], data['time'])
  
  for d,t in datetimes:
    if not ':' in t:
      t = '%02d:00' % str2int(t)
    if len(d) < 2:
      d = '1970-01-01'
    timestamps.append(timetuple.timetuple2epoch(time.strptime('%s %s' % (d,t),'%Y-%m-%d %H:%M')))
    
  return timestamps
  
def str2int(v):
  v = re.sub('[^\d\.\+-]','',v)
  if len(v) == 0:
    return 0
  else:
    return int(v)
  
def get_last_measurement(filename, observation, location):

  t = None
  
  if os.path.exists(filename):
    ncfile = Dataset(filename, 'r')
    if 'time' in ncfile.variables.keys():
      if len(ncfile.variables['time']) > 0:
        t = int(np.asscalar(ncfile.variables['time'][-1]))
    ncfile.close()
    
  return t

observation = 'Water level in cm with respect to normal amsterdam level in surface water'

locations, codes = w.get_locations(observation)    

for i, location in enumerate(locations):
  ncfile = '%s.nc' % codes[i]
  
  periods = [int(timetuple.timetuple2epoch(p)) for p in w.get_periods(observation, location)]
  
  p0 = get_last_measurement(ncfile, observation, location)
  if not p0 == None:
    periods[0] = p0
    
  if periods[1] - periods[0] > 24*3600:
    
    sys.stdout.write('File %s is being updated...\r' % ncfile)
    
    dt = 30*24*3600
    timechunks = range(periods[0],periods[1],dt)
    n_chunks = float(len(timechunks))
    t0 = datetime.now()
    
    for j, timechunk in enumerate(timechunks):
    
      try:
        data = w.get_data(observation, location, timechunk, timechunk + dt)
        add_to_netcdf(ncfile, data)
        
        progress = j/n_chunks*100
	eta = time.strftime("%H:%M:%S",time.gmtime((datetime.now()-t0).seconds/(j+1)*(n_chunks-j)))
	      
        sys.stdout.write('File %s is being updated... %d/%d | %2.1f%% | %s\r' % (ncfile, j+1, n_chunks, progress, eta))
      except:
        print sys.exc_info()[0]
        raise
        
    sys.stdout.write('File %s is updated%s\n' % (ncfile, ' '*40))
  
  else:
    sys.stdout.write('File %s is up-to-date\n' % ncfile)
  

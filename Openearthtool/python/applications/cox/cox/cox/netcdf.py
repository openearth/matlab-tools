import os
import time
import numpy as np
from netCDF4 import Dataset

from constants import *

def add_to_netcdf(filename, **kwargs):

  if not os.path.exists(filename):
    ncfile = Dataset(filename, 'w', format='NETCDF4')
  
    # create dimensions
    dU    = ncfile.createDimension('u', IRF_XSIZE)
    dV    = ncfile.createDimension('v', IRF_YSIZE)
    dTime = ncfile.createDimension('time', None)
    
    # create variables
    vU            = ncfile.createVariable('u','i4',('u',))
    vV            = ncfile.createVariable('v','i4',('v',))
    vTime         = ncfile.createVariable('time','f8',('time',))
    
    for var in kwargs.iterkeys():
      vTemperature  = ncfile.createVariable(var,'f4',('time','v','u',))
      vTemperature.units  = 'C'
    
    # create attributes
    ncfile.description  = 'Raw temperature data from COX320 infra-red camera at location Kijkduin, the Netherlands'
    ncfile.history      = 'Created ' + time.ctime(time.time())
    ncfile.source       = 'COX320 Python package by Bas Hoonhout <bas.hoonhout@deltares.nl>'
    
    vU.units            = 'pixels'
    vV.units            = 'pixels'
    vTime.units         = 'hours since 1970-01-01 00:00:00.0' 
    vTime.calendar      = 'gregorian'
    
    # add data
    ncfile.variables['u'] = np.arange(1,IRF_XSIZE)
    ncfile.variables['v'] = np.arange(1,IRF_YSIZE)
    
  else:
    ncfile = Dataset(filename, 'a')
  
  # add timestep
  t = ncfile.variables['time']
  i = t.shape[0]
  t[i] = time.time()
  
  # store temperatures
  for var, data in kwargs.iteritems():
    T = ncfile.variables[var]
    T[i,:,:] = data.reshape((1,IRF_YSIZE,IRF_XSIZE))
    
  ncfile.close()
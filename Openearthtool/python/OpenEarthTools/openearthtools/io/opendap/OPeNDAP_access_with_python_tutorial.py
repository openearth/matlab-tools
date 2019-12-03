#!/usr/bin/env python

# $Id: OPeNDAP_access_with_python_tutorial.py 8903 2013-07-09 09:51:58Z boer_g $
# $Date: 2013-07-09 02:51:58 -0700 (Tue, 09 Jul 2013) $
# $Author: boer_g $
# $Revision: 8903 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/io/opendap/OPeNDAP_access_with_python_tutorial.py $
# $Keywords: $

# This document is also posted on a wiki: http://public.deltares.nl/display/OET/OPeNDAP+access+with+python

# Read data from an opendap server
import netCDF4, pydap,     urllib
import pylab,   matplotlib
import numpy as np
from opendap import opendap # OpenEarthTools module, see above that makes pypdap quack like netCDF4

# test with local files: oldfashioned, downloads full z(x,y,t) instead of 
# just one temporal slice. This is faster nevertheless for sparse
# netCDF4 files with zlib compression, as DAP objects are not compressed.
#url_grid = 'vaklodingenKB116_4544.nc' 
#url_time = 'id410-DELFZBTHVN.nc'      
#urllib.urlretrieve(r'http://opendap.deltares.nl/thredds/fileServer/opendap/rijkswaterstaat/vaklodingen_remapped/vaklodingenKB116_4544.nc'                               ,url_grid)
#urllib.urlretrieve(r'http://opendap.deltares.nl/thredds/fileServer/opendap/rijkswaterstaat/waterbase/concentration_of_suspended_matter_in_sea_water/id410-DELFZBTHVN.nc',url_time)
# test with remote files
url_grid = r'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB122_2120.nc'
url_time = r'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/waterbase/concentration_of_suspended_matter_in_sea_water/id410-DELFZBTHVN.nc'

# Get grid data 
grid   = netCDF4.Dataset(url_grid) # opendap(url_grid) # when netCDF4 was not compiled with OPeNDAP
G_x    = grid.variables['x']
G_y    = grid.variables['y']
G_z    = grid.variables['z']
 
G      = {} # dictionary ~ Matlab struct
G['x'] = G_x[:].squeeze()
G['y'] = G_y[:].squeeze()
G['z'] = G_z[1,:,:].squeeze() # download only one temporal slice
 
# represent fillValue from data as Masked Array
booleanMask = np.isnan(G['z']) # the fillValue here hard-coced, we know it's NaN
G['z'][booleanMask ]=0
G['z'] = np.ma.MaskedArray(G['z'],booleanMask )

# Get time series data
time   = netCDF4.Dataset(url_time) # opendap(url_time) # when netCDF4 was not compiled with OPeNDAP
T_t    = time.variables['time']
T_z    = time.variables['concentration_of_suspended_matter_in_water']

T      = {} # dictionary ~ Matlab struct
T['t'] = netCDF4.num2date(T_t[:], units=T_t.units)
T['z'] = T_z[:].squeeze()

# plot grid data
matplotlib.pyplot.pcolormesh(G['x'],G['y'],G['z'])
pylab.xlabel('x [m]')
pylab.ylabel('y [m]')
matplotlib.pyplot.colorbar()
matplotlib.pyplot.axis('tight')
matplotlib.pyplot.axis('equal')
matplotlib.pyplot.title(url_grid)
pylab.savefig('vaklodingenKB116_4544')

# plot time series data
pylab.clf()
matplotlib.pyplot.plot_date(T['t'], T['z'], fmt='b-', xdate=True, ydate=False)
pylab.ylabel('SPM [kg/m3]')
matplotlib.pyplot.title(url_time)
pylab.savefig('DELFZBTHVN')

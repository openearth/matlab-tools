#!/usr/bin/env python
import numpy as np
import netCDF4
import pupynere
import matplotlib
matplotlib.use('MacOSX')
import matplotlib.pyplot as plt
import shutil

ds1 = netCDF4.Dataset('year_2008.nc')
shutil.copy('year_2008.nc', 'year_2008extra.nc')
ds3 = netCDF4.Dataset('year_2008extra.nc', 'r+')
ds2 = netCDF4.Dataset('http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/profiles/transect.nc')
id1 = ds1.variables['run_id'][:]
id2 = ds2.variables['id'][:]
assert all(id1 == np.intersect1d(id1,id2))   # all id1's should be in id2 also
(idx,) = np.nonzero(np.in1d(id2,id1))
lat = ds2.variables['rsp_lat'][:]
lon = ds2.variables['rsp_lon'][:]
ds3.createVariable('lat', 'double', ('n_run',))
ds3.createVariable('lon', 'double', ('n_run',))
assert len(ds3.dimensions['n_run']) == len(lat[idx])
ds3.variables['lat'][:] = lat[idx]
ds3.variables['lon'][:] = lon[idx]
ds3.close()
ds1.close()
ds2.close()

plt.plot(lon[idx], lat[idx])



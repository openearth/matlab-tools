import netCDF4
from pylab import *
import matplotlib.pyplot as plt
import numpy as np

url        = 'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/jarkus/profiles/transect.nc'

bp         = netCDF4.Dataset(url) # open .nc file; bp - beach profile

xlong = bp.variables['alongshore'][:] # load variables
ycros = bp.variables['cross_shore'][:]
altit = bp.variables['altitude']

Xlong,Ycros = np.meshgrid(xlong,ycros)

print shape(altit) #variable infos printed on the console
print type(altit)

from netCDF4 import Dataset
import os
import numpy as np
import time
import sys

print sys.argv

yeard = sys.argv[2]
year = int(yeard)
print year

areaidd = sys.argv[4]
areaid = int(areaidd)
print areaid

url="http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/profiles/transect.nc"
#path = "D:\\StormImpactApplication\\XBeach2Dnotes (Python)\\opendap Jarkus netCDF profiles\\transect_r20151012.nc"

yearindex = year - 1965

file = Dataset(url, mode='r')
vars = file.variables.keys()

idlist = file.variables['id'][:]                    #[alongshore = 0..2267] 
locid = list(idlist).index(areaid)
cross_shore = file.variables['cross_shore'][:]      #[cross_shore = 0..1924] 
angle = file.variables['angle'][locid]              #[alongshore = 0..2267] 
x = file.variables['x'][locid,:]                               #[2267,1925]
y = file.variables['y'][locid,:]                               #[2267,1925]
altitude = file.variables['altitude'][yearindex, locid, :] #[51, 2268, 1925], dus [time in days since 1970-01-01, raai_id/alongshore, cross_shore]
#file.close()

alt_data_ids = np.nonzero(altitude)[0]

x_jrk = cross_shore[alt_data_ids]
x_jrk = list(x_jrk)
z_jrk = altitude[alt_data_ids]
z_jrk = list(z_jrk)

dx = 20 # x_jrk[-1] - x_jrk[-2] (=10, maar 20 is minder gridcellen)
offshore_slope = 1/50.0
while z_jrk[-1] > -20:
    z_jrk.append(z_jrk[-1] - offshore_slope * dx)
    x_jrk.append(x_jrk[-1] + dx)

xid = list(cross_shore).index(x_jrk[-1])

xcoord_BC = x[xid] #xcoord_BC en ycoord_BC uit transect.nc (x is xcoords op cross_shore distance from RSP)
ycoord_BC = y[xid]
raaihoek_RSP = angle

print "netcdfread done"

with open('x_jrk.txt','w') as f:
    string = ' '.join("%e" %i for i in x_jrk)
    #for i in range(0,ny+1): #useful for 2D grid
    f.write(string)
with open('z_jrk.txt','w') as f:
    string = ' '.join("%e" %i for i in z_jrk)
    #for i in range(0,ny+1):
    f.write(string)
with open('xcoord_BC.txt','w') as f:
    f.write('%f' %xcoord_BC)
with open('ycoord_BC.txt','w') as f:
    f.write('%f' %ycoord_BC)
with open('raaihoek_RSP.txt','w') as f:
    f.write('%f' %raaihoek_RSP)



#raailist = idlist % 1000000 # dit pakt de laatste zes getallen van ieder item uit de idlist, dus alleen de raainummers, geen Delfland=9
#raai_id = list(raailist).index(offsetLocation)

print "Jarkusfiles created"

"""
for varnr in range(0, len(vars)):
    #test if varnr has an attribute 'unit'
    try:
        unit = file.variables[vars[varnr]].units
        print "Variable nr %d '%s' has  is in unit '%s'" %(varnr, vars[varnr], unit)
    except:
        print "Variable nr %d '%s' has no unit" %(varnr, vars[varnr])   


import datetime
times = file.variables['time']
print datetime.date(1970,01,01) + datetime.timedelta(days=times[0])
"""
# python version of Matlab counterpart ncwritetutorial_grid_lat_lon_curvilinear.m

__version__ = "$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/io/netcdf/netCDF4_tutorial_grid_lat_lon_curvilinear.py $" + "$Revision: 8907 $"

import CF # model for array mangling following CF conventions
import netCDF4, numpy, scipy, time
from datetime import datetime
import matplotlib.pyplot as plt
import numpy as np
import waq as wq
import matplotlib.dates as date
from datetime import datetime
from corner2center import corner2center

FileName = 'p:/1201763-cobios-fews/waq/waq_runs/KNO-L/2003/nzbloom.map'
lgaFile  = 'p:/1209005-eutrotracks/KPP/DINEOF/com-001-2d.lga'
Sub = 'Chlfa'
Seg = [];
nTime = 1

s = wq.openfile(FileName)
g = wq.openlga(lgaFile)

dtime, data = wq.read(s,Sub,Seg,1)
z = wq.ingrid(data,g)


NaN = numpy.nan

OPT = {}
OPT['filename']   ='NZBloom01.nc'
OPT['refdatenum'] = datetime(1970,1,1)
OPT['timezone']   = ''
OPT['bounds']     = True
OPT['RemoveUnusedLatLonTuples'] = True # as in curvi linear hydro grids
OPT['varname'] = 'Chlfa';

M = {}
M['institution'] = 'Deltares'

# Define dimensions/coordinates: lat,lon matrices

D = {}


x = g.X[1:,1:]
y = g.Y[1:,1:]
z1 = z[1:-1,1:-1];


nrow = len(z1[1,:])
ncol = len(z1[:,1])


D['lonc'] = x
D['latc'] = y

D['lon']  = CF.corner2center(D['lonc'])
D['lat']  = CF.corner2center(D['latc'])

#D['time'] = [datetime(2000,1,1), datetime(2000,1,2)]
D['time'] = (np.array([731316.5, 731317.5])-719163)*(60*60*24)

# Define variable (define some data) checkerboard  with 1 NaN-hole
D['val']   = z1

                    

f = netCDF4.Dataset(OPT['filename'], 'w', 
                    format='NETCDF3_CLASSIC')
                    # 'NETCDF4'
                    # 'NETCDF3_CLASSIC'
                    # 'NETCDF3_64BIT'
                    # 'NETCDF4_CLASSIC'
       
# create global atts

f.title           = 'ncwritetutorial_grid_lat_lon_curvilinear'
f.institution     = M['institution']
f.source          = ''
f.history         = "$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/io/netcdf/netCDF4_tutorial_grid_lat_lon_curvilinear.py $ $Id: netCDF4_tutorial_grid_lat_lon_curvilinear.py 8907 2013-07-10 12:39:16Z boer_g $"
f.references      = "http://svn.oss.deltares.nl"
f.email           = ''
f.featureType     = 'Grid'  # https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions
f.comment         = ''
f.version         = 'beta'
f.Conventions     = 'CF-1.6'
f.terms_for_use   = 'These data can be used freely for research purposes provided that the following source is acknowledged: ' + f.institution
f.disclaimer      = 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.'

# create dimensions
nc = D['lon'].shape[0]
nr = D['lon'].shape[1]
#nt = D['time'].shape[0]
#nt = len(D['time'])
nt = nTime

f.createDimension('col'   , nc)
f.createDimension('row'   , nr)
f.createDimension('time'  , nt)
if OPT['bounds']:
    f.createDimension('bounds', 4)
   
# create variables: CF convention recommends dimension order [time,Z,Y,X]
# http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#dimensions
#nc_x   = f.createVariable('x'          ,'f8',              ('col'))
#nc_y   = f.createVariable('y'          ,'f8',         ('row')     )
#nc_e   = f.createVariable('epsg'       ,'i' ,()                   )
nc_t   = f.createVariable('time'        ,'f8',('time'                     )                         ) # always double
nc_lon = f.createVariable('lon'         ,'f8',         ('row','col'       ),zlib=True,fill_value=NaN) # always double
nc_lat = f.createVariable('lat'         ,'f8',         ('row','col'       ),zlib=True,fill_value=NaN) # always double
nc_w   = f.createVariable('projection'  , 'i',())
if OPT['bounds']:
    nc_lonc= f.createVariable('lon_bnds','f8',(       'row','col','bounds'),zlib=True,fill_value=NaN) # always double
    nc_latc= f.createVariable('lat_bnds','f8',(       'row','col','bounds'),zlib=True,fill_value=NaN) # always double
nc_z   = f.createVariable(OPT['varname'],'f4',('time','row','col'         ),zlib=True,fill_value=NaN) # may be single

# mask all lat,lon coordinates where no data pixel is present at any time
# the zlib libray makes these lon,lat arrays much smaller than the full arrays.
anypixel = numpy.ones_like(D['lon'])==0 # False array

# add attributes

# 3a Create (primary) variables: time
#    http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#time-coordinate

#sec = numpy.array(range(0,nt))
#for it in range(0,nt):
#   #sec[it] = time.mktime(datetime.timetuple(D['time'][it]))
#   sec[it] = D['time'][it]
   
nc_t.standard_name = 'time'
nc_t.long_name     = 'time'
nc_t.units         = 'seconds since ' + time.strftime('%Y-%m-%d %H-%M-%S',time.gmtime(0)) # EPOCH # 'years since 0000-00-00 00:00:00'
nc_t.axis          = 'T'


nc_lon.standard_name = 'longitude'
nc_lon.long_name     = 'Longitude'
nc_lon.units         = 'degrees_east'
nc_lon.axis          = 'X'
nc_lon.grid_mapping  = "projection"
nc_lon.actual_range  = [numpy.min(D['lon'][:]), numpy.max(D['lon'][:])]
nc_lon.bounds        = 'lon_bnds'  # ADAGUC hard-coded name for cell boundaries for drawing 'pixels.

#    http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#latitude-coordinate

nc_lat.standard_name = 'latitude'
nc_lat.long_name     = 'Latitude'
nc_lat.units         = 'degrees_north'
nc_lat.axis          = 'Y'
nc_lat.grid_mapping  = "projection"
nc_lat.actual_range  = [numpy.min(D['lat'][:]), numpy.max(D['lat'][:])]
nc_lat.bounds        = 'lat_bnds'  # ADAGUC hard-coded name for cell boundaries for drawing 'pixels.

#  3.c Create coordinate variables: coordinate system: WGS84 default
#      global ellispes: WGS 84, ED 50, INT 1924, ETRS 89 and the upcoming ETRS update etc.
#      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#grid-mappings-and-projections
#      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#appendix-grid-mappings

nc_w.name               = "WGS 84"
nc_w.epsg               = 4326.0
nc_w.grid_mapping_name  = "latitude_longitude"
nc_w.semi_major_axis    = 6378137.0
nc_w.semi_minor_axis    = 6356752.314247833
nc_w.inverse_flattening = 298.2572236
# http://adaguc.knmi.nl/contents/documents/ADAGUC_Standard.html
nc_w.proj4_params    = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs" # needed for ADAGUC WMS server
nc_w.projection_name    = "Latitude Longitude"
nc_w.EPSG_code          = "EPSG:4326"

# 3.d Bounds (optional)
#     http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#cell-boundaries
if OPT['bounds']:
    nc_lonc.standard_name = 'longitude'
    nc_lonc.long_name     = 'Longitude bounds'
    nc_lonc.units         = 'degrees_east'
    nc_lonc.actual_range  = [numpy.min(D['lonc'][:]), numpy.max(D['lonc'][:])]

    nc_latc.standard_name = 'latitude'
    nc_latc.long_name     = 'Latitude bounds'
    nc_latc.units         = 'degrees_north'
    nc_latc.actual_range  = [numpy.min(D['latc'][:]), numpy.max(D['latc'][:])]

# 3c Create (primary) variables: data
nc_z.standard_name = 'Chorophyll-a'
nc_z.long_name     = 'Chorophyll-a concentration in water'
nc_z.units         = 'mg/l'
nc_z.positive      = 'up'
nc_z.actual_range  = numpy.array([NaN,NaN])
nc_z.grid_mapping  = "projection"
nc_z.coordinates   = "lat lon"
#nc_z.actual_range  = scheduled below after inserting data matrix
zmin = +numpy.inf
zmax = -numpy.inf

# store data
nc_t[:]     = sec
#nc_x[:]     = x[:]
#nc_y[:]     = y[:] # y already reversed above
#nc_e[:]     = OPT['epsg']
nc_z[:,:,:] = NaN # background is

if OPT['bounds']:
    nc_lonc[:,:,:] = CF.cor2bounds(D['lonc'].T)
    nc_latc[:,:,:] = CF.cor2bounds(D['latc'].T)

sec = numpy.array(range(0,nt))

for it in range(0,nt):

    #print "it", it ," ",datetime.strftime(D['time'][it],'%Y-%m-%dP%H:%M:%S')
    print "it", it
    
    dtime, data = wq.read(s,Sub,Seg,it)
    z = wq.ingrid(data,g)
    z1 = z[1:-1,1:-1]
    
    D['val'] = z1
    D['time'][it] = dtime
    sec[it] = D['time'][it]
 
    zmin = min(zmin,numpy.nanmin(D['val']))
    zmax = max(zmax,numpy.nanmax(D['val']))
    
    nc_z[it,:,:] = D['val'].T
    
# remove all lat,lon tuples where there are no data

    anypixel = (numpy.isnan(D['val'])==False)
    
if OPT['RemoveUnusedLatLonTuples']:
  D['lon'][anypixel==False] = NaN
  D['lat'][anypixel==False] = NaN
    
# insert data matrix
nc_lon[:,:] = D['lon'].T
nc_lat[:,:] = D['lat'].T

if numpy.isinf(zmin): zmin=NaN
if numpy.isinf(zmax): zmax=NaN
nc_z.actual_range  = numpy.array([zmin, zmax])
f.close()   

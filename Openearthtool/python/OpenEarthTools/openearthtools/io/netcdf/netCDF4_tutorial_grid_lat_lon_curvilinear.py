# python version of Matlab counterpart ncwritetutorial_grid_lat_lon_curvilinear

__version__ = "$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/io/netcdf/netCDF4_tutorial_grid_lat_lon_curvilinear.py $" + "$Revision: 11108 $"

import CF # model for array mangling following CF conventions
import netCDF4, scipy, time
from datetime import datetime
import numpy as np
NaN = np.nan

OPT = {}
OPT['refdatenum'] = datetime(1970,1,1)
OPT['timezone']   = ''
OPT['bounds']     = True
OPT['RemoveUnusedLatLonTuples'] = True # as in curvi linear hydro grids

M = {}
M['institution'] = 'Deltares'

# Define dimensions/coordinates: lat,lon matrices

D = {}
nrow = 5
ncol = 3

# define an orthogonal matrix, but treat it as curvi-linear by 
# replicating the 1D coordinate stick vectors to full 2D matrices
D['lonc'] =  1.0 + 2.0*(np.array(range(0,ncol+1))).squeeze()
D['latc'] = 54.5 - 1.0*(np.array(range(0,nrow+1))).squeeze() # reverse
D['latc'] = D['latc'][-1::-1] # reverse trick (make LL in array vs LL on globe)
# GIS files are often "upside-down"
 
# use ncols as 1st array dimension to get correct plot in ncBrowse 
# this does not agree with python printing 1st array dimension as row 
# D['lon'] = [[ 1.5  1.5  1.5  1.5  1.5]
#             [ 2.5  2.5  2.5  2.5  2.5]
#             [ 3.5  3.5  3.5  3.5  3.5]]
D['lonc'] = scipy.tile(D['lonc'][:],(nrow+1,1)).T
D['latc'] = scipy.tile(D['latc'][:],(ncol+1,1))

D['lon']  = CF.corner2center(D['lonc'])
D['lat']  = CF.corner2center(D['latc'])

D['time'] = [datetime(2000,1,1)]

# Define variable (define some data) checkerboard  with 1 NaN-hole

D['val']   = np.array([[   1.,  102.,    3.,  104.,    5.],
                       [ 106.,    7.,  108.,    9.,  110.],
                       [  11.,  112.,   NaN,  114.,   15.]]) # ncBrowse does not plot row dimension as rows by default

#D['val']   = np.array([[  1, 106,  11],
#                       [102,   7, 112],
#                       [  3, 108, NaN],
#                       [104,   9, 114],
#                       [  5, 110,  15]]) # ncBrowse does not plot row dimension as rows by default
                    

f = netCDF4.Dataset('netCDF4_tutorial_grid_lat_lon_curvilinear.nc', 'w', 
                    format='NETCDF3_CLASSIC')
                    # 'NETCDF4'
                    # 'NETCDF3_CLASSIC'
                    # 'NETCDF3_64BIT'
                    # 'NETCDF4_CLASSIC'
       
# create global atts

f.title           = 'ncwritetutorial_grid_lat_lon_curvilinear'
f.institution     = M['institution']
f.source          = ''
f.history         = "$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/io/netcdf/netCDF4_tutorial_grid_lat_lon_curvilinear.py $ $Id: netCDF4_tutorial_grid_lat_lon_curvilinear.py 11108 2014-09-15 14:10:07Z gerben.deboer.x $"
f.references      = "http://svn.oss.deltares.nl"
f.email           = ''
f.featureType     = 'Grid'  # https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions
f.comment         = ''
f.version         = 'beta'
f.Conventions     = 'CF-1.6'
f.terms_for_use   = 'These data can be used freely for research purposes provided that the following source is acknowledged: ' + f.institution
f.disclaimer      = 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.'

# create dimensions
f.createDimension('col'   ,     D['lon'].shape[0])
f.createDimension('row'   ,     D['lon'].shape[1])
f.createDimension('time'  , len(D['time']))
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
nc_z   = f.createVariable('depth'       ,'f4',('time','row','col'         ),zlib=True,fill_value=NaN) # may be single

# mask all lat,lon coordinates where no data pixel is present at any time
# the zlib libray makes these lon,lat arrays much smaller than the full arrays.
anypixel = np.ones_like(D['lon'])==0 # False array

# add attributes

# 3a Create (primary) variables: time
#    http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#time-coordinate

sec = np.array(range(0,len(D['time'])))
for it in range(0,len(D['time'])):
   sec[it] = time.mktime(datetime.timetuple(D['time'][it]))

nc_t.standard_name = 'time'
nc_t.long_name     = 'time'
nc_t.units         = 'seconds since ' + time.strftime('%Y-%m-%d %H-%M-%S',time.gmtime(0)) # EPOCH # 'years since 0000-00-00 00:00:00'
nc_t.axis          = 'T'

# 3b Create (primary) variables: space
#    http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#longitude-coordinate

#nc_x.standard_name   = 'projection_x_coordinate'
#nc_x.units           = 'm'
#nc_x.long_name       = 'x'
#nc_x.actual_range    = [np.min(x), np.max(x)]
#nc_x.grid_mapping    = "epsg"
#nc_x.grid_mapping  = "epsg" # not CF standard to add to coordinates
#
#nc_y.standard_name   = 'projection_y_coordinate'
#nc_y.units           = 'm'
#nc_y.long_name       = 'y'
#nc_y.actual_range    = [np.min(y), np.max(y)]
#nc_y.grid_mapping    = "epsg"
#nc_y.grid_mapping  = "epsg" # not CF standard to add to coordinates

nc_lon.standard_name = 'longitude'
nc_lon.long_name     = 'Longitude'
nc_lon.units         = 'degrees_east'
nc_lon.axis          = 'X'
nc_lon.grid_mapping  = "projection"
nc_lon.actual_range  = [np.min(D['lon'][:]), np.max(D['lon'][:])]
nc_lon.bounds        = 'lon_bnds'  # ADAGUC hard-coded name for cell boundaries for drawing 'pixels.

#    http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#latitude-coordinate

nc_lat.standard_name = 'latitude'
nc_lat.long_name     = 'Latitude'
nc_lat.units         = 'degrees_north'
nc_lat.axis          = 'Y'
nc_lat.grid_mapping  = "projection"
nc_lat.actual_range  = [np.min(D['lat'][:]), np.max(D['lat'][:])]
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
    nc_lonc.actual_range  = [np.min(D['lonc'][:]), np.max(D['lonc'][:])]

    nc_latc.standard_name = 'latitude'
    nc_latc.long_name     = 'Latitude bounds'
    nc_latc.units         = 'degrees_north'
    nc_latc.actual_range  = [np.min(D['latc'][:]), np.max(D['latc'][:])]

# 3c Create (primary) variables: data

nc_z.standard_name = 'sea_floor_depth_below_geoid'
nc_z.long_name     = 'bottom depth'
nc_z.units         = 'm'
nc_z.positive      = 'up'
nc_z.actual_range  = np.array([NaN,NaN])
nc_z.grid_mapping  = "projection"
nc_z.coordinates   = "lat lon"
#nc_z.actual_range  = scheduled below after inserting data matrix
zmin = +np.inf
zmax = -np.inf

# store data
nc_t[:]     = sec
#nc_x[:]     = x[:]
#nc_y[:]     = y[:] # y already reversed above
#nc_e[:]     = OPT['epsg']
nc_z[:,:,:] = NaN # background is

if OPT['bounds']:
    nc_lonc[:,:,:] = CF.cor2bounds(D['lonc'].T)
    nc_latc[:,:,:] = CF.cor2bounds(D['latc'].T)

for it in range(0,len(D['time'])):

    print("it", it ," ",datetime.strftime(D['time'][it],'%Y-%m-%dP%H:%M:%S'))

    zmin = min(zmin,np.nanmin(D['val']))
    zmax = max(zmax,np.nanmax(D['val']))
    
    nc_z[it,:,:] = D['val'].T
    
# remove all (lat,lon) tuples where there are no z data anyway

    anypixel = (np.isnan(D['val'])==False)
    
if OPT['RemoveUnusedLatLonTuples']:
  D['lon'][anypixel==False] = NaN
  D['lat'][anypixel==False] = NaN
    
# insert data matrix
nc_lon[:,:] = D['lon'].T
nc_lat[:,:] = D['lat'].T

if np.isinf(zmin): zmin=NaN
if np.isinf(zmax): zmax=NaN
nc_z.actual_range  = np.array([zmin, zmax])
f.close()   

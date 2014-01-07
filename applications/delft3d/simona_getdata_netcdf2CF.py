"""simona_getdata_netcdf2CF make legacy netCDF file from SIMONA getdata.exe CF compliant
>>>>>>>>>>>>>>>>>UNFINISHED BETA
This extra functionality is being implemented in getdata, this python fucntion
is used to explore what exactly to implement (ensure complaince with THREDDS and ADAGUC)
and for future fixes of netCDF files from previous (and current) getdata releases.

See also: simona_getdata_netcdf2CF.m 
http://www.helpdeskwater.nl/onderwerpen/applicaties-modellen/water_en_ruimte/simona/simona/simona-stekkers/
http://apps.helpdeskwater.nl/downloads/extra/simona/release/doc/usedoc/getdata/getdata.pdf

"""

import netCDF4
import shutil
import numpy
import os

ncfile0 = 'SDSddhzee.nc'

OPT = {}
OPT['xy']     = False # 0 removed coord attribute but does not remove XZETA/YZETA arrays itself
OPT['xybnds'] = False # ADAGUC can work with [x,y] coordinates only by mapping on-the-fly, THREDDS cannot map on-the-fly

OPT['ll']     = True  # required by THREDDS and Panoply
OPT['llbnds'] = True  # THREDDS needs [lat,lon] matrices to be included

# Panoply only works when xy=0, xybnds=0, ll=1, llbnds=1

if OPT['xy'] & OPT['ll']:
   print 'Panoply cannot handle coords = "lon lat XZETA YZETA"'
   
ncfile  = os.path.split(ncfile0)[0] + '_xy_' + str(OPT['xy']) + str(OPT['xybnds']) + '_ll_' + str(OPT['ll']) + str(OPT['llbnds']) + '.nc'

coords = ''
if OPT['ll']:
   coords  = coords + ' lon lat'
if OPT['xy']:
   coords  = coords + ' XZETA YZETA'

shutil.copy(ncfile0,ncfile)

f = netCDF4.Dataset(ncfile, 'r+')

f.variables['XZETA'].bounds = "grid_x"
f.variables['YZETA'].bounds = "grid_y"

f.Conventions       = 'CF-1.6'
f.coordinate_system = 'THIS ATTRIBUTE SHOULD BE REPLACED BY NEW VARIABLE "CRS"'
f.cdm_data_type     = 'Grid'

## make time small caps

f.variables['TIME'].standard_name = 'time'
 
f.variables['SEP'].grid_mapping ='CRS'   # add grid_mapping attribute
f.variables['SEP'].coordinates  = coords # connect CENTER (x,y) to CENTER matrix

f.variables['H'].standard_name  = 'sea_floor_depth_below_sea_level' # change
f.variables['H'].coordinates    = 'XDEP YDEP' # connect CORNER (x,y) to CORNER matrix (is H at corners???)
f.variables['H'].grid_mapping   = 'CRS' # add grid_mapping attribute
 
## staggered m-n velocities

#if nc_isvar(ncfile,'UP'): # check for spherical
#f.variables['UP'].standard_name = 'eastward_sea_water_velocity'
f.variables['UP'].standard_name = 'sea_water_x_velocity' # change: legal standard_name, different when grid is in spherical coordinates
f.variables['UP'].long_name     = 'velocity, x-component'# change: QuickPlot requires this in order to show vectors
f.variables['UP'].coordinates   = coords # connect CENTER (x,y) to CENTER matrix
f.variables['UP'].grid_mapping  = 'CRS'  # add grid_mapping attribute


#if nc_isvar(ncfile,'VP'): # check for spherical
#f.variables['VP'].standard_name = 'northward_sea_water_velocity'
f.variables['VP'].standard_name = 'sea_water_y_velocity' # change: legal standard_name, different when grid is in spherical coordinates
f.variables['VP'].long_name     = 'velocity, y-component' # change: QuickPlot requires this in order to show vectors
f.variables['VP'].coordinates   = coords # connect CENTER (x,y) to CENTER matrix
f.variables['VP'].grid_mapping  = 'CRS'  # add grid_mapping attribute

 
## unstaggared x-y velocities 

#if nc_isvar(ncfile,'UVEL'): # check for spherical
##f.variables['UVEL'].standard_name,'eastward_sea_water_velocity'
# f.variables['UVEL'].standard_name,'sea_water_x_velocity' # change: legal standard_name, different when grid is in spherical coordinates
# f.variables['UVEL'].long_name    ,'velocity, x-component' # change: QuickPlot requires this in order to show vectors
# f.variables['UVEL'].coordinates  ,coords # connect CENTER (x,y) to CENTER matrix
# f.variables['UVEL'].grid_mapping ,'CRS' # add grid_mapping attribute
#
#
#if nc_isvar(ncfile,'VVEL'): # check for spherical
##f.variables['VVEL'].standard_name,'northward_sea_water_velocity'
# f.variables['VVEL'].standard_name,'sea_water_y_velocity' # change: legal standard_name, different when grid is in spherical coordinates
# f.variables['VVEL'].long_name    ,'velocity, y-component' # change: QuickPlot requires this in order to show vectors
# f.variables['VVEL'].coordinates  ,coords # connect CENTER (x,y) to CENTER matrix
# f.variables['VVEL'].grid_mapping ,'CRS' # add grid_mapping attribute


## coordinates

f.variables['XZETA'].long_name    = 'x coordinate Arakawa-C centers' # change: make different than XDEP
f.variables['XZETA'].coordinates  = coords # connect CENTER (x,y) to CENTER matrix
f.variables['XZETA'].grid_mapping = 'CRS' # add grid_mapping attribute
if OPT['xybnds']:
 f.variables['XZETA'].bounds      = 'XZETA_bnds' # bounds:XDEP add bounds attribute once XDEP is 3D [4 x n x m]'); # add bounds attribute once XDEP is 3D [4 x n x m]


f.variables['YZETA'].long_name    = 'y coordinate Arakawa-C centers' # change: make different than YDEP
f.variables['YZETA'].coordinates  = coords # connect CENTER (x,y) to CENTER matrix
f.variables['YZETA'].grid_mapping = 'CRS' # add grid_mapping attribute
if OPT['xybnds']:
 f.variables['YZETA'].bounds      = 'YZETA_bnds' # bounds:YDEP add bounds attribute once YDEP is 3D [4 x n x m]'); # add bounds attribute once YDEP is 3D [4 x n x m]

 
f.variables['XDEP'].long_name     = 'x coordinate Arakawa-C corners' # change: make different than XZETA
f.variables['XDEP'].standard_name = 'projection_x_coordinate'        # change: make identical as XZETA
f.variables['XDEP'].coordinates   = 'YDEP XDEP' # connect CORNER (x,y) to CORNER matrix
f.variables['XDEP'].grid_mapping  = 'CRS' # add grid_mapping attribute
f.variables['XDEP'].comment       = 'XDEP and XZETA can''t be same size: document or remove dummy rows/columns'

f.variables['YDEP'].long_name     = 'y coordinate Arakawa-C corners' # change: make different than YZETA
f.variables['YDEP'].standard_name = 'projection_y_coordinate'        # change: make identical as XZETA
f.variables['YDEP'].coordinates   = 'YDEP XDEP' # connect CORNER (x,y) to CORNER matrix
f.variables['YDEP'].grid_mapping  = 'CRS' # add grid_mapping attribute
f.variables['YDEP'].comment       = 'XDEP and XZETA can''t be same size: document or remove dummy rows/columns'
 
nc_crs = f.createVariable('CRS' , 'i',())
nc_crs.wkt = ''

## lat, lon

if OPT['ll']:
 
  # get center coordinates, incl dummy rows and columns
  # put dummy rows and columns to NaN, to avoid strang uninitialized fill values

  XZETA = f.variables['XZETA'][:]
  YZETA = f.variables['YZETA'][:]
 
  XZETA[ 0,:] = numpy.nan
  XZETA[ 0,:] = numpy.nan
  XZETA[-1,:] = numpy.nan
  XZETA[-1,:] = numpy.nan

  XZETA[:,0 ] = numpy.nan
  YZETA[:,0 ] = numpy.nan
  XZETA[:,-1] = numpy.nan
  YZETA[:,-1] = numpy.nan
  
#TODO# [LONZETA,LATZETA] = convertCoordinates(XZETA,YZETA,'CS1.code',28992,'CS2.code',4326
 
  nc_lat = f.createVariable('lat' , 'f8', ('M','N'),zlib=True,fill_value=numpy.nan) # zlib very effetive for loads of nans  (dry)
  nc_lat.missing_value = 9.969209968386869e+36
  nc_lat.standard_name = 'latitude'
  nc_lat.units         = 'degrees_north'
  nc_lat.long_name     = 'latitude'
  nc_lat.coordinates   = coords # connect CENTER (x,y) to CENTER matrix
  
  if OPT['ll'] & OPT['llbnds']:
     f.variables['lat'].bounds = 'lat_bnds'

#TODO# nc_lat[:] = LATZETA[:]

  nc_lon = f.createVariable('lon' , 'f8', ('M','N'),zlib=True,fill_value=numpy.nan) # zlib very effetive for loads of nans  (dry)
  nc_lon.missing_value = 9.969209968386869e+36
  nc_lon.standard_name = 'longitude'
  nc_lon.units         = 'degrees_east'
  nc_lon.long_name     = 'longitude'
  nc_lon.coordinates   = coords # connect CENTER (x,y) to CENTER matrix   
    
  if OPT['ll'] & OPT['llbnds']:
     f.variables['lon'].bounds = 'lon_bnds'

#TODO# nc_lon[:] = LONZETA[:]

## get coordinates to determine bounds
#  note: only 1 dummy row/col, whereas centers have two

  if (OPT['xy'] and OPT['xybnds']) or (OPT['ll'] and OPT['llbnds']):

   XDEP  = f.variables['XDEP'][:]
   YDEP  = f.variables['YDEP'][:]
   
   if OPT['llbnds']:
#TODO# [LONDEP ,LATDEP ] = convertCoordinates(XDEP ,YDEP ,'CS1.code',28992,'CS2.code',4326
     pass

   f.createDimension('bounds',4)


## (lat,lon) bounds

  if (OPT['ll'] and OPT['llbnds']):

#TODO# lon_bnds = nc_cf_cor2bounds(addrowcol(LONDEP,-1,-1,nan)
#TODO# lat_bnds = nc_cf_cor2bounds(addrowcol(LATDEP,-1,-1,nan)

     nc_lonb = f.createVariable('lon_bnds' , 'f8', ('bounds','M','N'),zlib=True,fill_value=numpy.nan) # zlib very effetive due to loads of nans  (anypixel)
     f.variables['lon_bnds'].missing_value = 9.969209968386869e+36
     f.variables['lon_bnds'].standard_name = 'latitude'
     f.variables['lon_bnds'].units         = 'degrees_north'
     f.variables['lon_bnds'].long_name     = 'latitude corners'
#TODO# nc_lonb[:] = lon_bnds[:]

     nc_latb = f.createVariable('lat_bnds' , 'f8', ('bounds','M','N'),zlib=True,fill_value=numpy.nan) # zlib very effetive due to loads of nans  (anypixel)
     f.variables['lat_bnds'].missing_value = 9.969209968386869e+36
     f.variables['lat_bnds'].standard_name = 'longitude'
     f.variables['lat_bnds'].units         = 'degrees_east'
     f.variables['lat_bnds'].long_name     = 'longitude corners'
#TODO# nc_latb[:] = lat_bnds[:]
 
## (x,y) bounds

  if (OPT['xy'] & OPT['xybnds']):

#TODO# XZETA_bnds = nc_cf_cor2bounds(addrowcol(XDEP,-1,-1,nan) # add extra XDEP dummy row to get bounds for XZETA dummy row
#TODO# YZETA_bnds = nc_cf_cor2bounds(addrowcol(YDEP,-1,-1,nan)

     nc_xb = f.createVariable('XZETA_bnds' , 'f8', ('bounds','M','N'),zlib=True,fill_value=numpy.nan) # zlib very effetive due to loads of nans  (anypixel)
     f.variables['XZETA_bnds']._FillValue    = 9.969209968386869e+36
     f.variables['XZETA_bnds'].missing_value = 9.969209968386869e+36
     f.variables['XZETA_bnds'].standard_name = 'projection_x_coordinate'
     f.variables['XZETA_bnds'].units         = 'm'
     f.variables['XZETA_bnds'].long_name      = 'x corners'

     nc_xb[:] = XZETA_bnds[:]

     nc_yb = f.createVariable('YZETA_bnds' , 'f8', ('bounds','M','N'),zlib=True,fill_value=numpy.nan) # zlib very effetive due to loads of nans  (anypixel)
     f.variables['YZETA_bnds']._FillValue    = 9.969209968386869e+36
     f.variables['YZETA_bnds'].missing_value = 9.969209968386869e+36
     f.variables['YZETA_bnds'].standard_name = 'projection_y_coordinate'
     f.variables['YZETA_bnds'].units         = 'm'
     f.variables['YZETA_bnds'].long_name     = 'y corners' 

     nc_yb[:] = YZETA_bnds[:]
 
f.close()   

# NETCDF_versions_generate
# Make example netCDF files for all four netCDF version
# This script has been tested to work succesfully with 
# PythonXY 2.7.2.0 with netCDF4 version 1.0 (package updated)
# These are hosted for OPeNDAP testing at:
# http://opendap.deltares.nl/thredds/catalog/opendap/test/catalog.html

import time, numpy, netCDF4

ncversions = []
ncversions.append('NETCDF4'        )
ncversions.append('NETCDF3_CLASSIC')
ncversions.append('NETCDF3_64BIT'  )
ncversions.append('NETCDF4_CLASSIC')
# 'NETCDF4_CLASSIC' cannot be handled by Matlab R2011a and below 
# due to '_Netcdf4Dimid' attributes.
# Use fix_creation_order_issue.m to mend this.

for inc, ncversion in enumerate(ncversions):

   f = netCDF4.Dataset(ncversion + '.nc','w', format=ncversion)

   t = numpy.array([0,1,2])    # minimally 3 to allow for proper ncBrowse patch plotting
   y = numpy.array([0,1,2,3])  # each dimension has a different length to rapid test assessment of z
   x = numpy.array([0,1,2,3,4])  

# create global atts
   
   f.title           = 'test file for netCDF format: ' + ncversion
   f.institution     = 'Deltares'
   f.source          = 'Deltares'
   f.history         = '$Id: NETCDF_versions_generate.py 7074 2012-07-31 09:31:57Z boer_g $'
   f.references      = ''
   f.email           = 'gerben.deboer@deltares.nl'
   f.comment         = ''
   f.version         = 'Python netCDF4 version ' + netCDF4.__version__
   f.Conventions     = 'CF-1.5'
   f.terms_for_use   = 'These data can be used freely for research purposes provided that the following source is acknowledged: ' + f.institution
   f.disclaimer      = 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.'
   
# create dimensions

   f.createDimension('time', len(t))
   f.createDimension('y'   , len(y))
   f.createDimension('x'   , len(x))
      
# create variables

   nc_t   = f.createVariable('time' , 'f8', ('time')        )
   nc_y   = f.createVariable('y'   , 'f8',         ('y')    )
   nc_x   = f.createVariable('x'   , 'f8',             ('x'))
   nc_z   = f.createVariable('z'    , 'f4', ('time','y','x'),zlib=True,fill_value=numpy.nan)
   
# add attributes

   nc_t.units         = 'seconds since ' + time.strftime('%Y-%m-%d %H-%M-%S',time.gmtime(0)) # EPOCH # 'years since 0000-00-00 00:00:00'
   nc_t.standard_name = 'time'
   nc_t.long_name     = 'time'
   
   nc_y.standard_name = 'projection_y_coordinate'
   nc_y.units         = 'm'
   nc_y.long_name     = 'y'
   
   nc_x.standard_name = 'projection_x_coordinate'
   nc_x.units         = 'm'
   nc_x.long_name     = 'x'
   
   nc_z.standard_name = 'altitude'
   nc_z.units         = 'm'
   nc_z.long_name     = 'altitude'
   nc_z.comment       = 'z = 100*it + 10*iy + ix'
   
# store data
   
   nc_t[:]       = t
   nc_y[:]       = y
   nc_x[:]       = x

   for it    in range(0,len(t)):
    for iy   in range(0,len(y)):
     for ix  in range(0,len(x)):

      nc_z[it,iy,ix] = 100*it + 10*iy + ix 
     
      #nc_z[0,0,:]   = numpy.array([  0,  1,  2,  3,  4])
      #nc_z[0,1,:]   = numpy.array([ 10, 11, 12, 13, 14])
      #nc_z[0,2,:]   = numpy.array([ 20, 21, 22, 23, 24])
      #nc_z[0,3,:]   = numpy.array([ 30, 31, 32, 33, 34])
      #
      #nc_z[1,0,:]   = numpy.array([100,101,102,103,104])
      #nc_z[1,1,:]   = numpy.array([110,111,112,113,114])
      #nc_z[1,2,:]   = numpy.array([120,121,122,123,124])
      #nc_z[1,3,:]   = numpy.array([130,131,132,133,134])
   
   f.close()   
   
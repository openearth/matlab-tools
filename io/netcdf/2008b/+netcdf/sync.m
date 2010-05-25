function sync(ncid)
%netcdf.sync Synchronize netCDF dataset to disk.  
%   
%   netcdf.sync(ncid) synchronizes the state of a netCDF dataset to disk.  
%   The netCDF library will normally buffer accesses to the underlying
%   netCDF file unless the NC_SHARE mode is supplied to netcdf.open or
%   netcdf.create.
%
%   To use this function, you should be familiar with the information about 
%   netCDF contained in the "NetCDF C Interface Guide" for version 3.6.2.  
%   This documentation may be found by visiting the Unidata website at 
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/>.
%   This function corresponds to the "nc_sync" function in the netCDF 
%   library C API.
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf.open, netcdf.create, netcdf.close, netcdf.endDef
%

%   Copyright 2008 The MathWorks, Inc.
%   $Revision$ $Date$

error(nargchk(1,1,nargin,'struct'));
netcdflib('sync', ncid);            




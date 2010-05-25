function abort(ncid)
%netcdf.abort Revert recent netCDF file definitions.
%   netcdf.abort(ncid) will revert a netCDF file out of any definitions
%   made after netcdf.create but before netcdf.endDef.  The file will
%   also be closed.
%
%   To use this function, you should be familiar with the information about 
%   netCDF contained in the "NetCDF C Interface Guide" for version 3.6.2.  
%   This documentation may be found by visiting the Unidata website at 
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/>.
%   This function corresponds to the functions "nc_abort" in the netCDF 
%   library C API.
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf.create, netcdf.endDef.
%

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision$ $Date$

netcdflib('abort',ncid);

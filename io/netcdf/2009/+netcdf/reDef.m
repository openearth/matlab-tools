function reDef(ncid)
%netcdf.reDef Set netCDF file into define mode.
%   netcdf.reDef(ncid) Puts an open netCDF dataset into define mode so 
%   that dimensions, variables, and attributes can be added or renamed.  
%   Attributes can also be deleted in define mode.
%
%   To use this function, you should be familiar with the information about 
%   netCDF contained in the "NetCDF C Interface Guide" for version 3.6.2.  
%   This documentation may be found by visiting the Unidata website at 
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/>.
%   This function corresponds to the "nc_redef" function in the netCDF 
%   library C API.
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision$ $Date$

netcdflib('redef',ncid);            

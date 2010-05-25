function dimid = defDim(ncid,dimname,dimlen)
%netcdf.defDim Create netCDF dimension.
%   dimid = netcdf.defDim(ncid,dimname,dimlen) creates a new dimension 
%   given its name and length.  The return value is the numeric ID
%   corresponding to the new dimension.
%
%   To use this function, you should be familiar with the information about 
%   netCDF contained in the "NetCDF C Interface Guide" for version 3.6.2.  
%   This documentation may be found by visiting the Unidata website at 
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/>.
%   This function corresponds to the "nc_def_dim" function in the netCDF 
%   library C API.
%
%   Example
%
%       lat_dimid = netcdf.defDim(ncid,'latitude',360);
%
%       dimlen = netcdf.getConstantValue('NC_UNLIMITED');
%       time_dimid = netcdf.defDim(ncid,'time',dimlen);
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision$ $Date$

dimid = netcdflib('defDim', ncid,dimname,dimlen);            

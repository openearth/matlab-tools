function oldFormat = setDefaultFormat(newFormat)
%netcdf.setDefaultFormat Change default netCDF file format.
%   oldFormat = netcdf.setDefaultFormat(newFormat) changes the format 
%   of future created files to newFormat and returns the value of the
%   old format.  newFormat can be either 'FORMAT_CLASSIC' or 
%   'FORMAT_64BIT' or their numeric equivalents as retrieved by
%   netcdf.getConstant.
%   
%   Example
%   -------
%       newFormat = netcdf.getConstant('NC_FORMAT_64BIT');
%       oldFormat = netcdf.setDefaultFormat(newFormat);
%
%   To use this function, you should be familiar with the information about 
%   netCDF contained in the "NetCDF C Interface Guide" for version 3.6.2.  
%   This documentation may be found by visiting the Unidata website at 
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/>.
%   This function corresponds to the "nc_set_default_format" function in 
%   the netCDF library C API.
% 
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf.getConstant.
%

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision$ $Date$

if ischar(newFormat)
    newFormat = netcdf.getConstant(newFormat);
end

oldFormat = netcdflib('setDefaultFormat',newFormat);

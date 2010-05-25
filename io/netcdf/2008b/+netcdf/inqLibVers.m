function libvers = inqLibVers()
%netcdf.inqLibVers Return netCDF library version information.
%   libvers = netcdf.inqLibVers returns a string identifying the 
%   version of the netCDF library.
%
%   To use this function, you should be familiar with the information about 
%   netCDF contained in the "NetCDF C Interface Guide" for version 3.6.2.  
%   This documentation may be found by visiting the Unidata website at 
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/>.
%   This function corresponds to the "nc_inq_libvers" function in the 
%   netCDF library C API.
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%

%   Copyright 2008 The MathWorks, Inc.
%   $Revision$ $Date$

libvers = netcdflib('inqLibVers');
if ispc
    libvers = libvers(1:5);
else
    libvers = libvers(2:6);
end


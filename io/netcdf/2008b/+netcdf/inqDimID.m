function dimid = inqDimID(ncid,dimname)
%netcdf.inqDimID Return dimension ID.
%   dimid = netcdf.inqDimID(ncid,dimname) returns the ID of a dimension
%   given the name.
%
%   To use this function, you should be familiar with the information about 
%   netCDF contained in the "NetCDF C Interface Guide" for version 3.6.2.  
%   This documentation may be found by visiting the Unidata website at 
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/>.
%   This function corresponds to the "nc_inq_dimid" function in the netCDF 
%   library C API.
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision$ $Date$

dimid = netcdflib('inqDimID', ncid,dimname);            

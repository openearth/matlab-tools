function [varname,xtype,dimids,natts] = inqVar(ncid,varid)
%netcdf.inqVar Return information about netCDF variable.
%   [varname,xtype,dimids,natts] = netcdf.inqVar(ncid,varid) returns
%   the name, datatype, dimensions IDs, and the number of attributes of 
%   the variable identified by varid.
%
%   To use this function, you should be familiar with the information about 
%   netCDF contained in the "NetCDF C Interface Guide" for version 3.6.2.  
%   This documentation may be found by visiting the Unidata website at 
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/>.
%   This function corresponds to the "nc_inq_var" function in the netCDF 
%   library C API.  Because MATLAB uses FORTRAN-style ordering, however, 
%   the order of the dimension IDs is reversed relative to what would be 
%   obtained from the C API.  
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision$ $Date$

[varname,xtype,dimids,natts] = netcdflib('inqVar', ncid, varid);            

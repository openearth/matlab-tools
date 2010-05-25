function delAtt(ncid,varid,attname)
%netcdf.delAtt Delete netCDF attribute.
%   netcdf.delAtt(ncid,varid,attName) deletes the attribute identified
%   by attName from the variable identified by varid.  In order to delete
%   a global attribute, use netcdf.getConstant('GLOBAL') for the varid.
%
%   To use this function, you should be familiar with the information about 
%   netCDF contained in the "NetCDF C Interface Guide" for version 3.6.2.  
%   This documentation may be found by visiting the Unidata website at 
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/>.
%   This function corresponds to the "nc_del_att" function in the netCDF 
%   library C API.
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf.getConstant.

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision$ $Date$

netcdflib('delAtt', ncid, varid, attname);

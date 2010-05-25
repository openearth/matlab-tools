function renameAtt(ncid,varid,oldname,newname)
%netcdf.renameAtt Change name of netCDF attribute.
%   netcdf.renameAtt(ncid,varid,oldName,newName) renames the attribute 
%   identified by oldName to newName.  The attribute is associated with
%   the variable identified by varid.  A global attribute can be 
%   specified by using netcdf.getConstant('GLOBAL') for the varid.
%
%   To use this function, you should be familiar with the information about 
%   netCDF contained in the "NetCDF C Interface Guide" for version 3.6.2.  
%   This documentation may be found by visiting the Unidata website at 
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/>.
%   This function corresponds to the "nc_rename_att" function in the netCDF 
%   library C API.
% 
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf.getConstant.


%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision$ $Date$

netcdflib('renameAtt', ncid, varid, oldname, newname );

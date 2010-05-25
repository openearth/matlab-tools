function attid = inqAttID(ncid,varid,attname)
%netcdf.inqAttID Return ID of netCDF attribute.
%   attnum = netcdf.inqAttID(ncid,varid,attname) retrieves the 
%   number of the attribute associated with the attribute name.
%
%   To use this function, you should be familiar with the information about 
%   netCDF contained in the "NetCDF C Interface Guide" for version 3.6.2.  
%   This documentation may be found by visiting the Unidata website at 
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/>.
%   This function corresponds to the "nc_inq_att_id" function in the netCDF 
%   library C API.
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision$ $Date$

attid = netcdflib('inqAttID', ncid, varid,attname);            

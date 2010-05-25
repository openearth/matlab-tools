function [xtype,attlen] = inqAtt(ncid,varid,attname)
%netcdf.inqAtt Return information about netCDF attribute.
%   [xtype,attlen] = netcdf.inqAtt(ncid,varid,attname) returns
%   the datatype and length of an attribute identified by attname.
%
%   To use this function, you should be familiar with the information about 
%   netCDF contained in the "NetCDF C Interface Guide" for version 3.6.2.  
%   This documentation may be found by visiting the Unidata website at 
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/>.
%   This function corresponds to the "nc_inq_att" function in the netCDF 
%   library C API.
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision$ $Date$

[xtype,attlen] = netcdflib('inqAtt', ncid, varid,attname);            

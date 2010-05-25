function [ndims,nvars,ngatts,unlimdimid] = inq(ncid)
%netcdf.inq Return information about netCDF file.
%   [ndims,nvars,ngatts,unlimdimid] = netcdf.inq(ncid) inquires as to 
%   the number of dimensions, number of variables, number of global 
%   attributes, and the identity of the unlimited dimension, if any.
%   The netCDF file is identified by the numeric ID ncid.
%
%   To use this function, you should be familiar with the information about 
%   netCDF contained in the "NetCDF C Interface Guide" for version 3.6.2.  
%   This documentation may be found by visiting the Unidata website at 
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/>.
%   This function corresponds to the "nc_inq" function in the netCDF 
%   library C API.
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision$ $Date$

[ndims,nvars,ngatts,unlimdimid] = netcdflib('inq',ncid);

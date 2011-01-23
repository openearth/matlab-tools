function close(ncid)
%netcdf.close Copy of Close netCDF file.

% this is an exact copy of the matlab native netcdf.close
% file with some code appended to support allclear

%% exact copy of the matlab native netcdf.close
%netcdf.close Close netCDF file.
%   netcdf.close(ncid) terminates access to the netCDF file identified
%   by ncid.
%
%   This function corresponds to the "nc_close" function in the netCDF 
%   library C API.
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.open, netcdf.create.

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision$ $Date$

netcdflib('close', ncid);            

%% added code

% netcdf.list_of_open_nc_files('close',ncid);
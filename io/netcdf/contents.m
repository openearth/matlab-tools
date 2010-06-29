% OpenEarhTools netCDF toolbox distribution.
%
%   netcdf_settings     - adds all netCDF tools below to matlab path
%                         incl. some legacies solutions and JAVA library.
%                         Automacially uses matlan native netcdf library
%                         for write actions, uses JAVA Library for
%                         OPeNDAP (read) actions.
%
%   snctools            - simple netCDF io (external)
%                         tutorial: http://mexcdf.sourceforge.net/tutorial
%   mexnc               - low-level netCDF io (external)
%   nctools             - netCDF-CF tools
%
% Tutorials: reading net CDF files
%
% nc_cf_time              -  reads a time variable ino Matlab datanum
% nc_cf_grid              -  interprets grid
% nc_cf_stationTimeSeries -  interprets time series
%
% Tutorials: creating net CDF files
% 
%   nc_cf_stationTimeSeries_write_tutorial        - write time series
%   nc_cf_grid_write_lat_lon_orthogonal_tutorial  - write grid: (lat,lon)
%   nc_cf_grid_write_lat_lon_curvilinear_tutorial - write grid: (lat,lon)
%   nc_cf_grid_write_x_y_orthogonal_tutorial      - write grid: (x,y)
%   nc_cf_grid_write_x_y_curvilinear_tutorial     - write grid: (x,y)
%
% Please refer to the following websites for more info 
% on netCDF and the prevailing CF conventions:
%
% * http://www.unidata.ucar.edu/software/netcdf/
% * http://cf-pcmdi.llnl.gov/
%
% See also: OpenEarthTools: general, applications, netcdf

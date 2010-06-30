% OpenEarhTools netCDF toolbox distribution.
%
%   netcdf_settings     - adds all netCDF tools below to matlab path
%                         incl. some legacies solutions and JAVA library.
%                         Automacially uses Matlab native netcdf library (R2008b+)
%                         for write, uses JAVA library for OPeNDAP read.
%   snctools            - simple netCDF io (external)
%   mexnc               - low-level netCDF io (external)
%   nctools             - netCDF-CF tools (add-on to snctools)
%
% Reading netCDF files
%
%  http://mexcdf.sourceforge.net/tutorial - snctools basics
%  nc_cf_time                             - read CF time variable into Matlab datenum
%  nc_cf_grid                             - read CF grid
%  nc_cf_stationTimeSeries                - read CF time series
%  opendap_catalog                        - get netCDF file list from OPeNDAP server
%
% Creating netCDF files (tutorials)
% 
%  nc_cf_stationTimeSeries_write_tutorial        - write time series        f(time)
%  nc_cf_grid_write_lat_lon_orthogonal_tutorial  - write grid: orthogonal   f(lat,lon)
%  nc_cf_grid_write_x_y_orthogonal_tutorial      - write grid: orthogonal   f(x,y)     
%  nc_cf_grid_write_lat_lon_curvilinear_tutorial - write grid: curvi-linear f(lat,lon)
%  nc_cf_grid_write_x_y_curvilinear_tutorial     - write grid: curvi-linear f(x,y)
%
% For more info on netCDF and the CF conventions:
%
%  http://www.unidata.ucar.edu/software/netcdf/
%  http://cf-pcmdi.llnl.gov/
%
% See also: OpenEarthTools: general, applications, netcdf

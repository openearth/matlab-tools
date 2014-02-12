function [ noos_ascii ] = wps_t_tide(constituents, start, stop, interval)
%wps_t_tide     tidal timeseries predict as noos file from a netcdf file
%
% Input:
%   noos_ascii = text/csv
%
% Output:
%   constituents = application/netcdf
%   start = double
%   stop  = double
%   interval = double
%
%See also: wps_nc_t_tide, nc_t_tide, noos_read, noos_write


% * how to deal with keyword value: simpel require all of them to be present?

function [ constituents ] = wps_nc_t_tide(noos_ascii)
%wps_nc_t_tide     tidal timeseries analysis as noos file to netcdf
%
% Input:
%   noos_ascii= text/csv
%
% Output:
%   constituents= application/netcdf
%
%See also: wps_nc_t_tide, nc_t_tide, noos_read, noos_write

% t_tide

   OPT.period        = [];
   OPT.lat           = NaN;
   OPT.ddatenumeps   = 1e-8;
   OPT.synth         = 2;
   OPT.sort          = 'freq';

% result file

   OPT.ncfile        = '';
   
% netCDF formatting
   
   OPT.refdatenum    = datenum(1970,1,1);
   OPT.lon           = NaN;
   OPT.units         = '?';
   OPT.platform_id   = ' ';
   OPT.platform_name = ' ';
   OPT.title         = ' ';
   OPT.institution   = ' ';
   OPT.source        = ' ';
   OPT.history       = ' ';
   OPT.email         = ' ';
   
% call

   OPT = setproperty(OPT,varargin);

% # Timezone    : MET
% #------------------------------------------------------
% 200709010000   -0.387653201818466
% 200709010010   -0.395031750202179
% 200709010020   -0.407451331615448
% 200709010030   -0.414252400398254
% 200709010040   -0.425763547420502
% 200709010050   -0.43956795334816
  
   [time, data] = noos_read(noos_ascii);
   
   nc_t_tide(time,data,OPT);
   
% send file back: map local link to weblink ??

   constituents = OPT.ncfile;



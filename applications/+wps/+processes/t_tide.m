function [ constituents ] = wps_nc_t_tide(noos_ascii,varargin)
%t_tide     tidal timeseries analysis from noos file
%
% Input:
%   noos_ascii   = text/csv (NOOS format)
%   period       = text/csv (NOOS format)
%   format       = char [reserved WPS keyword]
%
% Output:
%   constituents = text/html, text/plain, text/xml, application/netcdf
%
%See also: t_tide, noos_read, noos_write, t_tide2html

%% t_tide keywords

   OPT.period        = [];
   OPT.lat           = NaN;
   OPT.synth         = 2;
   OPT.sort          = 'freq';
   
% reserved WPS keyword

   OPT.format        = 'text/html'; % http://en.wikipedia.org/wiki/Internet_media_type
   
% call

   WPS = setproperty(OPT,varargin);

% # Timezone    : MET
% #------------------------------------------------------
% 200709010000   -0.387653201818466
% 200709010010   -0.395031750202179
% 200709010020   -0.407451331615448
% 200709010030   -0.414252400398254
% 200709010040   -0.425763547420502
% 200709010050   -0.43956795334816
  
   [time, data] = noos_read(noos_ascii);
   
   OPT2 = OPT;OPT2 = rmfield(OPT,'format');
   
if strcmpi(WPS.format,'text/plain') % native t_tide ascii garbage

   OPT2.ascfile  = 't_tide.asc';
   D = nc_t_tide(time,data,OPT2);
   constituents = loadstr(OPT2.ascfile);

elseif strcmpi(WPS.format,'text/xml')

   D = nc_t_tide(time,data,OPT2);
   constituents = t_tide2xml(D);

%elseif strcmpi(WPS.format,'application/netcdf')

%   OPT.ncfile   = 't_tide.nc';
%   D = nc_t_tide(time,data,OPT2);
%   constituents = binarystream(OPT.ncfile);
   
else %if strcmpi(WPS.format,'text/html') % default
   
   D = nc_t_tide(time,data,OPT2);
   constituents = t_tide2html(D);
   
end

% send file back: map local link to weblink ??


function f = coriolis(lat,varargin)
% coriolis
%
% returns value of coriolis parameter f in [rad/s]
%
% f = coriolis(lat) where lat is the latitude in DEGREES.
% 
% By default the lentgh of a day is 23 hr 56 m 4.1 s
% being a siderial day.
%
% A solar day the day has a length of 24 h precise.
% This can be switched on with an additional keyword,value
% pair: coriolis(latitude,'day',value)
% where value can be 'SIDERIAL','SOLAR','D3D','delft3d' or 
% any value in SECONDS (all case insensitive).
%
% G.J. de Boer, TU Delft
% June 2005

% secperday = (23*60 + 60)*60 + 0.0; % solar day [s] (as in Delft3D)
secperday = (23*60 + 56)*60 + 4.1; % siderial day [s]

if nargin > 2

   keyword = varargin{1};
   value   = varargin{2};
   
   if strcmp(lower(keyword),'day')
      if isstr(value)
        if     strcmp(lower(value),'siderial')
           secperday = (23*60 + 56)*60 + 4.1; % siderial day [s]
        elseif strcmp(lower(value),'solar')
           secperday = (23*60 + 60)*60 + 0.0; % solar day [s] (as in Delft3D)
        elseif strcmp(lower(value),'d3d')
           secperday = (23*60 + 60)*60 + 0.0; % solar day [s] (as in Delft3D)
        elseif strcmp(lower(value),'delft3d')
           secperday = (23*60 + 60)*60 + 0.0; % solar day [s] (as in Delft3D)
        else
           error('Syntax: coriolis(latitude,''day'',value) where value is a string or a real')
        end
      elseif isreal(value)
           secperday = value;
      else
           error('Syntax: coriolis(latitude,''day'',value) where value is a string or a real')
      end
   end   

end


OMEGA  = 2*pi/secperday;             % angular velocity of the earth [rad/s]
f      = 2*OMEGA*sin(deg2rad(lat));  % Coriolis parameter [rad/s]

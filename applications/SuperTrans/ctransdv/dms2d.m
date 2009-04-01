function varargout = DMS2D(varargin)
%DMS2D
%
%   [lon    ] = DMS2D(lonstruct)
%   [lat    ] = DMS2D(latstruct)
%   [lon,lat] = DMS2D(lonstruct,lonstruct)
%   [lat,lon] = DMS2D(latstruct,lonstruct)
%
%   [lon    ] = DMS2D(lon.dg,lon.mn,lon.sc)                     
%   [lat    ] = DMS2D(lat.dg,lat.mn,lat.sc)                     
%   [lon,lat] = DMS2D(lon.dg,lon.mn,lon.sc,lat.dg,lat.mn,lat.sc)
%   [lat,lon] = DMS2D(lat.dg,lat.mn,lat.sc,lon.dg,lon.mn,lon.sc)
%
%   where
%   lon       and lat         are in decimal degrees
%   lonstruct and lonstruct   are structs with fields
%   - degrees 'dg' 
%   - minutes 'mn' 
%   - seconds 'sc'
%
%   See also: DDMMSS2D, DDMMSS2DMS

      x  = varargin{1};
      y  = [];
   if nargin==2
      y  = varargin{2};
   end
   
   if nargin>2
      x.dg = varargin{1};
      x.mn = varargin{2};
      x.sc = varargin{2};
   end   
   if nargin==6
      y.dg = varargin{4};
      y.mn = varargin{5};
      y.sc = varargin{6};
   end   
   
   % -------------------

   lon = [x.dg] + [x.mn] / 60.0 + [x.sc] / 3600.0;
   if ~isempty(y)
   lat = [y.dg] + [y.mn] / 60.0 + [y.sc] / 3600.0;
   end
   % -------------------
   
   if ~isempty(y)
      varargout = {lon,lat};
   else
      varargout = {lon};
   end

   % -------------------
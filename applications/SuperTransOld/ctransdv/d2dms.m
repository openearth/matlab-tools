function varargout=D2DMS(xgeo,varargin)
%D2DMS
%
% [latstruct          ] = D2DMS(lat)
% [lonstruct          ] = D2DMS(lon)
% [lonstruct,latstruct] = D2DMS(lon,lat)
% [latstruct,lonstruct] = D2DMS(lat,lon)
%
% where lon and lat are in decimal degrees
% and the structs have fields
%
% - degrees 'dg' 
% - minutes 'mn' 
% - seconds 'sc'

   x.dg  = floor(xgeo);
   seconds  = (xgeo - x.dg).* 3600;
   x.mn  = floor(seconds./60.);
   x.sc  = seconds - (x.mn.* 60);
   
   if nargin==2
   
      ygeo = varargin{1};
      
      y.dg  = floor(ygeo);
      seconds  = (ygeo - y.dg).* 3600;
      y.mn  = floor(seconds./60.);
      y.sc  = seconds   - (y.mn.* 60);
       
      varargout= {x,y};
      
   else

      varargout= {x};
   
   end


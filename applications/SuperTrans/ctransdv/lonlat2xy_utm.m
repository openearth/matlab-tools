function [xutm,yutm,zone] = lonlat2xy_utm(lon,lat,a,e,varargin)
%LONLAT2XY_UTM   Transform (lon,lat) to (x,y) coordinates in UTM system
%
% [xutm,yutm,zone] = LONLAT2XY_UTM (lon,ygeo,a,e)
%
% Only tested for Northern Hemisphere!
%
% ---------------------------------------------------------------------
%     Conversion of geographical (lat, lon) --> UTM coordinates (x, y, zone)
%
%     geographical coordinates   (lat, lon) expressed in decimal degrees.
% ----------------------------------------------------------------------
%     arguments:
%     lon     in     longitude (geographical coordinate)
%     lat     in     lattitude (geographical coordinate)
%     a       in     semi-major axis of ellipsoid
%     e       in     excentricity of ellipsoid
%     xutm    out    easting  (UTM)
%     yutm    out    northing (UTM)
%     zone    out    zone     (UTM) optional input
% -----------------------------------------------------------------------------
%
% See also: GETELLIPSOID,LONLAT2XY_UTM,XY_UTM2LONLAT,
%                        LONLAT2XY_RD , XY_RD2LONLAT ,
%                        LONLAT2XY_PAR,XY_PAR2LONLAT
%    MFWDTRAN,MINVTRAN, (from Matlab mapping toolbox)
%    pctrans.exe (http://www.hydro.nl/pgs/en/pctrans_en.htm)

% -----------------------------------------------------------------------------
%     G.J. de Boer                              vectorized for Matlab  Jul 2004
%     Hans Bonekamp                               converted to matlab  Feb 2001
%     T.J. Zitman                                 last update: 10 december 1990
% -----------------------------------------------------------------------------

%  Input
%  ------------------------------------

   zone    = nan;
   if nargin==5
   zone    = varargin{1};
   end
   
%  Limitation
%  --------------------------------------------

   if any(lat<0)
      warning('Only tested for Northern Hemisphere!')
   end

%  initialize constants
%  ------------------------------------

   e2     = e^2;
   e4     = e^4;
   e6     = e^6;
   n      = e2/(1.0-e2);
   nn     = n^2;
   f1     = 1.0 - (1.0/4.0)*e2 - ( 3.0/ 64.0)*e4 - ( 5.0/ 256.0)*e6;
   f2     =       (3.0/8.0)*e2 + ( 3.0/ 32.0)*e4 + (45.0/1024.0)*e6;
   f3     =                      (15.0/256.0)*e4 + (45.0/1024.0)*e6;
   f4     =                                        (35.0/3072.0)*e6;

%  set false northing and false easting
%  ------------------------------------
  
   fn            = zeros(size(lat));
   fn(lat < 0.0) = 1.0E+07;
   lat           = abs(lat);
   fe            = 5.0E+05;

%  set fi and dl
%  ---------------------
   if isnan(zone)
      % ONE zone for all pixels depending on zone of pixel(1)
      % provided that that pixel is not nan!!!!
      element = 0;
      while isnan(zone)
         element = element + 1;
         zone    = fix((lon(element)+180)./6)+1;
      end
      disp(['message from ctransdv: element ',num2str(element),' used for determining UTM zone: ',num2str(zone)])
   end

   fi      = lat.*pi./180.0;
   dl      = (lon + 177.0 - 6.0.*(zone-1) ).*pi./180.0;

%  constants, related to fi
%  ------------------------
   s       = sin(fi);
   ss      = s.^2;
   c       = cos(fi);
   cc      = c.^2;
   cccc    = c.^4;
   sc      = s.*c;

%  values of sub-functions
%  ------------------------------------- 
   rp      = a./sqrt(1.0-e2.*ss);
   dm      = a.*( f1.*fi - f2.*sin(2.0.*fi)...
                         + f3.*sin(4.0.*fi)...
                         - f4.*sin(6.0.*fi));
   dl2     = dl.^2;
 
   gx      = dl2.*(2.0.*cc - 1.0 +      nn.*cccc)./6.0;
   gy      = dl2.*(6.0.*cc - 1.0 + 9.0.*nn.*cccc)./12.0;

   x       = rp.*dl.*c.*(1.0+gx);
   y       = dm + rp.*0.5.*dl2.*sc.*(1.0+gy);

   xutm    = 0.9996.*x + fe;
   yutm    = 0.9996.*y + fn;

%% EOF
function [xpar,ypar]= lonlat2xy_par(lon,lat)
%LONLAT2XY_PAR   Transform (lon,lat) to (x,y) coordinates in Dutch Parijs system
%
% [xpar,ypar]= LONLAT2XY_PAR(lon,lat)
%
% -----------------------------------------------------------------------------
%     Conversion of Geographical coordinates (Bessel) into Paris -coordinates
%
%     geographical coordinates   (lat, lon) expressed in decimal degrees.
% -----------------------------------------------------------------------------
%     arguments:
%     lon       in    geographical east-coordinate (degrees; decimal)
%     lat       in    geographical north-coordinate (degrees; decimal)
%     xpar      out   east-coordinate in Paris system
%     ypar      out   north-coordinate in Paris system
% -----------------------------------------------------------------------------
%
% See also: GETELLIPSOID,LONLAT2XY_UTM,XY_UTM2LONLAT,
%                        LONLAT2XY_RD , XY_RD2LONLAT ,
%                        LONLAT2XY_PAR,XY_PAR2LONLAT
%    MFWDTRAN,MINVTRAN, (from Matlab mapping toolbox)
%    pctrans.exe (http://www.hydro.nl/pgs/en/pctrans_en.htm)

% -----------------------------------------------------------------------------
%     G.J. de Boer          vectorized and requirment for nan as missing values
%     Hans Bonekamp                               converted to matlab  Feb 2001
%     T.J. Zitman                                  last update: 29 january 1991
% -----------------------------------------------------------------------------

   [xrd,yrd] = lonlat2xy_rd(lon,lat);
   
   xpar = xrd + 155000.;
   ypar = yrd + 463000.;

%% EOF
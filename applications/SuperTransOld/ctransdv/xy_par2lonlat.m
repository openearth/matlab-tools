function  [lon,lat] = xy_par2lonlat(xpar,ypar)
%XY_PAR2LONLAT   Transform (lon,lat) to (x,y) coordinates in Dutch Parijs system
%
%   [lon,lat] = xy_par2lonlat(xpar,ypar)
%
% -----------------------------------------------------------------------------
%     geographical coordinates   (lat, lon) expressed in decimal degrees.
%
%     Conversion of paris coordinates into Geographical coordinates (Bessel)
% -----------------------------------------------------------------------------
%     arguments:
%     xrd      in    east-coordinate in RD system
%     yrd      in    north-coordinate in RD system
%     lon      out   geographical east-coordinate (degrees; decimal)
%     lat      out   geographical north-coordinate (degrees; decimal)
% -----------------------------------------------------------------------------
%
% See also: GETELLIPSOID,LONLAT2XY_UTM,XY_UTM2LONLAT,
%                        LONLAT2XY_RD , XY_RD2LONLAT ,
%                        LONLAT2XY_PAR,XY_PAR2LONLAT
%    MFWDTRAN,MINVTRAN, (from Matlab mapping toolbox)
%    pctrans.exe (http://www.hydro.nl/pgs/en/pctrans_en.htm)

% -----------------------------------------------------------------------------
%     G.J. de Boer                              vectorized for Matlab  Jul 2004
%     Hans Bonekamp                                converted  to Matlab    2001
%     T.J. Zitman                                  last update: 29 january 1991
% -----------------------------------------------------------------------------

   xrdc = xpar - 155000.0;
   yrdc = ypar - 463000.0;

   [lon,lat] = xy_rd2lonlat(xrdc,yrdc);

%% EOF
function [xrd,yrd]= lonlat2xy_rd(lon,lat)
%LONLAT2XY_RD   Transform (lon,lat) to (x,y) coordinates in Dutch Rijksdriehoek RD system
%
% [xrd,yrd]= LONLAT2XY_RD(xgeo,ygeo)
%
% -----------------------------------------------------------------------------
%     Conversion of Geographical coordinates (Bessel) into RD-coordinates
%
%     geographical coordinates   (lat, lon) expressed in decimal degrees.
% -----------------------------------------------------------------------------
%     arguments:
%     lon      in    geographical east-coordinate (degrees; decimal)
%     lat      in    geographical north-coordinate (degrees; decimal)
%     xrd      out   east-coordinate in RD system
%     yrd      out   north-coordinate in RD system
% ------------------------------------------------------------------------------
%
% See also: GETELLIPSOID,LONLAT2XY_UTM,XY_UTM2LONLAT,
%                        LONLAT2XY_RD , XY_RD2LONLAT ,
%                        LONLAT2XY_PAR,XY_PAR2LONLAT
%    MFWDTRAN,MINVTRAN, (from Matlab mapping toolbox)
%    pctrans.exe (http://www.hydro.nl/pgs/en/pctrans_en.htm)

% -----------------------------------------------------------------------------
%     G.J. de Boer                              vectorized for Matlab  Jul 2004
%     Hans Bonekamp                               converted to matlab  Feb 2001
%     T.J. Zitman                                  last update: 29 january 1991
% -----------------------------------------------------------------------------

   ugeo = 0.3600*lon -  1.9395500;
   vgeo = 0.3600*lat - 18.7762178;

   xrd  = + 190066.91.*(ugeo   )            ...
          - 11831.0  .*(ugeo   ).*(vgeo   ) ...
          - 114.2    .*(ugeo   ).*(vgeo.^2) ...
          - 32.39    .*(ugeo.^3)            ...
          - 2.33     .*(ugeo   ).*(vgeo.^3) ...
          - 0.61     .*(ugeo.^3).*(vgeo   );

   yrd  = 309020.34             .*(vgeo   ) ...
          + 3638.36  .*(ugeo.^2)            ...
          + 72.92               .*(vgeo.^2) ...
          - 157.97   .*(ugeo.^2).*(vgeo   ) ...
          + 59.77               .*(vgeo.^3) ...
          + 0.09     .*(ugeo.^4)            ...
          - 6.45     .*(ugeo.^2).*(vgeo.^2) ...
          + 0.07                .*(vgeo.^4);


%% EOF
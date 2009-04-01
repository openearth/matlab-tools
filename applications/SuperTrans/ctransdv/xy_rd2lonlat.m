function  [lon,lat] = xy_rd2lonlat(xrd,yrd)
%XY_RD2LONLAT   Transform (x,y) coordinates in Dutch Rijksdriehoek RD system to (lon,lat)
%
% [lon,lat] = XY_RD2LONLAT(xrd,yrd)
%
% -----------------------------------------------------------------------------
%     Conversion of RD-coordinates into Geographical coordinates (Bessel)
%
%     geographical coordinates   (lat, lon) expressed in decimal degrees.
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
%     Hans Bonekamp                              converted  to Matlab  Feb 2001
%     T.J. Zitman                                  last update: 29 january 1991
% -----------------------------------------------------------------------------

%  compute linear tramsformation of RD coordinates
%  -----------------------------------------------
   urd = 0.00001.*xrd;
   vrd = 0.00001.*yrd;

%  perform conversion
%  -------------------
   vgeo = + 187762.178 ...
          + 3236.033           .*(vrd   ) ...
          - 32.592   .*(urd.^2)           ...
          - 0.247              .*(vrd.^2) ...
          - 0.850    .*(urd.^2).*(vrd   ) ...
          - 0.065              .*(vrd.^3) ...
          + 0.005    .*(urd.^4)           ...
          - 0.017    .*(urd.^2).*(vrd.^2);
   ugeo = + 19395.500 ...
          + 5261.305 .*(urd   )           ...
          + 105.979  .*(urd   ).*(vrd   ) ...
          + 2.458    .*(urd   ).*(vrd.^2) ...
          - 0.819    .*(urd.^3)           ...
          + 0.056    .*(urd   ).*(vrd.^3) ...
          - 0.056    .*(urd.^3).*(vrd   );


%  compute linear transformation into Geo-coordinates
%  --------------------------------------------------
   lon = ugeo./3600.0;
   lat = vgeo./3600.0;

%% EOF
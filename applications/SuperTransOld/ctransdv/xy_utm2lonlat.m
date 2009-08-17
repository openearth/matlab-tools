function  [lon,lat] = xy_utm2lonlat(xutm,yutm,a,e,zone)
%XY_UTM2LONLAT   Transform (x,y) coordinates in UTM system to (lon,lat)
%
%     [lon,lat] = XY_UTM2LONLAT(xutm,yutm,zone,a,e)
%
%     Only tested for Northern Hemisphere!
%
% -----------------------------------------------------------------------------
%     Conversion of UTM coordinates (x, y, zone) into geographical
%
%     geographical coordinates   (lat, lon) expressed in decimal degrees.
% -----------------------------------------------------------------------------
%     arguments:
%     xutm    in        easting (UTM)
%     yutm    in        northing (UTM)
%     zone    in        zone (UTM)
%     a       in        semi-major axis of ellipsoid
%     e       in        excentricity of ellipsoid
%     lon     out       longitude (geographical coordinate)
%     lat     out       lattitude (geographical coordinate)
% -----------------------------------------------------------------------------
%
% See also: GETELLIPSOID,LONLAT2XY_UTM,XY_UTM2LONLAT,
%                        LONLAT2XY_RD , XY_RD2LONLAT ,
%                        LONLAT2XY_PAR,XY_PAR2LONLAT
%    MFWDTRAN,MINVTRAN, (from Matlab mapping toolbox)
%    pctrans.exe (http://www.hydro.nl/pgs/en/pctrans_en.htm)

% -----------------------------------------------------------------------------
%     G.J. de Boer                               vectorized for matlab Jul 2004
%     Hans Bonekamp                               converted  to matlab Feb 2001
%     T.J. Zitman                                  last update: 5 december 1990
% -----------------------------------------------------------------------------

%  Input
%  ------------------------------------

%  initialize constants
%  -----------------------
   eps    = 1.0E-05;
   fe     = 5.0E+05;
   fn     = 1.0E+07;

   e2     = e^2;
   e4     = e2^2;
   e6     = e2*e4;
   n      = e2/(1.0-e2);
   nn     = n^2;
   f1     = 1.0 - (1.0/4.0)*e2 - (3.0/64.0)*e4 -  ( 5.0/256.0)*e6;
   f2     =       (3.0/8.0)*e2 + (3.0/32.0)*e4 + (45.0/1024.0)*e6;
   f3     =                    (15.0/256.0)*e4 + (45.0/1024.0)*e6;
   f4     =                                      (35.0/3072.0)*e6;

   for i=1:length(xutm)
 
   %  correct input for false easting and false northing
   %  --------------------------------------------------
      cxutm = (xutm(i) - fe)/0.9996;
      
      if (yutm(i)  >=  fn) 
        cyutm = (yutm(i) - fn)/0.9996;
      else
        cyutm = yutm(i)/0.9996;
      end
      
   %  first estimates of dl and fi
   %  ------------------------------
      dl     = 0.0;
      fi     = pi/6.0;
      
%     ----------------------------
      iterate=1; 
      while  iterate==1      
      
   %  Newton Raphson iteration
   %  ----------------------------
      
      %  constants, related to fi
      %  ------------------------
         s      = sin(fi);
         ss     =   s^2;
         c      = cos(fi);
         cc     =   c^2;
         cccc   = cc^2;
         sc     = s*c;
      
      %  values of sub-functions and derivatives
      %  --------------------------------------------
         r      = 1.0-e2*ss;
         rp     = a/sqrt(r);
         drpdfi = a*e2*sc/(r^1.5);
         dm     = a*(+     f1*        fi ...
                     -     f2*sin(2.0*fi) ...
                     +     f3*sin(4.0*fi) ...
                     -     f4*sin(6.0*fi) );
         ddmdfi = a*(+     f1 ...
                     - 2.0*f2*cos(2.0*fi) ...
                     + 4.0*f3*cos(4.0*fi) ...
                     - 6.0*f4*cos(6.0*fi) );
         dl2    = dl^2;
         gx     =      dl2   *(  2.0   *cc - 1.0 +     nn*cccc)/6.0;
         dgxdfi = -2.0*dl2*sc*(      nn*cc + 1.0              )/3.0;
         gy     =      dl2*   (  6.0   *cc - 1.0 + 9.0*nn*cccc)/12.0;
         dgydfi =     -dl2*sc*(- 3.0*nn*cc + 1.0              );
      
      
      %  function values x, y and derivatives
      %  -------------------------------------
         x      = rp*dl*c*(1.0+gx) - cxutm;
         dxdfi  =    dl*  ((drpdfi*c-rp*s)*(1.0+gx) + rp*c*dgxdfi );
         dxddl  = rp   *c*(1.0+3.0*gx);
         y      = dm  + rp*0.5*dl2*sc*(1.0+gy) - cyutm;
         dydfi  = ddmdfi + 0.5*dl2*( sc*(drpdfi*(1.0+gy) + rp*dgydfi) +  ...
                                  rp*(cc-ss)*(1.0+gy) );
         dyddl  = rp*dl*sc*(1.0+2.0*gy);
      
      
      %   changes in the estimates dl and fi
      %   ------------------------------------
         det    = dxddl*dydfi - dxdfi*dyddl;
         if (det  == 0.0) 
              error( 'utmgeo determinant   singular');
         end
         chanfi = -(-x*dyddl + y*dxddl)/det;
         chandl = -( x*dydfi - y*dxdfi)/det;
      
      
      %  check stopping criterion
      %  --------------------------------

         %                         NOT THIS ONE
         %                         OR  |, was AND & in Bonekamps version
         if (abs(chanfi) > abs(eps*fi) | abs(chandl) > abs(eps*dl))   
             fi   = fi + chanfi;
             dl   = dl + chandl;
             iterate=1;
         else 
             iterate=0;
         end
         
      end  %while loop
      
   %  set final values
   %  -----------------------------
      lat(i)   = fi*180.0/pi;
      lon(i)   = dl*180.0/pi + 6.0*fix(zone-1) - 177.0;
      
      
   %  transform lat from one spheroid to another
   %  --------------------------------------------
      lat(i)=(180./pi)*atan((1-e^2)*tan((pi/180.)*lat(i))/(1-e^2));

   end
   
%  Take care of missing values
%  which otherwhise get real values lat = 30, lon = 3
%  --------------------------------------------

    lat(isnan(xutm)|isnan(yutm))=nan;
    lon(isnan(xutm)|isnan(yutm))=nan;

%  Limitation
%  --------------------------------------------

   if any(lat<0)
      warning('Only tested for Northern Hemisphere!')
   end

%% EOF
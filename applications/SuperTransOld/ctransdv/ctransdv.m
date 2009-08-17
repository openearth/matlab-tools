function varargout = CTRANSDV(varargin)
%CTRANSDV   Transform (x,y) coordinates to (lon,lat) and back for UTM, PARIJS & RD
%
% [xout,yout] = ctransdv(xin,yin,'COORDIN','COORDOUT')
%
% [xout,yout] = ctransdv(xin,yin,'COORDIN','COORDOUT',scale)
%               Divides the output co-ordinate by scale
%               so xscale = 1e3 gives results in [km] rather than in [m].
%
% calculates/projects/transforms the coordinates from
% projection COORDIN to projection COORDOUT on northern hemispere
% only.
%
%  Available coordinate systems are:
%  - 'RIJKS'  Dutch Rijksdriehoek net (Amersfoortse coordinaten).
%  - 'PARIJS' Parijse coordinaten, same as Dutch Rijksdriehoek net
%             but for a uniform shift in x and y direction, so Paris
%             is at the origin. The adventage (and reson for existence) 
%             is that for the Netherlands
%             * y is always bigger than x, and that 
%             * there are no negative coordinates.
%             coordinates.
%  - 'LONLAT' Decimal geographical coortdinates (latitude,longitude)
%  - 'GEODEC' Geographical (latitude,longitude), in degrees, minutes, seconds
%             are not implemented yet.
%  - 'UTM'    Universal Transverse Mercatorm for all zones and ellipsoids
%             that mya require additional (optional) arguments:
%
% [xout,yout] = ctransdv(xin,yin,'COORDIN','COORDOUT',scale,zone)
% [xout,yout] = ctransdv(xin,yin,'COORDIN','COORDOUT',scale,zone,ellipsoid)
%
% Method: decimal geographical coortdinates are always used as intermediate variable.
%     
%  Examples:
%  [xparis,yparis ] = ctransdv(xlon,ylat,'LONLAT','PARIJS')
%  [xutm,yutm,zone] = ctransdv(xgeo,ygeo,'GEODEC','UTM')
%  [xutm,yutm,zone] = ctransdv(xgeo,ygeo,'GEODEC','UTM',[1e3 1e3])
%  [xutm,yutm,zone] = ctransdv(xgeo,ygeo,'GEODEC','UTM',[1 1],31)
%  [xutm,yutm,zone] = ctransdv(xgeo,ygeo,'GEODEC','UTM',[1 1],31,'wgs84')
%  [xutm,yutm,zone] = ctransdv(xgeo,ygeo,'GEODEC','UTM',1e3)
%
%  Ctransdv uses external functions that may also be called directly:
%
%  * GETELLIPSOID   :obtains ellipoid parameters
%  * LONLAT2XY_UTM  :conversion of geographical coordinates into UTM   coordinates
%  * LONLAT2XY_RD   :conversion of geographical coordinates into RD    coordinates
%  * LONLAT2XY_PAR  :conversion of geographical coordinates into Paris coordinates
%  * XY_RD2LONLAT   :conversion of UTM   coordinates into geographical coordinates
%  * XY_PAR2LONLAT  :conversion of RD    coordinates into geographical coordinates
%  * XY_UTM2LONLAT  :conversion of Paris coordinates into geographical coordinates
%
% See web: pctrans.exe (<a href="http://www.hydro.nl/pgs/en/pctrans_en.htm">www.hydro.nl/pgs/en/pctrans_en.htm</a>)
% See also: GETELLIPSOID,LONLAT2XY_UTM,XY_UTM2LONLAT,
%                        LONLAT2XY_RD , XY_RD2LONLAT ,
%                        LONLAT2XY_PAR,XY_PAR2LONLAT
%    MFWDTRAN,MINVTRAN, (from mapping toolbox), SuperTrans,


% -----------------------------------------------------------------------------
%  G.J. de Boer                                  vectorized for matlab Feb 2004
%  Hans Bonekamp                                   converted to matlab Feb 2001
%  D.Verploegh                          Fortran version                may 2000
%  T.J. Zitman                          Fortran version last update: 6 Dec 1990
% -----------------------------------------------------------------------------

%% Input
%% ----------------------------------------------------------------------

   coordinate_in  =  varargin{3};
   coordinate_out =  varargin{4};
   
   if ~prod(double(size(varargin{1})==size(varargin{2})))
      error('two coordinate arrays have to be same size')
   else
     datasize = size(varargin{1});
   end
   
   xyscale_out    = 1;
   zone_in        = [];
   
   if nargin > 3
      xyscale_out = 1;
   end
   if nargin > 4
      xyscale_out = varargin{5};
   end
   if nargin > 5
      xyscale_out = varargin{5};
      zone_in     = varargin{6};
   end
   
      ellipsoid.definition     = 'WGS84';
   if nargin==7
       ellipsoid.definition = varargin{7};
   end

   if length(xyscale_out)==1
      xscale_out = xyscale_out(1);
      yscale_out = xyscale_out(1);
   elseif length(xyscale_out)==2
      xscale_out = xyscale_out(1);
      yscale_out = xyscale_out(2);
   else
      error('scale should either have 1 or 2 sizes');
   end
   
% Ellipsoide
% ------------------------------------------------------------------

     [ellipsoid.a,ellipsoid.e] = getellipsoid(ellipsoid.definition);    
 
% Convert to intermediate [lon,lat]
% ------------------------------------------------------------------

      coordinate_in =upper(coordinate_in);
      switch(deblank(coordinate_in))
      case {'UTM','U'}  
          if isempty(zone_in)
             zone_in     = 0;
             disp(['warning: for UTM projections zone = ',num2str(zone_in)]);
          end
          xutm             = varargin{1}(:);
          yutm             = varargin{2}(:);
          [lon,lat]        = xy_utm2lonlat(xutm,yutm,ellipsoid.a,ellipsoid.e,zone_in);
      case  {'RIJKS','R','RD'} 
          xrd              = varargin{1}(:);
          yrd              = varargin{2}(:);
          [lon,lat]        = xy_rd2lonlat(xrd,yrd);
      case {'PARIJS','PARIS','PAR','P'}
          xpar             = varargin{1};
          ypar             = varargin{2};
          [lon,lat]        = xy_par2lonlat(xpar,ypar);
      case  {'LONLAT','L','LL'}
          lon              = varargin{1};
          lat              = varargin{2};
      case  {'GEODEC','GEO','G'}
          error('Not implemented yet')
      otherwise 
          error('Input  parameters not correct');
      end; 

% Convert [lon,lat] to output co-ordinates
% ------------------------------------------------------------------

      coordinate_out=upper(coordinate_out);
      switch(deblank(coordinate_out))
      case {'UTM','U'}  
          if isempty(zone_in)
             zone_in     = 0;
             disp(['warning: for UTM projections zone = ',num2str(zone_in)]);
          end
          [xutm,yutm,zone_out] = lonlat2xy_utm(lon,lat,ellipsoid.a, ellipsoid.e,zone_in);
          varargout{1}         = reshape(xutm./xscale_out,datasize);
          varargout{2}         = reshape(yutm./yscale_out,datasize);
          varargout{3}         = zone_out;
      case  {'RIJKS','R','RD'} 
          [xrd,yrd ]           = lonlat2xy_rd (lon,lat);
          varargout{1}         = reshape(xrd ./xscale_out,datasize);
          varargout{2}         = reshape(yrd ./yscale_out,datasize);
      case {'PARIJS','PARIS','PAR','P'}
          [xpar,ypar]          = lonlat2xy_par(lon,lat);
          varargout{1}         = reshape(xpar./xscale_out,datasize);
          varargout{2}         = reshape(ypar./yscale_out,datasize);
      case  {'LONLAT','L','LL'}
          varargout{1}         = reshape(lon ./xscale_out,datasize);
          varargout{2}         = reshape(lat ./yscale_out,datasize);
      case  {'GEODEC','GEO','G'}
          error('Not implemented yet')
      otherwise 
          error('Output  parameters not correct');
      end; 

%% EOF
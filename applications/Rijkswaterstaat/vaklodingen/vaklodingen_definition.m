function S = vaklodingen_definition(varargin)
%VAKLODINGEN_DEFINITION   definition of Rijkswaterstaat vaklodingen tiles
%
%    S = vaklodingen_definition
%
% returns meta-info of all boxes.
%
%    S = vaklodingen_definition('KBxxx_yyyy')
%
% returns meta-info on specific box, where 
% *  xxx = 109:140, the horizontal box index-name, positive eastward
% * yyyy = 5150:0504, the vertical box index-name, positive southward
%
% At www.kadaster.nl the "Bladwijzer 25000.pdf" shows the boxes on land
% from which the vaklodingen boxes are a seaward generalisaton.
% Because the kadatser makes a mess out of all sea-adjacent areas,
% the vaklodingen boxes use their own naming convention.
%
% Noe that the vaklodingen boxes have a mesh size of 20 m
% where the CORNERS are at integer multiples of 20m, in
% contrast to the data of Rijkswatersaat Zeeland, where the CENTERS
% are at multiples of 20 m, i.e. a 10 m shift.
%
% returns fields 
% * ncol, nrow,  cellsize, xllcorner, yllcorner from arc asc grid
% * BoundingBox, <X,Y> from shaperead
% * xname, yname, name and <x,y>
%
%See also: vaklodingen, nc_multibeam, snctools, arcgis, nc_cf_gridset

 OPT.debug = 1;
 OPT.epsg  = 28992;
 
%% define all kaartbladen
 
   D.ncols        = 500; % nx
   D.nrows        = 625; % ny
   D.cellsize     = 20;  % dx = dy by definition
   D.xllcorner    = -20000:D.cellsize*D.ncols:290000; %  109 -  eastward ->  140
   D.yllcorner    = 362500:D.cellsize*D.nrows:662250; % 5150 - northward -> 0504
  
  [D.xllcorner,...
   D.yllcorner]=meshgrid(D.xllcorner,D.yllcorner);
   
   D.xname        = cellstr(num2str([109:1:140]'));
   D.yname        = cellstr([num2str([51:-2:05]','%0.2d') num2str([50:-2:04]','%0.2d')]);
 
%% create all kaartbladen
 
   for ix=1:length(D.xname)
    for iy=1:length(D.yname)
     D.name{iy,ix} = ['KB' D.xname{ix} '_' D.yname{iy}];
     x0 = D.xllcorner(iy,ix);
     x1 = D.xllcorner(iy,ix) + D.cellsize*D.ncols;
     y0 = D.yllcorner(iy,ix);
     y1 = D.yllcorner(iy,ix) + D.cellsize*D.nrows;
     D.x{ix,iy}           = [x0 x1 x1 x0 x0 nan]; % nan-separated BB x
     D.y{ix,iy}           = [y0 y0 y1 y1 y0 nan]; % nan-separated BB x
     D.BoundingBox{ix,iy} = [x0 y0;x1 y1]; % see shaperead: [minX minY;maxX maxY]
    end
   end

%% select one kaartblad

   if nargin==1
      name = varargin{1};
      xxx  = name(3:5);
      yyyy = name(7:10);
   
      ix = strmatch( xxx,D.xname);
      iy = strmatch(yyyy,D.yname);
   
      S = D;

      S.name        = D.name{ix,iy};
      S.xname       = D.xname{ix};
      S.yname       = D.yname{iy};
      S.xllcorner   = D.xllcorner(ix,iy);
      S.yllcorner   = D.yllcorner(ix,iy);
      S.BoundingBox = D.BoundingBox{ix,iy};
      S             = rmfield(S,'x');
      S             = rmfield(S,'y');
      S.X           = S.xllcorner + [.5:1:S.ncols-0.5]*S.cellsize;
      S.Y           = S.yllcorner + [.5:1:S.nrows-0.5]*S.cellsize;
   else
      S=D;
   end
 
%%
 if OPT.debug
    plot(cell2mat(D.x)', cell2mat(D.y)')
    [S.lonllcorner,S.latllcorner] = convertCoordinates(S.xllcorner,S.yllcorner,'CS1.code',OPT.epsg,'CS2.code',4326);
    KMLmarker(S.latllcorner,S.lonllcorner,'name',D.name,'kmlname','vaklodingen llcorner','fileName','vaklodingenll.kml')
    [lon,lat]=convertCoordinates(cell2mat(D.x)', cell2mat(D.y)','CS1.code',OPT.epsg,'CS2.code',4326);
    KMLline(lat,lon,'kmlname','vaklodingen BB','fileName','vaklodingenBB.kml','lineColor',[ .5 .5 .5], 'lineWidth',2)
 end

%% Examples

% KB111_4544_19640101.ASC
% -----------------------
% ncols    500
% nrows    625
% xllcorner       0.00
% yllcorner  400000.00

% KB110_4746_19640101.ASC
% -----------------------
% ncols    500
% nrows    625
% xllcorner  -10000.00
% yllcorner  387500.00

% KB109_5150_19760101.ASC
% -----------------------
% ncols    500
% nrows    625
% xllcorner  -20000.00
% yllcorner  362500.00

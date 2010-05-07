function OPT = delft3d_grd2kml(grdfile,varargin)
%DELFT3D_GRD2KML   Save grid (and depth) file as kml feed for Google Earth
%
%   delft3d_grd2kml(grdfile,<keyword,value>)
%
%   Input:
%      grdfile    = filename of the grd file
%   varargin:
%       epsg      = epsg code of the grid
%       dep       = filename of the dep file
%       mdf       = name of mdf file toretrieve dpsopt
%       dpsopt    = only when mdf not specified: dpsopt in mdf file 
%                   to specify location of depth values in *.dep filee.g. 'max','mean', 'dp'
%       ddep      = depth offset
%       linecolor = color of the grid lines
%
%   Output:
%   filemask = filemask of the grd files to be processed
%
% Note: that the grid file need to be of Spherical type
%       or you must specify epsg code.
% Note: for surf you must change reversePoly if the grid cells are too 
%       dark during the day, and light during the night.
%
% Example 1:
%   delft3d_grd2kml('i:\R1501_Grootschalige_modellen\roosters\A2275_western_mediterranean_r02.grd');
%
% Example 2:
%   delft3d_grd2kml('g04.grd','epsg',28992,'dep','g04.dep','dpsopt','mean','ddep',150,'clim',[-50 0])
%
%See also: googlePlot, delft3d

% updated by Bart Grasmeijer, Alkyon Hydraulic Consultancy & Research 19 November 2009


  %grdfile         = 'lake_and_sea_5_ll.grd';
   OPT.epsg        = [];  % 28992; % 7415; % 28992; ['Amersfoort / RD New']
   OPT.ddep        = 200;  % offset
   OPT.fdep        = 10; % factor
   OPT.clim        = [-200 0];  %
   OPT.debug       = 0;
   OPT.reversePoly = true;
   OPT.colorSteps  = 62;
   OPT.lineColor   = [.5 .5 .5];
   OPT.fillAlpha   = 0.5;

   OPT.dep         = [];  %'dep_at_cor_triangulated_filled_corners.dep';
   OPT.mdf         = [];  % or dpsopt
   OPT.dpsopt      = [];  % or mdf
   
   OPT = setProperty(OPT,varargin{:});
   
   if nargin==0
      return
   end
   
   G = delft3d_io_grd('read',grdfile);
   
   if     ~strcmpi(G.CoordinateSystem,'spherical') & isempty(OPT.epsg)
      error('no latitide and longitudes given')
   elseif    strcmpi(G.CoordinateSystem,'spherical')  
       G.cor.lon = G.cor.x;
       G.cor.lat = G.cor.y;
   elseif ~strcmpi(G.CoordinateSystem,'spherical')  
      [G.cor.lon,G.cor.lat,CS]=convertCoordinates(G.cor.x,G.cor.y,'CS1.code',OPT.epsg,'CS2.code',4326);
   end

   if ~isempty(OPT.mdf)
      MDF        = delft3d_io_mdf('read',OPT.mdf);
      OPT.dpsopt = MDF.keywords.dpsopt;
   end
   
   %% check for spherical !!
   
   if ~isempty(OPT.dep)
      G = delft3d_io_dep('read',OPT.dep,G,'dpsopt',OPT.dpsopt);
   else
      G.cen.dep     = 0.*G.cen.x;
      G.cor.dep     = 0.*G.cor.x;
      OPT.fillAlpha = 0;
   end
   
   % OPT.ddep = max(abs(max(G.cen.dep(:))),0);

   if OPT.debug
       TMP = figure;
       pcolorcorcen(G.cor.lon,G.cor.lat,-G.cor.dep);
       caxis([OPT.clim]);
       colorbarwithtitle('depth [m]');
       pausedisp
       try
           close(TMP);
       end
   end
   
   KMLpcolor(G.cor.lat,G.cor.lon,-G.cen.dep,...
                   'fileName',[filename(grdfile),'_2D.kml'],...
                'reversePoly',OPT.reversePoly,...
                       'cLim',OPT.clim,...
                 'colorSteps',OPT.colorSteps,...
                    'kmlName','depth [m]',...
                  'lineColor',OPT.lineColor,...
                  'lineAlpha',.6,...
                  'lineWidth',0,... % to prevent rastering of the pixels (WHY?)
                'polyOutline',true,...
                   'polyFill',true);
   
   KMLsurf  (G.cor.lat,G.cor.lon,(-G.cor.dep+OPT.ddep)*OPT.fdep,... % at corners for z !!
                             -G.cen.dep,...
                   'fileName',[filename(grdfile),'_3D.kml'],...
                'reversePoly',OPT.reversePoly,...
                       'cLim',OPT.clim,...
                 'colorSteps',OPT.colorSteps,...
                    'kmlName','depth [m]',...
                  'lineColor',OPT.lineColor,...
                  'lineAlpha',.6,...
                'polyOutline',true,...
                  'fillAlpha',OPT.fillAlpha,...
                  'fillAlpha',.8);

%%EOF
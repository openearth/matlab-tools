function varargout = plotNet(varargin)
%plotNetkml  Plot a D-Flow FM unstructured net in Google Earth
%
%     G  = dflowfm.readNetkml(ncfile) 
%    <h> = dflowfm.plotNetkml(G     ,<keyword,value>) 
%          % or 
%    <h> = dflowfm.plotNetkml(ncfile,<keyword,value>) 
%
%   plots a D-Flow FM unstructured net (centers, corners, contours),
%   as kml file.
%
%   The following optional <keyword,value> pairs have been implemented:
%    * axis: only grid inside axis is plotted, use [] for while grid.
%            for axis to be be a polygon, supply a struct axis.x, axis.y.
%   Struct with KML properties, if [] they are not plotted.
%    * cor: a struct with KMLmarker properties for corners
%    * cen: a struct with KMLmarker properties for centers (bug still: cor overrules cen in Google Earth)
%    * peri: a struct with KMLline properties for connection line
%   Defaults values can be requested with OPT = dflowfm.plotNet().
%
%   Note: all flow cells are plotted as one NaN-separated line: fast.
%
%   See also dflowfm, delft3d

%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Gerben de Boer
%
%       <g.j.deboer@deltares.nl>
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

% TO DO: to do: plot center connectors (NetElemNode)
% TO DO: to do: plot 1D cells too

%% input

   OPT.axis = []; % [x0 x1 y0 y1] or polygon OPT.axis.x, OPT.axis.y
   % arguments to plot(x,y,OPT.keyword{:})
   OPT.fileName = [];
   OPT.cen = struct(... % KMLpatch3()
         'iconnormalState','circle-white.png',...
        'colornormalState',[0 0 1],... % blue
        'scalenormalState',.1,...
     'scalehighlightState',0); % no mouse-over
   OPT.cor  = struct(... % KMLpatch3()
         'iconnormalState','circle-white.png',...
        'colornormalState',[1 1 0],... % yellow
        'scalenormalState',.1,...
     'scalehighlightState',0); % no mouse-over
   OPT.peri = struct('lineWidth',1); % KMLline
   OPT.epsg = 28992;
   
   if nargin==0
      varargout = {OPT};
      return
   else
      if ischar(varargin{1})
      ncfile   = varargin{1};
      G        = dflowfm.readNet(ncfile);
      else
      G        = varargin{1};
      ncfile   = G.file.name;
      end
      OPT = setProperty(OPT,varargin{2:end});
   end

   if isnumeric(OPT.axis) & ~isempty(OPT.axis) % axis vector 2 polygon
   tmp        = OPT.axis;
   OPT.axis.x = tmp([1 2 2 1]);
   OPT.axis.y = tmp([3 3 4 4]);clear tmp
   end
   
   sourceFiles = {};

%% plot corners ([= nodes)

   if isfield(G,'cor') & ~isempty(OPT.cor)
   
     % TO DO check whether x and y are not already spherical 
    [cor.lon,cor.lat] = convertCoordinates(G.cor.x,G.cor.y,'CS1.code',OPT.epsg,'CS2.code',4326);
   
     if isempty(OPT.axis)
        cor.mask = 1:G.cor.n;
     else
        cor.mask = inpolygon(G.cor.x,G.cor.y,OPT.axis.x,OPT.axis.y);
     end
     
     sourceFiles{end+1} = [tempname(fileparts(ncfile)),'_cor.kml'];
     OPT.cor.fileName = sourceFiles{end};
     KMLmarker(cor.lat(cor.mask),cor.lon(cor.mask),OPT.cor);

   end

%% plot centres (= flow cells = circumcenters)

   if (isfield(G,'cen')  & ~isempty(OPT.cen) ) | ...
      (isfield(G,'peri') & ~isempty(OPT.peri))
   
     % TO DO check whether x and y are not already spherical 
    [cen.lon,cen.lat] = convertCoordinates(G.cen.x,G.cen.y,'CS1.code',OPT.epsg,'CS2.code',4326);
     if isempty(OPT.axis)
        cen.mask = 1:G.cen.n;
     else
        cen.mask = inpolygon(G.cen.x,G.cen.y,OPT.axis.x,OPT.axis.y);
     end
     
    %cen.mask = cen.mask(1:1e4);
     
   end
   
   if isfield(G,'cen') & ~isempty(OPT.cen)
       
     sourceFiles{end+1} = [tempname(fileparts(ncfile)),'_cen.kml'];
     OPT.cen.fileName = sourceFiles{end};
     KMLmarker(cen.lat(cen.mask),cen.lon(cen.mask),OPT.cen);
   
   end

%% plot perimeters (= contours = flow cell faces)
%  plot contour of all circumcenters inside axis 
%  Always plot entire perimeter, so perimeter is partly 
%  outside axis for boundary flow cells. 
%  We turn all contours into a nan-separated polygon. 
%  After plotting this is faster than patches (only one figure child handle).

   if isfield(G,'peri') & ~isempty(OPT.peri)
       
     peri.mask1 = find(cen.mask(G.cen.LinkType(cen.mask)==1));
     peri.mask  = find(cen.mask(G.cen.LinkType(cen.mask)~=1)); % i.e. 0=closed or 2=between 2D elements
     
     if ~iscell(G.peri.x) % can also be done in readNet
       [x,y] = dflowfm.peri2cell(G.peri.x(:,peri.mask),G.peri.y(:,peri.mask));
        x    = poly_join(x);
        y    = poly_join(y);
     else
        x    = poly_join({G.peri.x{peri.mask}});
        y    = poly_join({G.peri.y{peri.mask}});
     end
     
    % TO DO check whether x and y are not already spherical 
    [cor.lon,cor.lat] = convertCoordinates(x,y,'CS1.code',OPT.epsg,'CS2.code',4326);
     
     sourceFiles{end+1} = [tempname(fileparts(ncfile)),'_peri.kml'];
     OPT.peri.fileName = sourceFiles{end};
     disp('plotting KMLline segments, please wait ...')
     h = KMLline(cor.lat,cor.lon,OPT.peri);   
   
   end
   
   KMLmerge_files('fileName',OPT.fileName,'sourceFiles',sourceFiles,'deleteSourceFiles',0)

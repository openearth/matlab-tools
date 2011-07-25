function varargout = KMLcylinder(lat,lon,z,c,varargin)
%KMLcylinder   draw a 3D cylinder at a specific location
%
%   KMLcylinder(lat,lon,z,c,R,<keyword,value>)
%
%    lat,lon must be cells with one double each
%    z must be a cell with top and bottom coordinates of the layers (length(c)+1
%    c must be a cell with values that are colors of the layers     (length(z)-1)
%
% Saves layer as nested columns of decreasing radius, each extrudes to the Earth surface.
% All segments are extruded to ground level, floating columns are not possible,
% use KMLcylinder for floating objects (slower in Google Earth though).
%
%  example:
%
%    KMLcylinder({51.9859},{4.3815},{[0 1 2 4 8 16 32]},{[1 2 3 4 5 6]},5e3,'fileName','KMLcylinder_test.kml')
%
% See also: googlePlot, KMLcylinder

%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares for Building with Nature
%       Gerben J. de Boer
%
%       gerben.deboer@Deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% process varargin

   % deal with colorbar options first
   OPT                    = KMLcolorbar();
   OPT                    = mergestructs(OPT,KML_header());
   % rest of the options
   OPT.nTH                = 12; % number of facets on side of cylinder
   OPT.R                  = 1000; % radius in m
   OPT.dR                 = 10; % reduction of Radius per layer
   OPT.epsg               = 23031;
   
   OPT.fileName           = '';
   OPT.kmlName            = '';
   OPT.name               = '';
   OPT.lineWidth          = 1;
   OPT.lineColor          = [0 0 0];
   OPT.lineAlpha          = 1;
OPT.colorMap           = @(z) jet(z);
OPT.colorSteps         = 32;
   OPT.fillAlpha          = 1;
   OPT.polyOutline        = false; % outlines the polygon, including extruded edges
   OPT.polyFill           = true;
   OPT.openInGE           = false;
   OPT.reversePoly        = [];

OPT.cLim               = [];
   OPT.zScaleFun          = @(z) 1000*z;
   OPT.timeIn             = [];
   OPT.timeOut            = [];
   OPT.dateStrStyle       = 'yyyy-mm-ddTHH:MM:SS';
OPT.colorbar           = 0;
      OPT.fillColor          = [];

   OPT.precision          = 8;
   OPT.tessellate         = false;
   OPT.lineOutline        = true; % draws a separate line element around the polygon. Outlines the polygon, excluding extruded edge

   if nargin==0
      varargout = {OPT};
      return
   end

   [OPT, Set, Default] = setproperty(OPT, varargin{:});
   
%% limited error check

    if ~isequal(size(lat),size(lon),size(c),size(z))
        error('lat and lon must be same size')
    end
    
%% get filename, gui for filename, if not set yet

   if isempty(OPT.fileName)
      [fileName, filePath] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as',[mfilename,'.kml']);
      OPT.fileName = fullfile(filePath,fileName);
   end

%% set kmlName if it is not set yet

   if isempty(OPT.kmlName)
      [ignore OPT.kmlName] = fileparts(OPT.fileName);
   end
   
%% pre-process color data

   if isempty(OPT.cLim)
      OPT.cLim         = [min(cell2mat(c)) max(cell2mat(c))];
   end

   for i=1:length(c)
   if   ~isempty(OPT.fillColor) &  isempty(OPT.colorMap) & OPT.colorSteps==1
       colorRGB = OPT.fillColor;
       c{i}        = 1;
   elseif  isempty(OPT.fillColor) & ~isempty(OPT.colorMap)
   
       colorRGB = OPT.colorMap(OPT.colorSteps);
      
       % clip c to min and max 
      
       c{i}(c{i}<OPT.cLim(1)) = OPT.cLim(1);
       c{i}(c{i}>OPT.cLim(2)) = OPT.cLim(2);
      
       %  convert color values into colorRGB index values
      
       c{i} = round(((c{i}-OPT.cLim(1))/(OPT.cLim(2)-OPT.cLim(1)+eps)*(OPT.colorSteps-1))+1);
    else
       
       error('fillColor and colorMap cannot be used simultaneously')
      
   end
   end   

%% start KML

   OPT.fid=fopen(OPT.fileName,'w');

   OPT_header = struct(...
       'name',OPT.kmlName,...
       'open',0);
   output = KML_header(OPT_header);

   if OPT.colorbar
      clrbarstring = KMLcolorbar(OPT);
      output = [output clrbarstring];
   end

%% STYLE
   OPT_stylePoly = struct(...
       'name'       ,['style' num2str(1)],...
       'fillColor'  ,colorRGB(1,:),...
       'lineColor'  ,OPT.lineColor,...
       'lineAlpha'  ,OPT.lineAlpha,...
       'lineWidth'  ,OPT.lineWidth,...
       'fillAlpha'  ,OPT.fillAlpha,...
       'polyFill'   ,OPT.polyFill,...
       'polyOutline',OPT.polyOutline); 
   for ii = 1:OPT.colorSteps
       OPT_stylePoly.name = ['style' num2str(ii)];
       OPT_stylePoly.fillColor = colorRGB(ii,:);
       output = [output KML_stylePoly(OPT_stylePoly)];
   end

   % print and clear output
   
   output = [output '<!--############################-->' fprinteol];
   fprintf(OPT.fid,output);output = '';

%% POLYGON

   OPT_poly = struct(...
            'name',OPT.name,...
       'styleName',['style' num2str(1)],...
          'timeIn',datestr(OPT.timeIn ,OPT.dateStrStyle),...
         'timeOut',datestr(OPT.timeOut,OPT.dateStrStyle),...
      'visibility',1,...
         'extrude',true,...
      'tessellate',OPT.tessellate,...
      'precision' ,OPT.precision);

%% preproess cylinder perimeter

   TH0     = linspace(0,2*pi,OPT.nTH+1); % nTH is number of faces = non-overllaping edges (first=last)

   for i=1:length(lon) % cycle cylinders
   
       if mod(i,10)==0
       disp([mfilename,': processing ',num2str(i),'/',num2str(length(lon))])
       end
       
       % preallocate output

       output = repmat(char(1),1,1e5);
       kk = 1;

   %% calculate projected cylinder layer 'in place'
       
       % TO DO: move outside loop?
       [x,y] = convertCoordinates(lon{i}(1),lat{i}(1),'persistent','CS1.code',4326,'CS2.code',OPT.epsg);% local center of circle
       
   %% loop cylinder layers

        lat1 = repmat(nan,[OPT.nTH+1,length(c{i})]);
        lon1 = repmat(nan,[OPT.nTH+1,length(c{i})]);
        dx   = repmat(nan,[OPT.nTH+1,length(c{i})]);
        dy   = repmat(nan,[OPT.nTH+1,length(c{i})]);
        X    = repmat(  x,[OPT.nTH+1,length(c{i})]);
        Y    = repmat(  y,[OPT.nTH+1,length(c{i})]);
        
        for ii=length(c{i}):-1:1 % cycle layers
          [TH, R] = meshgrid(TH0,OPT.R - (ii-1).*OPT.dR);
          [dx(:,ii),dy(:,ii)] = pol2cart(TH,R);
        end

       [lon1,lat1] = convertCoordinates(X+dx,Y+dy,'persistent','CS1.code',OPT.epsg,'CS2.code',4326);% spherical perimeter of circle
       
        if ~(z{i}(1)==0)
           disp('warning: KMLcolumn: column extended down to earth')
           % TO DO: add black segment below
        end

        for ii=length(c{i}):-1:1 % cycle layers

           OPT_poly.styleName = sprintf('style%d',c{i}(ii));

           %% draw cap
           newOutput = KML_poly(lat1(:,ii),lon1(:,ii),OPT.zScaleFun(lon1(:,ii).*0+z{i}(ii+1)),OPT_poly); % make sure that LAT(:),LON(:), Z(:) have correct dimension nx1
           output(kk:kk+length(newOutput)-1) = newOutput;
           kk = kk+length(newOutput);

        end
        fprintf(OPT.fid,output(1:kk-1)); % print output
        output = '';
   end
   
%% close KML

   output = KML_footer;
   fprintf(OPT.fid,output);
   fclose(OPT.fid);

%% compress to kmz?

   if strcmpi  ( OPT.fileName(end-2:end),'kmz')
       movefile( OPT.fileName,[OPT.fileName(1:end-3) 'kml'])
       zip     ( OPT.fileName,[OPT.fileName(1:end-3) 'kml']);
       movefile([OPT.fileName '.zip'],OPT.fileName)
       delete  ([OPT.fileName(1:end-3) 'kml'])
   end

%% openInGoogle?

   if OPT.openInGE
       system(OPT.fileName);
   end
   
   varargout = {};

%% EOF

function [OPT, Set, Default] = KMLfig2png(h,varargin)
% KMLFIG2PNG   makes a tiled png figure for google earth
%
%   h = surf(lon,lat,z)
%   KMLfig2png(h,<keyword,value>) 
%
% make a surf or pcolor in lon/lat/z, and then pass it to KMLfig2png
%
% For the <keyword,value> pairs and their defaults call
%
%    OPT = KMLfig2png()
%
% where Lod = Level of Detail.
%
% For plots with    light effects set:  'scaleHeight',true ,...
% For plots without light effects set:  'scaleHeight',false,...
%
% Note that the set generated this way works only locally.
% To make it also work on a server use
% KMLMERGE_FILES to merge all kml files into one big kml
% and insert absolute url's before every kml filename
%
% See also: GOOGLEPLOT, PCOLOR, KMLFIG2PNG_ALPHA

warning('deprecated, use KMLfig2pngNew instead')

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Thijs Damsma
%
%       Thijs.Damsma@deltares.nl
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

%% process varargin

OPT.fileName        =     [];
OPT.kmlName         =     []; % name in Google Earth Place list
OPT.url             =     ''; % webserver storaga needs absolute paths, local files can have relative paths. Only needed in mother KML.
OPT.alpha           =      1;
OPT.dim             =    256; % tile size
OPT.dimExt          =     16; % render tiles expanded by n pixels, to remove edge effects
OPT.minLod          =     []; % minimum level of detail to keep a tile in view. Is calculated when left blank.
OPT.minLod0         =     -1; % minimum level of detail to keep most detailed tile in view. Default is -1 (don't hide when zoomed in a lot)
OPT.maxLod          =     [];
OPT.maxLod0         =     -1;
OPT.latSubDivisions =      2; % must be integer. Number of divisions for further zoomlevels
OPT.lonSubDivisions =      2;
OPT.levels          = [-2 2]; % steps to zoom out and zoom in. For levels [-aa bb],
                              % the number of tiles created is aa+(4/3*4^bb)-1/3.
OPT.ha              =    gca; % handle to axes
OPT.hf              =    gcf; % handle to figure
OPT.timeIn          =     []; % time properties
OPT.timeOut         =     [];
OPT.drawOrder       =     10; 
OPT.bgcolor         = [100 155 100];  % background color to be made transparent
OPT.description     =     ''; 
OPT.light.az        =   -180; % default light azimuth
OPT.light.dist      =     60; % default light distance
OPT.scaleHeight     =   true; % rescale height for zoomlevels. 
OPT.scaleableLight  =  false; % adds a light that can be scaled (do not add additional lights)
OPT.colorbar        =      1;
OPT.colorTitle      =   '';
OPT.colorTick       =   [];
OPT.colorTickLabel  =   '';
OPT.cropping        =   true; % crops data off of the figure when zooming in, to make it render faster
OPT.CBtemplateHor        = 'KML_colorbar_template_horizontal.png';
OPT.CBtemplateVer        = 'KML_colorbar_template_vertical.png';

if nargin==0
  return
end

OPT.h               =      h; % handle to input figure

[OPT, Set, Default] = setproperty(OPT, varargin);

%% set maxLod and minLod defaults

   if isempty(OPT.minLod),                 OPT.minLod =   OPT.dim/1.5; end
   if isempty(OPT.maxLod)&&OPT.alpha  < 1, OPT.maxLod = 2*OPT.dim/1.5; end % you see 1 layers always
   if isempty(OPT.maxLod)&&OPT.alpha == 1, OPT.maxLod = 4*OPT.dim/1.5; end % you see 2 layers, except when fully zoomed in

%% filename
% gui for filename, if not set yet

   if isempty(OPT.fileName)
       [OPT.Name, OPT.Path] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as','renderedPNG.kml');
       OPT.fileName = fullfile(OPT.Path,OPT.Name);
   else
       [OPT.Path OPT.Name] = fileparts(OPT.fileName);
   end

%% set kmlName if it is not set yet

   [OPT.Path OPT.Name] = fileparts(OPT.fileName);
   if isempty(OPT.kmlName)
       OPT.kmlName = OPT.Name;
   end

%% make a folder for the sub files

   if ~isempty(OPT.Path)
       mkdir(OPT.Path,OPT.Name)
   end

%% prepare figure

   axis off;axis tight;view(0,90);
   bgcolor = OPT.bgcolor;
   set(OPT.ha,'Position',[0 0 1 1])

%% get bounding coordinates

   c.NS =get(OPT.ha,'YLim');
   c.WE =get(OPT.ha,'XLim');
   c.N = max(c.NS); c.S = min(c.NS);
   c.W = min(c.WE); c.E = max(c.WE);

%% store original size data for height deformations

   OPT.c0 = c;

%

% set light 

   if OPT.scaleableLight
      OPT.light.h = lightangle(OPT.light.az,OPT.light.dist);
   end

%% get data from figure

   G.lon = get(h,'XData');
   G.lat = get(h,'YData');
   G.z   = get(h,'ZData');

%% preproces timespan
%  http://code.google.com/apis/kml/documentation/kmlreference.html#timespan

   if  ~isempty(OPT.timeIn)
       if ~isempty(OPT.timeOut)
           OPT.timeSpan = sprintf([...
               '<TimeSpan>\n'...
               '<begin>%s</begin>\n'... % OPT.timeIn
               '<end>%s</end>\n'...     % OPT.timeOut
               '</TimeSpan>\n'],...
               datestr(OPT.timeIn,'yyyy-mm-ddTHH:MM:SS'),...
               datestr(OPT.timeOut,'yyyy-mm-ddTHH:MM:SS'));
       else
           OPT.timeSpan = sprintf([...
               '<TimeStamp>\n'...
               '<when>%s</when>\n'...   % OPT.timeIn
               '</TimeStamp>\n'],...
               datestr(OPT.timeIn,'yyyy-mm-ddTHH:MM:SS'));
       end
   else
       OPT.timeSpan ='';
   end

%% do the magic

   kml_id = 0;
   level = OPT.levels(1);
   if OPT.levels(1) == OPT.levels(2),OPT.maxLod = OPT.maxLod0;else OPT.maxLod = OPT.maxLod; end
   
   [succes, kml_id] = KML_region_png(level,G,c,kml_id,OPT);

%% make the 'mother' kml content

if succes

   if ~isempty(OPT.url)
      if ~strcmpi(OPT.url(end),'/');
      OPT.url = [OPT.url '\'];
      end
   end

   output = sprintf([...
       '<NetworkLink>'...
       '<name>%s</name>'...                                                                                             % name
       '%s'...                                                                                                          % time
       '<Region>\n'...
       '<Lod><minLodPixels>%d</minLodPixels><maxLodPixels>%d</maxLodPixels></Lod>\n'...                                 % minLod,maxLod
       '<LatLonAltBox><north>%3.8f</north><south>%3.8f</south><west>%3.8f</west><east>%3.8f</east></LatLonAltBox>\n' ...% N,S,W,E
       '</Region>\n'...
       '<Link><href>%s</href><viewRefreshMode>onRegion</viewRefreshMode></Link>'...                                     % link
       '</NetworkLink>'],...
       OPT.kmlName,...
       OPT.timeSpan,...
       -1,-1,...
       c.N,c.S,c.W,c.E,...
       fullfile(OPT.url, OPT.Path, OPT.Name, '00001.kml'));

   %% and write the KML

   OPT.fid=fopen(OPT.fileName,'w');
   OPT_header = struct(...
              'name',OPT.kmlName,...
              'open',0,...
       'description',OPT.description);

   output = [KML_header(OPT_header) output];
   
   % COLORBAR   
   
   if OPT.colorbar
      clrbarstring = KMLcolorbar('CBcLim',clim,'CBfileName',OPT.fileName,'CBcolorMap',colormap,...
          'CBcolorTitle',OPT.colorTitle,'CBcolorTick',OPT.colorTick,'CBcolorTickLabel',OPT.colorTickLabel,...
          'CBtemplateVer',OPT.CBtemplateVer,'CBtemplateHor',OPT.CBtemplateHor);
      output = [output clrbarstring];
   end   

   % FOOTER
   
   output = [output KML_footer];
   fprintf(OPT.fid,'%s',output);

   % close KML
   
   fclose(OPT.fid);
   disp(['KMLfig2png completed succesfully - ' num2str(kml_id) ' parts created'])
else
   rmdir(fullfile(OPT.Path,OPT.Name,[]))
   disp(['KMLfig2png failed                - ' num2str(kml_id) ' parts created'])
end




function KMLfig2pngNew (h,lat,lon,z,varargin)
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

D.lat = lat;
D.lon = lon;
D.z   = z;
D.N   = max(D.lat(:));
D.S   = min(D.lat(:));
D.W   = min(D.lon(:));
D.E   = max(D.lon(:));

OPT.basecode          = KML_fig2pngNew_SmallestTileThatContainsAllData(D);
OPT.ha                =    gca; % handle to axes
OPT.hf                =    gcf; % handle to figure
OPT.dim               =    256; % tile size
OPT.dimExt            =      8; % render tiles expanded by n pixels, to remove edge effects
OPT.bgcolor           = [100 155 100];  % background color to be made transparent
OPT.alpha             = 1;
OPT.highestLevel      = length(OPT.basecode);
OPT.lowestLevel       = OPT.highestLevel+4;
OPT.fileName          =     [];
OPT.kmlName           =     []; % name in Google Earth Place list
OPT.url               =     ''; % webserver storaga needs absolute paths, local files can have relative paths. Only needed in mother KML.
OPT.alpha             =      1;
OPT.dim               =    256; % tile size
OPT.dimExt            =     16; % render tiles expanded by n pixels, to remove edge effects
OPT.minLod            =     []; % minimum level of detail to keep a tile in view. Is calculated when left blank.
OPT.minLod0           =     -1; % minimum level of detail to keep most detailed tile in view. Default is -1 (don't hide when zoomed in a lot)
OPT.maxLod            =     [];
OPT.maxLod0           =     -1;
OPT.dWE               =    0.2*360/2^OPT.lowestLevel; % determines how much extra data to tiles to be able 
OPT.dNS               =    0.2*360/2^OPT.lowestLevel; % to generate them as fraction of size of smalles tile
OPT.ha                =    gca; % handle to axes
OPT.hf                =    gcf; % handle to figure
OPT.timeIn            =     []; % time properties
OPT.timeOut           =     [];
OPT.drawOrder         =      1; 
OPT.bgcolor           = [100 155 100];  % background color to be made transparent
OPT.description       =     ''; 
OPT.colorbar          =   true;
OPT.mergeExistingTiles = false;

if nargin==0
  return
end

OPT.h               =      h;  % handle to input figure
clear lat lon z h;    % take out the garbage

[OPT, Set, Default] = setProperty(OPT, varargin);

%% 
if OPT.lowestLevel <= OPT.highestLevel 
    error('OPT.lowestLevel <= OPT.highestLevel')
end


%% set maxLod and minLod defaults

if isempty(OPT.minLod),                 OPT.minLod = round(  OPT.dim/1.5); end
if isempty(OPT.maxLod)&&OPT.alpha  < 1, OPT.maxLod = round(2*OPT.dim/1.5); end % you see 1 layers always
if isempty(OPT.maxLod)&&OPT.alpha == 1, OPT.maxLod = round(4*OPT.dim/1.5); end % you see 2 layers, except when fully zoomed in

%% filename
% gui for filename, if not set yet
if isempty(OPT.fileName)
    [OPT.Name, OPT.Path] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as','renderedPNG.kml');
    OPT.fileName = fullfile(OPT.Path,OPT.Name);
else
    [OPT.Path OPT.Name] = fileparts(OPT.fileName);
end

if isempty(OPT.Path)
    OPT.Path = pwd;
end
% OPT.fileName = fullfile(OPT.Path,OPT.Name);

% set kmlName if it is not set yet
[ignore OPT.Name] = fileparts(OPT.fileName);
if isempty(OPT.kmlName)
    OPT.kmlName = OPT.Name;
end

% make a folder for the sub files
if ~exist([OPT.Path filesep OPT.Name],'dir')
    mkdir(OPT.Path,OPT.Name)
end

%% preproces timespan
%  http://code.google.com/apis/kml/documentation/kmlreference.html#timespan

if  ~isempty(OPT.timeIn)
    if ~isempty(OPT.timeOut)
        OPT.timeSpan = sprintf([...
            '<TimeSpan>\n'...
            '<begin>%s</begin>\n'...OPT.timeIn
            '<end>%s</end>\n'...OPT.timeOut
            '</TimeSpan>\n'],...
            datestr(OPT.timeIn,'yyyy-mm-ddTHH:MM:SS'),datestr(OPT.timeOut,'yyyy-mm-ddTHH:MM:SS'));
    else
        OPT.timeSpan = sprintf([...
            '<TimeStamp>\n'...
            '<when>%s</when>\n'...OPT.timeIn
            '</TimeStamp>\n'],...
            datestr(OPT.timeIn,'yyyy-mm-ddTHH:MM:SS'));
    end
else
    OPT.timeSpan ='';
end

%% figure settings

set(OPT.ha,'Position',[0 0 1 1])
set(OPT.hf,'PaperUnits', 'inches','PaperPosition',...
    [0 0 OPT.dim+2*OPT.dimExt OPT.dim+2*OPT.dimExt],...
    'color',OPT.bgcolor/255,'InvertHardcopy','off');

%% run scripts (These are the core functions)
%   --------------------------------------------------------------------
% Generates tiles at most detailed level
KML_fig2pngNew_printTile(OPT.basecode,D,OPT)
%   --------------------------------------------------------------------
% Generates tiles other levels based on already created tiles (merging & resizing)
KML_fig2pngNew_joinTiles(OPT)
%   --------------------------------------------------------------------
% Generates KML based on png file names
KML_fig2pngNew_makeKML(OPT)
%   --------------------------------------------------------------------
%% and write the 'mother' KML
if ~isempty(OPT.url)
    if ~strcmpi(OPT.url(end),'/');
        OPT.url = [OPT.url '\'];
    end
end

output = sprintf([...
    '<NetworkLink>'...
    '<name>%s</name>'...                                                                                             % name
    '%s'... %timespan                                                                                                          % time
    '<Link><href>%s</href><viewRefreshMode>onRegion</viewRefreshMode></Link>'...                                     % link
    '</NetworkLink>'],...
    OPT.kmlName,OPT.timeSpan,...
    fullfile(OPT.url, OPT.Path, OPT.Name, [OPT.Name '_' OPT.basecode '.kml']));

OPT.fid=fopen([OPT.fileName '.kml'],'w');
OPT_header = struct(...
    'name',OPT.kmlName,...
    'open',0,...
    'description',OPT.description);

output = [KML_header(OPT_header) output];

%% COLORBAR

if OPT.colorbar
    clrbarstring = KMLcolorbar('clim',clim,'fileName', [OPT.Name filesep OPT.fileName] ,'colorMap',colormap);
    clrbarstring = strrep(clrbarstring,['<Icon><href>' OPT.fileName '_'],['<Icon><href>' OPT.Name filesep OPT.fileName '_']);
    output = [output clrbarstring];
end

%% FOOTER

output = [output KML_footer];
fprintf(OPT.fid,'%s',output);

% close KML

fclose(OPT.fid);

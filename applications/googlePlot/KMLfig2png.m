function [OPT, Set, Default] = KMLfig2png(h,varargin)
% KMLFIG2PNG makes a tiled png figure for google earth
%
% make a surf or pcolor in lon/lat/z, and then pass it to KMLfig2png
%
% Example:
%   h = surf(lon,lat,z)
%   KMLfig2png(h,varargin)
%
% See also: googlePlot

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
OPT.kmlName         =     [];
OPT.alpha           =      1;
OPT.dim             =    256;
OPT.dimExt          =     16;
OPT.minLod          =     [];
OPT.minLod0         =     -1;
OPT.maxLod          =     [];
OPT.maxLod0         =     -1;
OPT.latSubDivisions =      2;
OPT.lonSubDivisions =      2;
OPT.levels          = [-2 2];
OPT.ha              =    gca;
OPT.hf              =    gcf;
OPT.timeIn          =     [];
OPT.timeOut         =     [];
OPT.drawOrder       =     10; 
OPT.bgcolor         = [100 155 100];

if nargin==0
  return
end

[OPT, Set, Default] = setProperty(OPT, varargin);

%% set maxLod and minLod defaults

if isempty(OPT.minLod),                 OPT.minLod =   OPT.dim/1.5; end
if isempty(OPT.maxLod)&&OPT.alpha  < 1, OPT.maxLod = 2*OPT.dim/1.5; end
if isempty(OPT.maxLod)&&OPT.alpha == 1, OPT.maxLod = 4*OPT.dim/1.5; end

%% filename
% gui for filename, if not set yet
if isempty(OPT.fileName)
    [OPT.Name, OPT.Path] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as','renderedPNG.kml');
    OPT.fileName = fullfile(OPT.Path,OPT.Name);
else
    [OPT.Path OPT.Name] = fileparts(OPT.fileName);
end

% set kmlName if it is not set yet
[OPT.Path OPT.Name] = fileparts(OPT.fileName);
if isempty(OPT.kmlName)
    OPT.kmlName = OPT.Name;
end

% make a folder for the sub files
mkdir(OPT.Path,OPT.Name)

%% prepare figure
axis off;axis tight;view(0,90);
bgcolor = OPT.bgcolor;
set(OPT.ha,'Position',[0 0 1 1])

% get bounding coordinates
c.NS =get(OPT.ha,'YLim');
c.WE =get(OPT.ha,'XLim');
c.N = max(c.NS); c.S = min(c.NS);
c.W = min(c.WE); c.E = max(c.WE);

% get data from figure
G.lon = get(h,'XData');
G.lat = get(h,'YData');
G.z   = get(h,'ZData');

%% preproces timespan
if  ~isempty(OPT.timeIn)
    if ~isempty(OPT.timeOut)
        OPT.timeSpan = sprintf([...
            '<TimeSpan>\n'...
            '<begin>%s</begin>\n'...OPT.timeIn
            '<end>%s</end>\n'...OPT.timeOut
            '</TimeSpan>\n'],...
            datestr(OPT.timeIn,29),datestr(OPT.timeOut,29));
    else
        OPT.timeSpan = sprintf([...
            '<TimeStamp>\n'...
            '<when>%s</when>\n'...OPT.timeIn
            '</TimeStamp>\n'],...
            datestr(OPT.timeIn,29));
    end
else
    OPT.timeSpan ='';
end

%% do the magic
kml_id = 0;
level = OPT.levels(1);
if OPT.levels(1) == OPT.levels(2),OPT.maxLod = OPT.maxLod0;else OPT.maxLod = OPT.maxLod; end

[succes, kml_id] = KML_region_png(level,G,c,kml_id,OPT);

if succes
    %% make the 'mother' kml content
    output = sprintf([...
        '<NetworkLink>'...
        '<name>%s</name>'... name
        '%s'...time
        '<Region>\n'...
        '<Lod><minLodPixels>%d</minLodPixels><maxLodPixels>%d</maxLodPixels></Lod>\n'...minLod,maxLod
        '<LatLonAltBox><north>%3.8f</north><south>%3.8f</south><west>%3.8f</west><east>%3.8f</east></LatLonAltBox>\n' ...N,S,W,E
        '</Region>\n'...
        '<Link><href>%s</href><viewRefreshMode>onRegion</viewRefreshMode></Link>'... link
        '</NetworkLink>'],...
        OPT.kmlName,...
        OPT.timeSpan,...
        -1,-1,...
        c.N,c.S,c.W,c.E,...
        [OPT.kmlName '/00001.kml']);

    %% and write the KML
    OPT.fid=fopen(OPT.fileName,'w');
    OPT_header = struct(...
        'name',OPT.kmlName,...
        'open',0);
    output = [KML_header(OPT_header) output];
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




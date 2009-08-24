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

OPT.fileName  =  [];
OPT.kmlName   =  [];
OPT.alpha     =  .7;
OPT.levels    =   4;
OPT.dim       = 256;
OPT.dimExt    =  16;
OPT.bgcolor   = [100 155 100];
OPT.minLod    = 128;
OPT.minLod0   =  -1;
OPT.maxLod    = 256;
OPT.maxLod0   =  -1;
OPT.ha        = gca;
OPT.hf        = gcf;
OPT.timeIn    =  [];
OPT.timeOut   =  [];
OPT.drawOrder =   0; 

[OPT, Set, Default] = setProperty(OPT, varargin);

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
set(OPT.hf,'PaperUnits', 'inches','PaperPosition',[0 0 OPT.dim+2*OPT.dimExt OPT.dim+2*OPT.dimExt],'color',bgcolor/255,'InvertHardcopy','off');

% get bounding coordinates
c.NS =get(OPT.ha,'YLim');
c.WE =get(OPT.ha,'XLim');
c.N = max(c.NS); c.S = min(c.NS);
c.W = min(c.WE); c.E = max(c.WE);
c.dNS = OPT.dimExt/OPT.dim*(c.N - c.S);
c.dWE = OPT.dimExt/OPT.dim*(c.E - c.W);

% get data from figure
G.lon = get(h,'XData');
G.lat = get(h,'YData');
G.z   = get(h,'ZData');

%% do the magic
kml_id = 0;
level = 1;
if OPT.levels == 1,OPT.maxLod = OPT.maxLod0;else OPT.maxLod = OPT.maxLod; end

[succes, kml_id] = KML_region_png(level,G,c,kml_id,OPT);

if succes
    %% make the 'mother' kml content

    output = sprintf([...
        '<NetworkLink>'...
        '<name>%s</name>'... name
        '<Region>\n'...
        '<Lod><minLodPixels>%d</minLodPixels><maxLodPixels>%d</maxLodPixels></Lod>\n'...minLod,maxLod
        '<LatLonAltBox><north>%3.8f</north><south>%3.8f</south><west>%3.8f</west><east>%3.8f</east></LatLonAltBox>\n' ...N,S,W,E
        '</Region>\n'...
        '<Link><href>%s</href><viewRefreshMode>onRegion</viewRefreshMode></Link>'... link
        '</NetworkLink>'],...
        OPT.kmlName,...
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




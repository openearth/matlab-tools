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

OPT.fileName =  [];
OPT.kmlName  =  [];
OPT.alpha    =  .7;
OPT.levels   =   6;
OPT.dim      = 256;
OPT.dimExt   =  16;
OPT.bgcolor  = [100 155 100];
OPT.minLod   = 128;
OPT.minLod0  =  -1;
OPT.maxLod   = 256;
OPT.maxLod0  =  -1;
OPT.ha       = gca;
OPT.hf       = gcf;
OPT.timeIn   =  [];%to do
OPT.timeOut  =  [];%to do

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
kml_id = 1;
level = 1;

%% make the first PNG

PNGfileName = fullfile(OPT.Path,OPT.Name,sprintf('%05d.png',kml_id));
set(OPT.ha,'YLim',[c.S - c.dNS c.N + c.dNS]);
set(OPT.ha,'XLim',[c.W - c.dWE c.E + c.dWE]);
print(OPT.hf,'-dpng','-r1',PNGfileName);
im = imread(PNGfileName);
im = im(OPT.dimExt+1:OPT.dimExt+OPT.dim,OPT.dimExt+1:OPT.dimExt+OPT.dim,:);
mask = bsxfun(@eq,im,reshape(bgcolor,1,1,3));
imwrite(im,PNGfileName,'Alpha',OPT.alpha*ones(size(mask(:,:,1))).*(1-double(all(mask,3))))


%% generate the bounding box
output = sprintf([...
    '<Region>\n'...
    '<Lod><minLodPixels>%d</minLodPixels><maxLodPixels>%d</maxLodPixels></Lod>\n'...minLod,maxLod
    '<LatLonAltBox><north>%3.8f</north><south>%3.8f</south><west>%3.8f</west><east>%3.8f</east></LatLonAltBox>\n' ...N,S,W,E
    '</Region>\n'],...
    OPT.minLod0,OPT.maxLod,...
    c.N,c.S,c.W,c.E);

%% add network link for the four subdivisions (if applicable)
if level<OPT.levels
    level2  = level+1;
    kml_id2 = kml_id;
    minLod2 = OPT.minLod;
    if level2 == OPT.levels
        maxLod2 = OPT.maxLod0;
    else
        maxLod2 = OPT.maxLod;
    end
    % sub coordinates
    c.NS    = linspace(c.N,c.S,3);
    c.WE    = linspace(c.W,c.E,3);
    % there are four possible subdivisions
    for nn = 1:4
        % set bounding subbox coordinates
        [ii,jj] = ind2sub([2 2],nn);
        c2.N = c.NS(ii); c2.S = c.NS(ii+1);
        c2.W = c.WE(jj); c2.E = c.WE(jj+1);
        % and delta coordinates, used to make a plot of a larger region,
        % that will consequently be cropped. Because of a MatLab quirk
        c2.dNS = OPT.dimExt/OPT.dim*(c2.N - c2.S);
        c2.dWE = OPT.dimExt/OPT.dim*(c2.E - c2.W);
        % check if there is data
        if any(~isnan(G.z(G.lat<=c.N&G.lat>=c.S&G.lon>=c.W&G.lon<=c.E)))
            kml_id2 = kml_id2+1;     
            PNGfileName2 = fullfile(OPT.Path,OPT.Name,sprintf('%05d.png',kml_id2));
            % make png
            set(OPT.ha,'YLim',[c2.S - c2.dNS c2.N + c2.dNS]);
            set(OPT.ha,'XLim',[c2.W - c2.dWE c2.E + c2.dWE]);
            print(OPT.hf,'-dpng','-r1',PNGfileName2);
            im = imread(PNGfileName2);
            im = im(OPT.dimExt+1:OPT.dimExt+OPT.dim,OPT.dimExt+1:OPT.dimExt+OPT.dim,:);
            mask = bsxfun(@eq,im,reshape(bgcolor,1,1,3));
            imwrite(im,PNGfileName2,'Alpha',OPT.alpha*ones(size(mask(:,:,1))).*(1-double(all(mask,3))))

            % call the function to make even more subdivisions
            kml_id3 = KML_region_png(level2,G,c2,kml_id2,PNGfileName2,OPT);

            % add the network link to the newly made KML file
            output = [output sprintf([...
                '<NetworkLink>\n'...
                '<name>%05d</name>\n'...name
                '<Region>\n'...
                '<Lod><minLodPixels>%d</minLodPixels><maxLodPixels>%d</maxLodPixels></Lod>\n'...minLod,maxLod
                '<LatLonAltBox><north>%3.8f</north><south>%3.8f</south><west>%3.8f</west><east>%3.8f</east></LatLonAltBox>\n' ...N,S,W,E
                '</Region>\n'...
                '<Link><href>%s\\%05d.kml</href><viewRefreshMode>onRegion</viewRefreshMode></Link>\n'...kmlname
                '</NetworkLink>\n'],...
                kml_id2,...
                minLod2,maxLod2,...
                c2.N,c2.S,c2.W,c2.E,...
                OPT.Name,kml_id2)];
            kml_id2 = kml_id3;
        end
    end
end

% add png to kml
output = [output sprintf([...
    '<GroundOverlay>\n'...
    '<name>%05d</name>\n'...file_name
    '<Icon><href>%s</href></Icon>\n'...%file_link
    '<LatLonAltBox><north>%3.8f</north><south>%3.8f</south><west>%3.8f</west><east>%3.8f</east></LatLonAltBox>\n' ...N,S,W,E
    '</GroundOverlay>'],...
    kml_id,...
    PNGfileName,...
    c.N,c.S,c.W,c.E)];

%% write the KML
OPT.fid=fopen(OPT.fileName,'w');
OPT_header = struct(...
    'name',sprintf('%05d.png',kml_id),...
    'open',0);
output = [KML_header(OPT_header) output];
% FOOTER
output = [output KML_footer];
fprintf(OPT.fid,'%s',output);
% close KML
fclose(OPT.fid);





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
OPT.levels   =   1;
OPT.dim      = 256;
OPT.dimExt   =  16;
OPT.bgcolor  = [100 155 100];
OPT.minLod   = 128;
OPT.minLod0  =  32;
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
c.NS0 =get(OPT.ha,'YLim');
c.WE0 =get(OPT.ha,'XLim');
c.R0 = 0;

% get data from figur
G.lon = get(h,'XData');
G.lat = get(h,'YData');
G.z   = get(h,'ZData');

%% do the magic
output = [];
for level = 0:OPT.levels-1
    % find bounding of subboxes
    c.NS = linspace(c.NS0(2),c.NS0(1),2^level+1);
    c.WE = linspace(c.WE0(1),c.WE0(2),2^level+1);
    output = [output sprintf([...
        '<Folder>'...
        '<name>level - %d</name>\n'],...level
        level)];
    
    % set level of detail
    if level==0,minLod = OPT.minLod0;
    else minLod = OPT.minLod; end
    if level==OPT.levels-1,maxLod = OPT.maxLod0;
    else maxLod = OPT.maxLod; end

    for nn = 1:4^level;
        % set bounding subbox
        [ii,jj] = ind2sub([2^level; 2^level],nn);
        c.N = c.NS(ii); c.S = c.NS(ii+1);
        c.W = c.WE(jj); c.E = c.WE(jj+1);
        c.dNS = OPT.dimExt/OPT.dim*(c.N - c.S);
        c.dWE = OPT.dimExt/OPT.dim*(c.E - c.W);
        
        % check if there is data
        if any(~isnan(G.z(G.lat<=c.N&G.lat>=c.S&G.lon>=c.W&G.lon<=c.E)))
            PNGName = sprintf('level %01d - nn %05d.png',level,nn);
            fileName = fullfile(OPT.Path,OPT.Name,PNGName);
            % make png
            set(OPT.ha,'YLim',[c.S - c.dNS c.N + c.dNS]);
            set(OPT.ha,'XLim',[c.W - c.dWE c.E + c.dWE]);
            print(OPT.hf,'-dpng','-r1',fileName);
            im = imread(fileName);
            im = im(OPT.dimExt+1:OPT.dimExt+OPT.dim,OPT.dimExt+1:OPT.dimExt+OPT.dim,:);
            mask = bsxfun(@eq,im,reshape(bgcolor,1,1,3));
            
            imwrite(im,fileName,'Alpha',OPT.alpha*ones(size(mask(:,:,1))).*(1-double(all(mask,3))))

            % write a bit of kml
            output = [output sprintf([...
                '<Folder>\n'...
                '<name>%d</name>\n',...level
                '<Region>\n'...
                '<LatLonAltBox>\n'...
                '<north>%3.8f</north><south>%3.8f</south>\n'...N,S
                '<west>%3.8f</west><east>%3.8f</east>\n'...W,E
                '<rotation>%3.3f</rotation>\n'...R
                '</LatLonAltBox>\n'...
                '<Lod>\n'...
                '<minLodPixels>%d</minLodPixels>\n'...minLod
                '<maxLodPixels>%d</maxLodPixels>\n'...maxLod
                '</Lod>\n'...
                '</Region>\n'...
                '<GroundOverlay>\n'...
                '<name>%s</name>\n'...file_name
                '<Icon><href>%s</href></Icon>\n'...%file_link
                '<LatLonBox>\n'...
                '<north>%3.8f</north><south>%3.8f</south>\n'...N,S
                '<west>%3.8f</west><east>%3.8f</east>\n'...W,E
                '<rotation>%3.3f</rotation>\n'...R
                '</LatLonBox>\n'...
                '</GroundOverlay>\n'...
                '</Folder>\n'],...
                nn,...      
                c.N,c.S,c.W,c.E,c.R0,...
                minLod,maxLod,...
                PNGName,[OPT.Name '\\' PNGName],...
                c.N,c.S,c.W,c.E,c.R0)];
        end
    end
    output = [output '</Folder>'];
end

%% write the KML
OPT.fid=fopen(OPT.fileName,'w');
OPT_header = struct(...
    'name','png',...
    'open',0);
output = [KML_header(OPT_header) output];
% FOOTER
output = [output KML_footer];
fprintf(OPT.fid,output);
% close KML
fclose(OPT.fid);
function [OPT, Set, Default] = KMLtrisurf(tri,lat,lon,z,varargin)
% KMLTRISURF   Just like trisurf
%
% see the keyword/vaule pair defaults for additional options
%
% use in combination with delaunay_simplified to make simple grids
% that google can easily display 
%
% See also: delaunay_simplified, KMLline, KMLline3, KMLpatch, KMLpcolor, KMLquiver, KMLsurf

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

%% error check
if all(isnan(z(:)))
    disp('warning: No surface could be constructed, because there was no valid height data provided...') %#ok<WNTAG>
    return
end
%% assign c if it is given
if ~isempty(varargin)
    if ~ischar(varargin{1});
        c = varargin{1};
        varargin = varargin(2:length(varargin));
    else
        c =  mean(z(tri),2);
    end
else
    c =  mean(z(tri),2);
end
%% process varargin
OPT.fileName = [];
OPT.kmlName = 'untitled';
OPT.lineWidth = 1;
OPT.lineColor = [0 0 0];
OPT.lineAlpha = 1;
OPT.colormap = 'jet';
OPT.colorSteps = 16;
OPT.fillAlpha = 0.6;
OPT.fileName = '';
OPT.polyOutline = 0;
OPT.polyFill = 1;
OPT.openInGE = false;
OPT.reversePoly = false;
OPT.extrude = 0;
OPT.cLim = [min(c(:)) max(c(:))];

[OPT, Set, Default] = setProperty(OPT, varargin);
%% get filename
if isempty(OPT.fileName)
    [fileName, filePath] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as','untitled.kml');
    OPT.fileName = fullfile(filePath,fileName);
end

%% pre-process data
eval(sprintf('colorRGB = %s(%d);',OPT.colormap,OPT.colorSteps));

%clip c to min and max 
c(c<OPT.cLim(1)) = OPT.cLim(1);
c(c>OPT.cLim(2)) = OPT.cLim(2);

%convert color values into colorRGB index values
c = round(((c-OPT.cLim(1))/(OPT.cLim(2)-OPT.cLim(1))*(OPT.colorSteps-1))+1);

%% start KML
OPT.fid=fopen(OPT.fileName,'w');
%% HEADER
OPT_header = struct(...
    'name',OPT.kmlName,...
    'open',0);
output = KML_header(OPT_header);
%% STYLE
OPT_stylePoly = struct(...
    'name',['style' num2str(1)],...
    'fillColor',colorRGB(1,:),...
    'lineColor',OPT.lineColor ,...
    'lineAlpha',OPT.lineAlpha,...
    'lineWidth',OPT.lineWidth,...
    'fillAlpha',OPT.fillAlpha,...
    'polyFill',OPT.polyFill,...
    'polyOutline',OPT.polyOutline); 
for ii = 1:OPT.colorSteps
    OPT_stylePoly.name = ['style' num2str(ii)];
    OPT_stylePoly.fillColor = colorRGB(ii,:);
    output = [output KML_stylePoly(OPT_stylePoly)];
end
%% print and clear output
fprintf(OPT.fid,output); 
%% POLYGON
OPT_poly = struct(...
'name','',...
'styleName',['style' num2str(1)],...
'timeIn',[],...
'timeOut',[],...
'visibility',1,...
'extrude',OPT.extrude);
% preallocate output
output = repmat(char(1),1,1e5);
kk = 1;

disp(['creating surf with ' num2str(size(tri,1)) ' elements...'])

for ii=1:size(tri,1)
    OPT_poly.styleName = sprintf('style%d',c(ii));
    %             if OPT.reversePoly
    %                 LAT = LAT(end:-1:1);
    %                 LON = LON(end:-1:1);
    %                   Z =   Z(end:-1:1);
    %             end
    newOutput = KML_poly(lat(tri(ii,[1:3 1])),lon(tri(ii,[1:3 1])),z(tri(ii,[1:3 1])),OPT_poly);
    output(kk:kk+length(newOutput)-1) = newOutput;
    kk = kk+length(newOutput);
    if kk>1e5
        %then print and reset
        fprintf(OPT.fid,output(1:kk-1));
        kk = 1;
        output = repmat(char(1),1,1e5);
    end
end
fprintf(OPT.fid,output(1:kk-1)); % print output
%% FOOTER
output = KML_footer;
 fprintf(OPT.fid,output);
%% close KML
fclose(OPT.fid);
%% compress to kmz?
if strcmpi(OPT.fileName(end),'z')
    movefile(OPT.fileName,[OPT.fileName(1:end-3) 'kml'])
    zip(OPT.fileName,[OPT.fileName(1:end-3) 'kml']);
    movefile([OPT.fileName '.zip'],OPT.fileName)
    delete([OPT.fileName(1:end-3) 'kml'])
end
%% openInGoogle?
if OPT.openInGE
    system(OPT.fileName);
end

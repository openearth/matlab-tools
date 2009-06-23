function [OPT, Set, Default] = KMLpatch(lat,lon,varargin)
% KMLLINE3 Just like patch
% 
% only works for a singe patch (filled polygon)
% see the keyword/vaule pair defaults for additional options

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
z = 'clampToGround';

OPT.fileName = [];
OPT.kmlName = 'untitled';
OPT.lineWidth = 1;
OPT.lineColor = [0 0 0];
OPT.lineAlpha = 1;
OPT.fillColor = [1 1 1];
OPT.fillAlpha = 0.3;
OPT.fileName = '';
OPT.polyOutline = 1;
OPT.polyFill = 1;
OPT.openInGE = false;
OPT.reversePoly = false;
OPT.extrude = 0;
OPT.text = '';
OPT.latText = lat(1);
OPT.lonText = lon(1);

[OPT, Set, Default] = setProperty(OPT, varargin);
%% get filename
if isempty(OPT.fileName)
    [fileName, filePath] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as','untitled.kml');
    OPT.fileName = fullfile(filePath,fileName);
end

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
    'fillColor',OPT.fillColor,...
    'lineColor',OPT.lineColor ,...
    'lineAlpha',OPT.lineAlpha,...
    'lineWidth',OPT.lineWidth,...
    'fillAlpha',OPT.fillAlpha,...
    'polyFill',OPT.polyFill,...
    'polyOutline',OPT.polyOutline); 
    output = [output KML_stylePoly(OPT_stylePoly)];

%% POLYGON
OPT_poly = struct(...
'name','',...
'styleName',['style' num2str(1)],...
'timeIn',[],...
'timeOut',[],...
'visibility',1,...
'extrude',OPT.extrude);

output = [output KML_poly(lat,lon,z,OPT_poly)];
%% text
if ~isempty(OPT.text)
    output = [output KML_text(OPT.latText,OPT.lonText,OPT.text)];
end
%% FOOTER
output = [output KML_footer];
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

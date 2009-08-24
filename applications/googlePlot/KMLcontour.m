function [OPT, Set, Default] = KMLcontour(lat,lon,z,varargin)
% KMLCONTOUR   Just like contour
%
% see the keyword/vaule pair defaults for additional options
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
% see if height is defined
OPT.levels      = 10;
OPT.fileName    = [];
OPT.kmlName     = [];
OPT.lineWidth   = 1;
OPT.lineAlpha   = 1;
OPT.openInGE    = false;
OPT.colorMap    = 'jet';
OPT.timeIn      = [];
OPT.timeOut     = [];
[OPT, Set, Default] = setProperty(OPT, varargin);

%% input check
if any((abs(lat)/90)>1)
    error('latitude out of range, must be within -90..90')
end
lon = mod(lon+180, 360)-180;

%% filename
% gui for filename, if not set yet
if isempty(OPT.fileName)
    [fileName, filePath] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as','contour.kml');
    OPT.fileName = fullfile(filePath,fileName);
end

%% find contours
coords = contours(lat,lon,z,OPT.levels);

%% pre allocate, find dimensions
max_size = 1;
jj = 1;ii = 0;
while jj<size(coords,2) 
    ii = ii+1;
    max_size = max(max_size,coords(2,jj));
    jj = jj+coords(2,jj)+1;
end
lat = nan(max_size,ii);
lon = nan(max_size,ii);
level = nan(1,ii);
%%
jj = 1;ii = 0;
while jj<size(coords,2) 
    ii = ii+1;
    height(ii) = coords(1,jj);
    lat(1:coords(2,jj),ii) = coords(1,[jj+1:jj+coords(2,jj)]); 
    lon(1:coords(2,jj),ii) = coords(2,[jj+1:jj+coords(2,jj)]); 
    jj = jj+coords(2,jj)+1;
end

level = round(10*height);
colors = jet(range(level)+1);
lineColors = colors(level-min(level)+1,:);

KMLline(lat,lon,'fileName',OPT.fileName,'lineColor',lineColors,'lineWidth',OPT.lineWidth,...
    'timeIn',OPT.timeIn,'timeOut',OPT.timeOut);

latText    = lat(1:10:end,:);
lonText    = lon(1:10:end,:);
textLevels = repmat(height,size(latText,1),1);
textLevels = textLevels(~isnan(latText));
latText    = latText(~isnan(latText));
lonText    = lonText(~isnan(lonText));
textLabels = arrayfun(@(x) sprintf('%2.1f',x),textLevels,'uni',false);

KMLtext(latText,lonText,textLabels,'fileName',[OPT.fileName(1:end-4) 'labels.kml'],...
    'timeIn',OPT.timeIn,'timeOut',OPT.timeOut);



function [OPT, Set, Default] = KMLcontour(lat,lon,z,varargin)
% KMLCONTOUR   Just like contour
%
% see the keyword/vaule pair defaults for additional options
%
% See also: googlePlot, contour

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
OPT.levels        = 10;
OPT.fileName      = [];
OPT.kmlName       = [];
OPT.lineWidth     = 1;
OPT.lineAlpha     = 1;
OPT.openInGE      = false;
OPT.colorMap      = @(m) jet(m);
OPT.colorSteps    = 32;   
OPT.timeIn        = [];
OPT.timeOut       = [];
OPT.is3D          = false;
OPT.cLim          = [];
OPT.writeLabels   = true;
OPT.labelDecimals = 1;
OPT.labelInterval = 5;
OPT.zScaleFun     = @(z) (z+0)*0;

if nargin==0
  return
end

%% check if labels are defined
if ~isempty(varargin)
    if isnumeric(varargin{1})
        c = varargin{1};
        varargin(1) = [];
        OPT.writeLabels = true;
    else
        OPT.writeLabels = false;
    end
else
    OPT.writeLabels = false;
end

%% set properties

[OPT, Set, Default] = setProperty(OPT, varargin{:});

%% input check

% correct lat and lon
if any((abs(lat)/90)>1)
    error('latitude out of range, must be within -90..90')
end
lon = mod(lon+180, 360)-180;

% color limits
if isempty(OPT.cLim)
    OPT.cLim = ([min(z(~isnan(z))) max(z(~isnan(z)))]);
end

%% filename
% gui for filename, if not set yet
if isempty(OPT.fileName)
    [fileName, filePath] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as','contour.kml');
    OPT.fileName = fullfile(filePath,fileName);
end
% set kmlName if it is not set yet
if isempty(OPT.kmlName)
    [ignore OPT.kmlName] = fileparts(OPT.fileName);
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
%% make z
z = repmat(height,size(lat,1),1);

%% make labels
if OPT.writeLabels
    latText    = lat(1:OPT.labelInterval:end,:);
    lonText    = lon(1:OPT.labelInterval:end,:);
    zText      =   z(1:OPT.labelInterval:end,:);
    zText      =   zText(~isnan(latText));
    labels     =   zText;
    latText    = latText(~isnan(latText));
    lonText    = lonText(~isnan(lonText));
    if OPT.is3D
        KMLtext(latText,lonText,labels,OPT.zScaleFun(zText),'fileName',[OPT.fileName(1:end-4) 'labels.kml'],...
            'kmlName','labels','timeIn',OPT.timeIn,'timeOut',OPT.timeOut,'labelDecimals',OPT.labelDecimals);
    else
        KMLtext(latText,lonText,labels,'fileName',[OPT.fileName(1:end-4) 'labels.kml'],...
            'kmlName','labels','timeIn',OPT.timeIn,'timeOut',OPT.timeOut,'labelDecimals',OPT.labelDecimals);
    end
end
%% draw the lines
height(height<OPT.cLim(1)) = OPT.cLim(1);
height(height>OPT.cLim(2)) = OPT.cLim(2);

level      = round((height-OPT.cLim(1))/(OPT.cLim(2)-OPT.cLim(1))*(OPT.colorSteps-1))+1;
colors     = OPT.colorMap(OPT.colorSteps);
lineColors = colors(level,:);

if OPT.is3D
    KMLline(lat,lon,OPT.zScaleFun(z),'fileName',OPT.fileName,'lineColor',lineColors,'lineWidth',OPT.lineWidth,...
        'timeIn',OPT.timeIn,'timeOut',OPT.timeOut,'fillColor',lineColors);
else
    KMLline(lat,lon,'fileName',OPT.fileName,'lineColor',lineColors,'lineWidth',OPT.lineWidth,...
        'timeIn',OPT.timeIn,'timeOut',OPT.timeOut);
end



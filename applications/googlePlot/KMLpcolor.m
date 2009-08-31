function [OPT, Set, Default] = KMLpcolor(lat,lon,c,varargin)
% KMLPCOLOR Just like pcolor
%
%    [<OPT, Set, Default>] = KMLpcolor(lat,lon,c,<keyword,value>)
% 
% If c and lat have the same dimensions, c is calculated as the mean value 
% of the surrounding gridpoints. 
%
% For the additional <keyword,value> pairs call
%
%    OPT = KMLpcolor()
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

% TO DO: patches without outlines, outline as separate polygons, to prevent course resolution lines at low angles
% KMLline(lat,lon)
% KMLline(lat',lon')

%% error check
if all(isnan(c(:)))
    disp('warning: No surface could be constructed, because there was no valid color data provided...') %#ok<WNTAG>
    return
end

%% calculate center color values
if all(size(c)==size(lat))
    c = (c(1:end-1,1:end-1)+...
         c(2:end-0,2:end-0)+...
         c(2:end-0,1:end-1)+...
         c(1:end-1,2:end-0))/4;
elseif ~all(size(c)+[1 1]==size(lat))
    error('wrong color dimension, must be equal or one less as lat/lon')
end
%% process varargin
z = 'clampToGround';

OPT.fileName    = [];
OPT.kmlName     = [];
OPT.lineWidth   = 1;
OPT.lineColor   = [0 0 0];
OPT.lineAlpha   = 1;
OPT.colorMap    = @(m) jet(m);
OPT.colorSteps  = 16;
OPT.fillAlpha   = 0.6;
OPT.fileName    = '';
OPT.polyOutline = 1;
OPT.polyFill    = 1;
OPT.openInGE    = false;
OPT.reversePoly = false;
OPT.extrude     = 0;
OPT.timeIn      = []; % can only be one value!
OPT.timeOut     = [];
OPT.cLim        = [min(c(:)) max(c(:))];

if nargin==0
    return
end

[OPT, Set, Default] = setProperty(OPT, varargin);
%% get filename
if isempty(OPT.fileName)
    [fileName, filePath] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as','untitled.kml');
    OPT.fileName = fullfile(filePath,fileName);
end
% set kmlName if it is not set yet
if isempty(OPT.kmlName)
    [ignore OPT.kmlName] = fileparts(OPT.fileName);
end
%% pre-process data
eval(sprintf('colorRGB = %s(%d);',OPT.colormap,OPT.colorSteps));

%clip c to min and max 
c(c<OPT.cLim(1)) = OPT.cLim(1);
c(c>OPT.cLim(2)) = OPT.cLim(2);

%convert color values into colorRGB index values
c = round(((c-OPT.cLim(1))/(OPT.cLim(2)-OPT.cLim(1))*(OPT.colorSteps-1))+1);

%convert time values
if ~isempty(OPT.timeIn)
   OPT.timeIn = datestr(OPT.timeIn,29); 
end
if ~isempty(OPT.timeOut)
   OPT.timeOut = datestr(OPT.timeOut,29); 
end

% correct coordinates
if any((abs(lat)/90)>1)
    error('latitude out of range, must be within -90..90')
end
lon = mod(lon+180, 360)-180;

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
    'fillAlpha',OPT.fillAlpha,...
    'polyFill',OPT.polyFill,...
    'polyOutline',0); 
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
'timeIn',OPT.timeIn,...
'timeOut',OPT.timeOut,...
'visibility',1,...
'extrude',OPT.extrude);
% preallocate output
output = repmat(char(1),1,1e6);
kk = 1;
% put nan values in lat and lon on a size -1 array
lat_nan = isnan(lat(1:end-1,1:end-1)+...
                lat(2:end-0,2:end-0)+...
                lat(2:end-0,1:end-1)+...
                lat(1:end-1,2:end-0));
lon_nan = isnan(lon(1:end-1,1:end-1)+...
                lon(2:end-0,2:end-0)+...
                lon(2:end-0,1:end-1)+...
                lon(1:end-1,2:end-0)); 
col_nan = isnan(c);
% add everything into a 'not'nan' array, of size: size(lat)-[1 1]
not_nan = ~(lat_nan|lon_nan|col_nan);         
disp(['creating pcolor with ' num2str(sum(sum(not_nan))) ' elements...'])

for ii=1:length(lat(:,1))-1
    for jj=1:length(lon(1,:))-1
        if not_nan(ii,jj)
            LAT = [lat(ii+1,jj) lat(ii+1,jj+1) lat(ii,jj+1) lat(ii,jj) lat(ii+1,jj)];
            LON = [lon(ii+1,jj) lon(ii+1,jj+1) lon(ii,jj+1) lon(ii,jj) lon(ii+1,jj)];
            OPT_poly.styleName = sprintf('style%d',c(ii,jj));
            if OPT.reversePoly
                LAT = LAT(end:-1:1);
                LON = LON(end:-1:1);
            end
            newOutput = KML_poly(LAT,LON,z,OPT_poly);
            output(kk:kk+length(newOutput)-1) = newOutput;
            kk = kk+length(newOutput);
            if kk>1e6
                %then print and reset
                fprintf(OPT.fid,output(1:kk-1));
                kk = 1;
                output = repmat(char(1),1,1e6);
            end
        end
    end
end
fprintf(OPT.fid,output(1:kk-1)); output = ''; % print and clear output
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

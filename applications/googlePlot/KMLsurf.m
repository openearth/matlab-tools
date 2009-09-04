function [OPT, Set, Default] = KMLsurf(lat,lon,z,varargin)
% KMLSURF Just like surf
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
OPT.fileName     = [];
OPT.kmlName      = [];
OPT.lineWidth    = 1;
OPT.lineColor    = [0 0 0];
OPT.lineAlpha    = 1;
OPT.colorMap     = @(m) jet(m);
OPT.colorSteps   = 16;
OPT.fillAlpha    = 0.6;
OPT.polyOutline  = false;
OPT.polyFill     = true;
OPT.openInGE     = false;
OPT.reversePoly  = false;
OPT.extrude      = false;
OPT.cLim         = [];
OPT.zScaleFun    = @(z) (z+20).*5;
OPT.timeIn        = [];
OPT.timeOut       = [];

if nargin==0
  return
end

%% assign c if it is given
if ~isempty(varargin)
    if ~ischar(varargin{1});
        c = varargin{1};
        varargin = varargin(2:length(varargin));
    else
        c = z;
    end
else
    c = z;
end

%% set properties
[OPT, Set, Default] = setProperty(OPT, varargin{:});

%% error check
if all(isnan(z(:)))
    disp('warning: No surface could be constructed, because there was no valid height data provided...') %#ok<WNTAG>
    return
end

%% calaculate center color values
if all(size(c)==size(lat))
    c = (c(1:end-1,1:end-1)+...
         c(2:end-0,2:end-0)+...
         c(2:end-0,1:end-1)+...
         c(1:end-1,2:end-0))/4;
elseif ~all(size(c)+[1 1]==size(lat))
    error('wrong color dimension, must be equal or one less as lat/lon')
end

%% get filename
if isempty(OPT.fileName)
    [fileName, filePath] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as','untitled.kml');
    OPT.fileName = fullfile(filePath,fileName);
end
% set kmlName if it is not set yet
if isempty(OPT.kmlName)
    [ignore OPT.kmlName] = fileparts(OPT.fileName);
end

%% set cLim
if isempty(OPT.cLim)
    OPT.cLim         = [min(c(:)) max(c(:))];
end

%% pre-process data

colors = OPT.colorMap(OPT.colorSteps);
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
    'fillColor',colors(1,:),...
    'lineColor',OPT.lineColor,...
    'lineAlpha',OPT.lineAlpha,...
    'lineWidth',OPT.lineWidth,...
    'fillAlpha',OPT.fillAlpha,...
    'polyFill',OPT.polyFill,...
    'polyOutline',OPT.polyOutline); 
for ii = 1:OPT.colorSteps
    OPT_stylePoly.name = ['style' num2str(ii)];
    OPT_stylePoly.fillColor = colors(ii,:);
    if strcmpi(OPT.lineColor,'fillColor')
        OPT_stylePoly.lineColor = colors(ii,:);
    end
    output = [output KML_stylePoly(OPT_stylePoly)];
end
%% print and clear output
fprintf(OPT.fid,output); 
%% POLYGON
OPT_poly = struct(...
'name','',...
'styleName',['style' num2str(1)],...
'timeIn' ,datestr(OPT.timeIn ,29),...
'timeOut',datestr(OPT.timeOut,29),...
'visibility',1,...
'extrude',OPT.extrude);

% preallocate output
output = repmat(char(1),1,1e5);
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
disp(['creating surf with ' num2str(sum(sum(not_nan))) ' elements...'])

for ii=1:length(lat(:,1))-1
    for jj=1:length(lon(1,:))-1
        if not_nan(ii,jj)
            LAT = [lat(ii+1,jj) lat(ii+1,jj+1) lat(ii,jj+1) lat(ii,jj) lat(ii+1,jj)];
            LON = [lon(ii+1,jj) lon(ii+1,jj+1) lon(ii,jj+1) lon(ii,jj) lon(ii+1,jj)];
            Z =   [  z(ii+1,jj)   z(ii+1,jj+1)   z(ii,jj+1)   z(ii,jj)   z(ii+1,jj)];
            OPT_poly.styleName = sprintf('style%d',c(ii,jj));
            if OPT.reversePoly
                LAT = LAT(end:-1:1);
                LON = LON(end:-1:1);
                  Z =   Z(end:-1:1);
            end
            newOutput = KML_poly(LAT,LON,OPT.zScaleFun(Z),OPT_poly);
            output(kk:kk+length(newOutput)-1) = newOutput;
            kk = kk+length(newOutput);
            if kk>1e5
                %then print and reset
                fprintf(OPT.fid,output(1:kk-1));
                kk = 1;
                output = repmat(char(1),1,1e5);
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

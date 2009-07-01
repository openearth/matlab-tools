function [OPT, Set, Default] = KMLquiver(lat,lon,u,v,varargin)
% KMLQUIVER Just like quiver
% 
% Arrows lengths are plotted in meters (for easy measuring of speeds in GE)
% If speeds are low compared to grid size, pre-scale u and v yourself
% see the keyword/value pair defaults for additional options
%
% Example:
%
%     [Lat Lon] = meshgrid(54:.011:54.1,4:.011:4.1);
%     u = 1000:1099;
%     v = 1000*rand(1,100);
% 
%     KMLquiver(Lat,Lon,u,v,'fileName','c:\test1.kml','arrowClose',false);
% 
%     KMLquiver(Lat,Lon,u,v,...
%         'fileName','c:\test2.kml','fillColor',[1 0 0],'fillAlpha',.6,'arrowFill',true);
%
% See also: KMLline, KMLline3, KMLpatch, KMLpcolor, KMLsurf, KMLtrisurf

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



OPT.arrowHeadAngle = 20;
OPT.arrowScale     = 1/4;
OPT.arrowClose     = true;
OPT.arrowFill      = false;
OPT.fileName       = [];
OPT.kmlName        = 'untitled';
OPT.lineWidth      = 1;
OPT.lineColor      = [0 0 0];
OPT.lineAlpha      = 1;
OPT.fillColor      = [1 0 0];
OPT.fillAlpha      = 0.3;
OPT.openInGE       = false;
OPT.reversePoly    = false;
OPT.description    = '';

[OPT, Set, Default] = setProperty(OPT, varargin);
%% calculate coordinates of arrows and arrow heads
lat         = lat(:)';
lon         = lon(:)';
u           = u(:)';
v           = v(:)';

%arrow tip
tipLat      = lat+v/(40000000)*360;
tipLon      = lon+u/(40000000)*360./cosd(lat);

% arrow sides
lineLength  = sqrt(v.^2+u.^2);
alpha       = atand(u./v);
beta        = [alpha+180+OPT.arrowHeadAngle;zeros(size(lat));alpha+180-OPT.arrowHeadAngle];
dx          = [lineLength;zeros(size(lat));lineLength]*OPT.arrowScale.*cosd(beta);
dy          = [lineLength;zeros(size(lon));lineLength]*OPT.arrowScale.*sind(beta);

% arrow line
arrowLat    = [tipLat;tipLat;tipLat]+dx/(40000000)*360;
arrowLon    = [tipLon;tipLon;tipLon]+dy/(40000000)*360./[cosd(lat); cosd(lat); cosd(lat)];

% merge arrow and line to arrays
if  OPT.arrowClose
    lat = [lat;tipLat;nan(size(lat));arrowLat; arrowLat(1,:)];
    lon = [lon;tipLon;nan(size(lon));arrowLon; arrowLon(1,:)];
else
    lat = [lat;tipLat;nan(size(lat));arrowLat];
    lon = [lon;tipLon;nan(size(lon));arrowLon];
end

if OPT.arrowFill
    latFill = [arrowLat; arrowLat(1,:)];
    lonFill = [arrowLon; arrowLon(1,:)];
end

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
OPT_style = struct(...
    'name',['arrowline' num2str(1)],...
    'fillColor',OPT.fillColor,...
    'lineColor',OPT.lineColor ,...
    'lineAlpha',OPT.lineAlpha,...
    'lineWidth',OPT.lineWidth);
    output = [output KML_style(OPT_style)];

if OPT.arrowFill
    OPT_stylePoly = struct(...
        'name',['arrowfill' num2str(1)],...
        'fillColor',OPT.fillColor,...
        'lineColor',OPT.lineColor ,...
        'lineAlpha',0,...
        'lineWidth',0,...
        'fillAlpha',OPT.fillAlpha,...
        'polyFill',1,...
        'polyOutline',0); 
        output = [output KML_stylePoly(OPT_stylePoly)];
end

%% print output
fprintf(OPT.fid,output);
%% LINE
OPT_line = struct(...
    'name','',...
    'styleName',['arrowline' num2str(1)],...
    'timeIn',[],...
    'timeOut',[],...
    'visibility',1,...
    'extrude',0);

if OPT.arrowFill
    OPT_poly = struct(...
        'name','',...
        'styleName',['arrowfill' num2str(1)],...
        'timeIn',[],...
        'timeOut',[],...
        'visibility',1,...
        'extrude',0);
end


% preallocate output
output = repmat(char(1),1,1e5);
kk = 1;
for ii=1:length(lat(1,:))
%     if length(OPT.lineColor(:,1))+length(OPT.lineWidth)+length(OPT.lineAlpha)>3
%         OPT_line.styleName = ['style' num2str(ii)];
%     end
    newOutput = KML_line(lat(:,ii),lon(:,ii),'clampToGround',OPT_line);
    if OPT.arrowFill
        newOutput = [newOutput...
            KML_poly(latFill(:,ii),lonFill(:,ii),'clampToGround',OPT_poly)];
    end
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
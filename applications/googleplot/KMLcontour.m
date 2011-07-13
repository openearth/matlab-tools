function varargout = KMLcontour(lat,lon,z,varargin)
% KMLCONTOUR   Just like contour
%
%    KMLcontour(lat,lon,z,<keyword,value>)
%
% For the <keyword,value> pairs and their defaults call
%
%    OPT = KMLcontour()
%
% The most important keywords are 'fileName', 'levels' and 'labelInterval';
%
%    OPT = KMLcontour(lat,lon,z,'fileName','mycontour.kml','levels',N)
%
% draws N contour lines when LENGTH(N)=1, or LENGTH(V) contour
% lines at the values specified in vector V. Use [v v] to plot
% a single contour at the level v. (same as CONTOUR). When
% 'labelInterval' is NaN (default) CLABEL is used to position
% the labels, otherwise the contour polygons are subsetted.
%
% The keyword 'colorMap' can either be a function handle to be sampled with
% keyword 'colorSteps', or a colormap rgb array (then 'colorSteps') is ignored).
%
% The kml code hat is written to file 'fileName' can optionally be returned.
%
%    kmlcode = KMLcontour(lat,lon,<keyword,value>)
%
% See also: googlePlot, contour, contour3

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

% TO DO: implement angle/rotation of Matlab clabels in KML_text()

   %% process <keyword,value>
   %  get colorbar and header options first
   OPT               = KMLcolorbar();
   OPT               = mergestructs(OPT,KML_header());
   % rest of the options
   OPT.levels        = 10;
   OPT.fileName      = '';
   OPT.lineWidth     = 1;
   OPT.lineAlpha     = 1;
   OPT.openInGE      = false;
   OPT.colorMap      = @(m) jet(m); % function(OPT.colorSteps) or an rgb array
   OPT.colorSteps    = 32;
   OPT.is3D          = false;
   OPT.cLim          = [];
   OPT.writeLabels   = true;
   OPT.colorbar      = 1;
   OPT.labelDecimals = 1;
   OPT.labelInterval = nan; % NaN means clabel is used
   OPT.zScaleFun     = @(z) (z+0)*0;
%% 
   if nargin==0
    varargout = {OPT};
    return
   end
   
   if isvector(lat) & isvector(lon)
      [lat,lon] = meshgrid(lat,lon);
   end

%% check if labels are defined
%  see if height is defined

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

[OPT, Set, Default] = setproperty(OPT, varargin{:});

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

%% get filename, gui for filename, if not set yet

if isempty(OPT.fileName)
    [fileName, filePath] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as',[mfilename,'.kml']);
    OPT.fileName = fullfile(filePath,fileName);
end

%% set kmlName if it is not set yet

if isempty(OPT.kmlName)
    [ignore OPT.kmlName] = fileparts(OPT.fileName);
end

%% find contours

if OPT.writeLabels & isnan(OPT.labelInterval)
    FIG = figure('visible','on');
    [coords,h] = contour(lat,lon,z,OPT.levels);
else
    coords = contours(lat,lon,z,OPT.levels);
end

if length(coords)==0
    error(['no contours found, please check levels([1 end])=[',num2str(OPT.levels(1)),' - ',num2str(OPT.levels(end)),'] against z range [',num2str(min(z(:))),' - ',num2str(max(z(:))),']'])
end
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

sourceFiles = {};

%% make labels

if OPT.writeLabels
    if ~isnan(OPT.labelInterval)
        latText    = lat(1:OPT.labelInterval:end,:);
        lonText    = lon(1:OPT.labelInterval:end,:);
        zText      =   z(1:OPT.labelInterval:end,:);
        zText      =   zText(~isnan(latText));
        labels     =   zText;
        latText    = latText(~isnan(latText));
        lonText    = lonText(~isnan(lonText));
    else
        t = clabel(coords,h);
        for i=1:length(t)
            p = get(t(i),'Position');
            latText(i) = p(1);
            lonText(i) = p(2);
            labels {i} = get(t(i),'String');
            zText      = str2num(char(labels));
        end
        close(FIG);
    end
    KMLtext(latText,lonText,labels,OPT.zScaleFun(zText),'fileName',[OPT.fileName(1:end-4) 'labels.kml'],...
        'kmlName','labels','timeIn',OPT.timeIn,'timeOut',OPT.timeOut,'labelDecimals',OPT.labelDecimals);
    
    sourceFiles = [sourceFiles,{[OPT.fileName(1:end-4) 'labels.kml']}];
    
end

%% draw the lines

height(height<OPT.cLim(1)) = OPT.cLim(1);
height(height>OPT.cLim(2)) = OPT.cLim(2);

if isnumeric(OPT.colorMap)
    OPT.colorSteps = size(OPT.colorMap,1);
end
if OPT.colorSteps==1
    OPT.colorbar = 0;
end

level      = round((height-OPT.cLim(1))/(OPT.cLim(2)-OPT.cLim(1))*(OPT.colorSteps-1))+1;

%%  get colormap

if isa(OPT.colorMap,'function_handle')
    colorRGB           = OPT.colorMap(OPT.colorSteps);
elseif isnumeric(OPT.colorMap)
    if size(OPT.colorMap,1)==1
        colorRGB         = repmat(OPT.colorMap,[OPT.colorSteps 1]);
    elseif size(OPT.colorMap,1)==OPT.colorSteps
        colorRGB         = OPT.colorMap;
    else
        error(['size ''colorMap'' (=',num2str(size(OPT.colorMap,1)),') does not match ''colorSteps''  (=',num2str(OPT.colorSteps),')'])
    end
end

lineColors = colorRGB(level,:);

if OPT.is3D
    if nargout==1
        kmlcode = KMLline(lat,lon,OPT.zScaleFun(z),'fileName',[OPT.fileName(1:end-4) 'lines.kml'],...
            'kmlName','lines',...
            'timeIn',OPT.timeIn,...
            'timeOut',OPT.timeOut,...
            'lineColor',lineColors,...
            'lineWidth',OPT.lineWidth,...
            'fillColor',lineColors);
    else
        KMLline(lat,lon,OPT.zScaleFun(z),'fileName',[OPT.fileName(1:end-4) 'lines.kml'],...
            'kmlName','lines',...
            'timeIn',OPT.timeIn,...
            'timeOut',OPT.timeOut,...
            'lineColor',lineColors,...
            'lineWidth',OPT.lineWidth,...
            'fillColor',lineColors);
    end
else
    if nargout==1
        kmlcode = KMLline(lat,lon,'fileName',[OPT.fileName(1:end-4) 'lines.kml'],...
            'kmlName','lines',...
            'timeIn',OPT.timeIn,...
            'timeOut',OPT.timeOut,...
            'lineColor',lineColors,...
            'lineWidth',OPT.lineWidth);
    else
        KMLline(lat,lon,'fileName',[OPT.fileName(1:end-4) 'lines.kml'],...
            'kmlName','lines',...
            'timeIn',OPT.timeIn,...
            'timeOut',OPT.timeOut,...
            'lineColor',lineColors,...
            'lineWidth',OPT.lineWidth);
    end
end

%% colorbar

if OPT.colorbar
    OPT.CBfileName = [OPT.fileName(1:end-4) 'colorbar.kml'];
    KMLcolorbar(OPT);
    sourceFiles = [sourceFiles {OPT.CBfileName}];
end

%% merge labels, lines and colorbar

sourceFiles = [sourceFiles {[OPT.fileName(1:end-4) 'lines.kml']}];

KMLmerge_files('fileName',OPT.fileName,...
    'sourceFiles',sourceFiles);

for i=1:length(sourceFiles)
    delete(sourceFiles{i});
end

if nargout ==1
    varargout = {kmlcode};
end

%% EOF



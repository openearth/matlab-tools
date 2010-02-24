function [OPT, Set, Default] = KMLtricontourf(tri,lat,lon,z,varargin)
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
OPT.lineWidth     = 3;
OPT.lineColor     = [0 0 0];
OPT.lineAlpha     = 1;
OPT.fillAlpha     = 1;
OPT.polyOutline   = false;
OPT.polyFill      = true;
OPT.openInGE      = false;
OPT.colorMap      = @(m) jet(m);
OPT.colorSteps    = [];   
OPT.timeIn        = [];
OPT.timeOut       = [];
OPT.is3D          = false;
OPT.cLim          = [];
OPT.writeLabels   = true;
OPT.labelDecimals = 1;
OPT.labelInterval = 5;
OPT.zScaleFun     = @(z) (z+0)*0;
OPT.colorbar      = 0;
OPT.extrude       = true;
OPT.staggered     = true;
if nargin==0
  return
end

%% set properties

[OPT, Set, Default] = setProperty(OPT, varargin{:});

if isempty(OPT.colorSteps), OPT.colorSteps = OPT.levels; end
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
    [~, OPT.kmlName] = fileparts(OPT.fileName);
end

%% find contours
C = tricontourc(tri,lat,lon,z,OPT.levels);

%% pre allocate, find dimensions
max_size = 1;
jj = 1;ii = 0;
while jj<size(C,2) 
    ii = ii+1;
    max_size = max(max_size,C(2,jj));
    jj = jj+C(2,jj)+1;
end
nContours = ii;
lat          = nan(max_size,nContours);
lon          = nan(max_size,nContours);
height       = nan(1,nContours);
closedLoop   = false(1,nContours);
jj = 1;ii = 0;
while jj<size(C,2) 
    ii = ii+1;
    height(ii) = C(1,jj);
    lat(1:C(2,jj),ii) = C(1,jj+1:jj+C(2,jj)); 
    lon(1:C(2,jj),ii) = C(2,jj+1:jj+C(2,jj)); 
    closedLoop(ii) = C(1,jj+1)==C(1,jj+C(2,jj)) &&...
                     C(2,jj+1)==C(2,jj+C(2,jj));
    jj = jj+C(2,jj)+1;
end
%% pre-process color data

   if isempty(OPT.cLim)
      OPT.cLim         = [min(z(:)) max(z(:))];
   end

   colorRGB = OPT.colorMap(OPT.colorSteps);

   %  convert color values into colorRGB index values
    [~,~,c] = unique(height);

%% find polygon area if the coordinates are a closed loop
polyArea = nan(1,nContours);
for ii=1:nContours
    if closedLoop(ii)
        polyArea(ii) = polyarea(lat(~isnan(lat(:,ii)),ii),lon(~isnan(lat(:,ii)),ii));
    end
end

% [~,outerPoly] = max(polyArea);
mm = 0;
for outerPoly = find(closedLoop)
    % OuterPoly is the outer boundary.
    
    
    % find the largest loop that is contained by that loop
    % polygons that form the inner boundaries
    innerPoly = [];
    % only check inpolygon for the first
    inOuterPoly  = inpolygon(lat(1,:),lon(1,:),...
        lat(~isnan(lat(:,outerPoly)),outerPoly),...
        lon(~isnan(lat(:,outerPoly)),outerPoly));
    inOuterPoly(outerPoly) = false; % OuterPoly is not in OuterPoly
    
    % check if there are polygons inside the outer poly, but not in one of the
    % inner polygons
    inOuterPoly = find(inOuterPoly);
    
    while ~isempty(inOuterPoly)
        for ii = innerPoly
            % remove self
            inOuterPoly(inOuterPoly==ii)=[];
            
            % find polygons inside the outer poly and in this innerPoly
            inInnerPoly  = inpolygon(lat(1,inOuterPoly),lon(1,inOuterPoly),...
                lat(~isnan(lat(:,ii)),ii),...
                lon(~isnan(lat(:,ii)),ii));
            
            % remove those the polygons from inOuterPoly
            inOuterPoly(inInnerPoly)=[];
        end
        
        if ~isempty(inOuterPoly)
            [~,ii] = max(polyArea(inOuterPoly));
            innerPoly(end+1) = inOuterPoly(ii); %#ok<AGROW>
        end
    end
    mm = mm+1;
    D(mm).outerPoly = outerPoly;
    D(mm).innerPoly = innerPoly;
end

%% start KML

   OPT.fid=fopen(OPT.fileName,'w');
   
   OPT_header = struct(...
       'name',OPT.kmlName,...
       'open',0);
   output = KML_header(OPT_header);
   
   if OPT.colorbar
      clrbarstring = KMLcolorbar('clim',OPT.cLim,'fileName',OPT.fileName,'colorMap',colorRGB,'colorTitle',OPT.colorbartitle);
      output = [output clrbarstring];
   end

%% STYLE

   OPT_stylePoly = struct(...
       'name'       ,['style' num2str(1)],...
       'fillColor'  ,colorRGB(1,:),...
       'lineColor'  ,OPT.lineColor,...
       'lineAlpha'  ,OPT.lineAlpha,...
       'lineWidth'  ,OPT.lineWidth,...
       'fillAlpha'  ,OPT.fillAlpha,...
       'polyFill'   ,OPT.polyFill,...
       'polyOutline',OPT.polyOutline); 
   for ii = 1:OPT.colorSteps
       OPT_stylePoly.name = ['style' num2str(ii)];
       OPT_stylePoly.fillColor = colorRGB(ii,:);
       output = [output KML_stylePoly(OPT_stylePoly)];
   end
   
   % print and clear output
   
   output = [output '<!--############################-->' fprinteol];
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
    
   for ii=1:mm
       OPT_poly.styleName = sprintf('style%d',c(D(ii).outerPoly));
       
       x1 =  lat(:,[D(ii).outerPoly D(ii).innerPoly]);
       y1 =  lon(:,[D(ii).outerPoly D(ii).innerPoly]);
       if OPT.staggered
       z1 = height(D(ii).outerPoly);
       z1 = repmat(z1,size(x1,1),size(x1,2));
       else
       z1 = height([D(ii).outerPoly D(ii).innerPoly]);
       z1 = repmat(z1,size(x1,1),1);
           
       end
       newOutput = KML_poly(x1,y1,OPT.zScaleFun(z1),OPT_poly);
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

%% close KML

   output = KML_footer;
   fprintf(OPT.fid,output);
   fclose(OPT.fid);

%% compress to kmz?

   if strcmpi  ( OPT.fileName(end-2:end),'kmz')
       movefile( OPT.fileName,[OPT.fileName(1:end-3) 'kml'])
       zip     ( OPT.fileName,[OPT.fileName(1:end-3) 'kml']);
       movefile([OPT.fileName '.zip'],OPT.fileName)
       delete  ([OPT.fileName(1:end-3) 'kml'])
   end

%% openInGoogle?
   if OPT.openInGE
       system(OPT.fileName);
   end

%% EOF































% %% make z
% z = repmat(height,size(lat,1),1);
% 
% %% make labels
% if OPT.writeLabels
%     latText    = lat(1:OPT.labelInterval:end,:);
%     lonText    = lon(1:OPT.labelInterval:end,:);
%     zText      =   z(1:OPT.labelInterval:end,:);
%     zText      =   zText(~isnan(latText));
%     labels     =   zText;
%     latText    = latText(~isnan(latText));
%     lonText    = lonText(~isnan(lonText));
%     if OPT.is3D
%         KMLtext(latText,lonText,labels,OPT.zScaleFun(zText),'fileName',[OPT.fileName(1:end-4) 'labels.kml'],...
%             'kmlName','labels','timeIn',OPT.timeIn,'timeOut',OPT.timeOut,'labelDecimals',OPT.labelDecimals);
%     else
%         KMLtext(latText,lonText,labels,'fileName',[OPT.fileName(1:end-4) 'labels.kml'],...
%             'kmlName','labels','timeIn',OPT.timeIn,'timeOut',OPT.timeOut,'labelDecimals',OPT.labelDecimals);
%     end
% end
% %% draw the lines
% height(height<OPT.cLim(1)) = OPT.cLim(1);
% height(height>OPT.cLim(2)) = OPT.cLim(2);
% 
% level      = round((height-OPT.cLim(1))/(OPT.cLim(2)-OPT.cLim(1))*(OPT.colorSteps-1))+1;
% colors     = OPT.colorMap(OPT.colorSteps);
% lineColors = colors(level,:);
% 
% if OPT.is3D
%     KMLline(lat,lon,OPT.zScaleFun(z),'fileName',OPT.fileName,'lineColor',lineColors,'lineWidth',OPT.lineWidth,...
%         'timeIn',OPT.timeIn,'timeOut',OPT.timeOut,'fillColor',lineColors);
% else
%     KMLline(lat,lon,'fileName',OPT.fileName,'lineColor',lineColors,'lineWidth',OPT.lineWidth,...
%         'timeIn',OPT.timeIn,'timeOut',OPT.timeOut);
% end



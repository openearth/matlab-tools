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
[C,E] = tricontourc(tri,lat,lon,z,OPT.levels);

%% pre allocate, find dimensions
max_size = 1;
jj = 1;ii = 0;
while jj<size(C,2) 
    ii = ii+1;
    max_size = max(max_size,C(2,jj));
    jj = jj+C(2,jj)+1;
end
nContours = ii;
lat           = nan(max_size,nContours);
lon           = nan(max_size,nContours);
height        = nan(1,nContours);
contourEndLat = nan(1,nContours);
contourEndLon = nan(1,nContours);
closedLoop   = false(1,nContours);
jj = 1;ii = 0;
while jj<size(C,2) 
    ii = ii+1;
    height(ii) = C(1,jj);
    lat(1:C(2,jj),ii) = C(1,jj+1:jj+C(2,jj)); 
    lon(1:C(2,jj),ii) = C(2,jj+1:jj+C(2,jj)); 
    contourEndLat(ii) = C(1,jj+C(2,jj));
    contourEndLon(ii) = C(2,jj+C(2,jj));
    closedLoop(ii) = C(1,jj+1)==C(1,jj+C(2,jj)) &&...
                     C(2,jj+1)==C(2,jj+C(2,jj));
    jj = jj+C(2,jj)+1;
end

%% close open polygons by following edge lines

% stitch elements of E together to form continouos loops

E(:,7) = nan;
ii = 1;
while any(isnan(E(:,7)))
    % first try to find connectingLIne form the first row of coordinates
    connectingLines = find(E(ii,4)==E(:,1)&E(ii,5)==E(:,2));
    % if nothing found, find it form the second row
    if isempty(connectingLines)
        connectingLines = find(E(ii,4)==E(:,4)&E(ii,5)==E(:,5));
        connectingLines(connectingLines==ii)=[];
        foundFromRow2 = true;
    else
        foundFromRow2 = false;
    end
    if numel(connectingLines)~=1
        error('the mesh is to complicated, holes and edges may not connect')
    end
    
    % reverse coordinates if foundFromRow2
    if foundFromRow2
        E(connectingLines,1:6) = E(connectingLines,[4:6 1:3]);
    end

    if isnan(E(ii,7))
        E(ii,7) = connectingLines;
        ii = connectingLines;
    else
        E(ii,7) = connectingLines;
        ii = find(isnan(E(:,7)),1);
    end
end

% now close loops by walking along the edge where a contour ends, until one runs
% into another contour that starts on the edge. Follow that contour, and
% then coninue along the edge, and so forth, until the routine is back at
% the beginning of the initial contour. 
%
% Unfortunately, the code got extremely messy...
%


lat2 = [lat; nan(size(lat,1)*5,size(lat,2))]; 
lon2 = [lon; nan(size(lat,1)*5,size(lat,2))];

for ii = 12%find(~closedLoop)

    endOfContour = find(~isnan(lat(:,ii)),1,'last');
searchDirection = 1;


while ~(lat2(1,ii)==lat2(endOfContour,ii) &&...
        lon2(1,ii)==lon2(endOfContour,ii));
     
    % determine where the contour end could possibly be
    % find all lines on the edge that cross the continue
    if searchDirection == 1;
        temp0 = xor(E(:,3)<height(ii),E(:,6)<height(ii));
            % calculate exact crossing locations
        temp1     = E(temp0,[3 6])-height(ii);
    else
        temp0 = xor(E(:,3)<nextHeight,E(:,6)<nextHeight);
            % calculate exact crossing locations
        temp1     = E(temp0,[3 6])-nextHeight;
    end    
    temp2     = abs([temp1(:,2)./(temp1(:,1)-temp1(:,2)),...
        temp1(:,1)./(temp1(:,1)-temp1(:,2))]);
    crossingX =  sum(temp2.*E(temp0,[1 4]),2);
    crossingY =  sum(temp2.*E(temp0,[2 5]),2);
 
    
    temp3 = (crossingX == lat2(endOfContour,ii) &...
        crossingY == lon2(endOfContour,ii));
    temp4 = find(temp0);
    edgeLineAtEndOfContour = temp4(temp3);
    
    % determine to go forwards of backwards through edge lines,
    % searchDirection = 1  go in the direction of the highest z value 
    % searchDirection = 2  go in the direction of the lowest z value
    
    
    [~,temp5] = max(E(edgeLineAtEndOfContour,[3 6]));
    if temp5==searchDirection
        x_to_add = 1;
        y_to_add = 2;
        z_to_add = 3;
        searchForwards = false;
    else
        x_to_add = 4;
        y_to_add = 5;
        z_to_add = 6;
        searchForwards = true;
    end
    
    % determine the next highest height level
    nextHeight = min(height(height>height(ii)));
    
    % start adding edge coordinates to the polygon
    edgeCoordinateToAdd = edgeLineAtEndOfContour;
    
    while E(edgeCoordinateToAdd,z_to_add)>height(ii)&&...
            E(edgeCoordinateToAdd,z_to_add)<nextHeight
        endOfContour = endOfContour+1;
        lat2(endOfContour,ii) = E(edgeCoordinateToAdd,x_to_add);
        lon2(endOfContour,ii) = E(edgeCoordinateToAdd,y_to_add);
        if searchForwards
            edgeCoordinateToAdd = E(edgeCoordinateToAdd,7);
        else
            edgeCoordinateToAdd = find(E(:,7)==edgeCoordinateToAdd);
        end
    end
    
    % find which height was actually crossed
    if E(edgeCoordinateToAdd,z_to_add)>height(ii)
        crossedHeight = nextHeight;
        searchDirection = 2;
    else
        crossedHeight = height(ii);
        searchDirection = 1;
    end
    
    % find exactly where that height was crossed
    temp1     = E(edgeCoordinateToAdd,[3 6])-crossedHeight;
    temp2     = abs([temp1(:,2)./(temp1(:,1)-temp1(:,2)),...
        temp1(:,1)./(temp1(:,1)-temp1(:,2))]);
    crossingX =  sum(temp2.*E(edgeCoordinateToAdd,[1 4]),2);
    crossingY =  sum(temp2.*E(edgeCoordinateToAdd,[2 5]),2);
    
    % find which contour line ends or begins exactly on that point
    
    nextContour = find(contourEndLat == crossingX &...
        contourEndLon == crossingY, 1);
    if isempty(nextContour)
        nextContour = find((lat(1,:) == crossingX &...
            lon(1,:) == crossingY),1);
        nextContourIndices = 1:find(~isnan(lat(:,nextContour)),1,'last');
    else
        nextContourIndices = find(~isnan(lat(:,nextContour)),1,'last'):-1:1;
    end
    if nextContour == ii
        % the crossing point is the beginning of the initial contour
        lat2(endOfContour,ii) = lat2(1,ii);
        lon2(endOfContour,ii) = lon2(1,ii);
    else
        lat2(endOfContour+(1:max(nextContourIndices)),ii) = lat(nextContourIndices,nextContour);
        lon2(endOfContour+(1:max(nextContourIndices)),ii) = lon(nextContourIndices,nextContour);
    end
    endOfContour = find(~isnan(lat2(:,ii)),1,'last');
end
closedLoop(ii) = true;
end

%%
lat2(all(isnan(lat2),2),:) = [];
lon2(all(isnan(lat2),2),:) = [];

lat = lat2;
lon = lon2;

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



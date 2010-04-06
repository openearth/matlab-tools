function varargout = KMLtricontourf(tri,lat1,lon1,z1,varargin)
% KMLTRICONTOURF   Just like tricontourc
%
%   KMLtricontourf(tri,lat,lon,z,<keyword,value>)
%
% For the <keyword,value> pairs and their defaults call
%
%    OPT = KMLtricontourf()
%
% See also: googlePlot, tricontourc

% TODO:
% * Also include *all* edge vertices in contours - wip
% * Multiple contour crossings on one boundary gives a problem - fixed
% * Improve edge find algortihm (and turn it into seperate function) - done
% * Major code cleaning - wip
% * Optimization of slow routines (think it can be made faster) - no
%   priority
% * make rest OPT arguments consistent with other KML functions

%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares for Building with Nature
%       Thijs Damsma
%
%       Thijs@Damsma.net
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
   OPT.zScaleFun     = @(z) z;
   OPT.colorbar      = 1;
   OPT.colorbartitle = '';
   OPT.extrude       = false;
   OPT.staggered     = true;

   if nargin==0
      varargout = {OPT};
      return
   end

%% set properties

[OPT, Set, Default] = setProperty(OPT, varargin{:});

if isempty(OPT.colorSteps), OPT.colorSteps = OPT.levels+1; end

%% input check

lat = lat1(:);
lon = lon1(:);
z   =   z1(:);

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
    [dummy, OPT.kmlName] = fileparts(OPT.fileName);
end

%% find contours and edges
if numel(OPT.levels)==1&&OPT.levels==fix(OPT.levels)&&OPT.levels>0
    OPT.levels = linspace(min(z),max(z),OPT.levels+2);
    OPT.levels = OPT.levels(1:end-1);
end

C = tricontourc(tri,lat,lon,z,OPT.levels);
E = trisurf_edges(tri,lat,lon,z);

Ecrossings = nan(size(E,1),2,numel(OPT.levels));
for ii = 1:numel(OPT.levels)
    crossings = find(xor(E(1:end-1,3)<OPT.levels(ii),E(2:end,3)<OPT.levels(ii))&...
        E(1:end-1,4)==E(2:end,4));
    weighting = abs([E(crossings+1,3) E(crossings,3)] - OPT.levels(ii))./...
        repmat(abs(E(crossings,3) - E(crossings+1,3)),1,2);
    Ecrossings(crossings,1,ii) = sum([E(crossings,1) E(crossings+1,1)].*weighting,2);
    Ecrossings(crossings,2,ii) = sum([E(crossings,2) E(crossings+1,2)].*weighting,2);
end

verySmall = eps(3*max([lat;lon]));

%% pre allocate, find dimensions
max_size = 1;
jj = 1;ii = 0;
while jj<size(C,2)
    ii = ii+1;
    max_size = max(max_size,C(2,jj));
    jj = jj+C(2,jj)+1;
end
contour.n      = ii;
lat            = nan(max_size*15,contour.n*2);
lon            = nan(max_size*15,contour.n*2);
z              = nan(max_size*15,contour.n*2);
contour.level  = nan(1,contour.n*2);
contour.begin  = nan(3,contour.n);
contour.end    = nan(3,contour.n);
contour.closed = false(1,contour.n);
jj = 1;ii = 0;
while jj<size(C,2)
    ii = ii+1;
    contour.level(1,ii) = C(1,jj);
    lat(1:C(2,jj),ii)   = C(1,jj+1:jj+C(2,jj));
    lon(1:C(2,jj),ii)   = C(2,jj+1:jj+C(2,jj));
    contour.begin(:,ii) = [C(1,jj+1)      ,C(2,jj+1)      ,C(1,jj)];
    contour.end(:,ii)   = [C(1,jj+C(2,jj)),C(2,jj+C(2,jj)),C(1,jj)];
    jj = jj+C(2,jj)+1;
end
z(1:max_size,1:contour.n) = repmat(contour.level(1:contour.n),max_size,1);
z(isnan(lat))             = nan;
contour.closed            = all(contour.begin==contour.end,1);
contour.open              = find(~contour.closed);
contour.toBeDeleted       = false(1,size(lat,2));
contour.usedAsUpperBnd    = false(1,size(lat,2));
contour.usedAsLowerBnd    = false(1,size(lat,2));
%% close open polygons by following edge lines
% close loops by walking along the edge where a contour ends, until one runs
% into another contour that starts on the edge. Follow that contour, and
% then coninue along the edge, and so forth, until the routine is back at
% the beginning of the initial contour.
%
% Unfortunately, the code got extremely messy...

% new attempt:
% walk along all edges. At upward crossings of a contour level:
%  * find the connecting contour
%  * connect to it
%  * follow that contour and it's edges till back to original corssing
%  * store which contours lines have been 'hooked up'
%  * note that there was at least one contour crossed in that edge-ring
%  * continue
% Finally, connect the lowest contour in downward direction
iNewContour = contour.n;
for iE = find(any(~isnan(squeeze(Ecrossings(:,1,:))),2))'
    isUpwardCrossing = E(iE,3)<E(iE+1,3);
    isLowestContour  = any(ismember(find(~isnan(squeeze(Ecrossings(iE,1,:)))),...
        find(any(~isnan(squeeze(Ecrossings(E(:,4)==E(iE,4),1,:)))),1,'first')));
    if isUpwardCrossing || isLowestContour  
        iCrossedLevels = find(~isnan(squeeze(Ecrossings(iE,1,:))));
        if isLowestContour && ~isUpwardCrossing
            iCrossedLevels = iCrossedLevels(1);
        end
        for iCrossedLevel = iCrossedLevels'
            % search direction for new contour
            searchUpwards = isUpwardCrossing;
            edgeWalk      = 1;
            crossedLevel  = iCrossedLevel;
            % adjust counters
            iNewContour = iNewContour+1;
            iLastCoord  = 0;
            
            % reset indices of first and last coordinate
            firstCoord = [Ecrossings(iE,1,iCrossedLevel),...
                Ecrossings(iE,2,iCrossedLevel),...
                OPT.levels(iCrossedLevel)];
            lastCoord = [nan nan nan];
            iE2 = iE;
            fprintf('a\n\n')
            while ~all(abs(firstCoord-lastCoord)<verySmall)
                %  find the crossed contour(s)
                iContour = abs(contour.begin(1,contour.open)-Ecrossings(iE2,1,crossedLevel))<verySmall&...
                    abs(contour.begin(2,contour.open)-Ecrossings(iE2,2,crossedLevel))<verySmall;
                
                % if no matching coordinates are found at the contour
                % begin, then also look at the ends
                if ~any(iContour)
                    iContour = abs(contour.end(1,contour.open)-Ecrossings(iE2,1,crossedLevel))<verySmall&...
                        abs(contour.end(2,contour.open)-Ecrossings(iE2,2,crossedLevel))<verySmall;
                    addContourReversed = true;
                else
                    addContourReversed = false;
                end
                iContour = contour.open(iContour);
                
                % indices of the coordinate to be added
                addContourCoordinates = find(~isnan(lat(:,iContour)));
                if addContourReversed; 
                    addContourCoordinates = flipud(addContourCoordinates); 
                end
                
                % adjust indices
                jNewContour = iLastCoord+1:iLastCoord+numel(addContourCoordinates);
                iLastCoord  = iLastCoord+numel(addContourCoordinates);
                
                % store contour level
                contour.level(iNewContour) = contour.level(iContour);
                
                % mark that contour as 'to be deleted'
                contour.toBeDeleted(iContour) = true;
%                 if searchUpwards
%                     if   contour.usedAsLowerBnd(iContour);        break
%                     else contour.usedAsLowerBnd(iContour) = true; end
%                 else
%                     if   contour.usedAsUpperBnd(iContour);        break
%                     else contour.usedAsUpperBnd(iContour) = true; end
%                 end
                
                % add the contour
                lat(jNewContour,iNewContour) = lat(addContourCoordinates,iContour);
                lon(jNewContour,iNewContour) = lon(addContourCoordinates,iContour);
                z  (jNewContour,iNewContour) =             contour.level(iContour) ;           

                % find the index of the edgecontour that continues
                % where the previous contour has ended
                lastCoord = [lat(iLastCoord,iNewContour),...
                    lon(iLastCoord,iNewContour),...
                    z(iLastCoord,iNewContour)];
                
                % The 'local' edge index iE2 counter (versus the global iE)
                iE2 = find(...
                    abs(Ecrossings(:,1,crossedLevel) - lastCoord(1))<verySmall &...
                    abs(Ecrossings(:,2,crossedLevel) - lastCoord(2))<verySmall);
                
                fprintf('starting from %02d\n',iE2)
                disp(['isUpwardCrossing = ' num2str(isUpwardCrossing)]) 
                disp(['isLowestContour = ' num2str(isLowestContour)]) 
                disp(['searchUpwards = ' num2str(searchUpwards)]) 
                
                % determine the direction to walk along the edge coordinates
                nn      = find(E(:,4)==E(iE2,4),1,'first');
                kk      = find(E(:,4)==E(iE2,4),1, 'last');
                iE2next = mod(iE2+edgeWalk-nn,kk-nn)+nn;
                
                if xor(searchUpwards,E(iE2,3)>E(iE2next,3))
                    iE2 = mod(iE2+1-nn,kk-nn)+nn;
                    edgeWalk = 1;
                else
                    edgeWalk =  -1;
                end
                
                % reverse search direction for next iteration
                searchUpwards = ~searchUpwards;
                
                first=true;
                while ~(~first&&any(~isnan(Ecrossings(iE2,1,crossedLevel)))||...                  
                    any(~isnan(Ecrossings(iE2,1,iCrossedLevel+iCrossedLevel+1-crossedLevel)))&&~isLowestContour)
                    first=false;
                    % add coordinate
                    fprintf('adding %02d\n',iE2);
                    iLastCoord                = iLastCoord+1;
                    lat(iLastCoord,iNewContour) = E(iE2,1);
                    lon(iLastCoord,iNewContour) = E(iE2,2);
                    z  (iLastCoord,iNewContour) = E(iE2,3);
                    iE2 = mod(iE2+edgeWalk-nn,kk-nn)+nn;
                end
                fprintf('stopt adding at %02d\n',iE2);
                iLastCoord                = iLastCoord+1;
                if isnan(Ecrossings(iE2,1,iCrossedLevel))
                    crossedLevel = iCrossedLevel+1;
                    searchUpwards = ~searchUpwards;
                else
                    crossedLevel = iCrossedLevel;
                end
                lastCoord = [Ecrossings(iE2,1,crossedLevel),...
                    Ecrossings(iE2,2,crossedLevel),...
                    OPT.levels(crossedLevel)];
                
                lat(iLastCoord,iNewContour) = lastCoord(1);
                lon(iLastCoord,iNewContour) = lastCoord(2);
                z  (iLastCoord,iNewContour) = lastCoord(3);
            end
        end
    end
end

% chek for edge rings without any crossings
for ii =1:E(end,4)
    if all(all(all(isnan(Ecrossings(E(:,4)==ii,:,:)),3),2),1)
        iNewContour = iNewContour+1;
        lat(1:numel(E(:,4)==ii),iNewContour) = E(E(:,4)==ii,1);
        lon(1:numel(E(:,4)==ii),iNewContour) = E(E(:,4)==ii,2);
        z  (1:numel(E(:,4)==ii),iNewContour) = E(E(:,4)==ii,3);
        contour.level(ii) = OPT.levels(find(OPT.levels<z(1,iNewContour),1,'last'));
    end
end

%% Delete all duplicate data, and the data from contoursToBeDeleted
contour.toBeDeleted(all(isnan(lat)))=true;
lat(:,contour.toBeDeleted) = [];
lon(:,contour.toBeDeleted) = [];
z  (:,contour.toBeDeleted) = [];

%% trim superfluous nan values from the coordinate arrays
z  (all(isnan(lon),2),:) = [];
lat(all(isnan(lon),2),:) = [];
lon(all(isnan(lon),2),:) = [];

contour.level(contour.toBeDeleted) = [];
contour.n = size(lat,2);

%% make all contour lines counterclockwise
for ii=1:size(lat,2)
    if ~polyIsClockwise(lon(:,ii),lat(:,ii))
        endOfContour = find(~isnan(lat(:,ii)),1,'last');
        lat(1:endOfContour,ii) = lat(endOfContour:-1:1,ii);
        lon(1:endOfContour,ii) = lon(endOfContour:-1:1,ii);
        z  (1:endOfContour,ii) = z  (endOfContour:-1:1,ii);
    end
end

%% pre-process color data

if isempty(OPT.cLim)
    OPT.cLim         = [min(z(:)) max(z(:))];
end

colorRGB = OPT.colorMap(OPT.colorSteps);

% determine the area's of the different polygons
contour.area = nan(1,contour.n);
for ii=1:contour.n
    contour.area(ii) = polyarea(lon(~isnan(lat(:,ii)),ii),lat(~isnan(lat(:,ii)),ii));
end

% [dummy,outerPoly] = max(contour.area);
mm = 0;
for outerPoly = 1:contour.n
    % OuterPoly is the outer boundary.
    
    % find the largest loop that is contained by that loop
    % polygons that form the inner boundaries
    innerPoly = [];
    % only check inpolygon for the first
    [inOuterPoly, onOuterPoly] = inpolygon(lat(1,:),lon(1,:),...
        lat(~isnan(lat(:,outerPoly)),outerPoly),...
        lon(~isnan(lat(:,outerPoly)),outerPoly));
    % if a line point is on the outerPoly, it is not in it.
    inOuterPoly(onOuterPoly) = false; % OuterPoly is not in OuterPoly
    
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
            [dummy,ii] = max(contour.area(inOuterPoly));
            innerPoly(end+1) = inOuterPoly(ii); %#ok<AGROW>
        end
    end
    mm = mm+1;
    D(mm).outerPoly = outerPoly;
    D(mm).innerPoly = innerPoly;
end

contour.colorLevel = nan(size(contour.level));
% set level to the minimum level of inner and outer polygon
for ii = 1:contour.n
    contour.colorLevel(ii) = min(contour.level([D(ii).outerPoly D(ii).innerPoly]));
    if isempty(D(ii).innerPoly)
        % then find out if is a valley, then lower contour color
        if mean(z1(inpolygon(lat1,lon1,lat(:,D(ii).outerPoly),lon(:,D(ii).outerPoly))))<contour.colorLevel(ii)
            contour.colorLevel(ii) = OPT.levels(max(find(OPT.levels==contour.level(D(ii).outerPoly))-1,1));
        end
    end
end

%  convert color values into colorRGB index values
[dummy,dummy,c] = unique(contour.colorLevel);

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
    if OPT.is3D
        if OPT.staggered
            z1 = height(D(ii).outerPoly);
            z1 = repmat(z1,size(x1,1),size(x1,2));
            z1 = OPT.zScaleFun(z1);
        else
            z1 = z(:,[D(ii).outerPoly D(ii).innerPoly]);
            z1 = OPT.zScaleFun(z1);
        end
    else
        z1 = 'clampToGround';
    end
    newOutput = KML_poly(x1,y1,z1,OPT_poly);
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


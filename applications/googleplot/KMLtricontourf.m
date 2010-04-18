function varargout = KMLtricontourf(tri,lat,lon,z,varargin)
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
% * Better identification of local lowest ring.
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
   OPT.debug         = false;

   if nargin==0
      varargout = {OPT};
      return
   end

%% set properties

OPT = setProperty(OPT, varargin{:});

%% input check

% vectorize input
lat = lat(:);
lon = lon(:);
z   = z(:);

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
    [dummy, OPT.kmlName] = fileparts(OPT.fileName); %#ok<ASGLU>
end

%% find contours and edges
if numel(OPT.levels)==1&&OPT.levels==fix(OPT.levels)&&OPT.levels>=0
    OPT.levels = linspace(min(z),max(z),OPT.levels+2);
    OPT.levels = OPT.levels(1:end-1);
end

if isempty(OPT.colorSteps), OPT.colorSteps = length(OPT.levels)+1; end

C = tricontourc(tri,lat,lon,z,OPT.levels);
E = trisurf_edges(tri,lat,lon,z);

%% pre allocate, find dimensions
verySmall = eps(30*max([lat;lon]));
max_size = 1;
jj = 1;ii = 0;
while jj<size(C,2)
    ii = ii+1;
    max_size = max(max_size,C(2,jj));
    jj = jj+C(2,jj)+1;
end
contour.n      = ii;
latC            = nan(max_size,contour.n);
lonC            = nan(max_size,contour.n);
zC              = nan(max_size,contour.n);
contour.level  = nan(1,contour.n);
contour.begin  = nan(3,contour.n);
contour.end    = nan(3,contour.n);
contour.closed = false(1,contour.n);
jj = 1;ii = 0;
while jj<size(C,2)
    ii = ii+1;
    contour.level(1,ii) = C(1,jj);
    latC(1:C(2,jj),ii)   = C(1,jj+1:jj+C(2,jj));
    lonC(1:C(2,jj),ii)   = C(2,jj+1:jj+C(2,jj));
    contour.begin(:,ii) = [C(1,jj+1)      ,C(2,jj+1)      ,C(1,jj)];
    contour.end(:,ii)   = [C(1,jj+C(2,jj)),C(2,jj+C(2,jj)),C(1,jj)];
    jj = jj+C(2,jj)+1;
end
zC(1:max_size,1:contour.n) = repmat(contour.level(1:contour.n),max_size,1);
zC(isnan(latC))             = nan;
contour.closed            = all(contour.begin==contour.end,1);
contour.open              = find(~contour.closed);
contour.toBeDeleted       = false(1,size(latC,2));
contour.usedAsUpperBnd    = false(1,size(latC,2));
contour.usedAsLowerBnd    = false(1,size(latC,2));
%% find crossing locations
Ecrossings = nan(size(E,1),2,numel(OPT.levels)+1);
for ii = 1:numel(OPT.levels)
    crossings = find(xor(E(1:end-1,3)<OPT.levels(ii),E(2:end,3)<OPT.levels(ii))&...
        E(1:end-1,4)==E(2:end,4));
    weighting = abs([E(crossings+1,3) E(crossings,3)] - OPT.levels(ii))./...
        repmat(abs(E(crossings,3) - E(crossings+1,3)),1,2);
    Ecrossings(crossings,1,ii) = sum([E(crossings,1) E(crossings+1,1)].*weighting,2);
    Ecrossings(crossings,2,ii) = sum([E(crossings,2) E(crossings+1,2)].*weighting,2);
end

F = nan(size(E,1)+sum(sum(~isnan(squeeze(Ecrossings(:,1,:))))),7);
kk=0;
for ii = 1:size(E,1)
    kk = kk+1;
    F(kk,1:5)= E(ii,:);
    if any(~isnan(squeeze(Ecrossings(ii,1,:))))
        jj = find(~isnan(squeeze(Ecrossings(ii,1,:))))';
        if E(ii,3) > E(ii+1,3)
            jj = fliplr(jj);
        end
        for ll = jj
            kk = kk+1;
            F(kk,1) = Ecrossings(ii,1,ll);%assign x
            F(kk,2) = Ecrossings(ii,2,ll);% assign y
            F(kk,3) = OPT.levels(ll);% assign z
            F(kk,4) = E(ii,4);
            F(kk,5) = E(ii,5);
            %  find the crossed contour
            iContour = abs(contour.begin(1,contour.open)-F(kk,1))<verySmall&...
                abs(contour.begin(2,contour.open)-F(kk,2))<verySmall;
            % if no matching coordinates are found at the contour
            % begin, then also look at the ends
            if ~any(iContour)
                iContour = abs(contour.end(1,contour.open)-F(kk,1))<verySmall&...
                    abs(contour.end(2,contour.open)-F(kk,2))<verySmall;
                F(kk,7) = 0;
            else
                F(kk,7) = 1;
            end
            if sum(iContour == 1)~=1
                 error %#ok<LTARG>
            end
            F(kk,6) = contour.open(iContour);
        end
    end
end
E = F;
clear F
if OPT.debug
    tricontour3(tri,lon,lat,z,OPT.levels)
    hold on
    for ii=1:E(end,4)
        jj = find(E(:,4)==ii&isnan(E(:,6)));
        plot3(E(jj,2),E(jj,1),E(jj,3),'r.');
    end
    for ii=1:E(end,4)
        jj = find(E(:,4)==ii&~isnan(E(:,6)));
        plot3(E(jj,2),E(jj,1),E(jj,3),'k*');
        h = text(E(jj,2),E(jj,1),reshape(sprintf('%5d',E(jj,6)),5,[])');
        set(h,'color','r','FontSize',6,'VerticalAlignment','top')
    end
    h = text(E(:,2),E(:,1),reshape(sprintf('%5d',1:size(E,1)),5,[])');
    set(h,'color','b','FontSize',6,'VerticalAlignment','bottom')
    view([0 90])
end


% E = 1 | 2 | 3 | 4       | 5              | 6                 | 7            | 8 
%     x | y | z | loop_nr | outer_boundary | cross contour ind | begin or end | section is used

%% 
E(:,8) = 0;
iNewContour = contour.n;
for ii =1:E(end,4)
    iE = E(:,4)==ii;
    E(find(iE==1,1,'last'),8) = 2;
    
    % for mod looping
    nn      = find( E(:,4)==ii,1,'first');
    kk      = find( E(:,4)==ii,1, 'last');
    
    while any(E(iE,8)<2) % there are non used sections in E2
        iE0 = find(E(iE,8)<2,1,'first')-1+nn; % start somewhere
        iNewContour = iNewContour+1;
        if iNewContour>contour.n
            latC            = [latC nan(size(latC,1),20)]; %#ok<AGROW>
            lonC            = [lonC nan(size(latC,1),20)]; %#ok<AGROW>
            zC              = [zC   nan(size(latC,1),20)]; %#ok<AGROW>
            contour.level  = [contour.level nan(1,20)];
            contour.n      = contour.n+20;
        end
      
        contour.level(iNewContour) = max([max(OPT.levels(OPT.levels<E(iE0,3))) OPT.levels(1)]);
        
        jNewContour = 0;
        
        iE1 = iE0;
        
        if E((mod(iE1+1-nn,kk-nn)+nn),8)<2;
            walk = 1;
        else
            walk = -1;
        end
       
        while jNewContour == 0 || iE1 ~= iE0
            edgeAddedAsLast = true;
            % add edge coordinates
            while jNewContour == 0 || (iE1 ~= iE0 && isnan(E(iE1,6)))
                E(iE1,8) = 2;
                jNewContour = jNewContour +1;
                if jNewContour>size(latC,1)
                    latC            = [latC; nan(5,size(zC,2))]; %#ok<AGROW>
                    lonC            = [lonC; nan(5,size(zC,2))]; %#ok<AGROW>
                    zC              = [zC  ; nan(5,size(zC,2))]; %#ok<AGROW>
                end
                latC(jNewContour,iNewContour) = E(iE1,1);
                lonC(jNewContour,iNewContour) = E(iE1,2);
                zC  (jNewContour,iNewContour) = E(iE1,3);
                
                iE1 = mod(iE1+walk-nn,kk-nn)+nn;
            end

            % add contour coordinates
            if jNewContour == 0 || iE1 ~= iE0
                edgeAddedAsLast = false;
                E(iE1,8) = E(iE1,8)+1;
                iContour = E(iE1,6);
                % indices of the coordinate to be added
                addContourCoordinates = find(~isnan(latC(:,iContour)));
                if ~E(iE1,7); 
                    addContourCoordinates = flipud(addContourCoordinates); 
                end

                % adjust indices
                jNewContour = jNewContour+1:jNewContour+numel(addContourCoordinates);

                % mark that contour as 'to be deleted'
                contour.toBeDeleted(iContour) = true;

                if jNewContour(end)>size(latC,1)
                    latC            = [latC; nan(length(jNewContour),size(zC,2))]; %#ok<AGROW>
                    lonC            = [lonC; nan(length(jNewContour),size(zC,2))]; %#ok<AGROW>
                    zC              = [zC  ; nan(length(jNewContour),size(zC,2))]; %#ok<AGROW>
                end

                % add the contour
                latC(jNewContour,iNewContour) = latC(addContourCoordinates,iContour);
                lonC(jNewContour,iNewContour) = lonC(addContourCoordinates,iContour);
                zC  (jNewContour,iNewContour) =             contour.level(iContour);           

                jNewContour = jNewContour(end);
                
                % find where to continue
                iE1 = find(E(:,6) ==  E(iE1,6) & E(:,7)+ E(iE1,7)==1,1);
                E(iE1,8) = E(iE1,8)+1;
                
                if iE1 ~= iE0
                    iE1 = mod(iE1+walk-nn,kk-nn)+nn;
                end
            end
        end
        if edgeAddedAsLast
            jNewContour = jNewContour +1;
            if jNewContour>size(latC,1)
                latC            = [latC; nan(1,size(zC,2))]; %#ok<AGROW>
                lonC            = [lonC; nan(1,size(zC,2))]; %#ok<AGROW>
                zC              = [zC  ; nan(1,size(zC,2))]; %#ok<AGROW>
            end
            latC(jNewContour,iNewContour) = E(iE1,1);
            lonC(jNewContour,iNewContour) = E(iE1,2);
            zC  (jNewContour,iNewContour) = E(iE1,3);
        end
    end
end

%% Delete all duplicate data, and the data from contoursToBeDeleted
contour.toBeDeleted(all(isnan(latC)))=true;
latC(:,contour.toBeDeleted) = [];
lonC(:,contour.toBeDeleted) = [];
zC  (:,contour.toBeDeleted) = [];

%% trim superfluous nan values from the coordinate arrays
zC  (all(isnan(lonC),2),:) = [];
latC(all(isnan(lonC),2),:) = [];
lonC(all(isnan(lonC),2),:) = [];

contour.level(contour.toBeDeleted) = [];
contour.n = size(latC,2);

makeTheKML(OPT,lat,lon,z,latC,lonC,zC,contour);


function OPT = makeTheKML(OPT,lat,lon,z,latC,lonC,zC,contour)
%% make all contour lines counterclockwise
for ii=1:size(latC,2)
    if ~polyIsClockwise(lonC(:,ii),latC(:,ii))
        endOfContour = find(~isnan(latC(:,ii)),1,'last');
        latC(1:endOfContour,ii) = latC(endOfContour:-1:1,ii);
        lonC(1:endOfContour,ii) = lonC(endOfContour:-1:1,ii);
        zC  (1:endOfContour,ii) = zC  (endOfContour:-1:1,ii);
    end
end

%% pre-process color data

if isempty(OPT.cLim)
    OPT.cLim         = [min(zC(:)) max(zC(:))];
end

colorRGB = OPT.colorMap(OPT.colorSteps);

% determine the area's of the different polygons
contour.area = nan(1,contour.n);
for ii=1:contour.n
    contour.area(ii) = polyarea(lonC(~isnan(latC(:,ii)),ii),latC(~isnan(latC(:,ii)),ii));
end

% [dummy,outerPoly] = max(contour.area);
mm = 0;
for outerPoly = 1:contour.n
    % OuterPoly is the outer boundary.
    
    % find the largest loop that is contained by that loop
    % polygons that form the inner boundaries
    innerPoly = [];
    % only check inpolygon for the first
    [inOuterPoly, onOuterPoly] = inpolygon(latC(1,:),lonC(1,:),...
        latC(~isnan(latC(:,outerPoly)),outerPoly),...
        lonC(~isnan(latC(:,outerPoly)),outerPoly));
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
            inInnerPoly  = inpolygon(latC(1,inOuterPoly),lonC(1,inOuterPoly),...
                latC(~isnan(latC(:,ii)),ii),...
                lonC(~isnan(latC(:,ii)),ii));
            
            % remove those the polygons from inOuterPoly
            inOuterPoly(inInnerPoly)=[];
        end
        
        if ~isempty(inOuterPoly)
            [dummy,ii] = max(contour.area(inOuterPoly)); %#ok<ASGLU>
            innerPoly(end+1) = inOuterPoly(ii); %#ok<AGROW>
        end
    end
    mm = mm+1;
    D(mm).outerPoly = outerPoly; %#ok<AGROW>
    D(mm).innerPoly = innerPoly; %#ok<AGROW>
end

contour.colorLevel = nan(size(contour.level));

% set level to the minimum level of inner and outer polygon
contour.min = nan(size(1,contour.n));
contour.max = nan(size(1,contour.n));
c           = nan(size(1,contour.n));
for ii = 1:contour.n
   contour.min(ii) = min(min(zC(:,[D(ii).outerPoly D(ii).innerPoly])));
   contour.max(ii) = max(max(zC(:,[D(ii).outerPoly D(ii).innerPoly])));
end

OPT.levels = [(2*OPT.levels(1) - OPT.levels(2)) OPT.levels];

for ii = 1:contour.n
    if contour.min(ii)~=contour.max(ii)
        c(ii) = find(OPT.levels<contour.max(ii),1,'last');
    else
        kk = 0;
 

        % Find the 5 points nearest to the first point of the polygon
        [dummy,ind] = sort((lat - latC(1,D(ii).outerPoly)).^2+(lon - lonC(1,D(ii).outerPoly)).^2);
        in = inpolygon(lat(ind(1:5)),lon(ind(1:5)),latC(:,D(ii).outerPoly),lonC(:,D(ii).outerPoly));
        if ~any(in)
            in = inpolygon(lat(ind(:)),lon(ind(:)),latC(:,D(ii).outerPoly),lonC(:,D(ii).outerPoly));
        end
        if  max(z(ind(in)))>contour.max(ii)
            kk = 0;
        else
            kk = -1;
        end
%         % start searching for a contour ...
%         for nn = [1:ii-1 ii+1:contour.n]
%             if ~isempty(D(nn).innerPoly)
%                 if any(D(nn).innerPoly == D(ii).outerPoly)
%                     if zC(1,D(nn).outerPoly)>contour.max(ii)
%                         kk = -1;
%                         break
%                     else
%                         kk = +0;
%                         break
%                     end
%                 end
%             end
%         end
        c(ii) = find(OPT.levels>=contour.max(ii),1,'first')+kk;
    end
end

% find if the loop is a local maximum
% for ii = 1:contour.n
%     if c(ii) == find(OPT.levels<min(min(zC(:,[D(ii).outerPoly D(ii).innerPoly]))),1,'last')
%         
%         
%         
%         find(any(ismember(latC,latC(1,D(ii).outerPoly))&ismember(lonC,lonC(1,D(ii).outerPoly))))
%         
%         
%         x1 =  latC(:,[D(ii).outerPoly D(ii).innerPoly]);
%         y1 =  lonC(:,[D(ii).outerPoly D(ii).innerPoly]);
%         ind = find(latC1 > min(x1) & latC1 < max(x1) & lonC1 > min(y1) & lonC1 < max(y1));
%         ind = ind(inpolygon(latC1(ind),lonC1(ind),x1,y1));
%         c(ii) = max([find(OPT.levels<max([max(z1(ind)); min(z1(:))]),1,'last') c(ii)]);
%         
%     end
% end







OPT.colorLevels = linspace(OPT.cLim(1),OPT.cLim(2),OPT.colorSteps);
[dummy,ind] = min(abs(repmat(OPT.colorLevels,length(OPT.levels),1) - repmat(OPT.levels',1,length(OPT.colorLevels))),[],2); %#ok<ASGLU>

c = ind(c);


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
for ii = unique(c)'
    OPT_stylePoly.name = ['style' num2str(ii)];
    OPT_stylePoly.fillColor = colorRGB(ii,:);
    output = [output KML_stylePoly(OPT_stylePoly)]; %#ok<AGROW>
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
    OPT_poly.styleName = sprintf('style%d',c(ii));
    
    x1 =  latC(:,[D(ii).outerPoly D(ii).innerPoly]);
    y1 =  lonC(:,[D(ii).outerPoly D(ii).innerPoly]);
    if OPT.is3D
        if OPT.staggered
            z1 = height(D(ii).outerPoly);
            z1 = repmat(z1,size(x1,1),size(x1,2));
            z1 = OPT.zScaleFun(z1);
        else
            z1 = zC(:,[D(ii).outerPoly D(ii).innerPoly]);
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


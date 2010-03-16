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
% * Also inclue *all* edge vertices in contours
% * Multiple contour crossings on one boundary gives a problem
% * Improve edge find algortihm (and turn it into seperate function)
% * Major code cleaning
% * Optimization of slow routines (think it can be made faster)

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

if isempty(OPT.colorSteps), OPT.colorSteps = OPT.levels; end

%% input check

   lat = lat(:);
   lon = lon(:);
   z   =   z(:);

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

   C =   tricontourc(tri,lat,lon,z,OPT.levels);
   E = trisurf_edges(tri,lat,lon,z);

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
%  close loops by walking along the edge where a contour ends, until one runs
%  into another contour that starts on the edge. Follow that contour, and
%  then coninue along the edge, and so forth, until the routine is back at
%  the beginning of the initial contour. 
%
%  Unfortunately, the code got extremely messy...

   lat2 = [lat; nan(size(lat,1)*5,size(lat,2))];
   lon2 = [lon; nan(size(lat,1)*5,size(lat,2))];
   
   z2 = repmat(height,size(lat2,1),1);
   z2(isnan(lat2))=nan;
   
   contourToBeDeleted = [];
   for ii = find(~closedLoop)
   
      if ismember(ii,contourToBeDeleted)
          %do nothing
      else
         endOfContour = find(~isnan(lat(:,ii)),1,'last');
         searchDirection = 1;
                 
         while ~(lat2(1,ii)==lat2(endOfContour,ii) &&...
                 lon2(1,ii)==lon2(endOfContour,ii));
             
             % determine where the contour end could possibly be
             % find all lines on the edge that cross the contour
             
             
             % temp0 = indices of all the edge lines that cross height(ii)
             % temp1 = difference of z and height(ii) on edge lines that
             %         cross the height
             % temp2 = weigting of the first and second coordinate (to find
             %         the crossing location on the edge line
             % temp3 = exact crossing locations
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
             % in some cases, more than one edgeLineAtEndOfContour is found,
             % namely when the crossing is at the end or begin of the edge
             % line.
             edgeLineAtEndOfContour = edgeLineAtEndOfContour(end);
             
             % determine to go forwards of backwards through edge lines,
             % searchDirection = 1  go in the direction of the highest z value
             % searchDirection = 2  go in the direction of the lowest z value
             
             [dummy,temp5] = max(E(edgeLineAtEndOfContour,[3 6]));
             if temp5==searchDirection
                 x_to_add = 1;y_to_add = 2;z_to_add = 3;
                 searchForwards = false;
             else
                 x_to_add = 4;y_to_add = 5;z_to_add = 6;
                 searchForwards = true;
             end
             
             % determine the next highest height level
             nextHeight = min(height(height>height(ii)));
             if isempty(nextHeight)
                 nextHeight = inf;
             end
             % start adding edge coordinates to the polygon
             edgeCoordinateToAdd = edgeLineAtEndOfContour;
            try 
             while E(edgeCoordinateToAdd,z_to_add)>height(ii)&&...
                     E(edgeCoordinateToAdd,z_to_add)<nextHeight
                 endOfContour = endOfContour+1;
                 E(edgeCoordinateToAdd,9) = 1; % record that that edge piece is used in a contour
                 lat2(endOfContour,ii) = E(edgeCoordinateToAdd,x_to_add);
                 lon2(endOfContour,ii) = E(edgeCoordinateToAdd,y_to_add);
                   z2(endOfContour,ii) = E(edgeCoordinateToAdd,z_to_add);
                 
                 if searchForwards
                     edgeCoordinateToAdd = E(edgeCoordinateToAdd,8);
                 else
                     edgeCoordinateToAdd = E(edgeCoordinateToAdd,7);
                 end
             end
            catch
                a=1
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
                 endOfContour = endOfContour+1;
                 lat2(endOfContour,ii) = lat2(1,ii);
                 lon2(endOfContour,ii) = lon2(1,ii);
                   z2(endOfContour,ii) = height(ii);   
             else
                 lat2(endOfContour+(1:max(nextContourIndices)),ii) = lat(nextContourIndices,nextContour);
                 lon2(endOfContour+(1:max(nextContourIndices)),ii) = lon(nextContourIndices,nextContour);
                   z2(endOfContour+(1:max(nextContourIndices)),ii) = height(nextContour);
                 if height(nextContour)==height(ii)&~ismember(ii,contourToBeDeleted)
                     % then the nextContour in itself would result in a
                     % connecting contour identical to the one already being
                     % created.
                     contourToBeDeleted(end+1) = nextContour;
                 end
             end
             endOfContour = find(~isnan(lat2(:,ii)),1,'last');
         end
         closedLoop(ii) = true;
         % some test plotting for debugging
         %
         %     disp(num2str(ii));
         %     plot(lon2(:,ii),lat2(:,ii),'.')
         %     axis([min(lon2(:))-1,max(lon2(:))+1,min(lat2(:))-1,max(lat2(:))+1]);
         %     hold on
         %     plot(lon2(:,ii),lat2(:,ii))
         %     scatter3(lon2(:,ii),lat2(:,ii),1:numel(lon2(:,ii)))
         %     fill(lon2(~isnan(lon2(:,ii)),ii),lat2( ~isnan(lat2(:,ii)),ii),'c')
         %     title(num2str([polyIsClockwise(lon2(:,ii),lat2(:,ii))]))
         %     hold off
      end
   end

%%

     z2(all(isnan(lat2),2),:) = [];
   lat2(all(isnan(lat2),2),:) = [];
   lon2(all(isnan(lon2),2),:) = [];
   
   lat = lat2;
   lon = lon2;
   
   lat(:,contourToBeDeleted) = [];
   lon(:,contourToBeDeleted) = [];
    z2(:,contourToBeDeleted) = [];
   closedLoop(contourToBeDeleted) = [];
   nContours = nContours -numel(contourToBeDeleted);
   height(contourToBeDeleted) = [];

%% make all contour lines counterclockwise

   for ii=1:size(lat,2)
       if ~polyIsClockwise(lon(:,ii),lat(:,ii))
           endOfContour = find(~isnan(lat(:,ii)),1,'last');
           lat(1:endOfContour,ii) = lat(endOfContour:-1:1,ii);
           lon(1:endOfContour,ii) = lon(endOfContour:-1:1,ii);
            z2(1:endOfContour,ii) =  z2(endOfContour:-1:1,ii);
       end
   end

%% pre-process color data

   if isempty(OPT.cLim)
      OPT.cLim         = [min(z(:)) max(z(:))];
   end

   if isnumeric(OPT.colorMap)
      OPT.colorSteps = size(OPT.colorMap,1);
   end

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

   %  convert color values into colorRGB index values
    [dummy,dummy,c] = unique(height);

%% find polygon area if the coordinates are a closed loop

   polyArea = nan(1,nContours);
   for ii=1:nContours
       if closedLoop(ii)
           polyArea(ii) = polyarea(lon(~isnan(lat(:,ii)),ii),lat(~isnan(lat(:,ii)),ii));
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
              [dummy,ii] = max(polyArea(inOuterPoly));
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
       if OPT.is3D
           if OPT.staggered
               z1 = height(D(ii).outerPoly);
               z1 = repmat(z1,size(x1,1),size(x1,2));
               z1 = OPT.zScaleFun(z1);
           else
               z1 = z2(:,[D(ii).outerPoly D(ii).innerPoly]);
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


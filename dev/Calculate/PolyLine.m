%Class to declare the most common PolyLine
%
% @author ABR
% @author SEO
% @version 0.8, 10/02/2014
%

classdef PolyLine < handle
    %Public properties
    properties
        Property1;
    end

    %Dependand properties
    properties (Dependent = true, SetAccess = private)

    end

    %Private properties
    properties(SetAccess = private)

    end

    %Default constructor
    methods
        function obj = Template(property1)
            if nargin > 0
                obj.Property1 = property1;
            end
        end
    end

    %Set methods
    methods
        function set.Property1(obj,property1)
            obj.Property1 = property1;
        end
    end

    %Get methods
    methods
        function property1 = get.Property1(obj)
            property1 = obj.Property1;
        end
    end

    %Public methods
    methods

    end

    %Private methods
    methods (Access = 'private')

    end

    %Stactic methods
    methods (Static)
        
        
        function [xNew,yNew] = buffer(x,y,dx)
            % make a polyline with all points at a certain distance from
            % the original
            %
            % [xNew,yNew] = buffer(x,y,dx)
            %
            % INPUT:
            % - x,y: vectors with coordinates of the polyline
            % - dx: vector with distance to the polyline; positive is outward
            % OUTPUT
            % - xNew,yNew : matrix with new polylines; different colums are
            % with different distance dx.
            

            
            % preallocate
            nrX  = length(x);
            nrDx = length(dx);
            
            xNew = zeros(nrX,nrDx);
            yNew = zeros(nrX,nrDx);
            
            [xC,yC] = PolyLine.centroid(x,y);
            for i= 1:nrX
                % determine directional vectors
                a = x(i)-xC;
                b = y(i)-yC;
                n = hypot(a,b);
                a = a/n;
                b = b/n;
                
                % extend lines
                xNew(i,:) = x(i)+dx.*a;
                yNew(i,:) = y(i)+dx.*b;                
            end
        end
        
        function [xC,yC] = centroid(x,y)
            % centroid of a polyline
            %
            % [xC,yC] = centroid(x,y)
            %
            polyS   = polyshape(x,y);
            [xC,yC] = centroid(polyS);
        end
        
        function [xC,yC] = centreLine(xL,yL,xR,yR,dx)
            % make a line in the middle between two polylines
            %
            % [xC,yC] = centreLine(xL,yL,xR,yR,dx)
            %
            % INPUT:
            % - xL,yL: coordinates (Mx1 vector) of left bank
            % - xR,yR: coordinates (Mx1 vector) of right bank
            % - dx: estimated distance between two points in the new line
            %
            % OUTPUT:
            % -xC,yC: [Nx1 vector] with a line in the middle between the
            % two banks
            

            % hard programmed parameters
            LARGE = 100000;
            DX_MIN = 0.5;
            JMAX   = 5;
            
            
            x1 = 0.5*(xL(1)+xR(1));
            y1 = 0.5*(yL(1)+yR(1));
            
            xC = zeros(LARGE,1);
            yC = zeros(LARGE,1);
            n = 1;
            
            xC(n) = x1;
            yC(n) = y1;
            
            % normal vector
            nX = yR(1)-yL(n);
            nY = xL(1)-xR(n);
            nL = hypot(nX,nY);
            nX = -nX./nL;
            nY = -nY./nL;
            
            while 1
                % do an esitimate of new point based on
                xPred = xC(n)+nX*dx;
                yPred = yC(n)+nY*dx;
                n = n + 1;
                % determine the distance to the bank
                [distL,indL] = PolyLine.dist2poly([xPred,yPred],[xL,yL]);
                [distR,indR] = PolyLine.dist2poly([xPred,yPred],[xR,yR]);
                
                j = 1;
                while 1
                    % update position to in the centre between the lines
                    nXtmp = 0.5*(xL(indL)+xL(indL+1) - (xR(indR)+xR(indR+1)));
                    nYtmp = 0.5*(yL(indL)+yL(indL+1) - (yR(indR)+yR(indR+1)));
                    nL = hypot(nXtmp,nYtmp);
                    nXtmp = nXtmp./nL;
                    nYtmp = nYtmp./nL;
                    % update new position
                    dxTmp = (distL-distR)/2;
                    xPred = xPred + dxTmp*nXtmp;
                    yPred = yPred + dxTmp*nYtmp;
                    [distL,indL] = PolyLine.dist2poly([xPred,yPred],[xL,yL]);
                    [distR,indR] = PolyLine.dist2poly([xPred,yPred],[xR,yR]);
                    % stop if converged
                    if abs(distL-distR)<DX_MIN ||j==JMAX
                        break;
                    end
                    j = j+1;
                end
                xC(n) = xPred;
                yC(n) = yPred;
                % update direction
                if n>1
                    nXold = nX;
                    nYold = nY;
                end
                nX = xC(n)-xC(n-1);
                nY = yC(n)-yC(n-1);
                nL = hypot(nX,nY);
                nX = nX./nL;
                nY = nY./nL;
                if n>1
                    dTheta = 180/pi*abs(acos(nX*nXold +nY*nYold));
                    if dTheta>90
                        error('Line search does not converge');
                    end
                end
                if indL==length(xL)-1 || indR==length(xR)-1 || n>3*length(xR)
                    break;
                end
            end
            % delete unused points
            xC(n+1:end) = [];
            yC(n+1:end) = [];
        end
        
        function cXy = convertNanLineType (x,y)
            % converts a list of lines sperate by nans to a cell
            %
            % cXy = convertNanLineType (x,y)
            %
            % INPUT
            % - x,y: x and y data in column vectors
            % OUTPUT:
            % -cXy: cell array with each polyline in a separate cell
            % (BlueKenue like). There, the data is a matrix with two
            % columns, containing x and y data.
            %
            allNan = [0;find(isnan(x(:,1)))];
            for i = length(allNan)-1:-1:1
                mask = allNan(i)+1:allNan(i+1)-1;
                cXy{i}(:,2) = y(mask,:);
                cXy{i}(:,1) = x(mask,:);
            end
        end
        
        function [x,y] = extend(x,y,dX,atStart)
            % extends polyline with distance dX
            %
            % [x,y] = extend(x,y,dX,atStart)
            % INPUT:
            % - x,y: coordinates of polyline
            % -dX : distance to update polyline
            % atStart: if true  change is at the start, otherwise it is at
            % the end
            % OUTPUT:
            % -x,y: updated coordinates
            
            if atStart
                dx = x(2)-x(1);
                dy = y(2)-y(1);
            else
                dx = x(end)-x(end-1);
                dy = y(end)-y(end-1);
            end
            dS = hypot(dx,dy);
            dx = dx/dS;
            dy = dy/dS;
            if atStart
                x(1) = x(2)-dX*dx;
                y(1) = y(2)-dX*dy;
            else
                x(end) = x(end-1)+dX*dx;
                y(end) = y(end-1)+dX*dy;
            end
        end
                
            
        
        function [xCsAll,yCsAll] = crossSections(xC,yC,dX,xL,yL,xR,yR)
            % generate a list of coordinates of corsssections to a line
            %
            % [xCsAll,yCsAll] = crossSections(xC,yC,dX,xL,yL,xR,yR)
            %
            %
            % INPUT:
            %  -xC,yC: [Nx1] : list of coordinates of center of a river
            %  -dX: distance: may be scalar or vector
            %  -xL,yL,xR,yR (optional): [Mx1] list of coordinates of the
            %  left and right bank of the river. if added corssections are
            %  stopped at te banks
            % OUTPUT:
            %  - xCsAll,yCsAll: [2,N-1]: list of left and right coordinates of the crossections 
            lineDir = PolyLine.polyDir([xC,yC]);
            cosDir  = cos(lineDir);
            sinDir  = sin(lineDir);
            nrBin   = length(xC)-1;
            useIntersec = nargin>3;
            if numel(dX) == 1
                nrY = 2;
            else
                nrY = numel(dX);
            end
            xCsAll = zeros(nrBin,nrY);
            yCsAll = zeros(nrBin,nrY);
            
            %extrapolate the left and right banks at start and end, to
            %prevent the occurrance of misses.
            if useIntersec
                [xL,yL] = PolyLine.extend(xL,yL,dX,true);
                [xL,yL] = PolyLine.extend(xL,yL,dX,false);
                [xR,yR] = PolyLine.extend(xR,yR,dX,true);
                [xR,yR] = PolyLine.extend(xR,yR,dX,false);
            end

            
            for i=1:nrBin
                % make a box over a line perpendicular to the line
                xTmp = 0.5*(xC(i+1)+xC(i));
                yTmp = 0.5*(yC(i+1)+yC(i));
                % bounding box
                
                if numel(dX) == 1
                    xCsTmp   =  [0,0];
                    yCsTmp   =  [-dX,dX];
                else
                    xCsTmp   =  0;
                    yCsTmp   =  dX;
                end
                % rotate and translate
                xCs      = cosDir(i).*xCsTmp- sinDir(i).*yCsTmp + xTmp;
                yCs      = sinDir(i).*xCsTmp+ cosDir(i).*yCsTmp + yTmp;
                % cut of at intersections if needed
                if useIntersec
                    [xLtmp,yLtmp] = intersections(xL,yL,xCs,yCs);
                    if numel(xLtmp)>1
                        % find closest point
                        [~,ind] = min(hypot(xLtmp-xC(i),yLtmp-yC(i))); 
                        xLtmp = xLtmp(ind);
                        yLtmp = yLtmp(ind);
                    elseif numel(xLtmp)<1
                        error('No matching cross scetion found; increase dX');
                    end
                    [xRtmp,yRtmp] = intersections(xR,yR,xCs,yCs);
                    if numel(xRtmp)>1
                        % find closest point
                        [~,ind] = min(hypot(xRtmp-xC(i),yRtmp-yC(i))); 
                        xRtmp = xRtmp(ind);
                        yRtmp = yRtmp(ind);
                    elseif numel(xRtmp)<1
                        error('No matching cross scetion found; increase dX');
                    end                    
                else
                    xLtmp = xCs(1);
                    yLtmp = yCs(1);
                    xRtmp = xCs(2);
                    yRtmp = yCs(2);
                end
                % add data to a List
                if numel(dX) == 1
                    xCsAll(i,:)= [xLtmp,xRtmp];
                    yCsAll(i,:)= [yLtmp,yRtmp];
                else
                    xCsAll(i,:)= xCs;
                    yCsAll(i,:)= yCs;
                end
            end
            % mirror, such that plotting is more easy
            xCsAll = xCsAll';
            yCsAll = yCsAll';
            
        end
        
        function dist = distAlong(x,y)
            % calculates the distance along a line
            %
            % dist = distAlong(x,y)
            %
            % INPUT: 
            % - x,y: [Nx1]: column vectors with coordinates
            %
            % OUTPUT: 
            % -dist: [Nx1]: distance laonge the line
            
            dist = [0;cumsum(hypot(diff(x),diff(y)))];
        end
        
        function dist = dist2line(xyP,xyL)
            % calculates the distance from a point to a line
            %
            % dist = dist2line(xyP,xyL)
            %
            % INPUT
            % - xyP: [Nx2] matrix with x and y coordinates of points to
            % check
            % - xyL: [Mx2] matrix with x and y coordinates of the lines 
            % OUTPUT
            % - dist [NxM-1]: the distance from the point(s) to the line(s)
            %
            x1 = xyL(1:end-1,1);
            x2 = xyL(2:end,1);
            y1 = xyL(1:end-1,2);
            y2 = xyL(2:end,2);
            
            dx = x2-x1;
            dy = y2-y1;
            
            ds = sqrt(dx.^2+dy.^2);
            dxy = x2.*y1-y2.*x1;
            
            xP = xyP(:,1)';
            yP = xyP(:,2)';
            dist = abs(xP.*dy - yP.*dx + dxy)./ds;
            dist = dist';
            
        end
        
        function [dist,ind,xProj,yProj] = dist2poly(xyPoint,xyPoly)
            % calculate the distance of a vector of points to a polyline
            %
            % [dist,ind,xProj,yProj] = dist2poly(xyPoint,xyPoly)
            %
            %INPUT:
            %     - xyPoint: [Nx2] matrix with x and y coordinates of the points to consider
            %     - xyPoly: [Mx2] matrix with x and y coordinates of the polyline
            %OUTPUT
            %     - dist: Nx1 vector with the distance of each point to the polyline
            %     - ind : Nx1 vector with the index of the segment of the
            %             polyline that is closest
            %     -xProj,yProj: [Nx1] vector wih coordinates of the
            %     projected point
            %
            % More info:
            %http://programmizm.sourceforge.net/blog/2012/distance-from-a-point-to-a-polyline

            % written by: ABR
            % date: 5-8-2013
            nrPoly  = size(xyPoly,1);
            nrPoint = size(xyPoint,1);
            
            % check sizes
            if size(xyPoly,2)~=2
                error('Wrong input. Data must be organized by columns');
            end
            if size(xyPoint,2)~=2
                error('Wrong input. Data must be organized by columns');
            end
            

            % preallocation/preparartion
            dist   = nan(nrPoint,1);
            ind    = nan(nrPoint,1);
            xProj  = nan(nrPoint,1);
            yProj  = nan(nrPoint,1);
            qx   = xyPoint(:,1);
            qy   = xyPoint(:,2);

            % calculate the squared length of each of the segments of the polyline
            for iPoly = 1:nrPoly-1
                % calculate
                %t = (ax-bx) (ax-qx) + (ay-by)(ay-qy) = dX (ax-qx) + dy (ay-dy)
                ax = xyPoly(iPoly,1);
                bx = xyPoly(iPoly+1,1);
                ay = xyPoly(iPoly,2);
                by = xyPoly(iPoly+1,2);

                dX = ax-bx;
                dY = ay-by;

                lengthSquared = dX.^2 + dY.^2;
                invLengthSquared = 1./lengthSquared;

                t = dX.* (ax-qx) + dY.* (ay-qy);
                t = t.*invLengthSquared;

                % handle cases for t smaller zero and t larger 1
                mask0 = t<0;
                mask1 = t>1;

                % calculate squared distance distance
                tempDist = (dX.*(by-qy) - dY.*(bx-qx)).^2;
                tempDist = tempDist.*invLengthSquared;


                % calculate distance to start point
                startDist = (ay-qy).^2 + (ax-qx).^2;
                tempDist(mask0) = startDist(mask0);

                % calculate distance to the endpoint
                endDist = (by-qy).^2 + (bx-qx).^2;
                tempDist(mask1) = endDist(mask1);

                % look for the smallest distance
                dist = min(tempDist,dist);
                mask = (tempDist==dist);
                if any(mask)
                    ind(mask) = iPoly;
                    % also find the projected coordinates
                    if nargout>2
                        xTmp = ax + t.*(bx-ax);
                        yTmp = ay + t.*(by-ay);
                        xProj(mask)  = xTmp(mask);
                        yProj(mask)  = yTmp(mask);
                    end
                end


            end

            % calculate distance
            dist = sqrt(dist);
        end
        
        function [xBb,yBb] = boundingBox(x,y)
            % determines the bounding box from a list of xy data
            %
            %  [xBb,yBb] = boundingBox(x,y)
                
            % coordinates bounding box
            x0 = min(x);
            y0 = min(y);
            x1 = max(x);
            y1 = max(y);
            xBb = [x0,x1,x1,x0,x0]';
            yBb = [y0,y0,y1,y1,y0]';
        end
        
        function ind =  closestSegment(xyPoint,xyPoly)
            % finds closes segment of a polyline
            %
            % note for closed polylines, the last point should equal the
            % first
            
            nrX    = size(xyPoint,1);
            ind    = zeros(nrX,1);
            
            % geometric quantities of polyline
            x  = xyPoint(:,1);
            y  = xyPoint(:,2);
            xP = xyPoly(:,1);
            yP = xyPoly(:,2);
            dx = diff(xP);
            dy = diff(yP);
            dL = sqrt(dx.^2+dy.^2);
            crt= x(2:end).*y(1:end-1)-y(2:end)-x(1:end-1);
            
            % look for closest line element
            for i=1:nrX
                allDist = abs((dy.*x(i) -dx.*y(i) + crt)./dL);
                [~,ind(i)] = min(allDist);
            end
        end

        function isLeft = leftOf(xL,yL,xP,yP)
            % determines whether a line is left of a point
            %
            %isLeft = leftOf(xL,yL,xP,yP)
            %
            %INPUT:
            %
            % -  xL, yL: [2x1] vector with the x and y coordinates of a line
            % -  xP, yP: [Mx1] vector with x and y coordinates of the points to check
            %
            % OUTPUT
            % - isLeft: [Mx1] vector which is true if teh points is to the
            % left of a line
            
            dx = xL(2)-xL(1);
            dy = yL(2)-yL(1);
            d = (xP-xL(1)).*dy - (yP-yL(1)).*dx;
            isLeft = d<0;
            
        end
        
        function polyLine = leftOfPrepare(xL,yL,xBb,yBb)
            % makes a closed polyline that can be used to check whether a
            % point is on the left or on the right using a bounding box
            %
            % polyLine = leftOfPrepare(xL,yL,xBb,yBb)
            %
            % INPUT:
            %  -xL,yL: [Nx1] points of the polyline
            %  -xBb,yBb: [2x1] lower left and upper right point of the bounding box 
            %
            % OUTPUT:
            % - polyLine: [Mx2] xy and points of new closed polyline
            %
            
            VERY_LARGE = 1e12;
            
           
            [eX,eY] = PolyLine.polyDirVec([xL,yL]);

            x0Tmp = xL(1)+eX(1).*VERY_LARGE.*[-1 0];
            y0Tmp = yL(1)+eY(1).*VERY_LARGE.*[-1 0];
            x1Tmp = xL(end)+eX(end).*VERY_LARGE.*[0 1];
            y1Tmp = yL(end)+eY(end).*VERY_LARGE.*[0 1];
            
            [xSelf,ySelf] = intersections(x0Tmp,y0Tmp,x1Tmp,y1Tmp);
            if ~isempty(xSelf)
                intWithBb = inpoly([xSelf,ySelf],[xBb,yBb]);
            else
                intWithBb = false;
            end
            
            % check if  point were lines join is inde
            if intWithBb
                polyLine = [xL([1:end,1]),yL([1:end,1])];
            else
                % intersection between data and bounding box
                [xSt,ySt,iSt]    = intersections(xBb,yBb,x0Tmp,y0Tmp);
                [xEnd,yEnd,iEnd] = intersections(xBb,yBb,x1Tmp,y1Tmp);
                % join line and polyline to make polyline
                if iEnd>iSt
                    iEnd = floor(iEnd);
                    iSt  =  ceil(iSt);
                    polyLine(:,2) = [ySt;yL;yEnd;yBb(iEnd:-1:iSt);ySt];
                    polyLine(:,1) = [xSt;xL;xEnd;xBb(iEnd:-1:iSt);xSt];
                else
                    iEnd = ceil(iEnd);
                    iSt  =  floor(iSt);
                    polyLine(:,2) = [ySt;yL;yEnd;yBb(iEnd:iSt);ySt];
                    polyLine(:,1) = [xSt;xL;xEnd;xBb(iEnd:iSt);xSt];
                end
            end
        end
        
        function [eX,eY] = polyDirVec(xyPoly)
            % get the direction vectors of all segments of a polyline
            %
            % [eX,eY] = polyDirVec(xyPoly)
            %
            %
            xP  = xyPoly(:,1);
            yP  = xyPoly(:,2);
            dx  = diff(xP);
            dy  = diff(yP);
            ds = sqrt(dx.^2+dy.^2);
            eX = dx./ds;
            eY = dy./ds;
        end        
        
        function dir = polyDir(xyPoly)
            % get the direction of all segments of a polyline
            %
            % dir = polyDir(xyPoly)
            %
            %
            xP  = xyPoly(:,1);
            yP  = xyPoly(:,2);
            dx  = diff(xP);
            dy  = diff(yP);
            dir = atan2(dy,dx);
        end
        
        function [x2,y2] = simpRadial (x,y,threshold)
            % radial distance polyline simplification
            %
            % [x2,y2] = simpRadial (x,y,threshold)
            %
            %
            % http://psimpl.sourceforge.net/radial-distance.html
            
            th   = threshold^2;
            nrX   = length(x);
            mask = true(nrX,1);
            n = 1;
            while n <nrX-1
                xT = x(n+1:end);
                yT = y(n+1:end);
                d  = (x(n)-xT).^2 + (y(n)-yT).^2 ;
                n2 = find(d>th,1,'first');
                mask(n+1:n2) = false;
                n  = n2;
            end
            x2 = x(mask);
            y2 = y(mask);
        end
        
        function [x2,y2] = simpPerpendicular (x,y,threshold)
            % perpendicular distance polyline simplification (opheim
            % method)
            %
            % [x2,y2] = simpPerpendicular (x,y,threshold)
            %
            %
            % 
            
            mask = opheimSimplify(x,y,threshold);
            x2 = x(mask);
            y2 = y(mask);
        end
        
       function [x2,y2] = simpDp (x,y,threshold)
            %  polyline simplification Douglas-Peucker algoritm
            %
            % [x2,y2] = simpDp (x,y,threshold)
            %
            %
            % 
            ps = dpsimplify([x,y],threshold);
            x2 = ps(:,1);
            y2 = ps(:,2);
        end
        
        function [x2,y2] = simpArea (x,y,threshold)
            % area polyline simplification
            %
            % [x2,y2] = simpPerpendicular (x,y,threshold)
            %
            % Visvalingam algoritm
            % https://bost.ocks.org/mike/simplify/
            % https://hydra.hull.ac.uk/assets/hull:8338/content
            
            
            % calculate area

            % area of a triangle
             % A = 0.5 |(xa-xc)*(yb-ya) - (xa-xb)*(yc-ya)|
             
             A = [inf;
                 0.5.*abs( (x(1:end-2)-x(3:end))  .*(y(2:end-1)-y(1:end-2)) - ...
                           (x(1:end-2)-x(2:end-1)).*(y(3:end  )-y(1:end-2)));
                 inf;          
                 ];          
            [minA,ind] = min(A);
            x2 = x;
            y2 = y;
            while minA<threshold
                % delete point with smallest area
                x2(ind) = [];
                y2(ind) = [];
                A(ind) = [];
                % update areas at delete point
                if ind <length(x2)-1
                    A(ind)   = 0.5.*abs( (x2(ind-1)-x2(ind+1)).*(y2(ind)  -y2(ind-1)) - ...
                                         (x2(ind-1)-x2(ind  )).*(y2(ind+1)-y2(ind-1)));
                end
                if ind>2
                    A(ind-1) = 0.5.*abs( (x2(ind-2)-x2(ind  ))  .*(y2(ind-1)-y2(ind-2)) - ...
                                         (x2(ind-2)-x2(ind-1))  .*(y2(ind  )-y2(ind-2)));
                end
                % find minimum
                [minA,ind] = min(A);
            end
        end
        
        function polyObc =makePoly(indObc)
            % make a polyline out of data from freeBoundary
            %
            % polyObc =makePoly(indObc)
            %
            % INPUT:
            % - indObc: list of nodes of the boundary from freeBoundary
            % [Nx2]
            % OUTPUT:
            % - polyObc: polyline list of noded (ordered) celll with [Mx1]
            % arrays
            % REMARKS:
            % - does not yet included multiple polylines in case of islands
            k = 1;
            while ~isempty(indObc)
                polyObcTmp = zeros(numel(indObc),1);
                polyObcTmp(1:2) = indObc(1,:);
                indObc(1,:) = [];
                n = 2;
                nodeNr = polyObcTmp(2);

                while true
                    ind = find(any(indObc==nodeNr,2),1,'first');
                    if ~isempty(ind)
                        tmp = indObc(ind,:);
                        indObc(ind,:) = [];
                        nodeNr = tmp(tmp~=nodeNr);
                        n = n+1;
                        polyObcTmp(n) = nodeNr;
                    else
                        break
                    end
                end
                polyObcTmp(n+1:end) = [];
                polyObc{k} = polyObcTmp;
                k = k + 1;
            end
        end
        
    end
end
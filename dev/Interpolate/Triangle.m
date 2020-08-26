classdef Triangle < handle
    %Class for interpolation and calculations on triangular meshes
    %
    
    
    
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
    methods(Static)
        
        function fractions = calcAreaFractions(XY,Connect,Depth,DepthThreshold)
            % Function to assess the fraction of the surface of each element
            % that is below a threshold depth.
            %
            % fractions = calcAreaFractions(Connect,Depth,DepthTreshold)
            % INPUT:
            %    XY: [Nx3] matrix with coordinates at the corners of the
            %        triangles, N equals the number of nodes.
            %    Connect: [Mx3] maxtrix with connections of the triangles,
            %        M equals the number of elements
            %    Depth: Nx1 matrix with depth values in the corners of
            %        triangles
            %    DepthThreshold: single value with threshold depth
            % OUTPUT: 
            %    fractions: [Mx1] vector with the fraction of the surface
            %        area of an element that is below the DepthThreshold.
            
            % get the coordinate of the triangles
            x1 =  XY(Connect(:,1),1);
            x2 =  XY(Connect(:,2),1);
            x3 =  XY(Connect(:,3),1);
            y1 =  XY(Connect(:,1),2);
            y2 =  XY(Connect(:,2),2);
            y3 =  XY(Connect(:,3),2);
            
            xx = [x1 x2 x3];
            yy = [y1 y2 y3];
            % combine the depths of elements and sort from deepest to
            % shallow
            [H,I] = sort(Depth(Connect),2); 

            xxsorted = nan(size(xx));
            yysorted = nan(size(yy));
            % van h1->h2->h3
            for i=1:size(I,1)
                xxsorted(i,:) = xx(i,I(i,:));
                yysorted(i,:) = yy(i,I(i,:));
                if H(i,2)==H(i,1) 
                    % make sure that point 1 is most right point (important for area calculation, counterclockwise points)
                    if xxsorted(i,2)>xxsorted(i,1)
                        xtemp = xxsorted(i,:);
                        xxsorted(i,1) = xtemp(2);
                        xxsorted(i,2) = xtemp(1);
                        ytemp = yysorted(i,:);
                        yysorted(i,1) = ytemp(2);
                        yysorted(i,2) = ytemp(1);
                    end
                end
                if H(i,3)==H(i,2) 
                    % make sure that point 3 is most right point (important for area calculation, counterclockwise points)
                    if xxsorted(i,3)<xxsorted(i,2)
                        xtemp = xxsorted(i,:);
                        xxsorted(i,2) = xtemp(3);
                        xxsorted(i,3) = xtemp(2);
                        ytemp = yysorted(i,:);
                        yysorted(i,2) = ytemp(3);
                        yysorted(i,3) = ytemp(2);
                    end
                end
            end
            x1s = xxsorted(:,1);
            x2s = xxsorted(:,2);
            x3s = xxsorted(:,3);
            y1s = yysorted(:,1);
            y2s = yysorted(:,2);
            y3s = yysorted(:,3);

            % Points at intersections 
            % - A, B for situation with h2<H<h3
            % - C, D for situation with h1<H<h2
            % - D for situation with H=h2
            xA = x3s+(DepthThreshold-H(:,3))./(H(:,2)-H(:,3)).*(x2s-x3s);
            xB = x3s+(DepthThreshold-H(:,3))./(H(:,1)-H(:,3)).*(x1s-x3s);
            xC = x1s+(DepthThreshold-H(:,1))./(H(:,2)-H(:,1)).*(x2s-x1s);
            xD = x1s+(DepthThreshold-H(:,1))./(H(:,3)-H(:,1)).*(x3s-x1s);
            yA = y3s+(DepthThreshold-H(:,3))./(H(:,2)-H(:,3)).*(y2s-y3s);
            yB = y3s+(DepthThreshold-H(:,3))./(H(:,1)-H(:,3)).*(y1s-y3s);
            yC = y1s+(DepthThreshold-H(:,1))./(H(:,2)-H(:,1)).*(y2s-y1s);
            yD = y1s+(DepthThreshold-H(:,1))./(H(:,3)-H(:,1)).*(y3s-y1s);
            
            areas = Triangle.triangleVolume(Connect,XY,ones(size(XY,1),1));

            % situation with H<=h1, not covered (area = 0, default)
            wetareas = zeros(size(areas));
            % situation with h2<H<h3
            ind = H(:,2)<DepthThreshold & H(:,3)>DepthThreshold;
            areacalc = areas - 1/2*abs( x3s.*(yA-yB) + xA.*(yB-y3s) + xB.*(y3s-yA) );
            wetareas(ind) = areacalc(ind);
            % situation with H=h2
            ind = H(:,2)==DepthThreshold;
            areacalc = 1/2*abs(x2s.*(y1s-yD) + x1s.*(yD-y2s) + xD.*(y2s-y1s));
            wetareas(ind) = areacalc(ind);
            % situation with h1<H<h2
            ind = H(:,1)<DepthThreshold & H(:,2)>DepthThreshold;
            areacalc = 1/2*abs(x1s.*(yD-yC) + xD.*(yC-y1s) + xC.*(y1s-yD));
            wetareas(ind) = areacalc(ind);
            % situation with h3<=H
            ind = H(:,3)<=DepthThreshold;
            wetareas(ind) = areas(ind);

            fractions = wetareas./areas;
            
            %%%%%%%%%%%%
            % OLD method - something goes wrong
            %%%%%%%%%%%%
            
            %             % to avoid negative problems make everything positive
            %             minDepth = floor(min(min(Depth),DepthThreshold)-1);
            %             DepthThreshold = DepthThreshold-minDepth;
            %             H = sort(Depth(Connect)-minDepth,2);
            %             % make matrix with per element [h1 h2 h3], with h1<h2<h3 the
            %             % elevatioins at the corner of an element
            %             % Surface fraction: (h3-h)^2 / ((h3-h1)(h3-h2))
            %             % fraction is dry part for h > h2
            %             % fraction is wet part for h < h2
            %             % In case of h2 = h3, surface fraction: (h1-h)^2 / ((h1-h3)(h1-h2))
            %
            %
            %             fractions = (H(:,3)-DepthThreshold).^2./...
            %                 ((H(:,3)-H(:,1)).*(H(:,3)-H(:,2))); % default case
            %             fractions2 = (H(:,1)-DepthThreshold).^2./...
            %                 ((H(:,1)-H(:,3)).*(H(:,1)-H(:,2))); % when h2 = h3
            %
            %             % check for those where h2<h<h3 -> fraction  = 1 - fraction
            %             ind = H(:,2)<= DepthThreshold & H(:,3)>DepthThreshold;
            %             fractions(ind) = 1-fractions(ind);
            %             % check for those where h2 = h3
            %             fractions(H(:,2)==H(:,3)) = fractions2(H(:,2)==H(:,3));
            %             % check for elements above and below DepthThreshold
            %             fractions(H(:,3)<=DepthThreshold) = 1;
            %             fractions(H(:,1)>DepthThreshold) = 0;

        end
        
        function nrElements  = calcNrElements(connection,XY)
            % Calculates the number of elements on each node of a triangle
            % in the vector nrElements

            % make one big list. It is assumed that a node occurs only once
            % in a triangle
            connection = connection(:);
            nrNodes    = size(XY,1);
            nrElements = zeros(nrNodes,1);
            % look for each node how much it occurs
            for i = 1:nrNodes
                nrElements(i) = sum(i==connection);
            end
        end
        
        function theSkewness  = calcTriangleSkewness(theAngle)
            % Calculates the equiangle skewness of a triangle
            %
            % Reference: Bakker Lecture notes
            %Tri’s: skewness should not exceed 0.85
            %Value ofSkewness
            %              0-0.25 0.25-0.50 0.50-0.80  0.80-0.95 0.95-0.99 0.99-1.00
            %Cell Quality excellent good    acceptable  poor       sliver   degenerate
            %
            % [theSkewness]  = Traingle.calcTriangleSkewness(theAngle)
            %
            % #INPUTS:
            % theAngle: Matrix [Nx3] with the three angles of the matrix (in radians)
            %           -
            %
            %
            % #OUTPUTS:
            % theSkewness: Vector [Nx1]  with the equiangle skewness
            % #STEPS:
            % #KNOWN ISSUES:
            %
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            % Written by: ABR
            % Date: 27/6/2012
            % Modified by:
            % Date:
            
            thetaE = pi*60/180;
            theMax = max(theAngle,[],2);
            theMin = min(theAngle,[],2);
            theSkewness = max((theMax-thetaE)./(pi-thetaE),1 - theMin./thetaE);
            
        end

        function [lengthTri,angleTri]  = calcTriangleStat(connection,xTri,yTri)
            % Calculates then three angles of a triangle from a triangular grid
            %
            %[lengthTri,angleTri]  = CalcTriangle(connection,xTri,yTri)
            %
            % #INPUTS:
            % connection: connectivity matrix [Nx3]
            % xTri,yTri: X coordinates and Y coordinates of the matrix [Kx1]
            %           -
            % #OUTPUTS:
            % lengthTri: [Nx3] matrix with the length of the three sides of the matrix
            % (point 1-2, point 2-3, point 3-1)
            % angleTri: [Nx3] matrix with the angles of the matrix (in radians)
            %
            % To plot use:
            % h=patch('faces',mConnect,'vertices',[vX,vY],'FaceVertexCData',180/pi*mAngle(:,1));
            %
            % #STEPS:
            % #KNOWN ISSUES:
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            % Written by: ABR
            % Date: 26/6/2012
            % Modified by:
            % Date:

            %1.) Calculate the length of the vertices

            nrElements = size(connection,1);
            lengthTri  = zeros(nrElements,3);
            angleTri   = zeros(nrElements,3);

            indSides = [1 2 3 1 2];
            for i = 1:3
                index1 = connection(:,indSides(i));
                index2 = connection(:,indSides(i+1));
                lengthTri(:,i) = sqrt((xTri(index1) - xTri(index2)).^2 + (yTri(index1) - yTri(index2)).^2 );
            end

            %2.) Calculate the angles
            for i  = 1:3
                angleTri(:,i) = acos((lengthTri(:,indSides(i+1)).^2 + lengthTri(:,indSides(i+2)).^2 - lengthTri(:,indSides(i)).^2) ./(2.* lengthTri(:,indSides(i+2)).*lengthTri(:,indSides(i+1))));
            end
        end
        
        function strechtData  = calcTriangleStretching(Connect,theLength,stretchType)
            % Calculates the stretching rate on a triangular mesh
            %
            % strechtData  = Triangle.calcTriangleStretching(Connect,theLength,stretchType)
            %
            % #INPUTS:
            % Connect: connectivity matrix [Nx3]
            % theLength: length of the three sides of the triangle[Nx3]
            % stretchType (optional): kind of calculation (scalar). Options are:
            %   1.) compare all edges of two adjacent triangles (default)
            %   2.) compare all edges connected to a given node

            %
            % #OUTPUTS:
            % strechtData: [Nx3] matrix with grid stretching ratio (for each connecting
            % vertex) for nType  =1
            % strechtData: [Mx1] matrix with grid stretching ratio (for each node) for nType  =3
            %
            % #STEPS:
            % #KNOWN ISSUES:
            %
            %
            % Written by: ABR
            % Date: 26/6/2012
            %
            if nargin ==2
                stretchType = 1;
            end
            
            switch stretchType
                % Compare all edges at a given node
                case 1
                    nElements = size(Connect,1);
                    vI = [1 2 3 1 2 3];
                    strechtData = zeros(nElements,3);
                    
                    % loop over all elements
                    for nI =1:nElements
                        vPoints = Connect(nI,:);
                        % look for elements that share two of the three points
                        mLengthThisTri = theLength(nI,:);
                        nMinLengthThis = min(mLengthThisTri);
                        nMaxLengthThis = max(mLengthThisTri);
                        for nJ = 1:3
                            nInd1 = vPoints(vI(nJ));
                            nInd2 = vPoints(vI(nJ+1));
                            vInd = any(Connect==nInd1,2) & any(Connect==nInd2,2);
                            vInd(nI) = 0;
                            mLengthOtherTri  = theLength(vInd,:);
                            %compare the lengths of the edges
                            if ~isempty(mLengthOtherTri)
                                nMinLengthOther = min(mLengthOtherTri);
                                nMaxLengthOther = max(mLengthOtherTri);
                                strechtData(nI,nJ) = max(nMaxLengthThis/nMinLengthOther,nMaxLengthOther/nMinLengthThis);
                            else
                                strechtData(nI,nJ) = nan;
                            end
                        end
                    end
                    % compare all edges at a given node
                case 2
                    nElements = max(Connect(:));
                    strechtData = zeros(nElements,1);
                    for nI =1:nElements
                        % find all edges that have that element
                        vInd = find(any(Connect==nI,2));
                        nLen = length(vInd);
                        mNewLength = zeros(nLen,2);
                        % find the lengths of all vertices with the element
                        for nJ = 1:nLen
                            vConnect  = Connect(vInd(nJ),:);
                            nNode = find(vConnect ==nI);
                            switch nNode
                                case 1
                                    mNewLength(nJ,1) = theLength(vInd(nJ),1);
                                    mNewLength(nJ,2) = theLength(vInd(nJ),3);
                                case 2
                                    mNewLength(nJ,1) = theLength(vInd(nJ),1);
                                    mNewLength(nJ,2) = theLength(vInd(nJ),2);
                                case 3
                                    mNewLength(nJ,1) = theLength(vInd(nJ),2);
                                    mNewLength(nJ,2) = theLength(vInd(nJ),3);
                            end
                        end
                        strechtData(nI) = max(mNewLength(:))/min(mNewLength(:));
                    end
                    
            end
        end
        
        function center = centerGravity(XY,Connect)
            % center of gravity is the average of the three vertices
            % center = centerGravity(XY,Connect)
            % INPUT: XY: Nx2 matrix with x and y coordinates of the corner
            % of a triangle
            % Connect: [Mx3]maxtrix with connections of the triangles
            % OUTPUT: center: [Mx2] vector with the coordinates of the
            % center points of the triangles.

            sizeConnect = size(Connect);
            center = zeros(sizeConnect(1),2);
            for i = 1:2
                for j = 1:3
                    %center(:,i) = center(:,i) + 0.333333*(XY(Connect(:,j),i)+XY(Connect(:,mod(j,3)+1),i));
                    center(:,i) = center(:,i) + 0.333333*XY(Connect(:,j),i);
                end
            end
        end

        function radius = circumcenterRadius(connection,XY)
            % Calculates the circumcenter radius
            % Output:
            % radius: the circumcenter radius

            % get the lengths of the vertices and the area of the triangle
            lengths = Triangle.lengthVertex(connection,XY);
            area    = Triangle.triangleArea(connection,XY);

            % circumcenter equation
            radius = 0.5 .*prod(lengths,2) ./area;
        end

        function indexTri = deleteDoubleVector(indexTri)
            % deletes double entries from the result of findDouble
            bGo = 1;
            nrElement = size(indexTri,1);
            while bGo
                mask = (indexTri(nrElement,1)==indexTri(:,2)) & (indexTri(nrElement,2)==indexTri(:,1));
                if any(mask)
                    indexTri(nrElement,:)= [];
                    nrElement = size(indexTri,1);
                else
                    bGo = 0;
                end
            end
        end

        function [connection,XY] = deleteTri(connection,XY,mask)
            % deletes a triangle from a grid by deleting an XY point and all triangles that belong to it
            % delete triangle
            %
            % [connection,XY] = deleteTri(connection,XY,mask)
            %
            connection(mask,:) = [];
            %delete unused points
            Points  = unique(connection(:));
            notUsed = setdiff(1:size(XY,1),Points);
            if ~isempty(notUsed)
                [connection,XY] = Triangle.deletePoints(connection,XY,notUsed);
            end
        end
        
        function  [connection,XY] = deletePoints(connection,XY,notUsed)
            % deletes points from a mesh
            %
            % [connection,XY] = deletePoints(connection,XY,notUsed)
            % INPUT
            % - connection,XY: mesh information
            % - notUsed : list of node numbers to delete
            % OUTPUT
            % - idem
            notUsed = sort(notUsed,'descend');
            for i =1:length(notUsed)
                %delete point
                XY(notUsed(i),:) = [];
                % update connections
                connection(connection>notUsed(i))  = connection(connection>notUsed(i)) - 1;
            end
        end
        
        function [connection,XY] = deleteDoubleNode(connection,XY,threshold,hWait)			
			% Deletes all nodes that occur twice from a mesh. Do not use if			
            % you have thin dams in your mesh
			% [connection,XY] = deleteDoubleNode(connection,XY,threshold,hWait)
			%
			% Input:
			% connection : connection information from telheadr
			% XY 		 : XY coordinates of the mesh
			% threshold  : distance in m for the script to check for double
			% 			   points (optional, default = 1 m)
			% hWait		 : handle to wait bar (optional)
			%
            % Output:
			% connection : changed connection information for the mesh
			% XY		 : new XY coordinates after deleting double nodes
			
			% delete triangle
            if nargin ==2
                threshold = 1;
            end
            threshold = threshold^2;
            nrNodes =  size(XY,1);
            n = 0;
            extraPoints = zeros(1000,1);
            orgPoints   = zeros(1000,1);
            % look for double nodes
            for i=1:nrNodes
                if nargin ==4 && mod(i,100)==0
                    waitbar(i/nrNodes,hWait);
                end
                dist2 = (XY(i,1)-XY(:,1)).^2 + (XY(i,2)-XY(:,2)).^2;
                ind  =  find(dist2<threshold);
                nrExtra = length(ind)-1;
                if nrExtra>0
                    extraPoints(n+1:n+nrExtra) = ind(2:end);
                    orgPoints(n+1:n+nrExtra)   = ind(1);
                    n = n+nrExtra;
                end
            end
            
            % delete double double points
            if n<1000
                extraPoints(n+1:end) = [];
            end
            [extraPoints,ind] = unique(extraPoints);
            orgPoints = orgPoints(ind);
            n = length(extraPoints);
            % delete all double points 
            for i =1:n
                % renumber elements to the first point
                nDelete = extraPoints(i);
                connection(connection==nDelete) = orgPoints(i);
                %delete point
                XY(nDelete,:) = [];
                % update connections
                connection(connection>nDelete)   = connection(connection>nDelete) - 1;
                extraPoints(extraPoints>nDelete) = extraPoints(extraPoints>nDelete) - 1;
                orgPoints(orgPoints>nDelete)     = orgPoints(orgPoints>nDelete) - 1;
            end
        end        

        function varAvg  = faceAvg(connection,aVar)
            % Calculates the average of a avariable on the phases
            %
            %varAvg  = faceAvg(connection,aVar)
            %
            % #INPUTS:
            % connection: connectivity matrix [Nx3]
            % aVar      : A column vector with a data [Mx1]
            %
            % #OUTPUTS:
            % varAvg: [Nx3] matrix with the average along each of the three
            % sides of the triangle
            % (point 1-2, point 2-3, point 3-1)
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            % Written by: ABR
            % Date: 23/4/2013
            % Modified by:
            % Date:

            %1.) Calculate the average of the

            nrElements = size(connection,1);
            varAvg     = zeros(nrElements,3);

            indSides = [1 2 3 1 2];
            for i = 1:3
                index1 = connection(:,indSides(i));
                index2 = connection(:,indSides(i+1));
                varAvg(:,i) = 0.5.*(aVar(index1)+aVar(index2));
            end
        end

        function varMax  = faceMax(connection,aVar)
            % Calculates the maximum of a avariable on the phases
            %
            %varMax  = faceMax(connection,aVar)
            %
            % #INPUTS:
            % connection: connectivity matrix [Nx3]
            % aVar      : A column vector with a data [Mx1]
            %
            % #OUTPUTS:
            % varAvg: [Nx3] matrix with the average along each of the three
            % sides of the triangle
            % (point 1-2, point 2-3, point 3-1)
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            % Written by: ABR
            % Date: 23/4/2013
            % Modified by:
            % Date:

            %1.) Calculate the average of the

            nrElements = size(connection,1);
            varMax     = zeros(nrElements,3);

            indSides = [1 2 3 1 2];
            for i = 1:3
                index1 = connection(:,indSides(i));
                index2 = connection(:,indSides(i+1));
                varMax(:,i) = max(aVar(index1),aVar(index2));
            end
        end

        function varMin  = faceMin(connection,aVar)
            % Calculates the minimum of a avariable on the phases
            %
            %varMin  = faceMin(connection,aVar)
            %
            % #INPUTS:
            % connection: connectivity matrix [Nx3]
            % aVar      : A column vector with a data [Mx1]
            %
            % #OUTPUTS:
            % varMin: [Nx3] matrix with the average along each of the three
            % sides of the triangle
            % (point 1-2, point 2-3, point 3-1)
            %
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            % Written by: ABR
            % Date: 23/4/2013
            % Modified by:
            % Date:

            %1.) Calculate the average of the

            nrElements = size(connection,1);
            varMin     = zeros(nrElements,3);

            indSides = [1 2 3 1 2];
            for i = 1:3
                index1 = connection(:,indSides(i));
                index2 = connection(:,indSides(i+1));
                varMin(:,i) = min(aVar(index1),aVar(index2));
            end
        end

        function filtVar = filterMedian(connection,XY,z,nrGen,indexCon, nrConnect)
            % apply median filter to data on a unstructured nmesh
            % get connections
            if nargin <5
                [indexCon, nrConnect] = Triangle.findConnection (connection,XY,1);
            end            
            
            % loop over all data and find the median
            nrX = size(XY,1);
            filtVar = zeros(nrX,1);
            for i=1:nrX
                %select connecting point
                ind = (indexCon(i,1:nrConnect(i)));
                indAll = ind;
                %select points connecting to connecting points
                for iGen=2:nrGen
                    for j=1:length(ind)
                      tmpInd  = (indexCon(ind(j),1:nrConnect(ind(j))));
                      indAll = unique([ind;tmpInd]);
                    end
                    ind = indAll;
                end
                % take median
                filtVar(i) = median(z(ind));
            end
        end
        
        function filtVar = filterTri(connection,XY, aVar,sctOptions)
            % filters a variable on a triangular mesh
            %
            % filtVar = Triangle.filterTri(connection,XY, aVar, sctOptions)
            %
            % INPUT: connection: [Mx3] matrix with connection of triangles
            %       XY:  [Nx2]  matrix with X and Y coordinates of the
            %       triangles
            %       aVar: variable to be filtered
            %       sctOptions(optional): a structure with options. It has the
            %       fields:
            %       sctOptions.filtVar:  Weight factor for the considered point and the other points  of the triangle. Default: [3 1 1]
            %       sctOptions.nrSmooth: nr of iterations. Default: 1
            %       sctOptions.xyPoly: [Kx2] matrix with x and y
            %       coordinates of a polygon used to make a mask. The
            %       filter will only be applied to the points inside the
            %       polygon.
            
            %process defaults
            if nargin == 3
               sctOptions = struct;
            end
            sctOptions = Util.setDefault(sctOptions,'nrSmooth',1);
            sctOptions = Util.setDefault(sctOptions,'filtVar',[3 1 1]);
            aFilt      = sctOptions.filtVar;
            
            % calc areas
            triArea = 1./Triangle.triangleArea(connection,[XY(:,1) XY(:,2)]);
            
            nrPoin = size(XY,1);
            nrElem = size(connection,1);
            
            %preallocate
            filtVar = zeros(nrPoin,1);
            countVar = zeros(nrPoin,1);
            cycleOp = 1+mod((1:5)-1,3);
            
            % make mask based on polygon if needed
            if isfield(sctOptions,'xyPoly')
                mask = inpoly([XY(:,1),XY(:,2)],sctOptions.xyPoly);
            else
                mask = ones(nrPoin,1);
            end
            % loop over nr of smoothings
            for n=1:sctOptions.nrSmooth
                % loop over all elements
                for i=1:nrElem
                    ikle = connection(i,:);
                    for j=1:3
                        i1 = ikle(j);
                        if mask(i1)
                            filtVar(i1) = filtVar(i1) + triArea(i).*(aFilt(1).* aVar(i1)...
                                + aFilt(2).* aVar(ikle(cycleOp(j+1)))...
                                + aFilt(3).* aVar(ikle(cycleOp(j+2))));
                            countVar(i1) = countVar(i1)+triArea(i).*sum(aFilt);
                        end
                    end
                end
                % calculate average
                filtVar = filtVar./countVar;
                % put in old variable, based on mask and prepare for next
                % iteration
                filtVar(~mask) = aVar(~mask);
                aVar = filtVar;
            end
        end
        
        
        function indexTri = findDouble(Connect)
            % find elements that are double in the definition.
            % indexTri is  a Nx2 matrix with number of the first element
            % and matching number of the second element

            nrDoubles   = 100;
            sizeConnect = size(Connect);
            indexTri    = nan(nrDoubles,2);
            nElement    = 1;
            for i = 1:sizeConnect(1)
                % compare all nodes
                a11 = Connect(i,1) == Connect(:,1);
                a12 = Connect(i,1) == Connect(:,2);
                a13 = Connect(i,1) == Connect(:,3);

                a21 = Connect(i,2) == Connect(:,1);
                a22 = Connect(i,2) == Connect(:,2);
                a23 = Connect(i,2) == Connect(:,3);

                a31 = Connect(i,3) == Connect(:,1);
                a32 = Connect(i,3) == Connect(:,2);
                a33 = Connect(i,3) == Connect(:,3);

                % look for those where three nodes are the same
                isDouble =  (a11 & ((a22 & a33 ) | (a23 & a32 ))) |...
                    (a12 & ((a21 & a33 ) | (a31 & a23 ))) |...
                    (a13 & ((a22 & a31 ) | (a21 & a32 )));
                % save those nodes that are double
                doubleIndex = find(isDouble);
                if length(doubleIndex)>1
                    % delete self triangle (triangle that is the
                    % same as itselft)
                    doubleIndex(doubleIndex==i) = [];
                    for j = 1:length(doubleIndex)
                        indexTri(nElement,:) = [i,doubleIndex(j)];
                        nElement = nElement +1;
                    end
                end
            end
            % delete extra entries from preallocation
            if (nElement+1) <= nrDoubles
                indexTri(nElement+1:end,:) = [];
            end
            % delete double enrtries
            indexTri = Triangle.deleteDoubleVector(indexTri);
        end

        function [indexCon, nrConnect] = findConnection (Connect,xy,useWait)
            % find a list of connection point for each point
            %
            % [indexCon, nrConnect] = findConnection (Connect,xy,useWait)
            
            MAX_CON = 15;
            nrX = size(xy,1);
            nrConnect = zeros(nrX,1);
            indexCon  = nan(nrX,MAX_CON);
            myTri = triangulation(double(Connect),xy(:,1),xy(:,2));
           
            %theEdge = edges(myTri);
            if useWait
                hWait = waitbar(0,'Making connection');
            end
            modTmp = round(nrX/100);
            for i=1:nrX
                if mod(i,modTmp)==0
                    hWait = waitbar(i/nrX,hWait);
                end
                  indTri = vertexAttachments(myTri,i);
                  tmp = Connect(indTri{1},:);
                  tmp2 = unique(tmp(:));
                  tmp3 = setdiff(tmp2,i);
                  indexCon(i,1:length(tmp3)) = tmp3;
                  nrConnect(i) = length(tmp3);                  
            end
            close(hWait);
            
        end
        
        function maskClump  =  findClump(Connect,xy,zBin,indStart,indexCon,nrCon)
            % triangular version of clump algoritm
            %
            % indClump  =  findClump(Connect,xy,zBin,indStart,indexCon,nrCon)
            %
            % see
            % https://en.wikipedia.org/wiki/Connected-component_labeling
            % (algorithm 1)
            
            nrX = length(zBin);
            maskClump  = false(nrX,1);
            tmpLabel   = false(nrX,1);
            queue      = zeros(nrX,1);
            if nargin <5
                [indexCon, nrCon] = Triangle.findConnection (Connect,xy,1);
            end
            i = indStart;
            z0 = zBin(indStart);
            nrQueue  = 1;
            queue(1) = i;
            while nrQueue>0
                % gets element from the queue
                i = queue(1);
                queue(1:nrQueue) = queue(2:nrQueue+1);
                nrQueue = nrQueue-1;
                % check if                                
                if ~tmpLabel(i)&& zBin(i)==z0
                    maskClump(i) = true;
                    tmpLabel(i)  = true;
                    %select connected points
                    indCon = indexCon(i,1:nrCon(i));
                    % look for points to add to the queue
                    mask = tmpLabel(indCon);
                    indCon(mask) = [];
                    mask =  (zBin(indCon)~=z0);
                    indCon(mask) = [];
                    % add data to the queue
                    nrAdd = length(indCon);
                    if ~isempty(indCon)
                        queue(nrQueue+1:nrQueue+nrAdd) = indCon;
                        nrQueue = nrQueue+nrAdd;
                    end
                end
            end
        end
        
        function [indexTri,nrEdge] = findEdge(Connect)
            % find triangles that share a common edge

            % default parameter
            MAX_CONNECT = 20;

            % preallocate
            nrElem   = size(Connect,1);
            indexTri = nan(nrElem,MAX_CONNECT);
            nrEdge   = zeros(nrElem,1);

            % loop over all triangles

            hWait = waitbar(0,'calculating edges');
            for i  = 1:nrElem
                % find trinagles that share two nodes
                node = Connect(i,:);
                common1 = (Connect == node(1));
                common2 = (Connect == node(2));
                common3 = (Connect == node(3));
                nrCommon = sum(common1 + common2 + common3,2);
                matchEdge = find(nrCommon>=2);

                % determine the nummer of connections
                nrEdge(i) = length(matchEdge);

                % store data
                if ~isempty(matchEdge)
                    indexTri(i,1:nrEdge(i)) = matchEdge;
                end

                if mod(i,round(nrElem/100))==0
                    waitbar(i/nrElem,hWait);
                end
            end
            close(hWait);
            % maximum number of connections
            maxEdge = max(nrEdge);
            % delete unused data
            if maxEdge < MAX_CONNECT
                indexTri(:,maxEdge+1:end) = [];
            end
        end

        function [index] = findNode(XY,XYref)
            % This function find the same nodes in two datasets
            % [index,notInRef,notInData] = findNode(XY,XYref)
            %
            %Input
            %
            % XY: Nx2 matrix with x and y coordinates of nodes
            % XYref: Nx2 matrix with x and y coordinates of reference nodes
            %
            %output:
            %
            % index: variable with the nodenummer of XYref for XY
            %        XY(index,:) = XYref(InData,:)
            % inData: the number of the nodes of XYref that occur in XY
            % inRef: the number of the nodes of XYref that occur in XY
            %

            precision = 1e-2;
            sizeXY    = size(XY);
            %            sizeXYref = size(XYref);
            index = nan(sizeXY(1),1);
            for i = 1:sizeXY(1)
                mask = (abs(XY(i,1)-XYref(:,1)) < precision) & (abs(XY(i,2)-XYref(:,2)) < precision);
                if sum(mask)>0
                    index(i) = find(mask);
                end
            end
        end

        function indexTri = findTri(XY,Connect,XYref,ConnectRef)
            % the same triangle must have the same center of gravity
            % Finds triangles that are the same, even though node numbering
            % is different
            % indexTri: the number of Triangle (in ConnectRef) which is the
            % same triangle
            precision = 1e-5;

            %determine center of gravity of the triangles
            center    = Triangle.centerGravity(XY,Connect);
            centerRef = Triangle.centerGravity(XYref,ConnectRef);

            sizeConnect = size(Connect);
            indexTri    = nan(sizeConnect(1),1);

            h = waitbar(0,'Finding triangles');
            for i = 1:sizeConnect(1)

                mask = abs(center(i,1)-centerRef(:,1))<precision &...
                    abs(center(i,2)-centerRef(:,2))<precision;

                if sum(mask)>0
                    indexTri(i) = find(mask);
                end
                waitbar(i/sizeConnect(1),h);
            end
            close(h);
        end

        function inTri = getAllTriangle(connection,XY,xyPoint,haveWaitBar)
            % loop arount inTriangle. This finds the triangle containing
            % xyPoint for all xyPoint
            
            if nargin ==3
                haveWaitBar = true;
            end
            sizeXYpoint = size(xyPoint);
            inTri = nan(sizeXYpoint(1),1);
            if haveWaitBar
                h = waitbar(0,'Preparing interpolation');
            end
            for i = 1:sizeXYpoint(1)
                if ~any(isnan(xyPoint(i,:)))
                    index = Triangle.inTriangle(connection,XY,xyPoint(i,:));
                    if ~isempty(index)
                        inTri(i) = index;
                    end
                end
                if haveWaitBar && mod(i,100)==0
                    waitbar(i/sizeXYpoint(1),h);
                end
            end
            if haveWaitBar
                close(h);
            end
        end
        
        function nodeMask = getBoundary(Connect,hWait)
            % get edges of all triangles
            %
            % nodeMask = Triangle.getBoundary(ikle)
            %INPUT: Connect [Mx3] matrix with connections
            %      : hWait (optional): handle to a waitbar
            %OUTPUT: nodeMaks: [Nx1] mask with true if a point is on the
            %boundary
            
            startNodeTmp = [Connect(:,1);Connect(:,2);Connect(:,3)];
            endNodeTmp   = [Connect(:,2);Connect(:,3);Connect(:,1)];
            
            % sort that edges always start with the lowest node number
            mask            = startNodeTmp > endNodeTmp;
            startNode       = startNodeTmp;
            endNode         = endNodeTmp;
            endNode(mask)   = startNodeTmp(mask);
            startNode(mask) = endNodeTmp(mask);
            
            % find boundary
            % loop over all edges. a boundary is an edge that occurs only once
            nodeMask = false(max(endNode),1);
            nrNodes = max(startNode);
            for i =1:nrNodes
                % update waitbar
                if nargin==2 && mod(i,500)==0
                    waitbar(i/nrNodes,hWait);
                end
                mask     = startNode==i;
                endTmp   = endNode(mask);
                endPoint = unique(endTmp);
                for j=1:length(endPoint)
                    nrEdge = sum(endTmp==endPoint(j));
                    if nrEdge ==1
                        nodeMask(i) = true;
                        nodeMask(endPoint(j)) = true;
                    end
                end
            end
        end

        function [Ind,minDist] = getClosest(XYdata,XY)
            % finds the closest mode from Xdata,Ydata [Nx2] to point XY
            %  [Mx2]
            sizeXY  = size(XY);
            Ind     = nan(sizeXY(1),1);
            minDist = nan(sizeXY(1),1);
            for i = 1:sizeXY(1)
                Dist = ((XYdata(:,1)-XY(i,1)).^2 +(XYdata(:,2)-XY(i,2)).^2);
                [minDist(i),minInd]  = min(Dist);
                minDist = sqrt(minDist);
                Ind(i) = minInd(1);
            end
        end

        function indDouble = getDoubleElements(connection, hWait)
            % finds elements that occur more than once in a mesh
            %
            % indDouble = Triangle.getDoubleElements(connection,hwait)
            %
            % INPUT:
            %       - connection: [Mx3] matrix with triangle connections
            %       - hWait (optional): handle to a waitbar
            % OUTPUT:
            %       - indDouble: [Nx1] vector with indices of double
            %                          vectors
            %
            
            nrElem = size(connection,1);
            indDouble = false(nrElem,1);
            % count how many time an element occurs
            for i=1:nrElem
                i1 = connection(i,1);
                i2 = connection(i,2);
                i3 = connection(i,3);
                mask = (connection(i,1)==i1 & connection(i,2)==i2 & connection(i,3)==i3);
                if sum(mask)>1
                    indDouble(i) = true;
                end
                mask = (connection(i,1)==i1 & connection(i,2)==i3 & connection(i,3)==i2);
                if sum(mask)>1
                    indDouble(i) = true;
                end
                mask = (connection(i,1)==i2 & connection(i,2)==i3 & connection(i,3)==i1);
                if sum(mask)>1
                    indDouble(i) = true;
                end
                mask = (connection(i,1)==i2 & connection(i,2)==i1 & connection(i,3)==i3);
                if sum(mask)>1
                    indDouble(i) = true;
                end
                mask = (connection(i,1)==i3 & connection(i,2)==i1 & connection(i,3)==i2);
                if sum(mask)>1
                    indDouble(i) = true;
                end
                mask = (connection(i,1)==i3 & connection(i,2)==i2 & connection(i,3)==i1);
                if sum(mask)>1
                    indDouble(i) = true;
                end
                if (nargin==2 && mod(i,100)==0)
                    hWait = waitbar(i/nrElem,hWait);
                end
            end
            
        end
        
        function [xL,yL] = getLine(connection,XY)
            % makes lines for each triangle (e.g )for kmlplot
            %
            % [xL,yL] = getLine(connection,XY)
            %
            % INPUT:connection: [Mx3] connections of the matrix (IKLE)
            %         XY: [Nx2]  X and Y coordinates of the nodes of the
            %         triangle 
            %
            % OUTPUT: xL: [2xK] matrix with x coordinates of triangle lines
            %         yL: [2xK] matrix with y coordinates of triangle lines
            %
            
            % use built in triangulation object to extract edges
            x       = XY(:,1);
            y       = XY(:,2);
            tri     = triangulation(double(connection),x,y);
            theEdge = edges(tri);
            xL      = x(theEdge)';
            yL      = y(theEdge)';
        end 
        
        function overId = getOverConAll(Connect,xy)
            % get all overconstraint elements in a mesh
            %
            % overId = getOverConAll(Connect,xy)
            %
            % INPUT:connection: [Mx3] connections of the matrix (IKLE)
            %         XY: [Nx2]  X and Y coordinates of the nodes of the
            %         triangle 
            %
            % OUTPUT: vector with the numbers of the overconstraint elements
            %
            
            nrX = size(xy,1);
            theTri = triangulation(double(Connect),xy(:,1),xy(:,2));
            theObc = freeBoundary(theTri);
            obcPoints = unique(theObc);
            nodeMask = false(nrX,1);
            nodeMask(obcPoints) = true;
            overId = Triangle.getOverConstraint(Connect,nodeMask);
        end
        
        function overId = getOverConstraint(Connect,nodeMask)
            % get overconstraint elements
            %
            % overId = Triangle.getOverConstraint(ikle,nodeMask)
            %
            % INPUT
            % Connect: [Mx3] connection matrix
            % nodeMask: [Nx1] mask which is true for boundary nodes (from getBoundary)
            %
            % OUTPUT: vector with the numbers of the overconstraint elements
            
            nrElem   = size(Connect,1);
            overMask = false(nrElem,1);
            for i=1:nrElem
                overMask(i) = nodeMask(Connect(i,1)) & ...
                    nodeMask(Connect(i,2)) & ...
                    nodeMask(Connect(i,3));
            end
            overId = find(overMask);
        end

  function [connection,XY] = getSubset(connection,XY,mask)
            % gets a subsset containing only the traingles for which mask
            % is true
            %
            % [connection,XY] = getSubset(connection,XY,mask)
            %
            % EXAMPLE:
            %
            %clear;clc;
            %[X,Y] = meshgrid (1:10);
            % ikle  = delaunay(X,Y);
            % XY = [X(:) Y(:)];
            % xyC   = Triangle.centerGravity(XY,ikle);
            % mask  = xyC(:,1)>5;
            % figure;
            % triplot(ikle,XY(:,1),XY(:,2));
            % grid on
            % [ikle,XY] = Triangle.getSubset(ikle,XY,mask);
            %
            % hold on;
            % triplot(ikle,XY(:,1),XY(:,2),'k');
            % grid on
            %
            %get subset
            connection = connection(mask,:);
            connection = double(connection);
            % make a point list only containing the new points
            points    = unique(connection(:));
            newPoints = (1:length(points))';
            XY = XY(points,:);
            % replace numbers in the connectivity list (table lookup,
            % therefor interp);
            connection  = interp1(points,newPoints,connection,'nearest');

        end
                
        
        function [wX,wY] = gradEl(connection,XY,F)
            % calculates the gradient on a triangular mesh per element
            %
            % [wX,wY] = gradEl(connection,XY,F)
            % 
            % preallocate
            nrElem = size(connection,1);
            
            wX = zeros(nrElem,1);
            wY = zeros(nrElem,1);
         
            % get element area
            A = 2.*Triangle.triangleArea(connection,XY);
            
            % compute gradients per element
            for i=1:nrElem
                x = XY(connection(i,:),1);
                y = XY(connection(i,:),2);
                dy   = y(2:3)-y(1);
                dx   = x(2:3)-x(1);
                fTmp = F(connection(i,:));
                df   = fTmp(2:3)-fTmp(1);
                wX(i,:) = (-dy(1)*df(2) + dy(2)*df(1))/A(i);
                wY(i,:) = ( dx(1)*df(2) - dx(2)*df(1))/A(i);
            end

        end
        
        function [gradX,gradY] = gradPoin(connection,XY,F)
            % calculates the gradient on a triangular mesh per point
            %
            % [gradX,gradY] = gradPoin(connection,XY,F)
            
             % compute gradients per element
            [wX,wY] = Triangle.gradEl(connection,XY,F) ;
            
            % get element area
            A = 2.*Triangle.triangleArea(connection,XY);            
            
            % assemble
            nrP    = size(XY,1);
            nrElem = size(connection,1);
            
            gradX = zeros(nrP,1);
            gradY = zeros(nrP,1);
            elmA  = zeros(nrP,1);
            for i=1:nrElem
                for j=1:3
                    iP = connection(i,j);
                    gradX(iP) = gradX(iP) + A(i)*wX(i);
                    gradY(iP) = gradY(iP) + A(i)*wY(i);
                    elmA(iP)  = elmA(iP)  + A(i);
                end
            end
            gradX = gradX./elmA;
            gradY = gradY./elmA;
        end
        
        function varargout = assemble(connection,XY,varargin)    
            % converts elemnent values to node values using finite element
            % assembly
            %
            % varargout = assemble(connection,XY,varargin);   
            %
            % INPUT
            % - 
            % OUTPUT:
            % - 
            
            % get element area
            A = 2.*Triangle.triangleArea(connection,XY);            
            
            % assemble
            nrP    = size(XY,1);
            nrElem = size(connection,1);
            
            %preallocate
            nrIn  = length(varargin);
            nrOut = nargout;
            if nrOut>nrIn
                error('Too many output argumets');
            end
            nrVar = min(nrIn,nrOut);
            for  iVar = nrVar:-1:1
                varargout{iVar} = zeros(nrP,1);
            end
            elmA  = zeros(nrP,nrVar);
            %assemble
            for i=1:nrElem
                for j=1:3
                    iP = connection(i,j);
                    for  iVar = nrVar:-1:1
                        if ~isnan(varargin{iVar}(iP))
                        varargout{iVar}(iP) = varargout{iVar}(iP) + A(i)*varargin{iVar}(i);
                        elmA(iP,iVar)  = elmA(iP,iVar)  + A(i);
                        end
                    end
                end
            end
            % apply weighting
            for  iVar = nrVar:-1:1
                varargout{iVar} = varargout{iVar}./elmA(:,iVar);
            end
        end

        function zElem = constAvgLoop(x,y,ikle,zElem,zPoin,xyPoin,ikleMask)
            %helper function to calculate const average in a domain used by avgPerTri
            
            nrElem = size(ikle,1);
            for i = 1:nrElem
                if ~ikleMask(i)
                    continue
                end
                theTri(:,2) = y(ikle(i,:));
                theTri(:,1) = x(ikle(i,:));
                mask = xyPoin(:,1)>min(theTri(:,1)) & xyPoin(:,1)<max(theTri(:,1)) &   xyPoin(:,2)>min(theTri(:,2)) & xyPoin(:,2)<max(theTri(:,2));
                if any(mask)
                    inTri = Triangle.inTriAll(xyPoin(mask,:),theTri);
                    zTmp  = zPoin(mask);
                    zElem(i) = nanmean(zTmp(inTri));
                end
            end
        end
        
        function [zElem,wElem] = linAvgLoop(x,y,ikle,zElem,wElem,zPoin,xyPoin,ikleMask)
            %helper function to calculate linear average in a domain used by avgPerTri
            %
            % discontinuous galerkin formulation
            nrElem = size(ikle,1);
            for i = 1:nrElem
                if ~ikleMask(i)
                    continue
                end
                theTri(:,2) = y(ikle(i,:));
                theTri(:,1) = x(ikle(i,:));
                inTri = Triangle.inTriFast(xyPoin,theTri);
                [a,b,c] = Triangle.getCoef(theTri);
                d = a.*xyPoin(inTri,1)+ b.*xyPoin(inTri,2) + c;
                wElem(i,1) = sum(d);
                zElem(i,1) = sum(d.*zPoin(inTri));
                [a,b,c] = Triangle.getCoef(theTri([2 3 1],:));
                d = a.*xyPoin(inTri,1)+ b.*xyPoin(inTri,2) + c;
                wElem(i,2) = sum(d);
                zElem(i,2) = sum(d.*zPoin(inTri));
                [a,b,c] = Triangle.getCoef(theTri([3 1 2],:));
                d = a.*xyPoin(inTri,1)+ b.*xyPoin(inTri,2) + c;
                wElem(i,3) = sum(d);
                zElem(i,3) = sum(d.*zPoin(inTri));
            end
       
            
        end
        
        function [xDmin,xDmax,yDmin,yDmax]  = domainDecomp(x,y,sctOpt)
            % domain decomposition (helper function) used by avgPerTri
            
            % process options
            minX = min(x);
            maxX = max(x);
            minY = min(y);
            maxY = max(y);
            nrX = sctOpt.nrDomainX;
            nrY = sctOpt.nrDomainY;

            %preallocate
            i = 0;
            nrDomain = nrX*nrY;
            xDmin = zeros(nrDomain,1);
            xDmax = zeros(nrDomain,1);
            yDmin = zeros(nrDomain,1);
            yDmax = zeros(nrDomain,1);
            % make domains
            for iX = 1:nrX
                for iY = 1:nrY
                    i = i+1;
                    xDmin(i) = minX + (iX-1)/(nrX)*(maxX-minX);
                    xDmax(i) = minX + (iX)/nrX*(maxX-minX);
                    yDmin(i) = minY + (iY-1)/(nrY)*(maxY-minY);
                    yDmax(i) = minY + (iY)/nrY*(maxY-minY);
                end
            end
        end
        
        
        function zElem = avgPerTri(ikle,x,y,xyPoin,zPoin,sctOpt)
            % takes the element average
            %
            % zElem = avgPerTri(ikle,x,y,xyPoin,zPoin,method)
            % INPUT
            % method: (optional) 'const': constant value output [nrelem x 1]
            %                   'linear': linear values. output [nrelem x
            %                   3]  (discontinuous galerkin style)
            if nargin ==5
                sctOpt = struct;
            end
            % process options
            sctOpt = Util.setDefault(sctOpt,'method','const');
            sctOpt = Util.setDefault(sctOpt,'nrDomainX',8);
            sctOpt = Util.setDefault(sctOpt,'nrDomainY',8);
            sctOpt = Util.setDefault(sctOpt,'halo',25000);
            sctOpt = Util.setDefault(sctOpt,'useWait',true);
            nrElem = size(ikle,1);
            useWait = sctOpt.useWait;
            if useWait
                hWait = waitbar(0,'Busy');
            end
            
            [xDmin,xDmax,yDmin,yDmax]  = Triangle.domainDecomp(x,y,sctOpt);
            nrDomain = length(xDmin);

            % average of all elements per triangle
            switch sctOpt.method
                case 'const'
                    zElem = nan(nrElem,1);
                case 'linear'
                    zElem = nan(nrElem,3);
                    wElem = zeros(nrElem,3);
                otherwise
                    error('Wrong average method');
            end
            
            % loop over all domains (for speedup)
            halo = sctOpt.halo;
            % get coordinates of centroid
            xyElem  = Triangle.centerGravity([x y],ikle);
            xElem   = xyElem(:,1);
            yElem   = xyElem(:,2);   
            xP = xyPoin(:,1);
            yP = xyPoin(:,2);
            for i = 1:nrDomain
                if useWait
                   hWait = waitbar(i/nrDomain,hWait);
                end
                mask = xP>xDmin(i)-halo & xP<xDmax(i)+halo & yP<yDmax(i)+halo & yP>yDmin(i)-halo;
                if ~any(mask)
                    continue;
                end
                xyPoinTmp = xyPoin(mask,:);
                ZPoinTmp  = zPoin(mask);
                ikleMask  = xElem>xDmin(i) & xElem<xDmax(i) & yElem<yDmax(i) & yElem>yDmin(i);
                if ~any(ikleMask)
                    continue;
                end                
                switch sctOpt.method
                    case 'const'
                        zElem = Triangle.constAvgLoop(x,y,ikle,zElem,ZPoinTmp,xyPoinTmp,ikleMask);
                    case 'linear'
                        zElem = Triangle.linAvgLoop(x,y,ikle,zElem,wElem,ZPoinTmp,xyPoinTmp,ikleMask);
                end
            end
            % take average
            switch sctOpt.method
                    case 'linear'
                        zElem = zElem./wElem;
            end
        
        if useWait
            close(hWait);
        end
    end
        
        function [a, b, c] = getCoef(theTri)
            % coeffcienmts of z = ax+by+c in a triangle
            % [a, b, c] = getCoef(theTri)
            % 
            x1 = theTri(1,1);
            y1 = theTri(1,2);
            dx2 = theTri(2,1)-x1;
            dx3 = theTri(3,1)-x1;
            dy2 = theTri(2,2)-y1;
            dy3 = theTri(3,2)-y1;
            A = dx2*dy3-dx3*dy2; 
            a = -(dy2-dy3)./A;
            b = -(dx3-dx2)./A;
            c = a.*x1 +b.*y1;
        end
        
        function inTri = inTriAll(xyAll,theTri)
            % find all point in a triangle vectorized
            %( see inTriFast)
           % inTri = inTriAll(xyAll,theTri)

            v0 = theTri(3,:) - theTri(1,:);
            v1 = theTri(2,:) - theTri(1,:);
            v2 = xyAll - theTri(1,:);

            % Compute dot products   (i,.e. should be column * row)
            dot00 = v0*v0';
            dot01 = v0*v1';
            dot11 = v1*v1';
            dot02 = v0(1).*v2(:,1)+v0(2).*v2(:,2);
            dot12 = v1(1).*v2(:,1)+v1(2).*v2(:,2);

            % Compute barycentric coordinates
            invDenom = 1 ./ (dot00 .* dot11 - dot01 .* dot01);
            u = (dot11 .* dot02 - dot01 .* dot12) .* invDenom;
            v = (dot00 .* dot12 - dot01 .* dot02) .* invDenom;

            % Check if point is in triangle
            inTri = (u >= 0) & (v >= 0) & (u + v < 1);

        end
        
        function inTri = inTriFast(xyPoint,Triangle)
            % fast determination whether a point is in a triangle
            % see http://www.blackpawn.com/texts/pointinpoly/default.html
            % Compute vectors; these are all row vectors
            %
            % inTri = inTriFast(xyPoint,Triangle)
            %
            % INPUT:
            %      -xyPoint: [1x2] matrix with x and y coordinates of a
            %      point to check
            %      - Triangle: [3x2] matrix with x and y coordinates of the
            %      triangle
            %
            % OUTPUT:
            %    - inTri = 
            v0 = Triangle(3,:) - Triangle(1,:);
            v1 = Triangle(2,:) - Triangle(1,:);
            v2 = xyPoint - Triangle(1,:);

            % Compute dot products   (i,.e. should be column * row)
            dot00 = v0*v0';
            dot01 = v0*v1';
            dot02 = v0*v2';
            dot11 = v1*v1';
            dot12 = v1*v2';

            % Compute barycentric coordinates
            invDenom = 1 / (dot00 * dot11 - dot01 * dot01);
            u = (dot11 * dot02 - dot01 * dot12) * invDenom;
            v = (dot00 * dot12 - dot01 * dot02) * invDenom;

            % Check if point is in triangle
            inTri = (u >= 0) && (v >= 0) && (u + v < 1);
        end

        function InTri = inTriangle(connection,XY,xyPoint)
            % Find the index to the triangle in which point xyPoint is
            % located

            % look for point closest to xy
            index = Triangle.getClosest(XY,xyPoint);
            % look for triangles that contain this point
            mask  = find(any(connection==index,2));
            InTri = false(length(mask));
            % check which point is inside the triangle
            for i = 1:length(mask)
                triangle = [XY(connection(mask(i),1),1:2);...
                    XY(connection(mask(i),2),1:2);...
                    XY(connection(mask(i),3),1:2);...
                    ];
                InTri(i) = Triangle.inTriFast(xyPoint,triangle);
                if InTri(i)
                    break
                end
            end
            
            % make sure only one points is found (in case points are on one
            % of the edges of the triangle
            if sum(InTri)>1
                InTri = find(InTri,1,'first');
            end
            InTri = mask(InTri);
            
        end

        function z = interpTriangle(sctInterp,zTri)
            % apply bilinear interpolation on a triangular grid
            %
            % z = interpTriangle(sctInterp,zTri)
            %
            % Note that zTri may be a matrix
            % Uses the the strcuture sctInterp (generated by
            % interpTrianglePrepare) in order to interpolate values on a
            % triangle using bilinear interpolation

            if length(size(zTri))>2
                error('Interpolation not possible for 3D arrays');
            end
            zSize = size(sctInterp.coordIndex);
            nrY   = size(zTri,2);
            z     = nan(zSize(1),nrY);
            for j = 1:nrY
                z(sctInterp.mask,j) = sctInterp.interpCoef(sctInterp.mask,1).*zTri(sctInterp.coordIndex(sctInterp.mask,1),j) + ...
                sctInterp.interpCoef(sctInterp.mask,2).*zTri(sctInterp.coordIndex(sctInterp.mask,2),j) + ...
                sctInterp.interpCoef(sctInterp.mask,3).*zTri(sctInterp.coordIndex(sctInterp.mask,3),j);
                if isfield(sctInterp,'nanPoints')
                    z(~sctInterp.mask,j) = zTri(sctInterp.nanPoints,j);
                end
            end
        end

        function interpCoef = interpTriangleArea(xTri,yTri,x,y)
            % performs barycentrix interpolation (similar to bilinear)
            %xTri: x-coordinates of triangle (Nx3)
            %yTri: y-coordinates of triangle (Nx3)
            % x = x coordinates for interpolation (Nx1)
            % y = y coordinates for interpolation (Nx1)

            % calculate
            % areas of triangles
            % A = 0.5 |(xa-xc)*(yb-ya) - (xa-xb)*(yc-ya)|
            %A = 0.5.*abs((xTri(1)-xTri(3))*(yTri(2)-yTri(1)) - (xTri(1)-xTri(2)) * (yTri(3)-yTri(1)));
            A1 = 0.5.*abs((x-xTri(:,3)).*(yTri(:,2)-y) - (x-xTri(:,2)) .* (yTri(:,3)-y));
            A2 = 0.5.*abs((xTri(:,1)-xTri(:,3)).*(y-yTri(:,1)) - (xTri(:,1)-x) .* (yTri(:,3)-yTri(:,1)));
            A3 = 0.5.*abs((xTri(:,1)-x).*(yTri(:,2)-yTri(:,1)) - (xTri(:,1)-xTri(:,2)) .* (y-yTri(:,1)));
            A = A1+A2+A3;
            interpCoef = [A1./A,A2./A,A3./A];
        end

        function sctInterp = interpTrianglePrepare(connection,xTri,yTri,x,y,haveWaitBar,extrap)
            % This function determines all preprocessing for trainagle interpolation
            %
            % sctInterp = interpTrianglePrepare(connection,xTri,yTri,x,y)
            %
            %INPUT
            %   - xTri: x-coordinates of triangle (Mx1)
            %   - yTri: y-coordinates of triangle (Mx1)
            %   - connection: coordinate number for interpolation (Kx3)
            %   - x = x coordinates for interpolation (Nx1)
            %   - y = y coordinates for interpolation (Nx1)
            %   - haveWaitBar: logical to determine wethre a waitbar is shown(optional)
            %   - extrap: logical to determine whether nearest neighbour interpolation is done (optional)
            %
            %OUTPUT
            % CoordIndex of the points on the triangle (Nx3) needed for interpolation
            % interpCoef (coefficient) used to multiply
            % mask: logical value of points

            % check whether the data are column vectors
            if nargin <= 5
                haveWaitBar = true;
            end
            if nargin <= 6
                extrap = false;
            end
            
            if size(xTri,2)~=1
                error('xTri must be a column vector');
            end
            if size(yTri,2)~=1
                error('yTri must be a column vector');
            end
            if size(x,2)~=1
                error('x must be a column vector');
            end
            if size(y,2)~=1
                error('y must be a column vector');
            end
            if size(connection,2)~=3
                error('connection must have each row a new triangle with 3 elements');
            end

            % determine in which triangle the points are
            sizePoints = size(x);
            myTri     = triangulation(double(connection),xTri,yTri);
            inTri     = pointLocation(myTri,x,y);
            CoordX     = nan(sizePoints(1),3);
            CoordY     = nan(sizePoints(1),3);
            CoordIndex = nan(sizePoints(1),3);
            mask = ~isnan(inTri);
            % matrix with the number of the three triangles for each point
            for i=1:3
                CoordIndex(mask,i) = connection(inTri(mask),i);
                CoordX(mask,i)     = xTri(CoordIndex(mask,i));
                CoordY(mask,i)     = yTri(CoordIndex(mask,i));
            end
            sctInterp.interpCoef = Triangle.interpTriangleArea(CoordX,CoordY,x,y);
            sctInterp.mask       = mask;
            sctInterp.coordIndex = CoordIndex;
            if extrap
                myTri     = triangulation(double(connection),xTri,yTri);
                sctInterp.nanPoints = nearestNeighbor(myTri, x(~mask),y(~mask));
            end
        end
        
        function [xyNew,indexCon,nrCon]  = laplaceSmooth(xy,ikle,mask,nrIter,indexCon,nrCon)
            % smooth a mesh
            %
            % xyNew  = laplaceSmooth(xy,ikle,mask,nrIter,indexCon,nrCon)
            %
            %INPUT
            % - xy: xy coordinates of the mesh
            % - ikle: connection table
            % - mask: logical, with length equaling the number of nodes. if true, points are NOT updated 
            % - nrIter: number of iterations
            % - indexCon,nrCon (optional) : info on connecting edges. see Triangle.findConnection 
            %OUTPUT
            % - xyNew: updated coordinates
            % - indexCon,nrCon (optional) : info on connecting edges. see Triangle.findConnection 
            
            % make triangulation if needed
            if nargin <5
                [indexCon,nrCon] = Triangle.findConnection(ikle,xy,true);
            end
            
            % copy data
            xyNew   = xy;
            nrPoin = size(xy,1);

            for iIter = 1:nrIter
                for iPoin=1:nrPoin
                    % for point not in the mask, x and y positions are
                    % average of surrounding points
                    if ~mask(iPoin)
                        tmpMask = [iPoin,indexCon(iPoin,1:nrCon(iPoin))];
                        xyNew(iPoin,1) = mean(xyNew(tmpMask,1));
                        xyNew(iPoin,2) = mean(xyNew(tmpMask,2));
                    end
                end
            end
            
        end

        function lengths = lengthVertex(connection,XY)
            % Calculates the length of the vertices
            % #OUTPUTS:
            % lengths: [Nx3] matrix with the length of the three sides of the matrix
            % (point 1-2, point 2-3, point 3-1)

            nrElements = size(connection,1);
            lengths    = zeros(nrElements,3);

            Sides = [1 2 3 1 2];
            for i = 1:3
                Ind1 = connection(:,Sides(i));
                Ind2 = connection(:,Sides(i+1));
                lengths(:,i) = sqrt((XY(Ind1,1) - XY(Ind2,1)).^2 + (XY(Ind1,2) - XY(Ind2,2)).^2 );
            end
        end

        function connectNew = makeCcw(connection,XY)
            % make all traingles counter clockwise
            connectNew = connection;
            
            % get points
            x1 =  XY(connection(:,1),1);
            x2 =  XY(connection(:,2),1);
            x3 =  XY(connection(:,3),1);
            y1 =  XY(connection(:,1),2);
            y2 =  XY(connection(:,2),2);
            y3 =  XY(connection(:,3),2);


            % compute the sign of the area
            area = x1.*(y2-y3) + x2.*(y3-y1) + x3.* (y1-y2);
            isCcw    = area>0;
            % swap points to make CCW
            connectNew(~isCcw,[2 3]) = connectNew(~isCcw,[3 2]);
            
            
        end
        
        function [connectNew, xyNew, zNew] = refineMesh(connection,xy,z)
           % refines a mesh by dividing all triangle edge in two 
           %
           % [connectNew, xyNew, zNew] = refineMesh(connect,xy,z)
           %
           % INPUT:
           %
           % OUTPUT: 
           
           % Preallocate
           nrMesh = size(connection,1);
           nrPoin = size(xy,1);
           
           connectNew = zeros(nrMesh*4,3);
           xyNew      = zeros(nrPoin*2,2);
           if nargout ==3
               if nargin ==2
                   error('Z data are obligatory if you specify z output');
               end
               nrVar = size(z,2);
               zNew  = zeros(nrPoin*2,nrVar);
           end
           
           % loop over all points to make new point list
           
           % loop over all elements
           for iElem = 1:nrMesh
               
               connectNew
           end
           
           
            
            
        end
        
        function area = triangleArea(connection,XY)
            % computes the area of all triangles
            %
            %area = triangleArea(connection,XY)
            %
            %INPUT: 
            %               - connection: [Mx3] matrix with triiangle definitions
            %               - XY: [Nx2] matrix with x and y coordinates of
            %               triangle nodes
            %
            %OUTPUT: 
            %               - area: [Mx1] vector with the area of each element

            % get the coordinate off the triangles
            x1 =  XY(connection(:,1),1);
            x2 =  XY(connection(:,2),1);
            x3 =  XY(connection(:,3),1);
            y1 =  XY(connection(:,1),2);
            y2 =  XY(connection(:,2),2);
            y3 =  XY(connection(:,3),2);


            % compute the area
            area = x1.*(y2-y3) + x2.*(y3-y1) + x3.* (y1-y2);
            area = 0.5 .* abs(area);
        end

        function volume = prismVolume(connection,XY,Z)
            % computes the volume of all primasmatic elements
            %
            %  volume = prismVolume(connection,XY,Z)
            %
            %with a triangular based and
            % the values given at the three corners of the triangle (in Z)
            % this is calculatyed by determing the center of mass as the
            % average of the point values and multiplying it with the area of the triangle
            % In this it is assumed that Z varies linearly between the
            % three nodes.
            % see http://www.mathpages.com/home/kmath393.htm for more
            % details

            area   = Triangle.triangleArea(connection,XY);
            nrEl      = size(connection,1);
            dimZ      = size(Z,2);
            volume    = zeros(nrEl,dimZ-1);
            for i = 1:dimZ-1
                dZ     = Z(:,i+1)-Z(:,i);
                zAvg   = Triangle.triangleAverage(connection,dZ);
                volume(:,i) = area.*zAvg;
            end
        end
        
        function average = triangleAverage(connection,Z)
            %calculates the average of the values at the three corners of a
            % triangle
            %
            % average = triangleAverage(connection,Z)
            %
            % INPUT: connection: [Mx3] matrix with triiangle definitions
            %               Z: [NxK] matrix with values at the corners of
            %               the triangle
            % OUTPUT: average value at the triangle
            
            nrEl      = size(connection,1);
            dimZ      = size(Z,2);
            average    = zeros(nrEl,dimZ);
            for i = 1:dimZ
                zTmp         = Z(:,i);
                points       = zTmp(connection);
                average(:,i) = nanmean(points,2);
            end
        end

        function volume = triangleVolume(connection,XY,Z)
            % computes the volume of all elements
            %
            % volume = triangleVolume(connection,XY,Z)
            %
            %with a triangular based and
            % the values given at the three corners of the triangle (in Z)
            % this is calculatyed by determing the center of mass as the
            % average of the point values and multiplying it with the area of the triangle
            % In this it is assumed that Z varies linearly between the
            % three nodes.
            % see http://www.mathpages.com/home/kmath393.htm for more
            % details

            area   = Triangle.triangleArea(connection,XY);
            zAvg   = Triangle.triangleAverage(connection,Z);
            volume = area.*zAvg;
        end

    end
end
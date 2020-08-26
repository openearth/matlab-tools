%Class with functions for improvegrid user interface
%
% @author ABR
% @version
%

classdef TriangleGui < handle
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
    methods(Static)
        
        function [Connect,xy] = addTriangle(Connect,xy,z,nrExistPoints,outline)
            % adds new triangles by clicking with the mouse
            %
            % [Connect,xy] = TriangleGui.addTriangle(Connect,xy,z,nrExistPoints,outline)
            % INPUT: xy: [Nx2] matrix with coordinates
            %        Connect: [Mx3] connection matrix
            %        z: either a vector with colordata or a function to a
            %        function to generate these
            %        outline: a cell array with the outlines to plot
            %        nrExistPoints: the number of existing points in the triangle
            %
            % OUTPUT: xy: [Nx2] matrix with updated coordinates
            %         Connect: [Mx3] updated connection matrix
            %
            % ABR
            %6-7-2012
            if nargin==4
                outline = {};
            end
            w = 1;
            while w==1
                
                %get point
                [x,y,w] = fastGinput(1);
                if w ==1
                    xData = xy(:,1);
                    yData = xy(:,2);
                    
                    
                    % look for point closest to the mouse
                    ind1 = TriangleGui.getDist(xData,yData,[x,y]);
                    
                    % find second point
                    [x,y,w] = fastGinput(1);
                    if w ==1
                        ind2 = TriangleGui.getDist(xData,yData,[x,y]);
                        if ind2==ind1
                            errordlg('Points should be destinct');
                            break;
                        end
                        [x,y,w] = fastGinput(1);
                        if w ==1
                            switch nrExistPoints
                                case 2
                                    xy(end+1,:) = [x,y,ones(1,size(xy,2)-2)];
                                    Connect(end+1,:) = [ind1,ind2,size(xy,1)];
                                case 3
                                    ind3 = TriangleGui.getDist(xData,yData,[x,y]);
                                    Connect(end+1,:) = [ind1,ind2,ind3];
                            end
                            % update plot
                            xyLims = [get(gca,'xlim');get(gca,'ylim')];
                            TriangleGui.updatePlot(Connect,xy,z,outline,xyLims);
                        else
                            break;
                        end
                    else
                        break;
                    end
                    
                end
            end
        end
        
        function [Connect,xyTri] = deleteManyTriangles(Connect,xyTri,z,outline)
            % Deletes all triangles inside a polyline
            %
            %[Connect,xyTri] = TriangleGui.deleteManyTriangles(Connect,xyTri,z,outline)
            %
            % INPUT: xy: [Nx2] matrix with coordinates
            %        Connect: [Mx3] connection matrix
            %        z: either a vector with colordata or a function to a
            %        function to generate these
            %        outline: a cell array with the outlines to plot
            %
            %
            % OUTPUT: xy: [Nx2] matrix with updated coordinates
            %         Connect: [Mx3] updated connection matrix
            % ABR
            %6-7-2012
            if nargin ==3
                outline = {};
            end
            xy = Util.polyLineSelect();
            if length(xy)>2
                center =  Triangle.centerGravity(xyTri,Connect);
                theMask = inpoly(center,xy);
                [Connect,xyTri] = Triangle.deleteTri(Connect,xyTri,theMask);
                % plot the triangles
                hPatch  = findobj('type','patch');
                delete(hPatch);
                % update plot
                xyLims = [get(gca,'xlim');get(gca,'ylim')];
                TriangleGui.updatePlot(Connect,xyTri,z,outline,xyLims);
            end
        end
        
        
        function [Connect,xy] = deleteTriangle(Connect,xy,z,outline)
            % Deletes an element in a grid (made with plotTriangle) by clicking with the mouse
            %
            % [Connect,xy] = TriangleGui.deleteTriangle(Connect,xy,z,outline)
            %
            % INPUT: xy: [Nx2] matrix with coordinates
            %        Connect: [Mx3] connection matrix
            %        z: either a vector with colordata or a function to a
            %        function to generate these
            %        outline: a cell array with the outlines to plot
            %
            %
            % OUTPUT: xy: [Nx2] matrix with updated coordinates
            %         Connect: [Mx3] updated connection matrix
            % ABR
            %6-7-2012
            
            if nargin ==3
                outline = {};
            end
            
            w = 1;
            while w==1
                
                %get point
                [x,y,w] = fastGinput(1);
                if w ==1
                    theMask = Triangle.inTriangle(Connect,xy,[x,y]);
                    if sum(theMask)==0
                        errordlg('Point is not inside a triangle');
                        break;
                    end
                    [Connect,xy] = Triangle.deleteTri(Connect,xy,theMask);
                    
                    hPatch  = findobj('type','patch');
                    delete(hPatch);
                    % update plot
                    xyLims = [get(gca,'xlim');get(gca,'ylim')];
                    TriangleGui.updatePlot(Connect,xy,z,outline,xyLims);
                    
                else
                    break;
                end
            end
        end
        
        
        function xy = movePoint(Connect,xy,z,outline,threshold)
            % Move points in a grid (made with plotTriangle) by clicking
            % with the mouse. Right mouse stops input.
            %
            % xy = TriangleGui.movePoint(Connect,xy,z,outline,threshold)
            % INPUT: xy: [Nx2] matrix with coordinates
            %        Connect: [Mx3] connection matrix
            %        z: either a vector with colordata or a function to a
            %        function to generate these
            %        outline: a cell array with the outlines to plot
            %        threshold(optional): the maximum distance to take into
            %        account
            %
            % OUTPUT: xy: [Nx2] matrix with updated coordinates
            % ABR
            %6-7-2012
            
            if nargin<=4
                threshold = 50000;
            end
            if nargin <=3
                outline = {};
            end
            
            w = 1;
            while w==1
                hAx = gca;
                %get point
                [x,y,w] = fastGinput(1);
                if w ==1
                    xyPoint = [x,y];
                    hKid = get(hAx,'chil');
                    xData = xy(:,1);
                    yData = xy(:,2);
                    
                    % look for point closest to the mouse
                    [theInd,minDist] = TriangleGui.getDist(xData,yData,xyPoint);
                    if minDist<threshold
                        % assuminmg that all points with the same distance are the same
                        %  point. may not be true
                        xyData = [xData(theInd(1)),yData(theInd(1))];
                        
                        % set
                        hold on;
                        hHulp = plot(xyData(1),xyData(2),'o','markersize',10);
                        hold off;
                        
                        % find
                        [x,y,w] = fastGinput(1);
                        if w ==1
                            xy(theInd,1) = x;
                            xy(theInd,2) = y;
                            delete(hKid)
                            delete(hHulp)
                            % update plot
                            xyLims = [get(gca,'xlim');get(gca,'ylim')];
                            TriangleGui.updatePlot(Connect,xy,z,outline,xyLims);
                            
                        end
                    else
                        errordlg('point not close enough');
                    end
                end
            end
        end
        
        function xy = movePointNumerical(Connect,xy,z,outline,threshold)
            % Move points in a grid (made with plotTriangle) by clicking
            % with the mouse. Right mouse stops input.
            %
            % xy = TriangleGui.movePoint(Connect,xy,z,outline,threshold)
            % INPUT: xy: [Nx2] matrix with coordinates
            %        Connect: [Mx3] connection matrix
            %        z: either a vector with colordata or a function to a
            %        function to generate these
            %        outline: a cell array with the outlines to plot
            %        threshold(optional): the maximum distance to take into
            %        account
            %
            % OUTPUT: xy: [Nx2] matrix with updated coordinates
            % ABR
            %6-7-2012
            
            if nargin<=4
                threshold = 50000;
            end
            if nargin <=3
                outline = {};
            end
            
            w = 1;
            while w==1
                hAx = gca;
                %get point
                [x,y,w] = fastGinput(1);
                if w ==1
                    xyPoint = [x,y];
                    hKid = get(hAx,'chil');
                    xData = xy(:,1);
                    yData = xy(:,2);
                    
                    % look for point closest to the mouse
                    [theInd,minDist] = TriangleGui.getDist(xData,yData,xyPoint);
                    if minDist<threshold
                        % assuminmg that all points with the same distance are the same
                        %  point. may not be true
                        xyData = [xData(theInd(1)),yData(theInd(1))];
                        
                        % set
                        hold on;
                        hHulp = plot(xyData(1),xyData(2),'o','markersize',10);
                        hold off;
                        
                        % Message dialogue
                        prompt = {'New X coordinate:';'New Y coordinate'};
                        title = 'New coordinates';
                        dims = [1 35];
                        definput = {num2str(xyData(1)),num2str(xyData(2))};
                        answer = inputdlg(prompt,title,dims,definput)
                        
                        
                        if ~isempty(answer)
                            xy(theInd,1) = str2double(answer(1));
                            xy(theInd,2) = str2double(answer(2));
                            delete(hKid)
                            delete(hHulp)
                            % update plot
                            xyLims = [get(gca,'xlim');get(gca,'ylim')];
                            TriangleGui.updatePlot(Connect,xy,z,outline,xyLims);
                        end
                    else
                        errordlg('point not close enough');
                    end
                end
            end
        end
        
        function xy = nodeNumberQuery(Connect,xy,outline,threshold)
            % Query node number
            %
            % xy = TriangleGui.movePoint(Connect,xy,z,outline,threshold)
            % INPUT: xy: [Nx2] matrix with coordinates
            %        Connect: [Mx3] connection matrix
            %        outline: a cell array with the outlines to plot
            %        threshold(optional): the maximum distance to take into
            %        account
            %
            % OUTPUT: xy: [Nx2] matrix with updated coordinates
            % ABR
            %6-7-2012
            
            if nargin<=3
                threshold = 50000;
            end
            if nargin <=2
                outline = {};
            end
            
            w = 1;
            while w==1
                hAx = gca;
                %get point
                [x,y,w] = fastGinput(1);
                if w ==1
                    xyPoint = [x,y];
                    hKid = get(hAx,'chil');
                    xData = xy(:,1);
                    yData = xy(:,2);
                    
                    % look for point closest to the mouse
                    [theInd,minDist] = TriangleGui.getDist(xData,yData,xyPoint);
                    if minDist<threshold
                        % assuminmg that all points with the same distance are the same
                        %  point. may not be true
                        xyData = [xData(theInd(1)),yData(theInd(1))];
                        
                        % set
                        hold on;
                        hHulp = plot(xyData(1),xyData(2),'o','markersize',10);
                        hold off;
                        
                        % Message dialogue
                        prompt = sprintf('Node Number = %i',theInd(1));
                        msgbox(prompt)
                        
                    else
                        errordlg('point not close enough');
                    end
                end
            end
        end
        
        
        function [ind,minDist] = getDist(xData,yData,xyPoint)
            % finds the closest point
            
            theDist = sqrt((xData(:)-xyPoint(1)).^2 +(yData(:)-xyPoint(2)).^2);
            [minDist,ind] = min(theDist);
            
        end
        
        function [Connect,xy] = splitManyTriangle(Connect,xy,z,nrSplit,outline)
            % splits new triangles by clicking with the mouse
            %
            % [Connect,xy] = TriangleGui.splitManyTriangle(Connect,xy,z,nrSplit,outline)
            % INPUT: xy: [Nx2] matrix with coordinates
            %        Connect: [Mx3] connection matrix
            %        z: either a vector with colordata or a function to a
            %        function to generate these
            %        outline: a cell array with the outlines to plot
            %        nrSplit: the resulting number of triangles
            %
            % OUTPUT: xy: [Nx2] matrix with updated coordinates
            %         Connect: [Mx3] updated connection matrix
            %
            % ABR
            
            ind1 = [1 2 3];
            ind2 = [2 3 1];
            
            if nargin==4
                outline = {};
            end
            uiwait(msgbox('Click to make a polyline. All triangles with their centers inside the polyline will be split','Split in four','modal'));
            % find all triangles to split using polyline
            theTri = triangulation(double(Connect),xy(:,1:2));
            xyPoly = Util.polyLineSelect();
            center =  Triangle.centerGravity(xy,Connect);
            theMask = inpoly(center,xyPoly);
            theMask = find(theMask);
            nrTri    = length(theMask);
            edgeMin =  zeros(nrTri,1);
            edgeMax =  zeros(nrTri,1);
            edgeNew =  zeros(nrTri,1);
            indNeb  =  nan(nrTri,3);
 
            switch nrSplit
                % split in four
                case 4
                    for iTri = 1:nrTri
                        % look for triangle touching
                        ikle = double(Connect(theMask(iTri),:));  
                        for i = 3:-1:1
                            cTmp = edgeAttachments(theTri,ikle(ind1(i)),ikle(ind2(i)));
                            cTmp = cTmp{1};
                            % delete original element
                            cTmp(cTmp==theMask(iTri))=[];
                            if ~isempty(cTmp)
                                indNeb(iTri,i) = cTmp;
                            end
                        end
                    end
                    n = 0;
                    % add points if needed
                    for iTri = 1:nrTri
                        nrX  = size(xy,1);
                        ikle = Connect(theMask(iTri),:);                        
                        for i=1:3
                            % point need to be added in the middle (in case no
                            % point or point not yet processed
                            % all dat a is interpolated on the edge 
                            iNeb = indNeb(iTri,i);
                            if  isnan(iNeb) || iTri==1 || (iTri>1 && ~any(iNeb==theMask(1:iTri-1)))
                                ikleEdge = ikle([ind1(i),ind2(i)]);
                                xyI = 0.5.*sum(xy(ikleEdge,:));
                                nrX = nrX +1 ;
                                xy(nrX,:) = xyI;
                                n = n+1;
                                % lookup table with new points on edges
                                edgeMin(n)=min(ikleEdge);
                                edgeMax(n)=max(ikleEdge);
                                edgeNew(n)=nrX;
                            end
                        end
                    end
                    % add new elements for split up cells
                    for iTri = 1:nrTri
                        % split triangle in four; add triangles
                        ikle = Connect(theMask(iTri),:); 
                        % find new points between edges
                        indL1  = edgeNew(edgeMin==min(ikle(1),ikle(2)) & edgeMax==max(ikle(1),ikle(2)));
                        indL2  = edgeNew(edgeMin==min(ikle(3),ikle(2)) & edgeMax==max(ikle(3),ikle(2)));
                        indL3  = edgeNew(edgeMin==min(ikle(1),ikle(3)) & edgeMax==max(ikle(1),ikle(3)));
                        % add new elements
                        Connect(end+1,:) = [ikle(1), indL1, indL3];
                        Connect(end+1,:) = [indL1, indL2, indL3];
                        Connect(end+1,:) = [ikle(2), indL2, indL1];
                        Connect(end+1,:) = [indL2,indL3,ikle(3)];                        
                    end
                    
                    % split up cells outside
                     allTri = unique(indNeb(~isnan(indNeb)));
                     allNb  = setdiff(allTri,theMask);
                     nrNb   = length(allNb);
                     % split boundary triangles in two
                     for iNb = 1:nrNb
                         ikle = Connect(allNb(iNb),:);
                         for i=1:3
                             ikleEdge = ikle([ind1(i),ind2(i)]);
                             edgeMask = edgeMin==min(ikleEdge) & edgeMax==max(ikleEdge);
                             if any(edgeMask)
                                 indNew = edgeNew(edgeMask);
                                 indOld = ikle(setdiff([1 2 3],[ind1(i),ind2(i)]));
                                 Connect(end+1,:) = [indNew, indOld, ikle(ind1(i))];
                                 Connect(end+1,:) = [indNew, indOld, ikle(ind2(i))];
                                 continue
                             end
                         end
                     end

                     % delete original triangles
                     theMask = [theMask; allNb];
                    [Connect,xy] = Triangle.deleteTri(Connect,xy,theMask);
                    
                otherwise
                    error('wrong input for nrSplit');
            end
            % update plot
            xyLims = [get(gca,'xlim');get(gca,'ylim')];
            TriangleGui.updatePlot(Connect,xy,z,outline,xyLims);
        end
        
        
        function [Connect,xy] = splitTriangle(Connect,xy,z,nrSplit,outline)
            % splits new triangles by clicking with the mouse
            %
            % [Connect,xy] = TriangleGui.splitTriangle(Connect,xy,z,nrSplit,outline)
            % INPUT: xy: [Nx2] matrix with coordinates
            %        Connect: [Mx3] connection matrix
            %        z: either a vector with colordata or a function to a
            %        function to generate these
            %        outline: a cell array with the outlines to plot
            %        nrSplit: the resulting number of triangles
            %
            % OUTPUT: xy: [Nx2] matrix with updated coordinates
            %         Connect: [Mx3] updated connection matrix
            %
            % ABR
            %6-7-2012
            triInd = [1 2 3;2 3 1;3 1 2];
            if nargin==4
                outline = {};
            end
            w = 1;
            while w==1
                
                %get point
                [x,y,w] = fastGinput(1);
                if w ==1
                    xData = xy(:,1);
                    yData = xy(:,2);
                    
                    
                    % look for point closest to the mouse
                    nrX  = size(xy,1);
                    % find original triangle
                    theMask = Triangle.inTriangle(Connect,xy,[x,y]);
                    if sum(theMask)==0
                        errordlg('Point is not inside a triangle');
                        break;
                    end
                    ikle = Connect(theMask,:);
                    
                    switch nrSplit
                        % split in two by edge
                        case 2
                            % find closest edge
                            tmp = xy([ikle,ikle(1)],:);
                            dist = PolyLine.dist2line([x y],tmp);
                            [~,ind] = min(dist);
                            % find points
                            indP = ikle(triInd(:,ind));
                            % find connecting triangles
                            mask = find(any(Connect==indP(1),2) & any(Connect==indP(2),2));
                            
                            % add point at center of the edge
                            xC = sum(xy(indP(1:2),1))/2;
                            yC = sum(xy(indP(1:2),2))/2;
                            xy(nrX+1,1) = xC;
                            xy(nrX+1,2) = yC;
                            
                            % add new  triangles
                            Connect(end+1,:) = [indP(1), indP(3),nrX+1];
                            Connect(end+1,:) = [indP(2), indP(3),nrX+1];
                            % if not a border tehre is another element
                            if length(mask)>1
                                theMask = setdiff(mask,theMask);
                                ikle = Connect(theMask,:);
                                newP = setdiff(ikle,indP);
                                Connect(end+1,:) = [indP(1), newP,nrX+1];
                                Connect(end+1,:) = [indP(2), newP,nrX+1];
                            end
                            
                            % delete original triangles
                            [Connect,xy] = Triangle.deleteTri(Connect,xy,mask);
                        case 3
                            % split in three using existing point
                            
                            % add points
                            xC = sum(xy(ikle,1))/3;
                            yC = sum(xy(ikle,2))/3;
                            xy(nrX+1,1) = xC;
                            xy(nrX+1,2) = yC;
                            % add new triangles
                            Connect(end+1,:) = [ikle(1), ikle(2),nrX+1];
                            Connect(end+1,:) = [ikle(2), ikle(3),nrX+1];
                            Connect(end+1,:) = [ikle(3), ikle(1),nrX+1];
                            % delete original trinagle
                            [Connect,xy] = Triangle.deleteTri(Connect,xy,theMask);
                        case 4
                            %
                            ind1 = [1 2 3];
                            ind2 = [2 3 1];
                            
                            % add points in the middle of the edges
                            for i = 3:-1:1
                                xI(i) = 0.5.*sum(xy(ikle([ind1(i),ind2(i)]),1));
                                yI(i) = 0.5.*sum(xy(ikle([ind1(i),ind2(i)]),2));
                            end
                            xy(nrX+1:nrX+3,1) = xI';
                            xy(nrX+1:nrX+3,2) = yI';
                            
                            % find neighbouring elemnst (which have the
                            % same edge)
                            for i = 3:-1:1
                                tmp   = find(any(Connect==ikle(ind1(i)),2) & any(Connect==ikle(ind2(i)),2));
                                nb(i) = tmp(tmp~=theMask);
                            end
                            
                            % split triangle in four; add triangles
                            Connect(end+1,:) = [ikle(1), nrX+1, nrX+3];
                            Connect(end+1,:) = [nrX+1, nrX+2, nrX+3];
                            Connect(end+1,:) = [ikle(2), nrX+2, nrX+1];
                            Connect(end+1,:) = [nrX+3,nrX+2,ikle(3)];
                            
                            % split neighbouring triangles in two
                            for i=1:3
                                ikleTmp  = Connect(nb(i),:);
                                farP = setdiff(ikleTmp,ikle);
                                Connect(end+1,:) = [ikle(ind1(i)),nrX+i,farP];
                                Connect(end+1,:) = [ikle(ind2(i)),nrX+i,farP];
                            end
                            
                            
                            % delete original triangles
                            theMask = [theMask, nb];
                            [Connect,xy] = Triangle.deleteTri(Connect,xy,theMask);
                    end
                    % update plot
                    xyLims = [get(gca,'xlim');get(gca,'ylim')];
                    TriangleGui.updatePlot(Connect,xy,z,outline,xyLims);
                else
                    break;
                end
                
            end
        end
        
        
        function updatePlot(Connect,xy,z,outline,xyLims)
            % updates a plot
            
            cla;
            if isnumeric(z)
                % numeric
                Plot.plotTriangle(xy(:,1),xy(:,2),z,Connect);
                caxis([0 1]);
            else
                %function handle for automatic updating
                vData = z(Connect,xy(:,1:2));
                Plot.plotTriangle(xy(:,1),xy(:,2),vData,Connect);
                caxis([0 1]);
            end
            shading flat;
            if ~isempty(outline)
                hold on;
                % lines
                if ~isempty(outline{1})
                    for i =1:length(outline{1})
                        plot(outline{1}{i}(:,1),outline{1}{i}(:,2),'-r','linewidth',3)
                    end
                end
                % points
                if  length(outline)>1 && ~isempty(outline{2})
                    for i =1:length(outline{2})
                        plot(outline{2}{i}(:,1),outline{2}{i}(:,2),'*r','markersize',5)
                    end
                end
                % outliers etc
                if length(outline)>2 && ~isempty(outline{3})
                    for i =1:length(outline{3})
                        if ~isempty(outline{3}{i})&&~isempty(outline{3}{i}.x)
                            h(i) = plot(outline{3}{i}.x,outline{3}{i}.y,outline{3}{i}.marker,'markersize',10);
                        end
                    end
                    if isfield (outline{3}{1},'legend') && exist('h','var')
                        legend(h,outline{3}{1}.legend);
                    end
                end
            end
            axis equal;
            
            if nargin==5
                set(gca,'xlim',xyLims(1,:));
                set(gca,'ylim',xyLims(2,:));
            end
            
        end
        
        
    end%methods
    
    
    
    
    %Private methods
    methods (Static,Access = 'private')
    end
    
end
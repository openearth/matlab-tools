%Class to declare the most common Output
%
% @author ABR
% @author THL
% @version 0.1, 27/02/2017
%

classdef MeshSizeTools < handle
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
        
        
        
        
        function [] = meshSize(sctInput)
            % Adjust mesh size based on geometric criteria
            % [] = meshSize(sctInput)
            %
            % INPUTS:
            % sctInput: structure with the following fields:
            % - bathFile: Bathy file (in .asc format), can be written with Export.writeArcView)
            % - outFile: Name of output file (in .xyz format)
            % - xMin: Minimum x value of grid (if no bathy file given)
            % - dx: x resolution of grid (if no bathy file given)
            % - xMax: Maximum x value of grid (if no bathy file given)
            % - yMin: Minimum y value of grid (if no bathy file given)
            % - dy: y resolution of grid (if no bathy file given)
            % - yMax: Maximum y value of grid (if no bathy file given)
            % Outputs:
            % - Text file in sctInput.outFile

            sctInput = Util.setDefault(sctInput,'dxAoi',5);
            sctInput = Util.setDefault(sctInput,'dxMin',50);
            sctInput = Util.setDefault(sctInput,'dxMax',200);
            sctInput = Util.setDefault(sctInput,'growthRate', 0.1);
            sctInput = Util.setDefault(sctInput,'Href',5);
            sctInput = Util.setDefault(sctInput,'useGrad',true);
            sctInput = Util.setDefault(sctInput,'useDist',false);
            sctInput = Util.setDefault(sctInput,'useHydroIncon',false);
            sctInput = Util.setDefault(sctInput,'maxGrad',Inf);
            sctInput = Util.setDefault(sctInput,'maxRelGrad',Inf);
            
            

            
            
            % read bathymetry
            if isfield(sctInput,'bathFile')
                [xGrid,yGrid,zBath] = Import.readArcView(sctInput.bathFile);
                sctInput = Util.setDefault(sctInput,'useGrad',1);
            else
                [xGrid,yGrid] = meshgrid(sctInput.xMin:sctInput.dx:sctInput.xMax,sctInput.yMin:sctInput.dy:sctInput.yMax);
                sctInput.useGrad = 0;
            end
            
            
            sizeGrid = inf.*ones(size(xGrid));

            % read outline
            if isfield(sctInput,'outlineFile')
                theData = Telemac.readKenue(sctInput.outlineFile);
                
                
                % initialize processing loop
                for iLine = 1:length(theData)
                    x = theData{iLine}(:,1);
                    y = theData{iLine}(:,2);
                    
                    % close if needed
                    if (x(1)-x(end))^2 + (y(1)-y(end))^2 >1e-3
                        x(end)=x(1);
                        y(end)=y(1);
                    end
                    
                    % smooth and resample the outline
                    [x,y] = MeshSizeTools.smoothOutline(x,y);
                    
                    % apply distance to the shoreline
                    if sctInput.useDist
                        sizeTmp  = MeshSizeTools.fromDistance(xGrid,yGrid,x,y,sctInput.dxMin,sctInput);
                        sizeGrid = min(sizeGrid,sizeTmp);
                    end
                end
            end
            
            
            % apply gradient criterium
            if sctInput.useGrad
                dx = xGrid(1,2)-xGrid(1,1);
                dy = yGrid(2,1)-yGrid(1,1);
                sctInput.xGrid = xGrid;
                sctInput.yGrid = yGrid;
                sizeTmp  =  MeshSizeTools.fromGradient(zBath,dx,dy,sctInput);
                sizeGrid =  min(sizeGrid,sizeTmp);
            end
            
            % apply area of interest
            if isfield(sctInput,'areaOfInterest')
                aoiData = Telemac.readKenue(sctInput.areaOfInterest);
                x = aoiData{1}(:,1);
                y = aoiData{1}(:,2);
                
                % close if needed
                if (x(1)-x(end))^2 + (y(1)-y(end))^2 >1e-3
                    x(end)=x(1);
                    y(end)=y(1);
                end
                sizeTmp  = MeshSizeTools.fromDistance(xGrid,yGrid,x,y,sctInput.dxAoi,sctInput);
                
                % set points inside to the minimum distance
                mask     = inpoly([xGrid(:),yGrid(:)],[x,y]);
                sizeGrid(mask) = sctInput.dxAoi;
                sizeGrid = min(sizeGrid,sizeTmp);
                
                % add some extra points to be certain
                % TODO
                
            end
                        
            %apply maximum distance
            if isfield(sctInput,'dxMax')
                sizeGrid = min(sizeGrid,sctInput.dxMax);
            end
            
            %dist = fromCurvature(xGrid,yGrid,x,y,sctInput.minDist,sctInput.maxDist,sctOpt);
            
            % store data
            if exist('theData','var')
                for i=1:length(theData)
                    sctOut.xOutline{i} = theData{i}(:,1);
                    sctOut.yOutline{i} = theData{i}(:,2);
                end
            end
            sctOut.x = xGrid;
            sctOut.y = yGrid;
            sctOut.size = sizeGrid;
            
            % Plot results
            MeshSizeTools.plotMeshDensity(sctOut);
            
            % preprocess
            dataOut = [sctOut.x(:),sctOut.y(:),sctOut.size(:)];
            mask = isnan(dataOut(:,3));
            dataOut(mask,:) = [];
            if exist('theData','var')
                % only use data inside the polygon
                mask = inpoly(dataOut(:,[1 2]),[sctOut.xOutline{1},sctOut.yOutline{1}]);
                dataOut(~mask,:) = [];
            end
            
            % write to file
            fid = fopen(sctInput.outFile,'w');
            fprintf(fid,'%f %f %f \n',dataOut');
            fclose(fid);
        end
        
        function [xNew,yNew] = smoothOutline(x,y)
            % smoothe the outline
            
            % todo
            xNew = x;
            yNew = y;
        end
        
        function dist = fromCurvature(xGrid,yGrid,x,y,minDist,maxDist,sctOpt)
            % determines distance grid
            
            if nargin < 7
                sctOpt = struct;
            end
            sctOpt = Util.setDefault(sctOpt,'minWindow',6);
            
            % compute curvature
            s = sqrt(diff(x).^2+diff(y.^2));
            d2xds2 = diffCyclic(x,s,2);
            d2yds2 = diffCyclic(y,s,2);
            k = sqrt(d2xds2.^2 + d2yds2.^2);
            
            % weighted min filter
            k = movingMinCyclic(k,sctOpt.minWindow);
            
            
            
            % assign weights based on curvature
            dist = maxDist - k./max(k).*(maxDist-minDist);
            
            % weighed average based on distances (interpolation)
            
            
            
        end
        
        function dydx = diffCyclic(y,x,N)
            % numeric central difference for data where the start and end are connected
            %
            % dydx = diffCyclic(y,x,N)
            %
            % INPUT:
            % x,y: [Nx1] vector with data where y = is a function of x
            %   N: the order of differentiation
            % OUTPUT:
            % dydx: theNth order central difference of the data in y
            %
            
            nrX = length(x);
            mask1 = 1+mod(1:nrX,nrX);
            mask2 = 1+mod(-1:nrX-2,nrX);
            dydx = y;
            for i=1:N
                dydx = (dydx(mask1)-dydx(mask2))./(x(mask1)-x(mask2));
            end
            
        end
        function y = movingMinCyclic(x,N)
            % moving minimum for data where the start and end are connected
            %
            % y = movingMinCyclic(x,N)
            %
            % INPUT:  x: [Mx1] input values
            %         N:  the number of neighbouring values to be taken into
            %         account
            % OUTPUT: y: [Mx1] fileterd output values
            
            
            if N>nrX
                error('number');
            end
            y = inf.*(ones(nrX,1));
            for i=-N:N
                mask = 1+mod(N:nrX+N-1,nrX);
                y = min(y,x(mask));
            end
        end
        
        
        function sizeGrid = fromDistance(xGrid,yGrid,x,y,dxMin,sctOpt)
            
            % calculate the distance from the mesh to the outline
            dist2 = inf.*ones(size(xGrid));
            for i=1:length(x)
                distTmp = (x(i)-xGrid).^2 + (y(i)-yGrid).^2;
                dist2 = min(dist2,distTmp);
            end
            dist = sqrt(dist2);
            
            % apply mesh size to the distance
            kE        = sctOpt.growthRate;
            sizeGrid  = dxMin + kE.*dist;
            
        end
        
        function sizeMesh = fromGradientOld(z,dx,dy,sctOpt)
            % calculates the mesh spacing based on gradients in the bathymetry
            
            sctOpt = Util.setDefault(sctOpt,'minDep',2.5);
            
            % calculates the gradients
            [z,gradZ] = targetedAveragingGradient(z,dx,dy,sctOpt);
            
            dxMin = sctOpt.dxMin;
            dxMax = sctOpt.dxMax;
            % mesh based on absolute gradient
            sizeAbs = dxMax -(dxMax-dxMin).*gradZ./max(gradZ(:));
            
            % mesh based on relative gradient
            dep = sctOpt.Href-z;
            dep(dep<0) = nan;
            relGradZ = gradZ./max(dep,sctOpt.minDep);
            sizeRel = dxMax -(dxMax-dxMin).*relGradZ./max(relGradZ(:));
            % combine
            sizeMesh = min(sizeAbs,sizeRel);
            sizeMesh = smoothn(sizeMesh);
            
            
        end
        
        function sizeMesh = fromGradient(z,dx,dy,sctOpt)
            % calculates the mesh spacing based on gradients in the bathymetry
            
            sctOpt = Util.setDefault(sctOpt,'minDep',2.5);
            sctOpt = Util.setDefault(sctOpt,'maxGrad',1e-2);
            sctOpt = Util.setDefault(sctOpt,'maxRelGrad',1e-2);
            
            % calculates the gradients
            [z,gradZ] = MeshSizeTools.targetedAveragingGradient(z,dx,dy,sctOpt);
            
            dxMin = sctOpt.dxMin;
            % mesh based on absolute gradient
            smoothGradZ = smoothn(gradZ);
            theDist = MeshSizeTools.distTransform(smoothGradZ<sctOpt.maxGrad,dx,dx.*sqrt(2));
            sizeAbs = dxMin + theDist.*sctOpt.growthRate;
            
            % mesh based on relative gradient
            dep = sctOpt.Href-z;
            dep(dep<0) = nan;
            relGradZ = gradZ./max(dep,sctOpt.minDep);
            relGradZ = smoothn(relGradZ);
            theDist = MeshSizeTools.distTransform(relGradZ<sctOpt.maxRelGrad,dx,dx.*sqrt(2));
            sizeRel = dxMin + theDist.*sctOpt.growthRate;
            
            % Mesh based on hydrostatic inconsistencies
            if sctOpt.useHydroIncon
                sizeHydro = (sctOpt.dss ./abs(relGradZ));
                
                sizeHydro2 = sizeHydro;
                for limSize = logspace(0,2,10)*min(sizeHydro(:))
                    theDist = MeshSizeTools.distTransform(sizeHydro>limSize,dx,dx.*sqrt(2));
                    thisSize = limSize+theDist.*sctOpt.growthRate;
                    sizeHydro2 = min(sizeHydro2,thisSize);
                end
                
            end
            
            % combine
            sizeMesh = min(sizeAbs,sizeRel);
            sizeMesh = min(sizeMesh,sizeHydro2);
            
            
            
        end
        
        
        
        function [z,gradZ] = targetedAveragingGradient(z,dx,dy,sctOpt)
            % adapts the bathymetry
            
            %default values
            sctOpt = Util.setDefault(sctOpt,'maxIter',100);
            sctOpt = Util.setDefault(sctOpt,'maxGrad',100);
            sizeZ = size(z) + [2,2];
            zTmp = nan(sizeZ);
            zTmp(2:end-1,2:end-1) = z;
            z = zTmp;
            %determine gradient
            [dzdx,dzdy] = gradient(z,dx,dy);
            gradZ = sqrt(dzdx.^2 + dzdy.^2);
            %targeted averaging
            nIter = 0;
            weights = [4 2 2 2 2 1 1 1 1];
            nrWrongOld = numel(z);
            nrCycle = 0;
            while nIter<sctOpt.maxIter && max(gradZ(:))>sctOpt.maxGrad
                %find cells to update
                zTmp = z;
                mask  = find(gradZ > sctOpt.maxGrad);
                %make list with points
                [iList,jList]  = ind2sub(mask,sizeZ);
                % update with surrounding values
                for i=1,nrCycle
                    iList = [iList;iList-i;iList+i;iList;  iList];
                    jList = [jList;jList;  jList  ;jList-i;jList+i];
                    % delete cells outside the boundaries
                    mask = iList>1 & jList>1 & iList<sizeZ(1) & jList<sizeZ(2);
                    iList(~mask) = [];
                    jList(~mask) = [];
                    % delete double points
                    nList = sub2ind(sizeZ,iList,jList);
                    [~,mask] = unique(nList);
                    iList = iList(mask);
                    jList = jList(mask);
                end
                nrWrong = length(iList);
                if nrWrong<nrWrongOld
                    nrWrongOld = nrWrong;
                else
                    nrCycle = nrCycle + 1;
                    nrWrongOld = numel(z);
                    continue;
                end
                for iP =1:nrWrong
                    % change bathymetry
                    i = iList(iP);
                    j = jList(iP);
                    tmp    = [z(i,j),z(i-1,j),z(i+1,j),z(i,j+1),z(i,j-1),z(i-1,j-1),z(i+1,j-1),z(i+1,j+1),z(i-1,j+1)];
                    zTmp(i,j) = sum(weights.*tmp)./sum(weights.*isnan(tmp));
                end
                % recalculate gradients
                z = zTmp;
                [dzdx,dzdy] = gradient(z,dx,dy);
                gradZ = sqrt(dzdx.^2 + dzdy.^2);
                nIter = nIter + 1;
            end
            z     =     z(2:end-1,2:end-1);
            gradZ = gradZ(2:end-1,2:end-1);
        end
        
        function theDist = distTransform( v,d1,d2 )
            % Computes distance map of an input image using 3x3 Chamfer mask
            % theDist = distTransform( v,d1,d2 )
            %
            %  INPUT:
            %        - v       Input image (should be double): (non-feature,feature) = (1,0)
            %        - d1      Horizontal/vertical neighbor weight
            %        - d2      Diagonal neighbor weight
            %  OUTPUT:
            %        - theDist Results after second pass of the Chamfer algorithm
            %  EXAMPLE:
            %   v = ones(300,300);
            %   v(150,150) = 0;
            %   d1 = 0.9612;
            %   d2 = 1.3604;
            %  Downloaded from https://nl.mathworks.com/matlabcentral/fileexchange/58661-fast-chamfer-distance-transform
            
            % Initialize the input Image
            if(ndims(v)==3)
                v = rgb2gray(v);
            end
            v = double(v);
            v = v([1,1:end,end],[1,1:end,end]);
            v(v~=0) = inf; % Replace 1's by a suitably large number
            M1 = size(v,1); % Number of lines (rows)
            M2 = size(v,2); % Number of columns
            
            %Forward pass
            [ rowsZero, colsZero ] = find(~v(2:end-1,2:end-1));
            rows = min(rowsZero) + 1;
            cols = min(colsZero) + 1;
            for k1=rows:M1-1
                for k2=cols:M2-1
                    v(k1,k2) = min([v(k1 - 1, k2 - 1) + d2, v(k1 - 1, k2) + d1,...
                        v(k1 - 1, k2 + 1) + d2, v(k1, k2 - 1) + d1, v(k1, k2)]);
                end
                cols = cols - 1;
                if(cols<=2)
                    cols = 2;
                end
            end
            % Backward pass
            
            for k1=M1-1:-1:2
                for k2=M2-1:-1:2
                    v(k1,k2) = min([v(k1, k2), v(k1, k2 + 1) + d1, v(k1 + 1, k2 - 1) + d2,...
                        v(k1 + 1, k2) + d1, v(k1 + 1, k2 + 1) + d2]);
                end
            end
            % Output
            theDist = v(2:end-1,2:end-1);
        end
        
        function [] = plotMeshDensity(sctData)
            % Plot results from Mesh Density Calculation
            figure;
            pcolor(sctData.x,sctData.y,sctData.size);
            shading flat
            axis equal;
            hold on;
            if isfield(sctData,'xOutline')
            for i=1:length(sctData.xOutline)
                plot(sctData.xOutline{i},sctData.yOutline{i},'-k','linewidth',2);
            end
            end
            colorbar;
        end
    end
end

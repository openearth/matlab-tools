%Class to declare the most common interpolate
%
% @author ABR
% @author SEO
% @version 0.8, 10/02/2014
%

classdef Interpolate < handle
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
        
        function [xNew,yNew] = gap2nan(x,y,xThresHold)
            % add nans to irregularly spaced data such that plots look
            % better
            %
            % [xNew,yNew] = gap2nan(x,y,xThresHold)
            %
            
            dx = median(diff(x));
            if nargin< 3
                xThresHold = 2*dx;
            end
            % make new regurlay specd variable
            options.threshold = xThresHold;
            options.method = 'nearest';
            xNew = linspace(round(min(x)),round(max(x)),round((max(x)-min(x))/dx))';
            yNew = Interpolate.interpThreshold(x,y,xNew,options);
        end
        
        function [i,j]  = getIndNearest(xi,yi,x,y)
            % find the index of the nearest point in a mesh
            %
            % [i,j]  = getIndNearest(xi,yi,x,y)
            % INPUT; xi, yi: [Nx1] vector with x and y coordinates for which the
            % closest point in th mesh neeeds to be found
            %   x,y: [MxK] matrixes with grid coodinates
            %
            % OUTPUT: [i,j] :indices of the closest point in the mesh
            %
            
            % preallocate
            nrXi = length(xi);
            i = zeros(nrXi,1);
            j = zeros(nrXi,1);
            for iX =1:nrXi
                % find the closest point
                dist2 = (x(:)-xi(iX)).^2 + (y(:)-yi(iX)).^2;
                [~,ind] = min(dist2);
                % use the first point in case there are multiple
                if numel(ind)>1
                    ind = ind(1);
                end
                % convert linear index
                [i(iX),j(iX)] = ind2sub(size(x),ind);
            end
        end
        
        function y = interpNan(x, options)
            % A very simple (basic) function that interpolates all nan values (using linear
            % interpolation and (neirest neighbour) extrapolation
            %
            %y = interpNan(x, options)
            %
            %INPUT: x:[Nx1] vector with input data
            %       options: a structure with the fields:
            %       - method: the used interpolation method in interp1 (the default is
            %       'linear)'
            %       -extrapmethod: the used extrapolation in intrep1 (the
            %       default is nearest)
            %OUTPUT: y [Nx1] vector with output data
            
            y = x;
            if  nargin==1
                options = struct;
            end
            for i=1:size(x,2) 
                y(:,i) = Interpolate.interpNanVec(x(:,i), options);
            end
        end
        
        function y = interpNanVec(x, options)
            % A very simple (basic) function that interpolates all nan values (using linear
            % interpolation and (neirest neighbour) extrapolation
            %
            %y = interpNanVec(x, options)
            %
            %INPUT: x:[Nx1] vector with input data
            %       options: a structure with the fields:
            %       - method: the used interpolation method in interp1 (the default is
            %       'linear)'
            %       -extrapmethod: the used extrapolation in intrep1 (the
            %       default is nearest)
            %OUTPUT: y [Nx1] vector with output data
            
            y = x;
            if  nargin==1
                options = struct;
            end
            options = Util.setDefault(options,'method','linear');
            options = Util.setDefault(options,'extrapmethod','nearest');

            if size(x,1)>size(x,2)
                x1 = (1:length(y))';
            else
                x1 = 1:length(y);
            end
            x2 = x1;
            isNan = isnan(y);
            yHulp = y;
            %make datasets to interpolate
            x2(isNan)= [];
            yHulp(isNan)= [];
            
            %extrapolate (using nearest neighbour)
            if ~ isempty(yHulp)
                yHulp2 = interp1(x2,yHulp,x1,options.extrapmethod,'extrap');
                %interpolation without extrapolation
                y = interp1(x2,yHulp,x1,options.method);
                %intsert nearest neighbour results
                y(isnan(y)) = yHulp2(isnan(y));
            end
        end
        
        function ynew = interpThreshold(x,y,xnew,options)
            % interpolate with matlab built-in function
            %
            % ynew = interpThreshold(x,y,xnew,options)
            %
            % INPUT:
            % x = source coordinate vector e.g.  time
            % y = variable to interpolate
            % xnew = coordinate vector in destiny file
            % options: -method: string with interpolation method
            %          -threshold : max interpolation interval.
            %
            % OUTPUT: ynew
            
            if nargin==3 || ~isfield(options,'method')
                options.method = 'linear';
            end
            
            % delete nans
            mask=isnan(x) | isnan(y);
            x(mask)=[];
            y(mask)=[];
            
            if ~isempty(y)
                %interpolate the data
                ynew = interp1(x,y,xnew,options.method);
                
                if isfield(options,'threshold')
                    % find the interval in the original dataset and compare to threshold
                    xinterval = diff(x);
                    xinterval = [xinterval(1);xinterval;xinterval(end)];
                    
                    xgrid = [x(1);0.5*(x(1:end-1)+x(2:end));x(end)];
                    dist = interp1(xgrid,xinterval,xnew,'linear','extrap');
                    mask =  (dist>options.threshold);
                    
                    % delete data
                    ynew(mask) = nan;
                end
            else
                ynew = nan(size(xnew));
            end
        end
        
        function yOut = interpMat1(xIn,yIn,xOut,extrap)
            % vectorized linear interpolation; use for vertical
            % interpolation in a 3D model
            %
            %  yOut = interpMat1(xIn,yIn,xOut,extrap)
            %
            % INPUT:
            %      - xIn: [NxM] matrix with coordinates (e.g. z values)
            %      - yIn: [NxM]matrix with values to interpolate
            %      - xOut: scalar [Nx1] vector matrix with values to interpolate to (e.g wanted z coordinate)
            %      - extrap: (optional) if true nearest neighhbour
            %      extrapolation is used
            % OUTPUT:
            %      - yOut: [Nx1] vector with interpolated values
            %
            % IMPORTANT:
            % The interpolation is always performed over the second
            % dimension!
            
            if nargin ==3
                extrap = false;
            end
            
            % Check if input data is oriented correctly
            if median(diff(xIn(1,:)))<0
                xIn = fliplr(xIn);
                yIn = fliplr(yIn);
            end
            
            % preallocate
            [nrX,nrLayer] = size(xIn);
            yOut = nan(nrX,1);
            
            if numel(xOut)==1
                xOut = repmat(xOut,nrX,1);
            end
            
            % loop over all layers
            for i=1:nrLayer-1
                mask = (xOut>=xIn(:,i)) & (xOut<=xIn(:,i+1));
                % weight
                dx   = (xOut(mask)-xIn(mask,i)) ./ (xIn(mask,i+1)-xIn(mask,i));
                % interpolate
                yOut(mask) = (1-dx).*yIn(mask,i) +(dx).*yIn(mask,i+1);
            end
            if extrap
                mask = xOut>xIn(:,end);
                yOut(mask) = yIn(mask,end);
                mask = xOut<xIn(:,1);
                yOut(mask) = yIn(mask,1);
            end
            
        end
        
        function zOut = InvDist(xIn,yIn,zIn,xOut,yOut,nFac)
            %inverse distance interpolation
            %
            % zOut = Interpolate.InvDist(xIn,yIn,zIn,xOut,yOut,nFac)
            %
            %INPUT:
            %  xIn: vector or Matrix with Input x-Coordinate
            %  yIn: vector or Matrix with Input y-Coordinate
            %  zIn: vector or Matrix with Input data
            %  xOut: vector or Matrix with output x-Coordinate
            %  yOut: vector or Matrix with output y-Coordinate
            %  nFac: scaling factor (DEFAULT = 2)
            
            % default pars
            if nargin ==5
                nFac = 2;
            end
            
            % preallocate
            sizeZ = size(xOut);
            nrZ   = prod(sizeZ);
            zOut  = zeros(nrZ,1);
            
            
            % apply masks
            mask = isnan(xIn) | isnan(yIn) | isnan(zIn);
            xDat = xIn(~mask);
            yDat = yIn(~mask);
            zDat = zIn(~mask);
            
            % update factor to account for distance
            bFac = -nFac/2;
            
            % loop over all points
            for i =1:nrZ
                dist2   = (xOut(i)-xDat(:)).^2 + (yOut(i)-yDat(:)).^2 ;
                [minDist,indDist] = min(dist2(:));
                if minDist~=0
                    weight  =   dist2.^(bFac);
                    zOut(i) = sum(weight.*zDat(:))./sum(weight);
                else
                    zOut(i) = zDat(indDist);
                end
            end
            
            % put back orginal size
            zOut = reshape(zOut,sizeZ);
            
        end
        
        function  [x,y] = preprocess(x,y)
            % prepare data for interpolation by deleting double data and sorting
            %
            % [x,y] = preprocess(x,y)
            %
            %INPUT/OUTPUT:
            % x: vector with coordinate data
            % y: vector with values to be interpolated
            
            % sorting data
            [xhulp,ind] = sort(x);
            if (any(xhulp~=x))
                %                 warning('Data is sorted during pre-processing;');
                x = xhulp;
                y = y(ind);
            end
            
            %removing double data
            
            [xhulp,ind] = unique(x);
            if length(xhulp)~=length(x)
                %                 warning('Double data is deleted during pre-processing;');
                x = xhulp;
                y = y(ind);
            end
            
            % deleting NaN values in 
            mask = isnan(x);
            if sum(mask)>0
                x = (x(~mask));
                y = (y(~mask));
            end
        end
        
        function   [x,permVec] = changeDim(x,oldXdim,newXdim)
            % extend data to four dimensions
            permVec = 1:4;
            permVec(oldXdim) = newXdim;
            permVec(newXdim) = oldXdim;
            x  = permute(x,permVec);
        end
        
        
        function cVar = uVarAtC(uVar,xDim)
            % interpolates data from U to C points
            %
            % cVar = uVarAtC(uVar)
            %
            % INPUT:
            %         - uVar:  multidimensional with values at U-points.
            %         - xDim: (optional): number of the dimension
            %               corresponding to the u direction; default = 1
            % OUTPUT:
            %         - cVar: array with values at C-points; the highest
            %                 data in the U dimension is filled with nan values
            
            if nargin ==1
                xDim = 1;
            end
            
            % make 4D
            [uVar,permVec] = Interpolate.changeDim(uVar,xDim,1);
            
            % determine sizes
            sizeU =  size(uVar);
            sizeC = sizeU;
            sizeC(1) = sizeC(1)-1;
            
            % determine nodata values
            mask       = isnan(uVar);
            uVar(mask) = 0;
            % mask when both points are zero
            newMask            = true(sizeU);
            newMask(1:end-1,:,:,:) = mask(1:end-1,:,:,:) & mask(2:end,:,:,:);
            
            % make empty data
            cVar = nan(sizeU);
            
            %determine weights.
            weight1 = 0.5.*ones(sizeC);
            
            %set weight to 1 if a nan value is found to the right
            weight1(mask(2:end,:,:,:))= 1;
            
            
            weight2 = 0.5.*ones(sizeC);
            %set weight to 1 if a nan value is found to the left
            weight2(mask(1:end-1,:,:,:))= 1;
            
            % interpolate
            cVar(1:end-1,:,:,:) = weight1.*uVar(1:end-1,:,:,:) + weight2.*uVar(2:end,:,:,:);
            cVar(newMask)   = nan;
            
            % set back to original format
            cVar = ipermute(cVar,permVec);
            
            
        end
        
        function cVar = vVarAtC(vVar,yDim)
            % interpolates data from V to C points
            %
            % cVar = vVarAtC(vVar,yDim)
            %
            % INPUT:
            %         - vVar:  multidimensional with values at V-points.
            %         - yDim: (optional): number of the dimension
            %               corresponding to the v direction; default = 2
            % OUTPUT:
            %         - cVar: array with values at C-points; the highest
            %                 data in the V dimension is filled with nan values
            
            if nargin ==1
                yDim = 2;
            end
            
            % make 4D
            [vVar,permVec] = Interpolate.changeDim(vVar,yDim,1);
            
            % determine sizes
            sizeV =  size(vVar);
            sizeC = sizeV;
            sizeC(2) = sizeC(2)-1;
            
            % determine nodata values
            mask       = isnan(vVar);
            vVar(mask) = 0;
            % mask when both points are zero
            newMask = true(sizeV);
            newMask(:,1:end-1,:,:) = mask(:,1:end-1,:,:) & mask(:,2:end,:,:);
            
            % make empty data
            cVar = nan(sizeV);
            
            %determine weights.
            weight1 = 0.5.*ones(sizeC);
            
            %set weight to 1 if a nan value is found to the right
            weight1(mask(:,2:end,:,:))= 1;
            
            weight2 = 0.5.*ones(sizeC);
            %set weight to 1 if a nan value is found to the left
            weight2(mask(:,1:end-1,:,:))= 1;
            
            % interpolate
            cVar(:,1:end-1,:,:) = weight1.*vVar(:,1:end-1,:,:) + weight2.*vVar(:,2:end,:,:);
            cVar(newMask)   = nan;
            
            % set back to original format
            cVar = ipermute(cVar,permVec);
        end
        
        function yNew = interpDir(x,y,xNew,isDegree,isNautical)
            % interpolates directions
            %
            % yNew = interpDir(x,y,xNew,isDegree,isNautical)
            %
            % NOTE: normally it is better to interpolate x and y components
            % Only use if that is not pissible.
            %
            
            if nargin <4
                isDegree = true;
            end
            if nargin <5 
                isNautical = isDegree;
            end
            if isNautical
                y = 90-y;
            end
            % convert to radians
            if isDegree
                y = y*pi/180;
            end
            % interpolate  x and y components
            sinY = interp1(x,sin(y),xNew);
            cosY = interp1(x,cos(y),xNew);
            % calculate back
            yNew = atan2(sinY,cosY);
            if isDegree
                yNew = 360/pi*yNew;
            end
            if isNautical
                yNew = 90-yNew;
            end
            
        end
        
        function varOut =  intExp2D(x,y,varIn,xIn,yIn)
            % combines 2d linear interpolation with nearest neighbour
            % extrapolation in 2d
            %
            %varOut =  intExp2D(x,y,varIn,xIn,yIn)
            %
            % INPUT:
            % - x,y: coordinate matrices (2D)
            % - varIn: variable to be interpolated
            % - xIn, yIn: column vector with points where to interpolate
            % OUTPUT
            % varOut: interpolated values (same size as xIn and yIn
            
            %linear interpolation
            varOut      = interp2(x,y,varIn,xIn,yIn,'linear');
            % nearest neighbour on nonNan points
            
            % make a list of all non nan points
            mask  = ~isnan(varIn);
            x     = x(mask);
            y     = y(mask);
            varIn = varIn(mask);
            % find nan values in interpolation
            int = find(isnan(varOut));
            for i=1:length(int)
                % find closest point to each nan point and apply
                d2 = (xIn(int(i))-x).^2 + (yIn(int(i))-y).^2;
                [~,i2] = min(d2);
                varOut(int(i)) = varIn(i2);
            end
        end
        
        
        function xInt = getThreshold(x,y,yLevel)
            % gets a threshold level by interpolation
            % 
            % xInt = getThreshold(x,y,yLevel)
            %
            % INPUT:
            % 
            % OUTPUT:
            %
            % e.g. used to determine fluid mud thickness form
            % concentrations or density
            
            % sort if needed
            [x,ind] = sort(x,'ascend');
            y = y(ind);
            
            for i= length(yLevel):-1:1
                mask = y(2:end)<yLevel(i) & y(1:end-1)>=yLevel(i);
                ind = find(mask,1,'first');
                if ~isempty(ind)
                    % linear interpolation
                    w = (yLevel(i)-y(ind))/(y(ind+1)-y(ind));
                    xInt(i) = x(ind)*(1-w) + x(ind+1)*w;
                else
                    xInt(i) = 0;
                end
            end
        end
        
    end
end
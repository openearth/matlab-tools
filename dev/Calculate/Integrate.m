%Class to declare the most common Calculations
%
% @author ABR
% @author SEO
% @version 0.8, 10/02/2014
%

classdef Integrate < handle
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
        
        function yMean = meanThreshold(x,y,dim,xMin,xMax)
            % average (i.e. voor depth average) using intThreshold
            %
            % yMean = meanThreshold(x,y,dim,xMin,xMax)
            %
            % INPUT see intTHreshold
            % 
            % OUTPUT: yMean average of y over x
            %
            
            % set default dimension
            
            % delete nans
%             mask = ~isnan(x)&~isnan(y);
%             x = x(mask);
%             y = y(mask);
            
            if isempty(x)||isempty(y)
                yMean = nan;
                return;
            end
            
            if nargin < 3
                dim = 1;
            end
            
            %set default thresholds
            if nargin < 5
                xMax = inf;
            end
            
            if nargin < 4
                xMin = -inf;
            end            

            yInt = Integrate.intThreshold(x,y,dim,xMin,xMax);
            if dim==1
                xLow  = min(x,[],1);
                xHigh = max(x,[],1);
            else
                xLow  = min(x,[],2);
                xHigh = max(x,[],2);
            end
            xMin = max(xLow,xMin);
            xMax = min(xHigh,xMax);
            
            dx   = xMax-xMin;
            yMean = yInt./dx;
        end
        
        function yInt = intThreshold(x,y,dim,xMin,xMax)
            % This function integrates data using the trapezium rule, while allowing a
            % cutoff at the lower and upper end of the integration domain.
            %
            %
            % yInt = intThreshold(x,y,dim,xMin,xMax)
            %
            % INPUT: y: [NxK] matrix of values to integrate. Optionally [N-1xK] (dim
            % ==1) or [N,K-1] (dim ==2_ are alos allowed. In that case cell centered
            % values are assumed, and the integration is first oprcer accurate rather
            % than second order (NOT TESTED YET).
            %        x: [NxK] matrix of coordinates used for the integration. Note that
            %        is assumed that x are the edges of the cells used for integration
            %        and that the values of y are also on the edges.
            %        xMin(optional): [1x1] or [1xK] (dim = 1) or {Nx1 (dim = 2}  vector of lower bound of integration (default -inf)
            %        xMax(optional): [1x1] or [1xK] (dim = 1) or {Nx1 (dim = 2}  vector of upper bound of integration
            %        dim: dimeniosn to integration. 1 means columns, 2 means rows
            %
            % OUTPUT: yInt: [1xK] dim = 1 or[Nx1](dim =2)  vector with the integrated values
            % values, each cell corresponds to a different value of the threshold
            %
            % METHOD: The boundaries are determined using linear interpolation; the size of the area of integration takes this into account
            %
            % Written by ABR
            % 24-5-2013
            
            
            
            % set default dimension
            
            if nargin < 3
                dim = 1;
            end
            
            %set default thresholds
            if nargin < 5
                xMax = inf;
            end
            
            if nargin < 4
                xMin = -inf;
            end
            
            % vectorise minimum and maximum if needed
            nrX = size(x);
            nrY = size(y);
            xMin = Integrate.vectData(xMin,dim,nrX);
            xMax = Integrate.vectData(xMax,dim,nrX);
            
            
            % integrate along columns
            if dim==1
                % determine the grid psacing
                dx = x(2:end,:) - x(1:end-1,:);
                % calculation of the integratiom factors
                % lower one
                alpha = (xMin-x(1:end-1,:))./dx;
                alpha = max(min(alpha,1),0);
                % upper one
                beta =  (x(2:end,:)-xMax)./dx;
                beta = min(max(beta,0),1);
                % use trapezium rule
                if nrY(1)==nrX(1)
                    dyInt = 0.5.* dx.* (1-alpha-beta).*((1-alpha+beta).*y(1:end-1,: )+(1+alpha-beta).*y(2:end,: ));
                else % use simpler integration (first order accurate)
                    dyInt = dx.* (1-alpha-beta).*y;
                end
            else
                % determine the grid spacing
                dx = x(:,2:end) - x(:,1:end-1);
                % calculation of the integratiom factors
                % lower one
                alpha = (xMin-x(:,1:end-1))./dx;
                alpha = max(min(alpha,1),0);
                % upper one
                beta =  (x(:,2:end)-xMax)./dx;
                beta = max(min(beta,1),0);
                % use trapezium rule
                if nrY(2)==nrX(2)
                    dyInt = 0.5.*dx.* (1-alpha-beta).*((1-alpha+beta).*y(:,1:end-1 )+(1+alpha-beta).*y(:,2:end ));
                else
                    dyInt = dx.* (1-alpha-beta).*y;
                end
                
            end
            % sum all data to get the answer
            yInt = sum(dyInt,dim);
            
            
        end
        
        function int = trapeziumRule(x,y)
            % integrate 1d data using trapezium rule
            %
            % int = trapeziumRule(x,y)
            %
            % INPUT
            % - x: Nx1 vector or NxM matrix
            % - y: [NxM] matrix
            %
            % OUTPUT
            % -int: [1xM] vector
            
            dx = diff(x);
            if size(x,2)==1
                dx = repmat(dx,1,size(y,2));
            end
            int = 0.5.*nansum(dx.*(y(2:end,:)+y(1:end-1,:)),1);
        end
        
        function int = trapeziumRule2dMG(x,y,z)
            %integrate 2d data twice using trapezium rule on data from
            % meshgrid
            %
            % int = trapeziumRule2dMG(x,y,z)
            %
            % NOTE: it is assumed that x varie salong the first domension
            % and y along the second (i.e. something crated bu meshgrid)
            
            dx    = diff(x(1,:));
            dy    = diff(y(:,1));
            int1d = 0.5.*nansum(dy.*(z(2:end,:)+z(1:end-1,:)));
            int   = 0.5.*nansum(dx.*(int1d(1:end-1)+int1d(2:end)));
            
        end
        
        function int = trapeziumRule2d(x,y,z)
            % integrate 2d data twice using trapezium rule
            %
            % int = trapeziumRule2d(x,y,z)
            %
            % INPUT: -x: vector with coordinates
            %  matrix with coordinates; the first dimension is
            % the x dimension and the second one the y direction
            %        -z: matrix with the 
            % OUTPUT:
            %        -int: the integrated value
            %                 
            
            % formal definition of the area of quadrilateral
%             dx1 = x(2:end,1:end-1)-x(1:end-1,1:end-1);
%             dy1 = y(2:end,1:end-1)-y(1:end-1,1:end-1);
%             dx2 = x(2:end,2:end)-x(1:end-1,2:end);
%             dy2 = y(2:end,2:end)-y(1:end-1,2:end);
%             A = 0.25.*(dx1+dx2).*(dy1.*dy2);
            
%             x1 = x(1:end-1,1:end-1);
%             x2 = x(2:end,1:end-1);
%             x3 = x(2:end,2:end);
%             x4 = x(1:end-1,2:end);
%             y1 = y(1:end-1,1:end-1);
%             y2 = y(2:end,1:end-1);
%             y3 = y(2:end,2:end);
%             y4 = y(1:end-1,2:end);
%             
%             A = 0.5*(x1.*y2+x2.*y3+x3.*y4+x4.*y1-x2.*y1-x3.*y2-x4.*y3-x1.*y4);
%             % now integrate
%             int = 0.25.*sum(sum(A.* ( z(1:end-1,1:end-1)+z(1:end-1,2:end)...
%                                   +   z(2:end  ,1:end-1)+z(2:end  ,2:end))));
            % stupid way only 2d data in y, not in x
            
            dx    = diff(x);
            dy    = y(:,2:end)-y(:,1:end-1);
            int1d = 0.5.*nansum(dy.*(z(:,2:end)+z(:,1:end-1)));
            int   = 0.5.*nansum(dx.*(int1d(1:end-1)+int1d(2:end)));

        end
        function int = trapeziumRulePos(x,y)
            % integrate 1d data using trapezium rule, using only positive
            % y data
            %
            % int = trapeziumRulePos(x,y)
            %
            % INPUT: -x: coordinatye
            %        -y: data; this can be a matrix integration occurs along the first
            %        dimension
            % OUTPUT:
            %        -int: the integrated value
            %            
            
            SMALL = 1e-12;
            dx = diff(x);
            dy = diff(y);
            dx = repmat(dx,1,size(dy,2));
            tmp = y(1:end-1,:)./max(abs(dy),SMALL);
            alpha1 = max(min(tmp,1),0);
            tmp = y(2:end,:)./max(abs(dy),SMALL);
            alpha2 = max(min(tmp,1),0);
            int = 0.5.*sum(dx.*(alpha2.*y(2:end,:)+alpha1.*y(1:end-1,:)));
        end
        
        function int = trapeziumRuleNeg(x,y)
            % integrate 1d data using trapezium rule, using only negative
            % y data
            %
            %int = trapeziumRuleNeg(x,y)
            %
            % INPUT: -x: coordinatye
            %        -y: data; this can be a matrix integration occurs along the first
            %        dimension
            % OUTPUT:
            %        -int: the integrated value
            %
            SMALL = 1e-12;
            dx = diff(x);
            dy = diff(y);
            dx = repmat(dx,1,size(dy,2));
            tmp = y(1:end-1,:)./max(abs(dy),SMALL);
            alpha1 = -min(max(tmp,-1),0);
            tmp = y(2:end,:)./max(abs(dy),SMALL);
            alpha2 = -min(max(tmp,-1),0);
            int = 0.5.*sum(dx.*(alpha2.*y(2:end,:)+alpha1.*y(1:end-1,:)));
        end        
        
    end % Static methods
    
    methods(Static,Access=private)
        function xMat = vectData(xVec,dim,nrX)
            % vectorise minimum and maximum if needed
            % Only used by intThreshold
            xMat = xVec;
            nrXdat = size(xVec);
            
            % column vector
            if nrXdat(1) > 1
                if dim == 1
                    % integration on columns for each row.
                    % mirror data to match (need to be rows)
                    xMat = repmat(xVec',nrX(1)-1,1);
                else
                    % integration over rows
                    xMat = repmat(xVec,1,nrX(2)-1);
                end
            elseif nrXdat(2) > 1
                if dim == 1
                    % integration over columns
                    xMat = repmat(xVec,nrX(1)-1,1);
                else
                    % integration over rows
                    % mirror data to match (need to be columns)
                    xMat = repmat(xVec',1,nrX(2)-1);
                end
            end
        end
        
    end% Private static methods
end
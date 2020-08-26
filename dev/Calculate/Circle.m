%%Class to declare the most common Calculations
%
% @author ABR
% @author SEO
% @version 0.8, 10/02/2014
%

classdef Circle < handle
    %Public properties
    properties
        Property1;
    end

    %Dependent properties
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

    %Static methods
    methods (Static)
                
        function [x, y] = create(center, r, degrees, arc)
            % This function calculates the x and y-coordinates in
            % carthesian grid. These coordinates could be used to plot a
            % circle using plot(x,y).
            %
            % INPUT: - center: coordinates of the center format [x(mid),y(mid)]
            %        - r: radius of the circle (numeric)
            %        - options: 
            %           * degrees: resolution expressed in degrees 
            %              (default: 1)
            %           * arc: limits of the angles [angle(lower),angle(upper)] 
            %                  (in degrees): default [0,360];
            %        
            % OUTPUT: x = NX1 with x-coordinates of circle
            %         y = NX1 with y-coordinates of circle
            
            if nargin == 2
               degrees = 1; 
               arc = [0, 360];
            elseif nargin == 3
                arc = [0, 360];
            end
            th = deg2rad(min(arc):degrees:max(arc));
            r = repmat(r,size(th));
            [x,y] = pol2cart(th,r);
            x = x + center(1);
            y = y + center(2);
        end
        
        function y = getXCoord(center, r, x, range)
            % This function gives the y coordinates (always 2) of circle if
            % x-coordinate is known.
            %
            % INPUT: - center: coordinates of the center format [x(mid),y(mid)]
            %        - r: radius of the circle (numeric)
            %        - x: Nx1 matrix with x coordinates
            %        - dim
            %        - options: 
            %           * range: range of theta need to be searched otherwise replace by NaN 
            %              (default: [] = all y-values)
            %           
            %        
            % OUTPUT: Nx2 matrix with y coordinates of a circle
            
            if nargin < 4
               range = []; 
            end
            bTranspose = false;
            if size(x,2) == length(x)
               x = x'; bTranspose = true;
            end
            
            r = repmat(r,size(x));
            x = x - center(1);
            y(:,1) = center(2) + (r.^2 - x.^2).^0.5;
            y (:,2) = center(2) - (r.^2 - x.^2).^0.5;
            
            if ~isempty(range)
                range(range < 0) = range(range < 0) + 360;
                
                th = atan2d(y - center(2), repmat(x,1,2));
                th(th < 0) = th(th < 0) + 360;
                mask = min(range) < th & th < max(range);
                y(~mask) = nan;
                
            end
            if bTranspose
               y = y';
            end
        end
        function x = getYCoord(center, r, y, range)
            % This function gives the x coordinates (always 2) of circle if
            % y-coordinate is known.
            %
            % INPUT: - center: coordinates of the center format [x(mid),y(mid)]
            %        - r: radius of the circle (numeric)
            %        - y: Nx1 matrix with x coordinates
            %        - dim
            %        - options:
            %           * range: range of theta need to be searched otherwise replace by NaN
            %              (default: [] = all x-values)
            %
            %
            % OUTPUT: Nx2 matrix with x coordinates of a circle
            if nargin < 4
               range = []; 
            end
            center = center([2,1]);
            x = Circle.getXCoord(center, r, y, range);
        end
    end
end
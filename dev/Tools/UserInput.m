%Class with a template to make new Classes
%
% @author ABR
% @author SEO
% @version
%

classdef UserInput < handle
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
        function [imX,imY] = digitize()
            % Function to get points from mouse. Stop with right mouse
            % button.
            %
            % [imX,imY] = UserInput.digitize()
            %
            % OUTPUT: imX and imY: [Nx1] vectors with x and y coordinates
            % (in image coordinates). Last clicked point is last in the
            % list.
            w = 1;
            imX= [];
            imY= [];
            while w==1
                [xIn,yIn,w] = fastGinput(1);
                imX = [imX;xIn];
                imY = [imY;yIn];
            end
            if ~isempty(imX)
                imX = imX(1:end-1);
                imY = imY(1:end-1);
            end
        end
        
        function [xPoly,yPoly,handle] = getPoly(isClosed)
            % get start and end coordinates
            %
            %  [xPoly,yPoly,handle] = getPoly(isClosed)
            %
            % OUTPUT:
            % xPoly, yPoly: [nx1] matrix with start and end x and y
            % coordinates
            % handle: list with handles to graphic objects
            
            if nargin <1
                isClosed = false;
            end
            
            i = 2;
            hold on;
            % start coordinate
            xPoly = [];
            yPoly = [];
            handle = [];
            [x0,y0,w] = fastGinput(1);
            if w~=1
                return;
            end
            xPoly = x0;
            yPoly = y0;
            
            hP = plot(x0,y0,'mo','markerfacecolor','m');
           
            while true
                
                [x1,y1,w] = fastGinput(1);
                if w~=1
                    break;
                end
                xPoly(i) = x1; %#ok<AGROW>
                yPoly(i) = y1; %#ok<AGROW>
                handle(1) = plot(x1,y1,'mo','markerfacecolor','m');
                if length(handle)>1
                    delete(handle(2));
                end
                if isClosed && i>=3
                    handle(2) = plot([xPoly,xPoly(1)],[yPoly,yPoly(1)],'m-','linewidth',1.5);
                else
                    handle(2) = plot(xPoly,yPoly,'m-','linewidth',1.5);
                end
                i = i + 1;
            end
            if isClosed && i>=3
                xPoly = [xPoly,xPoly(1)];
                yPoly = [yPoly,yPoly(1)];
            end
        end

        
        function [xprof,yprof,handle] = getProf
            % get start and end coordinates
            %
            %  [xprof,yprof,handle] = getProf
            %
            % OUTPUT:
            % xprof, yprof: [nx2] matrix with start and end x and y
            % coordinates
            % handle: list with handles to graphic objects
            
            i = 1;
            xprof = [];
            yprof = [];
            hold on;
            while true
                
                % start coordinate
                [x0,y0,w] = fastGinput(1);
                if w~=1
                    break;
                end
                hP = plot(x0,y0,'mo','markerfacecolor','m');
                tP = text(x0,y0,num2str(i),'fontsize',9,'color','k');
                [x1,y1,w] = fastGinput(1);
                if w~=1
                    break;
                end
                
                handle(i,1) = plot(x1,y1,'mo','markerfacecolor','m');
                handle(i,2) = plot([x0 x1],[y0 y1],'m-','linewidth',1.5);
                handle(i,3) = text(x0,y0,num2str(i),'fontsize',6,'color','k');
                
                xprof(i,1) = x0; %#ok<AGROW>
                xprof(i,2) = x1; %#ok<AGROW>
                yprof(i,1) = y0; %#ok<AGROW>
                yprof(i,2) = y1; %#ok<AGROW>
                i = i + 1;
            end
        end
    end
end
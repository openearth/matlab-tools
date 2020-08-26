%Class to declare the most common WebCalibrate
%
% @author ABR
% @author SEO
% @version 0.8, 10/02/2014
%

classdef WebCalibrate < handle
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
        function calibrateData(varX, varY, fileToApply, flags, options)
            %open a gui to make some calibration
            [dataset, loadOk] = Dataset.loadData(fileToApply,0);
            if ~loadOk
                errordlg('Error to read the end file. Please verify the format.');
                return;
            end;

            if ~isfield(dataset, varX) || ~isfield(dataset, varY)
                errordlg('Error. The selected variables do not exist in the file');
                return;
            end;
            %prepare the data for the GUI
            data.xName       = varX;
            data.yName       = varY;
            data.x           = dataset.(varX).data;
            data.y           = dataset.(varY).data;
            data.options     = options;
            data.fileToApply = fileToApply;

            %open the gui
            calibrateData(data);
        end;

        function [dataInRect,dataInd] = getDataInRect( p1, p2, hline )
            % Define low and high x and y values, rbbox will reverse them if you draw rectangle from bottom up
            if ( p1(1) < p2(1) )
                lowX = p1(1); highX = p2(1);
            else
                lowX = p2(1); highX = p1(1);
            end

            if ( p1(2) < p2(2) )
                lowY = p1(2); highY = p2(2);
            else
                lowY = p2(2); highY = p1(2);
            end

            xdata = get(hline,'XData');
            ydata = get(hline,'YData');

            xind = (xdata >= lowX & xdata <= highX);
            yind = (ydata >= lowY & ydata <= highY);

            %dataInd    = xind & yind; % these are the indices in xdata and ydata where the points lie within the rectangle
            dataInd = xind; % these are the indices in xdata and ydata where the points lie within the rectangle

            dataInRect = [xdata(dataInd)]'; % this returns all of the data inside the rect in one 2xN matrix

        end;

        function [setDataInRect setDataInd] = selectDataPlot( hax )
            %allow to make a selection with a rectangle and extract the data inside
            k = waitforbuttonpress;
            point1 = get(gca,'CurrentPoint');    % button down detected
            rbbox;                   % return figure units
            point2 = get(gca,'CurrentPoint');

            % Now lets iterate through all lines in the axes and extract the data that lies within the selected region
            allLines = findall(hax,'type','line');

            for n = 1:length(allLines)
                point1 = point1(1,1:2);              % extract x and y
                point2 = point2(1,1:2);
                p1     = min(point1,point2);             % calculate locations
                offset = abs(point1-point2);         % and dimensions
                x = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
                y = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];
                hold on
                line(x,y,'color','r','linewidth',2);

                [setDataInRect,setDataInd] = WebCalibrate.getDataInRect( point1(1,1:2), point2(1,1:2), allLines(n) ); % not interested in z-coord

            end;
        end;

    end
end
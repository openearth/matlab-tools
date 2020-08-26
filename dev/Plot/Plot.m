classdef Plot < handle
    % Special plotting functions
    
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
        function  [hAxesQuiver,hColorbar] = colorQuiver(x, y, z, u, v, nrColors, colorScale, plotOptions)
            % plot colored quiver vectors, using a colormap
            %
            % [hAxesQuiver,hColorbar] = colorQuiver(x, y, z, u, v, nrColors, colorScale, plotOptions)
            % INPUT: data: struct with x,y,u,v, fields (x coordinate y corrdinate x vector length and y vector
            % length) for quiver plot ([NxM],  z: colordata (samesize as x,y,u,v)
            %       plotOptions: struct with arrowScale, colorScale, colorMap
            %           arrowScale: scaling factor for arrow lengths; default = 1;
            %           colorScale: scaling for colors : either
            %                   - [2x1] vector, with upper and lower scale
            %                   - [C+1x1] vector, with edges of the colorbins
            %           colorMap: [Cx3] matrix with colorinformation
            %           colorMapStyle: style of the colormap (default: jet)
            %           addColorBar: boolean stating whether a colorbar
            %           need to be added
            %
            % OUTPUT:
            %      hQuiv: vector of handles to the quiverplot
            %      hColorbar: handle to the colorbar
            
            plotOptions = Util.setDefault(plotOptions,'colorMapStyle', 'jet');
            plotOptions = Util.setDefault(plotOptions,'addColorBar', true);
            % plotOptions = Util.setDefault(plotOptions,'arrowScale',1);
            if ~isfield(plotOptions,'colorMap')
                plotOptions.colorMap = UtilPlot.colormapIMDC(plotOptions.colorMapStyle, nrColors);
            end
            
            for i=1:nrColors
                mask = (z>=colorScale(i)) & (z<colorScale(i+1));
                if any(any(mask))
                    hQuiv(i) = quiver(x(mask),y(mask),u(mask),v(mask),0,'color',plotOptions.colorMap(i,:));
                    hold on
                end
            end
            % checks for values higher than color limit
            maskHigh = z>=colorScale(end);
            if any(any(maskHigh))
                hQuivHigh(i) = quiver(x(maskHigh),y(maskHigh),u(maskHigh),v(maskHigh),0,'color',plotOptions.colorMap(end,:));
            end
            
            maskLow = z<colorScale(1);
            if any(any(maskLow))
                hQuivLow(i) = quiver(x(maskLow),y(maskLow),u(maskLow),v(maskLow),0,'color',plotOptions.colorMap(1,:));
            end
            
            hAxesQuiver = gca;
            
            % make a colorbar
            colormap(plotOptions.colorMap);
            caxis(colorScale([1 end]));
            if plotOptions.addColorBar
                hColorbar = colorbar('location','eastoutside');
                %set(hColorbar,'ylim',colorScale([1 end]));
                set(hColorbar,'ytick',colorScale);
            else
                hColorbar = nan;
            end
        end
        
        function [hContour, hColor, oldPos] = contourFigure(ax, x, y, z, plotOptions)
            % this function plot a contour. You can specify if you want to use pcolor
            % function or contourf. By default use pcolor
            % plotOptions.contourType
            % ax: current axes Handle
            
            plotOptions = Util.setDefault(plotOptions,'nrColors', 8);
            %verifiy if the value is a number
            plotOptions = Util.setDefaultNumberField(plotOptions,'nrColors');
            nrColors    = plotOptions.nrColors;
            
            %set default Z limits
            plotOptions = Util.setDefault(plotOptions,'zLimitStart', '');
            plotOptions = Util.setDefault(plotOptions,'zLimitEnd', '');
            
            %verifiy if the value is a number - is necesary for web app
            plotOptions = Util.setDefaultNumberField(plotOptions,'zLimitStart');
            plotOptions = Util.setDefaultNumberField(plotOptions,'zLimitEnd');
            
            %define Z limits
            if ~isempty(plotOptions.zLimitStart) && ~isempty(plotOptions.zLimitEnd)
                zLimit = [plotOptions.zLimitStart plotOptions.zLimitEnd];
            else
                zLimitStart = min(z(:));
                zLimitEnd   = max(z(:));
                
                zLimit = [zLimitStart zLimitEnd];
            end;
            axes(ax);
            oldPos = get(gca,'pos');
            hColor = colorbar;
            
            set(hColor, 'location','eastoutside');
            ztick = zLimit(1):range(zLimit)/(nrColors):zLimit(2);
            
            plotOptions = Util.setDefault(plotOptions,'contourType', 'pcolor');
            plotOptions = Util.setDefault(plotOptions,'colorMapStyle', 'jet');
            plotOptions = Util.setDefault(plotOptions,'contourLevel', '');
            plotOptions = Util.setDefault(plotOptions,'xVar', '');
            hContour = [];
            
            %apply colorbar correction
            switch plotOptions.contourType
                case 'pcolor'
                    checkYData = find(isnan(y) == 0);
                    checkZData = find(isnan(z) == 0);
                    if ~isempty(checkYData)
                        hContour = pcolor(ax,x,y,z);
                    end
                    if ~isnan(zLimit)
                        caxis(zLimit);
                    end
                    %apply shading
                    UtilPlot.applyShading(plotOptions);
                    %apply colormap IMDC fix
                    if ~strcmpi(plotOptions.xVar, 'Time')
                        myColorMap = UtilPlot.colormapIMDC(plotOptions.colorMapStyle, nrColors);
                        colormap(myColorMap);
                    end
                    hColor = colorbar;
                    
                    if ~isnan(ztick)
                        %set(hColor,'ztick',length(ztick)+1);
                        set(hColor,'ytick',ztick);
                    end
                    
                    if ~isnan(zLimit)
                        set(hColor,'ylim',zLimit);
                    end
                    
                case 'contourf'
                    contourLevel = [];
                    %get the contourlevel input and convert to a function
                    getContourlevel = str2func(['@()' plotOptions.contourLevel]);
                    
                    %execute the function to get the value
                    contourLevel = getContourlevel();
                    
                    %apply colormap imdc fix
                    colorMap = UtilPlot.colormapIMDC(plotOptions.colorMapStyle, length(contourLevel));
                    
                    %plot the general contour.
                    [hContour, hContourgroup, hColor] = UtilPlot.generalContour(x,y,z,contourLevel,colorMap, plotOptions, ax);
                otherwise
                    error('Invalid contour type');
            end
            
            plotOptions = Util.setDefault(plotOptions,'titleColorbar', '');
            if ~isempty(plotOptions.titleColorbar)
                set(get(hColor,'title'),'string',plotOptions.titleColorbar)
            else
                %set(get(hColor,'title'),'string',dataset.(zVar).longname);
            end
            
        end
        
        function  namePlot(names,x,y, varargin)
            % this function plots data as function of
            %
            % namePlot(names,y, varargin)
            %
            % INPUT:
            %    - names: cell array with names to put ton the x axis
            %    - x: x-values; if empty just an increasing number 1:n will
            %    be used
            %    - y: values to plot; the dependent variables are in the
            %    first dimensions
            %    - varargin: input parameters to pass to the plot function
            % OUTPUT:
            %
            %REMARKS: you must set the ylims of the axis and fontsize before calling
            % this function!!!!
            %
            
            if length(names)~=size(y,1)
                error('The number of names does not match the number of data values ')
            end
            if nargin<3
                x = [];
            end
            if isempty(x)
                index = 1:length(names);
                xLim = [0 length(names)+1]; % makes a nicer plot
            else
                index = x;
                dXTotal = max(x)-min(x);
                xLim = [min(x)-dXTotal/20 max(x)+dXTotal/20];
            end
            
            plot(index,y,varargin{:})
            set(gca,'xlim',xLim);
            set(gca,'xtick',index);
            set(gca,'xticklabels',names);
            rotateticklabel(gca,45);
        end
        
        function aBar = plotBar(ax,xData,yData, plotOptions)
            %this function makes a plot type bar.
            plotOptions = Util.setDefault(plotOptions,'widthBar',0.8);
            %verifiy if the value is a number - is necesary for web app
            plotOptions = Util.setDefaultNumberField(plotOptions,'widthBar');
            plotOptions = Util.setDefault(plotOptions,'barStyle','grouped');
            plotOptions = Util.setDefault(plotOptions,'barColor','b');
            
            
            %plot bar
            aBar = bar(ax, xData,yData,plotOptions.widthBar,'stacked', 'FaceColor', plotOptions.barColor);
        end
        
        function plotCell(aCell,lineSpec)
            % wrapper to plot all data in a cell array
            %
            % plotCell(aCell,lineSpec)
            
            hold on;
            for i=1:length(aCell)
                plot(aCell{i}(:,1),aCell{i}(:,2),lineSpec)%,varargin);
            end
        end
        
        function aHLine = plotHorizontalLine(x, y, xVar, yVar, plotOptions)
            %this function makes a horizontal line plot
            lineConfiguration = '';
            plotOptions = Util.setDefault(plotOptions,'lineType','');
            if ~isempty(plotOptions.lineType)
                lineConfiguration = [lineConfiguration plotOptions.lineType];
            end
            
            plotOptions = Util.setDefault(plotOptions,'color','');
            if ~isempty(plotOptions.color)
                lineConfiguration = [lineConfiguration plotOptions.color];
            end
            
            plotOptions = Util.setDefault(plotOptions,'markerType','');
            if ~isempty(plotOptions.markerType)
                lineConfiguration = [lineConfiguration plotOptions.markerType];
            end
            
            hold on;
            [xStart xEnd] = UtilPlot.getLimsXData(x, xVar, plotOptions);
            [yStart yEnd] = UtilPlot.getLimsYData(y, yVar, plotOptions);
            
            xLims = [xStart xEnd];
            yLims = [yStart yEnd];
            
            xmin =  xLims(1);
            xmax =  xLims(2);
            for i = 1:length(x)
                newX = [xmin xmax];
                newY = [y(i) y(i)];
                aHLine = plot(newX, newY, lineConfiguration);
            end
            
            xlim(xLims);
            ylim(yLims);
            hold off;
        end
        
        function aLine = plotLinesSplited(ax, x, y, plotOptions)
            %start to build the line configuration for each line in
            %plot
            [plotProperty plotPropertyValue] = UtilPlot.buildLinePropertiesNew(plotOptions);
            
            %make the plot
            aLine = plot(ax,x,y);
            
            %set the custom properties plot
            for zz=1:length(plotProperty)
                set(aLine, plotProperty{zz}, plotPropertyValue{zz})
            end
        end
        
        function plotPyramid(axHandle, x, y, plotOptions)
            % plots data in a triangle (for sand mud mixtures)
            %
            % plotPyramid(axHandle, x, y, plotOptions)
            %
            % INPUT:
            % x: vector with percentages (between 0 and 100)
            % y: vector with percentages (between 0 and 100;note that z is generated
            % automatically as z = 1-x-y)
            % plotOptions: a structure with the fields:
            %  - dx: spacing of the grid lines
            %  - offset: offset of the text
            %  -fontSize: the size of the fontd
            %  -leftLabel: the label on the left
            %  -rightLabel: the label on the right
            %  -topLabel: the label on the top
            %  -markerType: the type of marker
            %
            %set default options
            if nargin == 3
                plotOptions = struct;
            end
            plotOptions = Util.setDefault(plotOptions,'dx',10);
            plotOptions = Util.setDefault(plotOptions,'offset',3);
            plotOptions = Util.setDefault(plotOptions,'fontSize',10);
            plotOptions = Util.setDefault(plotOptions,'leftLabel',{''});
            plotOptions = Util.setDefault(plotOptions,'rightLabel',{''});
            plotOptions = Util.setDefault(plotOptions,'topLabel',{''});
            plotOptions = Util.setDefault(plotOptions,'markerType','*');
            
            dx         = plotOptions.dx;
            offset     = plotOptions.offset;
            fontSize   = plotOptions.fontSize;
            leftLabel  = plotOptions.leftLabel;
            rightLabel = plotOptions.rightLabel;
            topLabel   = plotOptions.topLabel;
            markerType = plotOptions.markerType;
            
            set(axHandle, 'visible','off');
            
            % create the background
            xPatch = [0 100 50 0];
            yPatch = [0 0 50*sqrt(3) 0];
            patch(xPatch,yPatch,ones(size(xPatch)),'facecolor','w');
            
            % add the lines and marks
            for i = dx:dx:100-dx
                % left side to bottom
                xTri(1) = i/2;
                yTri(1) = i/2*sqrt(3);
                xTri(2) = i;
                yTri(2) = 0;
                
                line(xTri,yTri,'color','k','linestyle',':');
                text(xTri(1)-offset,yTri(1),num2str(100-i),'fontsize',fontSize,'horizontalalignment','center');
                text(xTri(2),yTri(2)-offset,num2str(i),'fontsize',fontSize,'horizontalalignment','center');
                
                % left side to right side
                xTri(2) = 50 + (100-i)/2;
                yTri(2) = yTri(1);
                line(xTri,yTri,'color','k','linestyle',':');
                text(xTri(2)+offset,yTri(2),num2str(i),'fontsize',fontSize,'horizontalalignment','center');
                
                % right side to bottom side
                xTri(1) = 100-i;
                yTri(1) = 0;
                line(xTri,yTri,'color','k','linestyle',':');
            end
            
            % add the labels
            
            text(0,0-offset,leftLabel,'fontsize',fontSize,'horizontalalignment','right')%,'verticalalignment','top');
            text(100,0-offset,rightLabel,'fontsize',fontSize,'horizontalalignment','left')%,'verticalalignment','top');
            text(50,50*sqrt(3)+offset,topLabel,'fontsize',fontSize,'horizontalalignment','center')%,'verticalalignment','bottom');
            
            % plot the data
            
            % transform data to the right coordinate
            hold on;
            x = x + y./2;
            y = y./2*sqrt(3);
            plot(axHandle, x, y, markerType);
            axis equal;
        end
        
        function hpol = plotPolar(theta, radius, plotOptions)
            % polar plot usiong nautical directions
            %
            % hpol = plotPolar(theta, radius, plotOptions)
            %
            % INPUT: theta: the direction in degrees (with respect to the north, nautical convention)
            %        radius: gthe radius
            %
            %  Options are provided in the variable plotOptions with the following fields:
            %           -plotOptions.plotAxis A boolean variable which is
            %           one when the axis are plotted, and zero when data
            %           are plotted. Inorder to have a nice plot, call this
            %           function twice, first to plot the axis (setting
            %           plotAxis = 1), than to plot the data (plotAxis =
            %           0). Use hold on;
            %           -plotOptions.unitString A string containing the unit to be plotted.
            %           -plotOptions.rLimit: The maximum radius (scalar).
            %           -plotOptions.rLimitTick: The interval in radial
            %           direction (scalar).
            %           -plotOptions.thetaLimitTick (scalar): the interval in the angular direction.
            %           -plotOptions.lineStyle: the linestyle of the plotnvoke
            %   See PLOT for a description of legal linestyles. Note that there is an
            %   extra option to use the linestyle 'A' in order to plot arrows coming
            %   from the origin.
            %
            % OUTPUT:
            % hpol: the handle to the generated figure;
            
            
            if nargin == 2
                plotOptions = struct;
            end
            plotOptions = Util.setDefault(plotOptions,'lineStyle','-');
            %generate the polar plot.
            hpol = UtilPlot.polarPlotNautical(theta,radius,plotOptions);
        end
        
        
        function [p,pEdge] = plotStrip(xIn,yIn,zIn,w,style,edgeColor)
            % plots line data in colors on a strip with a width
            %
            % [p,pEdge] = plotStrip(xIn,yIn,zIn,w,style,edgeColor)
            %
            %INPUT:
            % - xIn,yIn,zIn: Nx1 vectors with x y and z data of the
            %stript. The z data is plot in colroscale
            % - w: Nx1 vector or scalar with the width of the strip (same scale as xIn and yIn )
            % - style: interpolation style of the path. options are : 'flat'
            % and 'interp'
            % - edgeColor (optional): color pof the edge
            %OUTPUT:
            % -p: handle to the patch object that is generated
            % -pEdge: handle to the outline
            
            if nargin ==5
                plotEdge = false;
            else
                plotEdge = true;
            end
            
            % allow variable and constant width
            if length(w) ==1
                w = w.*ones(size(xIn));
            end
            
            % calculate position of the strip (based on the width)
            dy = diff(yIn);
            dx = diff(xIn);
            dist = sqrt(dx.^2+dy.^2);
            % normals
            nX = dy./dist;
            nY = -dx./dist;
            
            % calculate coordinates strips
            % virual strat and end coordinates
            
            %  determine the coordinates of the corner
            [x0,y0] = Plot.getPatchCorner(xIn,yIn,w,nX,nY);
            [x1,y1] = Plot.getPatchCorner(xIn,yIn,-w,nX,nY);
            x = [x0;flipud(x1)];
            y = [y0;flipud(y1)];
            
            % calculate coordinates of the patch
            vertices = [x,y];
            nrX = length(xIn);
            nrP = 2*nrX+1;
            index = (1:nrX)';
            faces = [index(1:end-1),index(2:end),nrP-index(2:end),nrP-index(1:end-1)];
            
            % plot patch
            z = [zIn;flipud(zIn)];
            p = patch('Faces',faces,'Vertices',vertices,'FaceColor',style,'FaceVertexCData',z,'EdgeColor',style);
            if plotEdge
                hold on;
                pEdge = plot(x,y,edgeColor);
            end
        end
        
        
        function plotTable(data,sctOptions)
            % this function  makes a nice table from the data in the matrix
            %
            % plotTable(data,sctOptions)
            %
            % INPUT:
            % data: numerical matrix with data in the table
            % sctOptions.style:options are '', 'blue', 'gray', 'dark'
            % sctOptions.spreading: 'tight' or 'fill'
            % sctOptions.pos: obligarory the position of the table (in figure units)!
            % sctOptions.Color: text color
            % sctOptions.align: left, center,right
            % sctOptions.format: string describing numerical format (e.g. %08.0f)
            % sctOptions.dateFormat: string describing format for dates (e.g. yyyy/mm/dd HH:MM)
            % sctOptions.header: cell array with header of the data
            % sctOptions.columnStyle: 1: numerical data, 2: date time
            % sctOptions.interpreter: 'latex','tex','none'
            if nargin<2
                sctOptions=struct;
            end
            % size of the data
            
            sizeData = size(data);
            % setting default options
            sctOptions = Util.setDefault(sctOptions,'align','left');
            sctOptions = Util.setDefault(sctOptions,'interpreter','none');
            sctOptions = Util.setDefault(sctOptions,'fontSize',10);
            sctOptions = Util.setDefault(sctOptions,'fontColor','b');
            sctOptions = Util.setDefault(sctOptions,'format','%8.2f');
            sctOptions = Util.setDefault(sctOptions,'dateFormat','dd-mm-yyyy HH:MM');
            sctOptions = Util.setDefault(sctOptions,'header',cell(sizeData(2),1));
            sctOptions = Util.setDefault(sctOptions,'columnStyle',ones(sizeData(2),1));
            sctOptions = Util.setDefault(sctOptions,'horzMargin',0.1);
            sctOptions = Util.setDefault(sctOptions,'vertMargin',0.1);
            sctOptions = Util.setDefault(sctOptions,'columnStyle',ones(sizeData(2),1));
            sctOptions = Util.setDefault(sctOptions,'addRectangle','yes');
            
            sctOptions = Util.setDefaultNumberField(sctOptions,'fontSize');
            
            sizeHeader = size(sctOptions.header);
            nSizeH = 0;
            
            % make  axis
            ca = gca;
            delete(ca);
            nhAx = axes('pos',sctOptions.pos,'visible','off');
            
            % spread out completely
            sctOptions.vertPos    = (1-2*sctOptions.vertMargin)/(sizeData(1)+sizeHeader(1));
            sctOptions.horzPos    = repmat((1-2*sctOptions.horzMargin)/(sizeData(2)),1,sizeData(2));
            sctOptions.horzPos(1) = 0;
            
            % summing the polsitions
            sctOptions.horzPos =  sctOptions.horzMargin + cumsum(sctOptions.horzPos);
            
            % plot header Text
            y = 1-sctOptions.vertMargin;
            for i = 1:sizeHeader(1)
                y = y - sctOptions.vertPos;
                for j=1:sizeHeader(2)
                    x = sctOptions.horzPos(j);
                    strText = sctOptions.header{i,j};
                    text(x,y,strText, 'HorizontalAlignment',sctOptions.align,'FontWeight','bold','fontSize',sctOptions.fontSize,'interpreter',...
                        sctOptions.interpreter,'units','normalized','Color',sctOptions.fontColor);
                end
            end
            vIndex=1:sizeData(2);
            for i=1:sizeData(1)
                % plot text of the table
                y = y - sctOptions.vertPos;
                % plot eacht column
                for j=1:sizeData(2)
                    x = sctOptions.horzPos(vIndex(j));
                    strText = UtilPlot.makeText(data(i,j),j,sctOptions);
                    text(x,y,strText, 'HorizontalAlignment',sctOptions.align,'Color',sctOptions.fontColor,'units','normalized',...
                        'fontSize',sctOptions.fontSize);
                    %
                end
            end
            xlim([0 1]);
            ylim([0 1]);
            
            set(gca,'color','w')
            
            if strcmp(sctOptions.addRectangle, 'yes')
                annotation('rectangle',sctOptions.pos);
            end
        end
        
        function hPatch = plotTriangle(x, y, z, connections,ax,varargin)
            % function to plot a triangles (use the patch function)
            %
            % hPatch = plotTriangle(x, y, z, connections, ax,varargin)
            %
            %INPUT: x,y: [Nx1] vector with coordinates
            %       z:   [Nx1]  vector with data to plot
            %       connections: [Mx3] vector with coordinates
            %       ax: current axes
            %       varargin: standard patch attribute value pairs
            % OUTPUT: hPatch: handles to the generated patches
            
            if nargin == 4
                ax = gca;
            end
            
            
            hPatch = [];
            
            XY = [x(:),y(:)];
            
            %check sizes
            nrZ     = size(z,1);
            nrL     = size(z,2);
            nrTri   = size(connections,1);
            nrPoint = size(XY,1);
            if (nrPoint==nrZ || nrTri==nrZ) && (nrL==1)
                %make plot
                if nargin < 5
                    hPatch = patch('faces',connections,'vertices',XY,'FaceVertexCData',z, 'Parent', ax);
                else
                    hPatch = patch('faces',connections,'vertices',XY,'FaceVertexCData',z, 'Parent', ax,varargin{:});
                end
                % same number of Z values as number of edges
            elseif (nrZ == nrTri) && (nrL==3)
                error('not yet implemented');
            end
            shading flat;
        end
        
        function hLeg = plotTriContour(xy,z,ikle,cLevel,sctOpt)
            % make contourplot on a triangular mesh
            %
            % hLeg = plotTriContour(xy,z,ikle,cLevel,sctOpt)
            %
            % INPUT
            % - xy    : x coordinates
            % -  z    : variable to plot
            % - ikle  : the ikle
            % - cLevel: the contour levels
            % sctOpt: options with field:
            %    -- colormap: function handle to colormap function
            %    -- unit: string with the unit to plot
            %    -- addLegend: whether or not to add a legend
            
            % OUTPUT
            % - hLeg: handle to the legend
            
            % set default values
            if nargin ==4
                sctOpt = struct;
            end
            sctOpt = Util.setDefault(sctOpt,'colormap',@jet);
            sctOpt = Util.setDefault(sctOpt,'addLegend',true);
            sctOpt = Util.setDefault(sctOpt,'unit','');
            
            myC = sctOpt.colormap(length(cLevel));
            nrC = length(cLevel);
            % plot each contour
            hold on;
            i = 0;
            for iCont=1:nrC
                [~,tmp] = tricontour(xy,ikle, z,[cLevel(iCont) cLevel(iCont)],myC(iCont,:),true);
                if ~isempty(tmp)
                    i = i +1;
                    h(i) = tmp(1);
                    if i<nrC
                        cLeg{i} = [num2str(cLevel(iCont)),'-',num2str(cLevel(iCont+1)),' ',sctOpt.unit];
                    else
                        cLeg{i} = ['>' num2str(cLevel(iCont)),' ',sctOpt.unit];
                    end
                end
            end
            % Legend
            
            if sctOpt.addLegend
                [hLeg,brol] = legend(h,cLeg);
            else
                hLeg = 0;
            end
            
        end
        
        function aVLine = plotVerticalLine(x, y, xVar, yVar, plotOptions)
            %this function makes a vertical line plot. Usefull to indicate the tidal position
            %at specific time
            lineConfiguration = '';
            plotOptions = Util.setDefault(plotOptions,'lineType','');
            if ~isempty(plotOptions.lineType)
                lineConfiguration = [lineConfiguration plotOptions.lineType];
            end
            
            plotOptions = Util.setDefault(plotOptions,'color','');
            if ~isempty(plotOptions.color)
                lineConfiguration = [lineConfiguration plotOptions.color];
            end
            
            plotOptions = Util.setDefault(plotOptions,'markerType','');
            if ~isempty(plotOptions.markerType)
                lineConfiguration = [lineConfiguration plotOptions.markerType];
            end
            
            hold on;
            [xStart xEnd] = UtilPlot.getLimsXData(x, xVar, plotOptions);
            [yStart yEnd] = UtilPlot.getLimsYData(y, yVar, plotOptions);
            
            xLims = [xStart xEnd];
            yLims = [yStart yEnd];
            
            ymin =  yLims(1);
            ymax =  yLims(2);
            for kk = 1:length(y)
                newY = [ymin ymax];
                newX = [x(kk) x(kk)];
                aVLine =  plot(newX, newY, lineConfiguration);
            end
            
            xlim(xLims);
            ylim(yLims);
            hold off;
        end
        
        
        
        function hQuiv = scaleQuiver(x, y, u, v, plotOptions)
            %Plot scale quiver
            %x: x data, y data, u data, v data
            %plotOptions.linespec specify the line in the plot
            plotOptions = Util.setDefault(plotOptions,'linespec','');
            
            if ~isempty(plotOptions.linespec)
                hQuiv = quiver(x,y,u,v,0,plotOptions.linespec);
            else
                hQuiv = quiver(x,y,u,v);
            end
        end
        
        function scatterFast(x,y,z,plotOptions)
            % fast scatter plot with constant size markers.
            %
            % Plot.scatterFast(x,y,z,plotOptions)
            %
            % INPUT: x, y, z: matrices or vectors with data to plot. theuy
            % all must have the same size.
            % plotOptions (optional): structure with options, with the
            % following fields
            %   nrBins: the number of bins in the plot (default = 10)
            %   minZ: the minimum z value of the bins (default = min(z));
            %   maxZ: the maximum z value of the bins (default = max(z));
            %   colorMap: function handle to a function that generates a
            %   colormap. (default = @jet)
            %   markerType: type of marker (default = 'o').
            %   markerSize: size of the markers (default = 3).
            
            
            % preprocess data
            x = x(:);
            y = y(:);
            z = z(:);
            
            % set defaults
            if nargin ==3
                plotOptions = struct;
            end
            
            plotOptions = Util.setDefault(plotOptions,'minZ',min(z));
            plotOptions = Util.setDefault(plotOptions,'maxZ',max(z));
            plotOptions = Util.setDefault(plotOptions,'colorMap',@jet);
            if ~isa(plotOptions.colorMap,'function_handle')
                plotOptions = Util.setDefault(plotOptions,'nrBins',size(plotOptions.colorMap,1));
            else
                plotOptions = Util.setDefault(plotOptions,'nrBins',10);
            end
            plotOptions = Util.setDefault(plotOptions,'markerType','o');
            plotOptions = Util.setDefault(plotOptions,'markerSize',3);
            
            
            % get parameters
            minZ   = plotOptions.minZ;
            maxZ   = plotOptions.maxZ;
            markerType = plotOptions.markerType;
            markerSize = plotOptions.markerSize;
            nrBins = plotOptions.nrBins;
            dz   = maxZ-minZ;
            bins = minZ:dz/nrBins:maxZ;
            
            % make the colormap
            if isa(plotOptions.colorMap,'function_handle')
                cMap = plotOptions.colorMap(nrBins);
            else
                cMap = plotOptions.colorMap;
                if size(cMap,1)~=nrBins
                    error('wrong number of colors in colormap');    
                end
            end
            
            % plot each class
            hold on;
            for i=1:nrBins-1
                mask = z>=bins(i) & z < bins(i+1);
                plot(x(mask),y(mask),markerType,'color',cMap(i,:),'markersize',markerSize);
            end
            % plot values outside range
            mask = z>=bins(nrBins) ;
          
            plot(x(mask),y(mask),markerType,'color',cMap(nrBins,:),'markersize',markerSize);
            
            % add colorbar
            
            colormap(cMap);
            caxis([minZ,maxZ]);
            colorbar;
        end
        
        function setPlotOptions(currentAxesHandle, plotOptions)
            %set different options to the plot
            try
                clear conf;
                conf = Configuration;
                
                %get the names
                xVariableName = '';
                if isfield(plotOptions.xVarInfo, 'longname')
                    xVariableName = plotOptions.xVarInfo.longname;
                end
                
                yVariableName = '';
                if isfield(plotOptions.yVarInfo, 'longname')
                    yVariableName = plotOptions.yVarInfo.longname;
                end
                
                
                plotOptions.xVarUnit = '';
                if isfield(plotOptions.xVarInfo, 'unit')
                    plotOptions.xVarUnit = plotOptions.xVarInfo.unit;
                end
                
                plotOptions.yVarUnit = '';
                if isfield(plotOptions.yVarInfo, 'unit')
                    plotOptions.yVarUnit = plotOptions.yVarInfo.unit;
                end
                
                zVariableName = '';
                if isfield(plotOptions, 'zVarInfo')
                    
                    if isfield(plotOptions.zVarInfo, 'longname')
                        zVariableName = plotOptions.zVarInfo.longname;
                    end
                    
                    plotOptions.zVarUnit = '';
                    if isfield(plotOptions.zVarInfo, 'unit')
                        plotOptions.zVarUnit = plotOptions.zVarInfo.unit;
                    end
                end
                
                %get the data
                xData = [];
                if isfield(plotOptions.xVarInfo, 'data')
                    xData = plotOptions.xVarInfo.data;
                end
                
                yData = [];
                if isfield(plotOptions.yVarInfo, 'data')
                    yData = plotOptions.yVarInfo.data;
                end
                
                %guarantee the number format
                plotOptions = Util.setDefaultNumberField(plotOptions, 'ylimStart');
                plotOptions = Util.setDefaultNumberField(plotOptions, 'ylimEnd');
                plotOptions = Util.setDefaultNumberField(plotOptions, 'yInterval');
                %calculate the Y limits and update the plotOptions
                %structure with Y info.
                if isempty(plotOptions.ylimStart) && isempty(plotOptions.ylimEnd)
                    [yStart yEnd] = UtilPlot.getLimsYData(yData, yVariableName, plotOptions);
                else
                    yStart = plotOptions.ylimStart;
                    yEnd = plotOptions.ylimEnd;
                end
                
                
                %set ztick limits
                if any(strcmpi(zVariableName, conf.TIME_VARS))
                    if isfield(plotOptions, 'zlimStart') && isfield(plotOptions, 'zlimEnd')
                        if ~isempty(plotOptions.zlimStart) && ~isempty(plotOptions.zlimEnd)
                            zLimit = [datenum(plotOptions.zlimStart),datenum(plotOptions.zlimEnd)];
                            xlim(zLimit);
                            
                            zTicks = [zLimit(1):plotOptions.xInterval:zLimit(2)];
                            set(currentAxesHandle,'ztick',xTicks)
                            set(currentAxesHandle,'zticklabel',datestr(zTicks','dd-mm-yy'))
                        end
                    end
                end
                
                %set titles
                %get the mean of the x data to show in the title.
                titleDate = mean(xData(:));
                
                plotOptions = Util.setDefault(plotOptions,'titleFormat','');
                plotOptions = Util.setDefault(plotOptions,'titleText','');
                plotOptions = Util.setDefault(plotOptions,'subsetType','');
                
                %get the format according the subset selection.
                nrFormat = UtilPlot.getSubsetFormatNumber(plotOptions.subsetType);
                
                if strcmp(plotOptions.showTitle, 'true')
                    strTitle = '';
                    if ~isempty(plotOptions.titleText)
                        strTitle = plotOptions.titleText;
                    else
                        if strcmp(xVariableName, 'Time')
                            if ~isempty(plotOptions.titleFormat)
                                strTitle  = datestr(titleDate,plotOptions.titleFormat);
                            else
                                %if the user no select a format, by default show
                                %the format given by the subsetType
                                strTitle  = datestr(titleDate,conf.TITLE_FORMATS{nrFormat});
                            end
                        end
                    end
                    %set the title
                    title(strTitle);
                end
                
                currentAxes.posAxBeforeLegend = get(currentAxesHandle, 'position');
                
                %set legend options
                plotOptions = Util.setDefault(plotOptions,'applyLegend','true');
                %UtilPlot.setLegendDetails(plotOptions);
                
                %set legend details for the plot
                if strcmpi(plotOptions.applyLegend, 'true')
                    if isempty(plotOptions.legendText)
                        plotOptions.legendText = yVariableName;
                    end
                    
                    %put the legend in the plot
                    [~,~,~,legendName] = legend;
                    hleg = legend([legendName plotOptions.legendText]);
                    
                    plotOptions = Util.setDefault(plotOptions,'legendPosition','');
                    if ~isempty(plotOptions.legendPosition)
                        set(hleg, 'Location', plotOptions.legendPosition);
                    end
                    plotOptions = Util.setDefault(plotOptions,'Orientation','vertical');
                    if ~isempty(plotOptions.legendOrientation)
                        set(hleg, 'Orientation', plotOptions.legendOrientation);
                    end
                    
                    plotOptions = Util.setDefault(plotOptions,'otherLegendPosition','');
                    if ~isempty(plotOptions.otherLegendPosition)
                        plotOptions = Util.setDefaultNumberField(plotOptions,'otherLegendPosition');
                        set(hleg, 'Position', plotOptions.otherLegendPosition);
                    end
                    
                    plotOptions = Util.setDefault(plotOptions,'custom','');
                    if ~isempty(plotOptions.custom)
                        customValues = fieldnames(plotOptions.custom);
                        for j = 1: length(customValues)
                            pattern = regexp(plotOptions.custom.(customValues{j}), '\[.*\]', 'once');
                            if isempty(pattern)
                                set(hleg, customValues{j}, plotOptions.custom.(customValues{j}));
                            else
                                set(hleg, customValues{j}, str2num(plotOptions.custom.(customValues{j})));
                            end;
                        end;
                    end
                end;
                %end legend options
                
                currentAxes.posAxAfterLegend = get(currentAxesHandle, 'position');
                
                %set labels
                UtilPlot.setCoordinateLabel(plotOptions,'X');
                UtilPlot.setCoordinateLabel(plotOptions,'Y');
                UtilPlot.setCoordinateLabel(plotOptions,'Z');
                
                % if all coordinates limits are time
                plotOptions = Util.setDefault(plotOptions,'subsetIndex',[]);
                
                plotOptions = Util.setDefault(plotOptions,'xlimStart', '');
                plotOptions = Util.setDefaultNumberField(plotOptions,'xlimStart');
                
                plotOptions = Util.setDefault(plotOptions,'xlimEnd', '');
                plotOptions = Util.setDefaultNumberField(plotOptions,'xlimEnd');
                
                plotOptions = Util.setDefault(plotOptions,'showXTick','true');
                
                % if isempty(plotOptions.subsetIndex)
                if any(strcmpi(xVariableName, conf.TIME_VARS))
                    %Check if the user select one custom X tick
                    plotOptions = Util.setDefault(plotOptions,'customTickType', '');
                    if ~isempty(plotOptions.customTickType)
                        %Options for the PlotTimeTick - type1
                        if strcmpi(plotOptions.customTickType, 'type1')
                            plotOptions = Util.setDefault(plotOptions,'tickOneTimeSelected', 'daily');
                            plotOptions = Util.setDefault(plotOptions,'tickOnePeriod', 2);
                            plotOptions = Util.setDefaultNumberField(plotOptions,'tickOnePeriod');
                            switch plotOptions.tickOneTimeSelected
                                case 'daily'
                                    tickSpace = plotOptions.tickOnePeriod/24;
                                case 'monthly'
                                    tickSpace = plotOptions.tickOnePeriod/30;
                                case 'yearly'
                                    tickSpace = plotOptions.tickOnePeriod/12;
                            end;
                            %verify the order in the data
                            if xData(1) > xData(end)
                                xlim([xData(end),xData(1)]);
                                UtilPlot.plotTimeTick(tickSpace,xData(end),xData(1),currentAxes);
                            else
                                xlim([xData(1),xData(end)]);
                                UtilPlot.plotTimeTick(tickSpace,xData(1),xData(end),currentAxes);
                            end;
                            
                        end;
                    else
                        %get the X limits
                        [xStart xEnd] = UtilPlot.getLimsXData(xData, xVariableName, plotOptions);
                        
                        %correct the xtick values
                        options.start = xStart;
                        options.end   = xEnd;
                        xTick = UtilPlot.getXtick(options, plotOptions);
                        %asure increasing values
                        if xEnd > xStart
                            xlim([xStart,xEnd]);
                        end;
                        if strcmpi(plotOptions.showXTick, 'true')
                            set(currentAxesHandle,'xtick',xTick);
                            %apply the selected xtick format, by
                            %default apply dd-mmm-yyyy
                            plotOptions = Util.setDefault(plotOptions,'xTickFormat', 1);
                            set(currentAxesHandle,'XTickLabel',datestr(xTick',plotOptions.xTickFormat));
                        else
                            set(currentAxesHandle,'xticklabel',{});
                        end;
                    end;
                else
                    %get the X limits
                    [xStart xEnd] = UtilPlot.getLimsXData(xData, xVariableName, plotOptions);
                    if xEnd > xStart
                        xlim([xStart,xEnd]);
                    end
                end
                %end;
                
                
                %set axis location
                plotOptions = Util.setDefault(plotOptions,'xAxisLocation', '');
                if ~isempty(plotOptions.xAxisLocation)
                    set(currentAxesHandle,'XAxisLocation', plotOptions.xAxisLocation)
                end
                
                %set default axes color
                plotOptions = Util.setDefault(plotOptions,'xAxisColor','k');
                set(currentAxesHandle,'xcolor', plotOptions.xAxisColor)
                
                plotOptions = Util.setDefault(plotOptions,'yAxisColor','k');
                set(currentAxesHandle,'ycolor', plotOptions.yAxisColor)
                
                %set axis visibility
                if plotOptions.hideAxis
                    set(currentAxesHandle, 'visible', 'off');
                    set(currentAxesHandle,'HandleVisibility', 'off')
                    axis off;
                else
                    set(currentAxesHandle, 'visible', 'on');
                end
                
                %set default grid options
                plotOptions = Util.setDefault(plotOptions,'xGrid','off');
                set(currentAxesHandle,'xGrid', plotOptions.xGrid)
                
                plotOptions = Util.setDefault(plotOptions,'yGrid','off');
                set(currentAxesHandle,'yGrid', plotOptions.yGrid)
                
                plotOptions = Util.setDefault(plotOptions,'hColorBar',[]);
                %if the colorbar is present
                if ~isempty(plotOptions.hColorBar)
                    plotOptions = Util.setDefaultNumberField(plotOptions,'zlimStart');
                    plotOptions = Util.setDefaultNumberField(plotOptions,'zlimEnd');
                    plotOptions = Util.setDefaultNumberField(plotOptions,'zInterval');
                    
                    if ~isempty(plotOptions.zlimStart) && ~isempty(plotOptions.zlimEnd) && ~isempty(plotOptions.zInterval)
                        newZtick = plotOptions.zlimStart:plotOptions.zInterval:plotOptions.zlimEnd;
                        set(plotOptions.hColorBar, 'ytick', newZtick);
                    end
                end
                
                plotOptions = Util.setDefault(plotOptions,'axisEqual','false');
                if strcmp(plotOptions.axisEqual, 'true')
                    axis equal;
                end;
                
                %set xScale
                plotOptions = Util.setDefault(plotOptions,'xScale','linear');
                set(currentAxesHandle,'XScale', plotOptions.xScale)
                
                plotOptions = Util.setDefault(plotOptions,'yScale','linear');
                set(currentAxesHandle,'YScale', plotOptions.yScale)
                
                %yreverse
                plotOptions = Util.setDefault(plotOptions,'yReverse','false');
                if strcmpi(plotOptions.yReverse, 'true')
                    set(currentAxesHandle, 'Ydir', 'reverse');
                end
                
                %set options for the yAxisLocation
                flagSecondAxes = 0;
                hNewRightAxes = [];
                plotOptions = Util.setDefault(plotOptions,'yAxisLocation', 'left');
                if ~isempty(plotOptions.yAxisLocation)
                    if strcmp(plotOptions.yAxisLocation, 'right')
                        %get the templayer axes
                        tempAxesH = gca;
                        set(tempAxesH,'color','none');
                        
                        hOld           = plotOptions.hFirstLayer;
                        hNewRightAxes  = UtilPlot.rightAxis(hOld,[yStart yEnd]);
                        flagSecondAxes = 1;
                        
                    end
                    set(currentAxesHandle,'YAxisLocation', plotOptions.yAxisLocation);
                end
                
                %set the Y ticks if the user defined
                if ~isempty(plotOptions.ylimStart) && ~isempty(plotOptions.ylimEnd)
                    yTicks = plotOptions.ylimStart:plotOptions.yInterval:plotOptions.ylimEnd;
                    if ~isempty(hNewRightAxes)
                        set(hNewRightAxes,'ytick',yTicks);
                    else
                        set(currentAxesHandle,'ytick',yTicks);
                    end
                end
                
                if flagSecondAxes == 0
                    if ~isnan(yStart) && ~isnan(yEnd)
                        if yEnd > yStart
                            ylim([yStart,yEnd]);
                        end;
                    end
                end
                
            catch
                sct = lasterror;
                errordlg(['Error! ' sct.message])
                return;
            end
            
        end
        
        
        
        
        function [x,y] = getPatchCorner(xIn,yIn,w,nX,nY)
            % determined the coordinates of the patches
            %
            % [x,y] = Plot.getPatchCorner(xIn,yIn,w,nX,nY)
            %
            %used bby plotStrip
            %
            % INPUT: xIn,yIn: [Nx1] vectors of x and y coordinates of a line
            %        w: scalar or Nx1 vector with the width of the strips
            %        nX,nY: [N-1x1] vector with x and y components of the
            %        normal vectors of a line
            % OUTPUT: x,y,: [2*N-2] x1 vector with coordinates of the strip
            %
            %
            
            % determine coffcients of the lines
            % one less then number of lines, i.e. two less than number of
            % points)
            if numel(w) ==1
                w = w.*ones(size(xIn));
            end
            xSt0  = xIn(1:end-2)  + 0.5.*w(1:end-2) .*nX(1:end-1);
            xEn0  = xIn(2:end-1)  + 0.5.*w(2:end-1) .*nX(1:end-1);
            xSt1  = xIn(2:end-1)  + 0.5.*w(2:end-1) .*nX(2:end);
            xEn1  = xIn(3:end)    + 0.5.*w(3:end)   .*nX(2:end);
            ySt0  = yIn(1:end-2)  + 0.5.*w(1:end-2) .*nY(1:end-1);
            yEn0  = yIn(2:end-1)  + 0.5.*w(2:end-1) .*nY(1:end-1);
            ySt1  = yIn(2:end-1)  + 0.5.*w(2:end-1) .*nY(2:end);
            yEn1  = yIn(3:end)    + 0.5.*w(3:end)   .*nY(2:end);
            % now solve coordinates of intersection of two lines
            a =    xEn0-xSt0;
            b = - (xEn1-xSt1);
            c =    yEn0-ySt0;
            d = - (yEn1-ySt1);
            det = a.*d-b.*c;
            dx = xSt1-xSt0;
            dy = ySt1-ySt0;
            t =  (d.*dx-b.*dy) ./det;
            %s =  (-c.*dx+a.*dy)./det;
            % apply the solution
            xInt = xSt0 + t.*a;
            yInt = ySt0 + t.*c;
            % put together
            x = [xSt0(1);xInt;xEn1(end)];
            y = [ySt0(1);yInt;yEn1(end)];
        end
        
        function [hq,hAx] = vectorStickPlot(time,u,v,varargin)
            % Vector stick plot (for directions time series)
            %
            % [hq,h_ax] = Plot.vectorStickPlot(time,u,v,hAx);
            %
            % INPUTS:
            % - time : time vector
            % - u : u velocity
            % - v : v velocity
            % - h_ax (optional): Axis handle of existing axis. If not
            % provided, the plot will be created in a new axis.
            % - Optional name-value parameters:
            %    - Direction (default: horizontal): direction along which
            %     the profile is plotted. 'horizontal' works best for time
            %     series, 'vertical' best for profiles.
            %
            % OUTPUTS:
            % - hq: Handle of the stick plot item
            % - hAx: Axis handle where the stick plot is added
            %
            % Note: when using custom xlim/ylim or multiple axes with linkaxes,
            % specify the xlim and ylim before calling Plot.vectorStickPlot
            % and pass the axis handle hAx.
            %
            
            p = inputParser;
            addRequired(p,'time');
            addRequired(p,'u');
            addRequired(p,'v');
            addOptional(p,'hAx',[]);
            addParameter(p,'direction','horizontal');
            parse(p,time,u,v,varargin{:});
            
            
            
            if nargin <4
                hAx = axes;
            else
                hAx = p.Results.hAx;
                axes(hAx);
            end
            hold on;
            
            % Put all vectors in column form
            time = time(:);
            u = u(:);
            v = v(:);
            
            timeRange = max(time)-min(time);
            
            if strcmpi(p.Results.direction,'horizontal');
                
                if strcmp(hAx.XLimMode,'auto');
                    xRange = [min(time) - 0.2*timeRange max(time) + 0.2*timeRange];
                    xlim(xRange);
                end
                if strcmp(hAx.YLimMode,'auto');
                    yRange = max(abs(v)*1.05) * [-1 1];
                    ylim(yRange);
                end
                drawnow;
                
                hAx.PlotBoxAspectRatioMode = 'manual';
                drawnow;
                hAx.DataAspectRatioMode = 'manual';
                drawnow;
                
                scale = hAx.DataAspectRatio(1:2)/hAx.DataAspectRatio(2);
                
                
                hq= quiver(time,zeros(size(time)),u*scale(1),v*scale(2),'autoscale','off');
                hq.ShowArrowHead = 'off';
                
                plot([-1e10 1e10],[0 0],'color',.5*[1 1 1],'linewidth',.5);
                uistack(hq,'top');
            elseif strcmpi(p.Results.direction,'vertical')
                
                if strcmp(hAx.YLimMode,'auto');
                    xRange = [min(time) - 0.2*timeRange max(time) + 0.2*timeRange];
                    ylim(xRange);
                end
                if strcmp(hAx.XLimMode,'auto');
                    yRange = max(abs(v)*1.05) * [-1 1];
                    xlim(yRange);
                end
                drawnow;
                
                hAx.PlotBoxAspectRatioMode = 'manual';
                drawnow;
                hAx.DataAspectRatioMode = 'manual';
                drawnow;
                
                scale = hAx.DataAspectRatio(1:2)/hAx.DataAspectRatio(1);
                
                
                hq= quiver(zeros(size(time)),time,u*scale(1),v*scale(2),'autoscale','off');
                hq.ShowArrowHead = 'off';
                
                plot([0 0],[-1e10 1e10],'color',.5*[1 1 1],'linewidth',.5);
                
                uistack(hq,'top');
            else
                error('Unknown direction %s',p.Results.direction);
            end
            
        end
        
    end
    
end
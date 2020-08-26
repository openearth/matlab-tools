%Class with utilities usefull to  generate the plots.
% @author ABR
% @author SEO
% @version 1.0, 04/14/04
%

classdef UtilPlot < handle
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
    
    %set methods
    methods
        function set.Property1(obj,property1)
            obj.Property1 = property1;
        end
    end
    
    %get methods
    methods
        function property1 = get.Property1(obj)
            property1 = obj.Property1;
        end
    end
    
    methods
        
    end
    
    %private methods
    methods (Access = 'private')
        
    end
    
    %Stactic methods
    methods (Static)
        function applyShading(plotOptions, ax)
            %Apply the shading options to the current axes
            if nargin == 1
                ax = gca;
            end
            
            %set the default value
            plotOptions = Util.setDefault(plotOptions,'shading','flat');
            
            switch plotOptions.shading
                case 'flat'
                    shading(ax,'flat');
                case 'interp'
                    shading(ax,'interp');
                case 'faceted'
                    shading(ax,'faceted');
                otherwise
                    shading(ax,'flat');
            end
        end
        
        function [plotProperty plotPropertyValue] = buildLineProperties(dataToPlot, lineNumber)
            %set the line plot properties
            plotProperty      = {};
            plotPropertyValue = {};
            
            if isfield(dataToPlot(lineNumber),'lineStyle')
                if ~isempty(dataToPlot(lineNumber).lineStyle)
                    plotProperty{length(plotProperty)+1} = 'LineStyle';
                    if strcmp(dataToPlot(lineNumber).lineStyle, ' ')
                        dataToPlot(lineNumber).lineStyle = 'none';
                    end
                    plotPropertyValue{length(plotPropertyValue)+1} = dataToPlot(lineNumber).lineStyle;
                end
            end
            
            if isfield(dataToPlot(lineNumber),'colorLine')
                if ~isempty(dataToPlot(lineNumber).colorLine)
                    plotProperty{length(plotProperty)+1} = 'Color';
                    plotPropertyValue{length(plotPropertyValue)+1} = dataToPlot(lineNumber).colorLine;
                end
            end
            if isfield(dataToPlot(lineNumber),'lineMarker')
                if ~isempty(dataToPlot(lineNumber).lineMarker)
                    plotProperty{length(plotProperty)+1} = 'Marker';
                    plotPropertyValue{length(plotPropertyValue)+1} = dataToPlot(lineNumber).lineMarker;
                end
            end
            
            if isfield(dataToPlot(lineNumber),'lineWidth')
                if ~isempty(dataToPlot(lineNumber).lineWidth)
                    plotProperty{length(plotProperty)+1} = 'LineWidth';
                    %change the value from string to number if its
                    %necesary
                    dataToPlot(lineNumber) = Util.setDefaultNumberField(dataToPlot(lineNumber), 'lineWidth');
                    plotPropertyValue{length(plotPropertyValue)+1} = dataToPlot(lineNumber).lineWidth;
                end
            end
            
            if isfield(dataToPlot(lineNumber),'markerSize')
                if ~isempty(dataToPlot(lineNumber).markerSize)
                    plotProperty{length(plotProperty)+1} = 'MarkerSize';
                    %change the value from string to number if its
                    %necesary
                    dataToPlot(lineNumber) = Util.setDefaultNumberField(dataToPlot(lineNumber), 'markerSize');
                    plotPropertyValue{length(plotPropertyValue)+1} = dataToPlot(lineNumber).markerSize;
                end
            end
        end
        
        function [plotProperty plotPropertyValue] = buildLinePropertiesNew(plotOptions)
            %set the line plot properties
            plotProperty      = {};
            plotPropertyValue = {};
            
            if isfield(plotOptions,'lineType')
                if ~isempty(plotOptions.lineType)
                    plotProperty{length(plotProperty)+1} = 'LineStyle';
                    if strcmp(plotOptions.lineType, ' ')
                        plotOptions.lineType = 'none';
                    end
                    plotPropertyValue{length(plotPropertyValue)+1} = plotOptions.lineType;
                end
            end
            
            if isfield(plotOptions,'lineColor')
                if ~isempty(plotOptions.lineColor)
                    plotProperty{length(plotProperty)+1} = 'Color';
                    plotPropertyValue{length(plotPropertyValue)+1} = plotOptions.lineColor;
                end
            end
            if isfield(plotOptions,'lineMarker')
                if ~isempty(plotOptions.lineMarker)
                    plotProperty{length(plotProperty)+1} = 'Marker';
                    plotPropertyValue{length(plotPropertyValue)+1} = plotOptions.lineMarker;
                end
            end
            
            if isfield(plotOptions,'lineWidth')
                if ~isempty(plotOptions.lineWidth)
                    plotProperty{length(plotProperty)+1} = 'LineWidth';
                    %change the value from string to number if its
                    %necesary
                    plotOptions = Util.setDefaultNumberField(plotOptions, 'lineWidth');
                    plotPropertyValue{length(plotPropertyValue)+1} = plotOptions.lineWidth;
                end
            end
            
            if isfield(plotOptions,'markerSize')
                if ~isempty(plotOptions.markerSize)
                    plotProperty{length(plotProperty)+1} = 'MarkerSize';
                    %change the value from string to number if its
                    %necesary
                    plotOptions = Util.setDefaultNumberField(plotOptions, 'markerSize');
                    plotPropertyValue{length(plotPropertyValue)+1} = plotOptions.markerSize;
                end
            end
        end
        
        function changePos(hAx,sctAxis)
            % change the position of the axes such that the are alligned
            % INPUT:hAx: a vector of handles to the axes to take into account
            %       : sctAxis: a vector with structures. In this structure the fuield
            %       'pos' gives teh desired outer position of the figure
            % OUTPUT: none
            % written by : ABR
            
            nrAxis = length(hAx);
            % calculate wanted lower left upper right
            wantedPos = zeros(nrAxis,4);
            for i=1:nrAxis
                wantedPos(i,:) = sctAxis(i).pos;
            end
            
            wantedCoor = UtilPlot.pos2coor(wantedPos);
            
            % determine the positions of all axes
            pos = nan(nrAxis,4);
            for i=1:nrAxis
                if hAx(i)~=0
                    pos(i,:) = get(hAx(i),'pos');
                end
            end
            
            coor = UtilPlot.pos2coor(pos);
            
            % determine unique wanted positions
            % and change positions such they are all the same for the same positions
            
            % check all four coordinates
            for j= 1:4
                uniqueCoor = unique(wantedCoor(:,j));
                for i = 1:length(uniqueCoor)
                    % find all figure positions
                    mask = uniqueCoor(i)==wantedCoor(:,j);
                    allCoor = coor(mask,j);
                    %chose one HOW
                    bestCoor = min(allCoor);
                    % change the values
                    coor(mask,j) = bestCoor;
                end
            end
            pos = UtilPlot.coor2pos(coor);
            
            % set back the positions of the axes to the newly calculated ones
            for i=1:nrAxis
                if hAx(i)~=0
                    set(hAx(i),'pos',pos(i,:));
                end
            end
        end
        
        function colorData = colormapIMDC(colormapType,nrColor)
            % This function contain custom colormaps
            %function colorData = UtilPlot.colormapIMDC(colormapType,nrColor)
            % %
            % #INPUTS:
            %   colormapType: a string containing the name of the colormap:
            %           The following are available:
            % all matlab built in colorbars (e.g.   'jet', 'gray', 'hsv', 'cool'
            %          'rwb': red white and blue
            %          'rgb': red gray and blue
            %          'rwg': red white and green
            %          'symmetric-rwb' : syymmetric red white and blue (works best with
            %          nrColor multiple of 4)
            %          'inverse-gray' % inverse of gray colormap
            %          'bright' % some bright colormap
            %          'also-bright' %another brightly colroer colormap
            %          'modified-jet' % jet modified to suit the tatse of MSA
            %          'ssc-map' % old maps for adcp data
            %          'vel-map' % special map for velocity data (lowest is white)
            %   nrColor: (scalar): the number of colors in the colormap
            % #OUTPUTS:-colorData a colormap that can be used by Matlab
            
            % #STEPS:-
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            % Written by: Alexander Breugem
            % Date: June 2013
            
            switch lower(colormapType)
                case 'rwb'
                    % red white and blue
                    colorData=[0 0 1;1 1 1;1 0 0];
                    if(nrColor~=3)
                        acgi = colorData;
                        colorData=interp1(0:2,acgi,2./(nrColor-1).*(0:nrColor-1),'linear','extrap');
                    end
                case 'rgb'
                    % red white and blue
                    colorData=[0 0 1;0.75 0.75 0.75;1 0 0];
                    if(nrColor~=3)
                        acgi = colorData;
                        colorData=interp1(0:2,acgi,2./(nrColor-1).*(0:nrColor-1),'linear','extrap');
                    end
                case 'imdcflag' % brown, white, blue
                    colorData= UtilPlot.getIMDCcolors;
                    if(nrColor~=3)
                        acgi = colorData;
                        colorData=interp1(0:2,acgi,2./(nrColor-1).*(0:nrColor-1),'linear','extrap');
                    end
                case 'imdc-ssc' % brown, white, blue
                    colorData= [195/255,237/255,1;UtilPlot.getIMDCcolors('old-blue');UtilPlot.getIMDCcolors('old-brown');91/255,83/255,64/255];
                    if(nrColor~=4)
                        acgi = colorData;
                        colorData=interp1(0:3,acgi,3./(nrColor-1).*(0:nrColor-1),'linear','extrap');
                    end
                case 'rwg' % red white green
                    colorData=[0 0.5 0;1 1 1;1 0 0];
                    if(nrColor~=3)
                        acgi = colorData;
                        colorData=interp1(0:2,acgi,2./(nrColor-1).*(0:nrColor-1),'linear','extrap');
                    end
                case 'symmetric-rwb'
                    % Red white blue colormap. The two values around the zero are
                    %         forced to a white color. (best choice for number of colors is a
                    %         multiple of 4).
                    colorData=[0 0 1;1 1 1;1 1 1;1 0 0];
                    if(nrColor~=4)
                        acgi = colorData;
                        colorData=interp1(0:3,acgi,3./(nrColor-1).*(0:nrColor-1),'linear','extrap');
                    end
                case 'inverse-gray'
                    colorData = 1-gray(nrColor);
                case 'bright'
                    colorData=[0 0 1;0 1 0; 0 1 1;1 1 1;1 1 1;1 1 0;1 .5 0;1 0 0];
                    if(nrColor~=8)
                        acgi = colorData;
                        colorData=interp1(0:7,acgi,7./(nrColor-1).*(0:nrColor-1),'linear','extrap');
                    end
                case 'also-bright'
                    colorData=[0 0 1;0 1 0; 0 1 1;.5 .5 .5;1 1 0;1 .5 0;1 0 0];
                    if(nrColor~=7)
                        acgi = colorData;
                        colorData=interp1(0:6,acgi,6./(nrColor-1).*(0:nrColor-1),'linear','extrap');
                    end
                case  'modified-jet'
                    nrExtra = round(nrColor*0.46);
                    colorData = jet(nrColor);
                    colorData = colorData(nrExtra:end,:);
                    colorData = interp1((1:length(colorData))',colorData,1:nrColor);
                case 'ssc-map' % BDC zijn SSC colormap (zie createcolormapoptions)
                    lightred=[1 1 206/255];
                    darkred=[155/255 16/255 0];
                    lightblue=[223/255 223/255 1];
                    darkblue=[0 13/255 153/255];
                    if(nrColor~=4)
                        for i=1:floor(nrColor/2)
                            map1(i,:)=darkblue+(i-1)*(lightblue - darkblue)/(floor(nrColor/2)-1);
                        end
                        for i=1:floor(nrColor/2)
                            map2(i,:)=lightred-(i-1)*(lightred-darkred)/(floor(nrColor/2)-1);
                        end
                        colorData=[map1 ; map2];
                        colorData=abs(colorData);
                    else
                        colorData=[darkblue;lightblue;lightred;darkred];
                    end
                case 'vel-map' % WL map used to print velocities (white at zero)
                    mapStart  = [1 1 1;1 1 0; 1 0.75 0; 1 0.5 0;1 0 0; 1 0 0.5; 1 0 1; 0.5 0 1; 0 0 1;0 0 0.75];
                    nrStart   = length(mapStart);
                    colorData = interp1(1:nrStart,mapStart,1:(nrStart-1)/nrColor:nrStart);
                otherwise % standard colormaps
                    try
                        fColormap = str2func(colormapType);
                        colorData = fColormap(nrColor);
                    catch
                        error('colormapType does not contain a  valid colormap type');
                    end
            end
        end
        
        function pos = coor2pos(coor)
            % the position vector form lolwerl eft and upper right coordinates
            % OUTPUT: pos [n x 4] vector of positions (Matlab format; (xLowerLeft yLowerLeft width height))
            % INPUT: coor [n x 4] vector of coordinates (xLowerLeft yLowerLeft xUppperRight yUpperRight)
            pos =  coor;
            pos(:,3) = abs(coor(:,3)-coor(:,1));
            pos(:,4) = abs(coor(:,4)-coor(:,2));
        end
        
        function copyTimeAxis(hIn,hOut,fmt)
            % copies time limits to another graph
            %
            % copyTimeAxis(hIn,hOut,fmt)
            % INPUT:
            % -hIn: handle to axis with time info
            % -hOut(optional): handle of axis to which to copy
            % -fmt(optional): handle of axis to which to copy
            
            
            if nargin < 2
                hOut = gca;
            end
            
            
            % copies
            xLim  = get(hIn,'xlim');
            xTick = get(hIn,'xtick');
            
            % guess the format
            if nargin <3
                dx = xLim(2)-xLim(1);
                if dx < 1/24/60
                    fmt = 'MM:SS';
                elseif dx < 1
                    fmt = 'HH:MM';
                elseif dx < 365
                     fmt = 'dd/mm';
                else
                     fmt = 'dd/mm';
                end
            end
            
            % pastes
            set(gcf,'currentaxes',hOut);
            xlim(xLim);
            xticks(xTick);
            xticklabels(datestr(xTick',fmt))
            
            
        end
        
        function freezeColorbarApply(sctColorBar)
            % This functions sets back colorbardata for an axes. See freezeColorbar
            % for an example of use
            %reset colors for the first colorbar
            hColorbarKid = get(sctColorBar.hColorbar,'chil');
            
            % look for the index of the image
            colorbarIndex = [];
            for i = 1:length(hColorbarKid)
                if ~isempty(strfind(get(hColorbarKid(i),'tag'),'TMW_COLORBAR'))
                    colorbarIndex = i;
                end
            end
            if isempty(colorbarIndex)
                error('Input is not a valid freezeColorbarStructure');
            end
            % set back the color information
            set(hColorbarKid(colorbarIndex),'CData',sctColorBar.colorbarData);
        end
        
        function [contours,hContourgroup,hColorBar] = generalContour(X,Y,Z,contLev,colorMap,plotOptions,hAxis)
            % function to make a filled contour plot in which the intervals
            % are discontinuous. For each interval a seperate color is
            % used. This function is a newer version (2017) of the old
            % generalContour from 2009.
            % [contours,hContourgroup,hColorBar] = contourfIrregular(X,Y,Z,contLev,colorMap,plotOptions,hAxis)
            
            
            % #INPUTS:
            %       -X: Matrix with X data for the plot
            %       -Y: Matrix with Y data for the plot
            %       -Z: Matrix with Z data to be plottend. Note X, Y and Z should
            %        have the same size.
            %       -contourLevel: a vector (with a minimum of 2 elements) containing the values at which a contour level
            %       should be drawn(in the same units of Z). This can be used with a
            %       general format (although the values should be sorted in ascending order). For logarithmic spacing use e.g.: [0.01
            %       0.02 0.05 0.1 0.2 0.5 1 2 5]. Note that if the first (usually the
            %       lowest) value in this vector is higher than the lowest value in the
            %       data. The area in the data that is loweer, will have the background
            %       color(usually white; this is the samein the ordinary contourf).
            %       The values larger than the maximum contour level will
            %       be plotted according to the last color in the colorMap.
            %       If the background color for these values is required,
            %       the data should be filtered to nans before creating the
            %       contourmap.
            %
            %       -colorMap (optional): a function handle to the colormap that
            %       should be used for plotting the data. e.g. @hsv
            %       In case  an empty value is given, the default colormap (jet) is
            %       used. If specified the number of colors equals the
            %       number of contour levels - 1.
            %       -plotOptions (optional): contourlines, colorbar
            %       -hAxis  (optional): the handle of the axes in which the plot should
            %       be made (for plotting in subplots). If nothing is specified, the
            %       plot is made into the currentAxes.
            %
            % #OUTPUTS:-contours,hContourgroup: (matrix with contourdata and handle to
            %          contourgroup. These properties can be used to generate contourlabels in the graph(see matlab documentation
            %          from clabel and contour)
            %         -hColorBar: The handle to the colorbar that is created.
            %
            
            if nargin <6
                plotOptions=struct;
            end
            
            % axis manipulation (if given)
            if nargin >6
                hOldAxis = get(gcf,'currentaxes');
                set(gcf,'currentaxes',hAxis);
            end
            
            % default settings
            nrColors = length(contLev)-1;
            %plotOptions = Util.setDefault(plotOptions,'colormap', jet(nrColors));
            plotOptions = Util.setDefault(plotOptions,'colorbar', true);
            plotOptions = Util.setDefault(plotOptions,'contourlines', true);
            
            if nargin >4 && ~isempty(colorMap)
                if size(colorMap,1)<nrColors
                    error('The number of colors in the colormap must be at least one smaller to the nr of contours');
                elseif size(colorMap,1)>nrColors
                    colorMap(nrColors+1:end,:) = [];
                end
                plotOptions.colormap = colorMap;
            end
            plotOptions = Util.setDefault(plotOptions,'colormap', jet(nrColors));
            
            mPlot = nan(size(X));
            % check if there is something to be plotted
            if sum(Z(:)>=min(contLev))>0
                index = Z<contLev(1); % these values should be lower than 1 in mPlot
                if contLev(1)<0
                    mPlot(index) = contLev(1)/Z(index);
                else
                    mPlot(index) = Z(index)/(contLev(1));
                end
                for iV = 1:length(contLev)-1
                    index = Z>=contLev(iV);
                    mPlot(index) = iV+(Z(index)-contLev(iV))./(contLev(iV+1)-contLev(iV));
                end
                mPlot(~isnan(mPlot)) = min(mPlot(~isnan(mPlot)),length(contLev)-1e-12);
                
                if plotOptions.contourlines
                    [contours,hContourgroup] = contourf(X,Y,mPlot,1:length(contLev));
                else
                    [contours,hContourgroup] = contourf(X,Y,mPlot,1:length(contLev), 'linecolor', 'none');
                end
                caxis([1 length(contLev)]);
                colormap(plotOptions.colormap)
                if plotOptions.colorbar
                    hColorBar = colorbar;
                    set(hColorBar,'ytick',1:length(contLev),'yticklabel',contLev)
                else
                    hColorBar = [];
                end
                
            else
                %C = [];
                %h = [];
                [contours,hContourgroup] = contourf(X,Y,mPlot,1:length(contLev));
                hColorBar = [];
            end
            
            if nargin >6
                set(gcf,'currentaxes',hOldAxis);
            end
            
        end
        
        function listSelectedFiles = getFileList(myAxes)
            %function to get list of all files selected by the user to
            %plot.
            listSelectedFiles = {};
            try
                for ii=1:length(myAxes)
                    axesToPlot  = myAxes{ii}.plot;
                    currentAxes = {};
                    for jj=1:length(axesToPlot)
                        axesInfo = struct;
                        plotInfo = axesToPlot{jj};
                        
                        %if is a layer
                        if isfield(plotInfo, 'plot')
                            axesInfo = plotInfo.plot{1};
                        else
                            axesInfo = plotInfo;
                        end
                        
                        filesSelected = regexp(axesInfo.filesSelected,';','split');
                        
                        for nrFile=1:length(filesSelected)
                            listSelectedFiles{length(listSelectedFiles)+1} = filesSelected{nrFile};
                        end
                    end
                end
            catch
                return;
            end
        end
        
        function [xStart xEnd] = getLimsXData(xData, xVar, plotOptions)
            %get X limit data
            plotOptions = Util.setDefault(plotOptions,'xlimStart', '');
            plotOptions = Util.setDefaultNumberField(plotOptions,'xlimStart');
            
            plotOptions = Util.setDefault(plotOptions,'xlimEnd', '');
            plotOptions = Util.setDefaultNumberField(plotOptions,'xlimEnd');
            
            conf = Configuration;
            if any(strcmpi(xVar, conf.TIME_VARS))
                %Define limits for xStart
                if ~isempty(plotOptions.xlimStart)
                    xStart = datenum(plotOptions.xlimStart);
                else
                    xStart = min(xData(:));
                end
                
                %Limit end for X variable
                if ~isempty(plotOptions.xlimEnd)
                    xEnd = datenum(plotOptions.xlimEnd);
                else
                    xEnd = max(xData(:));
                end
            else
                if ~isempty(plotOptions.xlimStart)
                    xStart = plotOptions.xlimStart;
                else
                    xStart = min(xData(:));
                end
                
                %Limit end for X variable
                if ~isempty(plotOptions.xlimEnd)
                    xEnd = plotOptions.xlimend
                else
                    xEnd = max(xData(:));
                end
            end
        end
        
        function [yStart yEnd] = getLimsYData(yData, yVar, plotOptions)
            %get Y limits data
            plotOptions = Util.setDefault(plotOptions,'ylimStart', '');
            plotOptions = Util.setDefaultNumberField(plotOptions,'ylimStart');
            
            plotOptions = Util.setDefault(plotOptions,'ylimEnd', '');
            plotOptions = Util.setDefaultNumberField(plotOptions,'ylimEnd');
            
            conf = Configuration;
            if any(strcmpi(yVar, conf.TIME_VARS))
                %Define limits for yStart
                if ~isempty(plotOptions.ylimStart)
                    yStart = datenum(plotOptions.ylimStart);
                else
                    yStart = min(yData(:));
                end
                
                %Limit end for Y variable
                if ~isempty(plotOptions.ylimEnd)
                    yEnd = datenum(plotOptions.ylimEnd);
                else
                    yEnd = max(yData(:));
                end
            else
                if ~isempty(plotOptions.ylimStart)
                    yStart = plotOptions.ylimStart;
                else
                    yStart = min(yData(:));
                end
                
                %Limit end for Y variable
                if ~isempty(plotOptions.ylimEnd)
                    yEnd = yData;
                else
                    yEnd = max(yData(:));
                end
            end
        end
        
        function myPos = getNewAxesPosition(width, height, x, y, globalConfig)
            %Get the new position for an axes with template generator.
            conf = Configuration;
            globalConfig = Util.setDefaultNumberField(globalConfig, 'pageWidth');
            globalConfig = Util.setDefaultNumberField(globalConfig, 'pageHeight');
            maxWidth = globalConfig.pageWidth;
            maxHeight = globalConfig.pageHeight;
            gridSpace = conf.GRID_SIZE;
            
            realWidth = (width * gridSpace);
            realHeight = (height * gridSpace);
            
            xNorm = (x - 1)*gridSpace/maxWidth;
            yNorm = 1-((y - 1)*gridSpace/maxHeight + realHeight/maxHeight);
            
            if xNorm < 0
                xNorm = 0;
            end
            if xNorm > 1
                xNorm = 1;
            end
            
            if yNorm < 0
                yNorm = 0;
            end
            if yNorm > 1
                yNorm = 1;
            end
            
            xSize = realWidth/maxWidth;
            ySize = realHeight/maxHeight;
            myPos = [xNorm yNorm xSize ySize];
        end
        
        function [yStart yEnd plotOptions] = getPlotYlimits(plotOptions)
            %function to get the Ylmitis in the plot - template generator
            plotOptions = Util.setDefault(plotOptions,'ylimStart', '');
            plotOptions = Util.setDefaultNumberField(plotOptions,'ylimStart');
            plotOptions = Util.setDefault(plotOptions,'ylimEnd', '');
            plotOptions = Util.setDefaultNumberField(plotOptions,'ylimEnd');
            plotOptions = Util.setDefault(plotOptions,'yInterval', 1);
            plotOptions = Util.setDefaultNumberField(plotOptions,'yInterval');
            
            yStart = [];
            yEnd   = [];
            
            if isempty(plotOptions.ylimStart) && isempty(plotOptions.ylimEnd)
                [yStart yEnd] = UtilPlot.getLimsYData(plotOptions.yData, plotOptions.yVariableName, plotOptions);
            else
                yStart = plotOptions.ylimStart;
                yEnd = plotOptions.ylimend
            end
        end
        
        function nrFormat = getSubsetFormatNumber(subsetType)
            switch subsetType
                case 'daily'
                    nrFormat = 1;
                case 'weekly'
                    nrFormat = 2;
                case 'monthly'
                    nrFormat = 3;
                case 'yearly'
                    nrFormat = 4;
                otherwise
                    nrFormat = 1;
            end
        end
        
        function xTick = getXtick(options, plotOptions)
            if isfield(plotOptions, 'xTickTimeType')
                plotOptions.intervalOption = plotOptions.xTickTimeType;
            end
            
            if isfield(plotOptions, 'xTickInverval')
                plotOptions.xInterval = plotOptions.xTickInverval;
            end
            
            %Return the xTick from plot
            if ~isfield(plotOptions, 'intervalOption') || isempty(plotOptions.intervalOption)
                plotOptions.intervalOption = 'days';
            end
            
            if ~isfield(plotOptions, 'xInterval') || isempty(plotOptions.xInterval)
                plotOptions.xInterval = 1;
            end
            
            if isfield(plotOptions, 'xInterval') && isa(plotOptions.xInterval, 'char')
                plotOptions.xInterval = str2num(plotOptions.xInterval);
            end
            xStart =  options.start;
            xEnd = options.end
            
            switch plotOptions.intervalOption
                case 'years'
                    xTick = Time.timeStampYears(options);
                case 'months'
                    xTick = Time.timeStampMonth(options);
                case 'days'
                    interval = plotOptions.xInterval;
                    xTick = [xStart:interval:xEnd];
                case 'hours'
                    interval = plotOptions.xInterval / 24;
                    xTick = [xStart:interval:xEnd];
                case 'minutes'
                    interval = plotOptions.xInterval / 1440;
                    xTick = [xStart:interval:xEnd];
                case 'seconds'
                    interval = plotOptions.xInterval / 86400;
                    xTick = [xStart:interval:xEnd];
                otherwise
                    interval = plotOptions.xInterval;
                    xTick = [xStart:interval:xEnd];
            end
        end
        
        function  strText = makeText(data,i,sctOptions)
            % function for making the string of the data in the tables
            switch sctOptions.columnStyle(i)
                case 1  % numerical
                    strText = num2str(data,sctOptions.format);
                case 2  % date
                    strText = datestr(data,sctOptions.dateFormat);
                case 3
                    strText = num2str(data{1},sctOptions.format);
            end
        end
        
        function axesInfo = mergePlotOptions(axesInfo)
            %Cleans the data in the current axes and set all the plot
            %options into the options structure.
            
            fields = fieldnames(axesInfo);
            for i=1:length(fields)
                %exclude the fields related with data.
                if ~any(strcmpi(fields{i}, {'subset', 'filesSelected', 'subsetSelected', 'options', 'myData', 'dataset'}))
                    axesInfo.options.(fields{i}) = axesInfo.(fields{i});
                    %remove the field
                    axesInfo = rmfield(axesInfo, fields{i});
                end
            end
        end
                     
        function [hTick,hDay] = plotTimeTick(DT,startTime,endTime,applyCorrection,hAx)
            % plots nice looking ticks for time series on the x axis
            % INPUT: DT: time period to plot the interval (in days)
            %   startTime: the start time of the plot
            %   endTime: the end time of the plot
            %  hAx: axes to plot (optional)
            % applyCorrection (Optional struct): when the plot has legend north outside, fix
            % the size
            % OUTPUT: hTick: handle to tickmarks
            %         hDays: handle to date strings
            % REMARKS: it is probably assumed that the limits (xlim) correrspond
            % with startTime and ERndTime and these are intgeres (i.e. rounded to a
            % whole number of days)
            
            if nargin == 3 || nargin == 4
                hAx = gca;
            end
            
            if nargin == 4
                %fix the ticks position with the original plot height
                diff = applyCorrection.posAxBeforeLegend - applyCorrection.posAxAfterLegend
                fixValue = diff(4);
            else
                fixValue = 0;
            end
            
            j = 1;
            % convert time to hours
            DT = DT*24;
            hour = 0:DT:23;
            
            % determine y limits in order to now where to plot
            yLim = get(hAx,'ylim');
            maxBin = yLim(2);
            minBin = yLim(1);
            
            % delete standard tickmarks
            set(hAx,'xticklabel',{})
            
            timeTick = 0:DT:(endTime-startTime)*24;
            nrTime = length(timeTick)+1;
            hTick = zeros(nrTime,2);
            
            % plot marks for hours
            
            for i = timeTick
                hTick(j,1) = text(startTime+i/24,minBin,'|','FontSize', 4,'HorizontalAlignment','center','VerticalAlignment', 'top');
                % add number
                if j>1
                    hTick(j,2)=text(startTime+i/24,minBin-(maxBin-minBin)/25,num2str(hour(j)),'FontSize', 4.5,'HorizontalAlignment','center','VerticalAlignment', 'top');
                end
                % reset time
                if j==length(hour)
                    j=0;
                end
                j=j+1;
            end
            
            % add the date for each day
            nrDay = floor(-startTime+endTime);
            dateString = cell(nrDay);
            hDay = zeros(nrDay,1);
            for i=1:nrDay
                dateString{i} = datestr(startTime+(i-1),1);
                hDay(i) = text(startTime-0.5+i,(minBin-(maxBin-minBin)/10) - fixValue,dateString{i,1},'FontSize', 8,'HorizontalAlignment','center');
            end
        end
        
        function hpol = polarPlotNautical(varargin)
            % makes a plot using polar coordinates of the angle THETA, in degrees
            %(with respect to the north, nautical convention), versus the radius RHO.
            % uses the linestyle specified in string S.
            %  Options are provided in the variable plotOptions with the following fields:
            %           -plotOptions.plotAxis A boolean variable which is one when the axis are plotted, and zero when data are plotted. Inorder to have a nice plot, invoke this function twice, first to plot the axis, than to plot the data.
            %           -plotOptions.unitString A string containing the unit to be plotted.
            %           -plotOptions.rLimit: The maximum radius, the interval in the radial direction and the interval in the angualr direction.
            %           -plotOptions.rLimitTick: The maximum radius, the interval in the radial direction
            %           -plotOptions.thetaLimitTick: the interval in the angualr direction.
            %           -plotOptions.lineStyle: the linestyle of the plot
            %   See PLOT for a description of legal linestyles. Note that there is an
            %   extra option to use the linestyle 'A' in order to plot arrows coming
            %   from the origin.
            %
            %   H =  Job_IMDC_PolarPlot_Nautical(...) returns a handle to the plotted object in H.
            %
            %   Example:
            %      t = 0:.01:2*pi;
            %      Job_IMDC_PolarPlot_Nautical(t,sin(2*t).*cos(2*t),'--r')
            %
            %   See also PLOT, LOGLOG, SEMILOGX, SEMILOGY.
            
            %   Copyright 1984-2006 The MathWorks, Inc.
            %   $Revision$  $Date$
            
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            % Written by: Alexander Breugem
            % Date: June 2008
            % Modified by:
            % Date:
            
            % setting default values
            hasManLimit    = 0;
            thetaLimitTick = 30;
            
            % input argument checking
            [cax,args,nargs] = axescheck(varargin{:});
            error(nargchk(1,4,nargs));
            
            if nargs < 1 || nargs > 4
                error('MATLAB:polar:InvalidInput', 'Requires 2 or 3 data arguments.')
            elseif nargs == 2
                plotAxis   = 1;
                unitString = '';
                theta      = args{1};
                rho        = args{2};
                if ischar(rho)
                    line_style = rho;
                    rho = theta;
                    [mr,nr] = size(rho);
                    if mr == 1
                        theta = 1:nr;
                    else
                        th = (1:mr)';
                        theta = th(:,ones(1,nr));
                    end
                else
                    line_style = 'auto';
                end
            elseif nargs == 1
                theta      = args{1};
                line_style = 'auto';
                rho        = theta;
                [mr,nr]    = size(rho);
                if mr == 1
                    theta = 1:nr;
                else
                    th    = (1:mr)';
                    theta = th(:,ones(1,nr));
                end
                plotAxis   = 1;
                unitString = '';
                
            else %nargs == 4
                [theta,rho,plotOptions] = deal(args{1:3});
                if isfield(plotOptions,'unitString') && ~isempty(plotOptions.unitString)
                    unitString   = plotOptions.unitString;
                else
                    unitString   = '';
                end
                if isfield(plotOptions,'plotAxis') && ~isempty(plotOptions.plotAxis)
                    plotAxis   = plotOptions.plotAxis;
                else
                    plotAxis   = 1;
                end
                if isfield(plotOptions,'rLimit') && ~isempty(plotOptions.rLimit)
                    hasManLimit =1;
                    rLimit = plotOptions.rLimit;
                else
                    hasManLimit =0;
                end
                if isfield(plotOptions,'rLimitTick') && ~isempty(plotOptions.rLimitTick)
                    hasManLimitTick =1;
                    rLimitTick = plotOptions.rLimitTick;
                else
                    hasManLimitTick =0;
                end
                if isfield(plotOptions,'thetaLimit') && ~isempty(plotOptions.thetaLimit)
                    thetaLimitTick = plotOptions.thetaLimit;
                end
                
                if isfield(plotOptions,'lineStyle') && ~isempty(plotOptions.lineStyle)
                    line_style = plotOptions.lineStyle;
                else
                    line_style = 'auto';
                end
            end
            if ischar(theta) || ischar(rho)
                %error('Input arguments must be numeric.');
                error('MATLAB:polar:InvalidInputType', 'Input arguments must be numeric.');
            end
            if ~isequal(size(theta),size(rho))
                %error('THETA and RHO must be the same size.');
                error('MATLAB:polar:InvalidInput', 'THETA and RHO must be the same size.');
            end
            
            if ~isempty(strfind(line_style,'A'));
                plotArrow  = 1;
                line_style = strrep(line_style,'A','');
            else
                plotArrow = 0;
            end
            
            %%
            %This cell is new by ABR
            
            %conversion to mathematical directions
            theta = 90-theta;
            theta(theta<0)=theta(theta<0)+360;
            %degrees to radials
            theta = 2.*pi.*theta./360;
            %%
            
            % get hold state
            cax = newplot(cax);
            
            next       = lower(get(cax,'NextPlot'));
            hold_state = ishold(cax);
            
            % get x-axis text color so grid is in same color
            tc = get(cax,'xcolor');
            ls = get(cax,'gridlinestyle');
            
            % Hold on to current Text defaults, reset them to the
            % Axes' font attributes so tick marks use them.
            fAngle  = get(cax, 'DefaultTextFontAngle');
            fName   = get(cax, 'DefaultTextFontName');
            fSize   = get(cax, 'DefaultTextFontSize');
            fWeight = get(cax, 'DefaultTextFontWeight');
            fUnits  = get(cax, 'DefaultTextUnits');
            set(cax, 'DefaultTextFontAngle',  get(cax, 'FontAngle'), ...
                'DefaultTextFontName',   get(cax, 'FontName'), ...
                'DefaultTextFontSize',   get(cax, 'FontSize'), ...
                'DefaultTextFontWeight', get(cax, 'FontWeight'), ...
                'DefaultTextUnits','data')
            
            % transform data to Cartesian coordinates.
            xx = rho.*cos(theta);
            yy = rho.*sin(theta);
            
            % only do grids if hold is off
            if plotAxis
                % make a radial grid
                hold(cax,'on');
                if hasManLimit
                    maxrho = rLimit;
                else
                    maxrho = max(abs(rho(:)));
                end
                
                hhh=line([-maxrho -maxrho maxrho maxrho],[-maxrho maxrho maxrho -maxrho],'parent',cax);
                set(cax,'dataaspectratio',[1 1 1],'plotboxaspectratiomode','auto')
                v = [get(cax,'xlim') get(cax,'ylim')];
                ticks = sum(get(cax,'ytick')>=0);
                delete(hhh);
                % check radial limits and ticks
                if hasManLimit
                    rmin = 0;
                    rmax = rLimit;
                else
                    rmin = 0; rmax = v(4); rticks = max(ticks-1,2);
                    if rticks > 5   % see if we can reduce the number
                        if rem(rticks,2) == 0
                            rticks = rticks/2;
                        elseif rem(rticks,3) == 0
                            rticks = rticks/3;
                        end
                    end
                end
                
                % define a circle
                th = 0:pi/50:2*pi;
                xunit = cos(th);
                yunit = sin(th);
                % now really force points on x/y axes to lie on them exactly
                inds = 1:(length(th)-1)/4:length(th);
                xunit(inds(2:2:4)) = zeros(2,1);
                yunit(inds(1:2:5)) = zeros(3,1);
                %plot background if necessary
                if ~ischar(get(cax,'color')),
                    patch('xdata',xunit*rmax,'ydata',yunit*rmax, ...
                        'edgecolor',tc,'facecolor',get(cax,'color'),...
                        'handlevisibility','off','parent',cax);
                end
                
                % draw radial circles
                c82 = cos(82*pi/180);
                s82 = sin(82*pi/180);
                if hasManLimitTick
                    rinc = rLimitTick;
                else
                    rinc = (rmax-rmin)/rticks;
                end
                for i=(rmin+rinc):rinc:rmax
                    hhh = line(xunit*i,yunit*i,'linestyle',ls,'color',tc,'linewidth',1,...
                        'handlevisibility','off','parent',cax);
                    text((i+rinc/20)*c82,(i+rinc/20)*s82, ...
                        ['  ',num2str(i),' ',unitString],'verticalalignment','bottom',...
                        'fontsize',7,...
                        'handlevisibility','off','parent',cax)
                end
                set(hhh,'linestyle','-') % Make outer circle solid
                
                % plot spokes
                
                th = pi.*(thetaLimitTick:thetaLimitTick:180)/180;
                
                cst = cos(th); snt = sin(th);
                cs = [-cst; cst];
                sn = [-snt; snt];
                line(rmax*cs,rmax*sn,'linestyle',ls,'color',tc,'linewidth',1,...
                    'handlevisibility','off','parent',cax)
                
                % annotate spokes in degrees
                cs = [-cst cst];
                sn = [-snt snt];
                rt = 1.075*rmax;
                for i = 1:2*length(th)
                    thedir = 270-(i)*thetaLimitTick;
                    thedir(thedir<0)=thedir(thedir<0)+360;
                    text(rt*cs(i),rt*sn(i),[int2str(thedir),'°'],...
                        'horizontalalignment','center',...
                        'Fontsize',7,...
                        'handlevisibility','off','parent',cax);
                end
                
                % Annotate text for north/south east/west:
                rt2 = 1.2*rmax;
                text(rt2*cosd(0),rt2*sind(0),'E',...
                    'horizontalalignment','center',...
                    'Fontsize',10,...
                    'handlevisibility','off','parent',cax);
                
                text(rt2*cosd(90),rt2*sind(90),'N',...
                    'horizontalalignment','center',...
                    'Fontsize',10,...
                    'handlevisibility','off','parent',cax);
                
                text(rt2*cosd(270),rt2*sind(270),'S',...
                    'horizontalalignment','center',...
                    'Fontsize',10,...
                    'handlevisibility','off','parent',cax);
                rt2 = 1.25*rmax;
                text(rt2*cosd(180),rt2*sind(180),'W',...
                    'horizontalalignment','center',...
                    'Fontsize',10,...
                    'handlevisibility','off','parent',cax);
                
                % set view to 2-D
                view(cax,2);
                % set axis limits
                axis(cax,rmax*[-1 1 -1.15 1.15]);
            end% if ~holdstate
            
            % plot data on top of grid
            if plotArrow
                if strcmp(line_style,'auto') || isempty(line_style)
                    q = quiver(zeros(size(xx)),zeros(size(xx)),xx,yy,0,'parent',cax);
                else
                    q = quiver(zeros(size(xx)),zeros(size(xx)),xx,yy,0,line_style,'parent',cax);
                end
                
            else
                if strcmp(line_style,'auto')
                    q = plot(xx,yy,'parent',cax);
                else
                    
                    if ~isempty(regexp(line_style,'[-:]'))
                        q = plot(xx,yy,line_style,'parent',cax,'linewidth',2);
                    else
                        q = plot(xx,yy,line_style,'parent',cax);
                    end
                end
                
            end
            
            % Reset defaults.
            set(cax, 'DefaultTextFontAngle', fAngle , ...
                'DefaultTextFontName',   fName , ...
                'DefaultTextFontSize',   fSize, ...
                'DefaultTextFontWeight', fWeight, ...
                'DefaultTextUnits',fUnits );
            
            if nargout == 1
                hpol = q;
            end
            
            if ~hold_state
                set(cax,'dataaspectratio',[1 1 1]), axis(cax,'off'); set(cax,'NextPlot',next);
            end
            set(get(cax,'xlabel'),'visible','on')
            set(get(cax,'ylabel'),'visible','on')
            
            if ~isempty(q) && ~isdeployed
                makemcode('RegisterHandle',cax,'IgnoreHandle',q,'FunctionName','polar');
            end
        end
        
        function allAxesHandles = plotTemplate(jsonFile)
            % plot a figure from a web template
            %
            % allAxesHandles = plotTemplate(jsonFile)
            %
            % INPUT: jsonFile: the path of a json file generated by the web
            % interface
            % OUTPUT: allAxesHandles: a vector of structures with the
            % fields:
            % -axes:  with handles to all the axes
            % -position: the positions of the axes
            [myAxes, options, axesProperties, textInAxes, imagesInAxes, rectanglesInAxes, globalConfig, ~] = UtilPlot.readTemplateFile(jsonFile);
            [allAxesHandles,~,~] = WebPlot.getAxisFromTemplate(axesProperties, globalConfig, 1);
            WebPlot.completeTemplate(textInAxes, rectanglesInAxes, imagesInAxes, globalConfig);
        end
        
        function coor = pos2coor(pos)
            % calculate lower left and upper right coordinates of each axis
            % INPUT: pos [n x 4] vector of positions (Matlab format; (xLowerLeft yLowerLeft width height))
            % OUTPUT: coor [n x 4] vector of coordinates (xLowerLeft yLowerLeft xUppperRight yUpperRight)
            coor = pos;
            coor(:,3) = pos(:,1) + pos(:,3);
            coor(:,4) = pos(:,2) + pos(:,4);
        end
        
        function [myAxes options axesProperties textInAxes imagesInAxes rectanglesInAxes globalConfig saveOptions] = readTemplateFile(jsonFile)
            %this function read and .json file from the Web template
            %generator and return the structures to build the final layout.
            % [myAxes options axesProperties textInAxes imagesInAxes rectanglesInAxes globalConfig saveOptions] = readTemplateFile(jsonFile)
            % INPUT:
            % jsonFile: the path of a file with a template from the Web
            % OUTPUT: many handles to the generated figure;
            
            
            if isempty(jsonFile)
                errordlg('You have to select a file');
                return;
            end
            
            try
                %read the json file
                elements = loadjson(jsonFile);
                
                %get the axes info
                myAxes  = elements{1}.axes;
                options = elements{1}.options;
                
                %get the axes properties
                tempAxes = elements{2};
                
                axesProperties = [];
                for ii=1:length(tempAxes)
                    %get the plots
                    if strcmpi(tempAxes{ii}.type, 'plot')
                        aux = tempAxes{ii};
                        aux = rmfield(aux, 'plotId'); %clean the structure
                        aux = rmfield(aux, 'type');
                        
                        aux.id = [];
                        axesProperties = [axesProperties aux];
                        continue
                    end
                end
                
                tempAxes = elements{3};
                textInAxes = [];
                %get the text
                for ii=1:length(tempAxes)
                    %get the texts
                    if strcmpi(tempAxes{ii}.type, 'text')
                        tempTextInAxes        = tempAxes{ii};
                        tempTextInAxes.id     = [];
                        tempTextInAxes.textId = [];
                        tempTextInAxes        = rmfield(tempTextInAxes, 'type');
                        
                        %read the aditional properties
                        textProperties        = loadjson(tempAxes{ii}.properties);
                        %convert from string to number
                        textProperties = Util.setDefaultNumberField(textProperties, 'fontSize');
                        
                        %merge the struct adding the other properties
                        allPropTextInAxes = catstruct(tempTextInAxes,textProperties);
                        textInAxes        = [textInAxes allPropTextInAxes];
                    end
                end
                
                tempAxes     = elements{4};
                imagesInAxes = [];
                
                %get the images
                for ii=1:length(tempAxes)
                    %get the images
                    if strcmpi(tempAxes{ii}.type, 'image')
                        tempImagesInAxes    = tempAxes{ii};
                        tempImagesInAxes    = rmfield(tempImagesInAxes, 'imageId');
                        tempImagesInAxes    = rmfield(tempImagesInAxes, 'type');
                        tempImagesInAxes.id = [];
                        
                        %read the aditional properties
                        imageProperties    = loadjson(tempAxes{ii}.properties);
                        %merge the struct adding the other properties
                        allPropImageInAxes = catstruct(tempImagesInAxes,imageProperties);
                        imagesInAxes       = [imagesInAxes allPropImageInAxes];
                    end
                end
                
                %get rectangles
                tempRectangles   = elements{5};
                rectanglesInAxes = [];
                for ii=1:length(tempRectangles)
                    %convert from string to number
                    tempRectangles{ii} = Util.setDefaultNumberField(tempRectangles{ii}, 'height');
                    tempRectangles{ii} = Util.setDefaultNumberField(tempRectangles{ii}, 'width');
                    tempRectangles{ii} = Util.setDefaultNumberField(tempRectangles{ii}, 'x');
                    tempRectangles{ii} = Util.setDefaultNumberField(tempRectangles{ii}, 'y');
                    
                    %get the rectangles
                    rectanglesInAxes = [rectanglesInAxes tempRectangles{ii}];
                end
                
                %get globalconfig
                tempGlobalConfig = elements{6};
                if isempty(tempGlobalConfig)
                    globalConfig.pageWidth = 600;
                    globalConfig.pageHeight = 849;
                else
                    globalConfig = tempGlobalConfig;
                    
                    globalConfig.pageWidth = str2double(globalConfig.pageWidth);
                    globalConfig.pageHeight = str2double(globalConfig.pageHeight);
                end
                
                saveOptions = struct;
                if length(elements) > 6
                    saveOptions = elements{7};
                    if ~isempty(saveOptions)
                        saveOptions = saveOptions{1};
                    end
                end
            catch
                return;
            end
            
        end
        
        function hFig = reportFigureTemplate(varargin)
            % Create a new figure that looks good in an IMDC report
            %
            % Function hFig = reportFigureTemplate(orientation,height,allOptions);
            %
            % INPUT
            % - Orientation: 'portrait' (default) or 'landscape'. Can also be
            % the width for the figure in cm.
            % - Height: the height (in centimeters). Default = 9 cm
            % - Options: a list of strings with extra settings. Currently
            % implemented options:
            %  - 'grid on': add a grid to the plot
            %  - 'logx': add logaritmic x scale
            %  - 'logy': add logaritmic y scale
            %  - 'logxy': add logaritmic x and y scale
            
            
            %makes a right axis in the current plot with the same size than the
            %left axis
            switch nargin
                case 0
                    ori = 'portrait';
                    height = 9;
                    allOptions = {};
                case 1
                    ori = varargin{1};
                    height = 9;
                    allOptions = {};
                case 2
                    ori = varargin{1};
                    height = varargin{2};
                    allOptions = {};
                otherwise
                    ori = varargin{1};
                    height = varargin{2};
                    allOptions = varargin(3:end);
            end
            
            hFig = figure(...
                'units','centimeter',...
                'paperpositionmode','auto',...
                'defaultaxesfontsize',9,...
                'defaulttextfontsize',9,...
                'defaultlinelinewidth',1);
            if any(strcmpi('grid on',allOptions))
                set(hFig,'defaultaxesxgrid','on',...
                    'defaultaxesygrid','on',...
                    'defaultaxesgridalpha',0.25,...
                    'defaultaxesgridcolor',[0.25 0.25 0.25]);
            end
            if any(strcmpi('logx',allOptions))
                set(hFig,'defaultaxesxscale','log')
            end
            if any(strcmpi('logy',allOptions))
                set(hFig,'defaultaxesxscale','log')
            end
            if any(strcmpi('logxy',allOptions))
                set(hFig,'defaultaxesxscale','log',...
                    'defaultaxesyscale','log')
            end
            
            
            
            
            
            
            if isnumeric(ori)
                set(hFig,...
                    'PaperOrientation', 'portrait',...
                    'position',[2 2 ori height]);
            else
                switch lower(ori)
                    % set size and orientation of figure
                    case 'portrait'
                        set(hFig,...
                            'PaperOrientation', 'portrait',...
                            'position',[2 2 15 height]);
                    case 'landscape'
                        % set size and orientation of figure
                        set(hFig,...
                            ...
                            'position',[2 2 23.5 height]);
                    otherwise
                        error('Incorrect figure orientation provided');
                end
            end
        end
        
        
        
        function hNew = rightAxis(hOld,limNew)
            %makes a right axis in the current plot with the same size than the
            %top axis
            position = get(hOld,'pos');
            fs=get(hOld,'fontsize');
            xLim = get(hOld,'xlim');
            %make new axes with the same size
            hNew = axes('position',position,'XAxisLocation','bottom','YAxisLocation','right','visible','on','Ycolor','k','color','none','fontsize',fs);
            hold on;
            set(gcf,'currentAxes',hNew)
            % link axes
            set(hNew,'xlim',xLim)
            linkaxes([hOld,hNew],'x');
            ylim(limNew)
            % calculate tcik interval based on other axes
            tickOld = get(hOld,'ytick');
            limOld  = get(hOld,'ylim');
            
            set(hNew,'xticklabel',[]);
            tickNew = limNew(1) + (tickOld-limOld(1)).*(limNew(2)-limNew(1))./(limOld(2)-limOld(1));
            set(hNew,'ytick',tickNew)
        end
        
        function hNew = topAxis(hOld,limNew)
            %makes a top axis in the current plot with the same size as the
            %bottom axis
            position = get(hOld,'pos');
            fs=get(hOld,'fontsize');
            yLim = get(hOld,'ylim');
            %make new axes with the same size
            hNew = axes('position',position,'XAxisLocation','top','YAxisLocation','left','visible','on','Ycolor','k','color','none','fontsize',fs);
            hold on;
            set(gcf,'currentAxes',hNew)
            % link axes
            set(hNew,'ylim',yLim)
            linkaxes([hOld,hNew],'y');
             xlim(limNew)
            % calculate tcik interval based on other axes
            tickOld = get(hOld,'xtick');
            limOld  = get(hOld,'xlim');
            
            set(hNew,'yticklabel',[]);
            tickNew = limNew(1) + (tickOld-limOld(1)).*(limNew(2)-limNew(1))./(limOld(2)-limOld(1));
            set(hNew,'xtick',tickNew)
        end
 
        function hgrp = satelliteBackground(varargin)
        % PLOT_OPENSTREETMAP  Plots OpenStreetMap on the background of a figure.
        %    h = PLOT_OPENSTREETMAP(Property, Value,...)
        %
        %    Properties (optional):
        %
        %      'Alpha'   Transparency level of the map (0 is fully transparent, 1 
        %                is opaque). Default: 1.
        %      'Scale'   Resolution scale factor (Default: 1). Using Scale=2 will
        %                double the resulotion of the map image and will result in
        %                finer rendering.
        %     'Maptype'  Sets the maptype to be downloaded from openmaptiles.
        %                Default: 'hybrid' (= satillite), other maptypes: basic,
        %                streets. See https://www.maptiler.com/ for more
        %                types.
        %     Remark:    Base figure must have Lat-Lon coordinates in order to
        %                use the satellite background!!
        %     To do:     Make funcion compatible with other EPSG coordinate
        %                systems.
        %
        % EXAMPLE
        %
        %    x = [11.6639 11.7078 11.7754 11.8063 11.8797];
        %    y = [57.6078 57.6473 57.6607 57.6804 57.6886];
        %    figure('Color', 'w'); plot(x, y, 'o-', 'LineWidth', 2);
        %    hBase = UtilPlot.plot_SatelliteBackground('Alpha', 0.4, 'Scale', 2, 'MapType','hybrid')
        %    title('Map data from Maptiler');
        %
        p = inputParser;
        validScalar0to1 = @(x) isnumeric(x) && isscalar(x) && (x >= 0) && (x <=1);
        validScalarPos  = @(x) isnumeric(x) && isscalar(x);
        addParameter(p, 'BaseUrl','https://api.maptiler.com/maps/hybrid/', @isstring);
        addParameter(p, 'Alpha', 1, validScalar0to1);
        addParameter(p, 'Scale', 1, validScalarPos);
        addParameter(p, 'MapType', 'hybrid' ,@ischar);
        options=weboptions; 
        options.CertificateFilename=(''); 

        parse(p,varargin{:});
        ax = gca();
        curAxis = axis(ax);
        verbose = false;
        baseurl = p.Results.BaseUrl;
        alpha = p.Results.Alpha;
        scale = p.Results.Scale;
        maptype = p.Results.MapType;
        %% Convertion from lat lon to tile x and y, and back.
        lon2x = @(lon, zoomlevel) floor((lon + 180) / 360 * 2 .^ zoomlevel);
        lat2y = @(lat, zoomlevel) floor((1 - log(tan(deg2rad(lat)) + (1 ./ cos(deg2rad(lat)))) / pi) / 2 .* 2 .^ zoomlevel);
        x2lon = @(x, zoomlevel) x ./ 2.^zoomlevel * 360 - 180;
        y2lat = @(y, zoomlevel) atan(sinh(pi * (1 - 2 * y ./ (2.^zoomlevel)))) * 180 / pi;
        %% 
        hold on;
        %% Adjust aspect ratio.
        adjust_axis(ax, curAxis);
        ax.PlotBoxAspectRatioMode = 'manual';
        %% Compute zoom level.
        [width, height] = ax_width_pixels(ax);
        width = width * scale;
        height = height * scale;
        zoomlevel = get_zoomlevel(curAxis, width, height);
        %% Memoize downloaded tiles, to save bandwidth.
        memoizedImread = memoize(@webread);
        memoizedImread.CacheSize = 200;
        %% Get tiles and display them.
        minmaxX = lon2x(curAxis(1:2), zoomlevel);
        minmaxY = lat2y(curAxis(3:4), zoomlevel);
        hgrp = hggroup;

        if strcmp(maptype,'hybrid');
            ext = 'jpg';
        else
            ext = 'png';
        end

        for x = min(minmaxX):max(minmaxX)
            for y = min(minmaxY):max(minmaxY)

                url = sprintf("%s/%d/%d/%d.%s?key=QjIDL1vfZrdGI5O561FF", strrep(baseurl,'hybrid',maptype), zoomlevel, x, y,ext);
                if verbose
                    disp(url)
                end
                [indices, cmap, imAlpha] = memoizedImread(url,options);
                % For other sizes
                if size(indices, 3) > 1
                    imagedata = indices;
                else
                    imagedata = ind2rgb(indices, cmap);
                end

                if numel(imAlpha) == 0
                    imAlpha = 1;
                end

                im = image(ax, ...
                           x2lon([x, x+1], zoomlevel), ...
                           y2lat([y, y+1], zoomlevel), ...
                           imagedata, ...
                           'AlphaData', alpha*imAlpha...                
                       );
                set(im,'tag','osm_map_tile')
                set(im,'Parent',hgrp) 
                uistack(im, 'bottom') 
            end
        end
        set(hgrp,'tag','osm_map')
        uistack(hgrp, 'bottom')  % move map to bottom (so it doesn't hide previously drawn annotations)
        set(gca,'layer','top')

        %%
            function [width, height] = ax_width_pixels(axHandle)
                orig_units = get(axHandle,'Units');
                set(axHandle,'Units','Pixels')
                ax_position = get(axHandle,'position');        
                set(axHandle,'Units',orig_units)
                width = ax_position(3);
                height = ax_position(4);
            end
            function adjust_axis(axHandle, curAxis)        
                % adjust current axis limit to avoid strectched maps
                [xExtent,yExtent] = latLonToMeters(curAxis(3:4), curAxis(1:2) );
                xExtent = diff(xExtent); % just the size of the span
                yExtent = diff(yExtent); 
                % get axes aspect ratio
                drawnow
                orig_units = get(axHandle,'Units');
                set(axHandle,'Units','Pixels')
                ax_position = get(axHandle,'position');        
                set(axHandle,'Units',orig_units)
                aspect_ratio = ax_position(4) / ax_position(3);
                if xExtent*aspect_ratio > yExtent        
                    centerX = mean(curAxis(1:2));
                    centerY = mean(curAxis(3:4));
                    spanX = (curAxis(2)-curAxis(1))/2;
                    spanY = (curAxis(4)-curAxis(3))/2;
                    % enlarge the Y extent
                    spanY = spanY*xExtent*aspect_ratio/yExtent; % new span
                    if spanY > 85
                        spanX = spanX * 85 / spanY;
                        spanY = spanY * 85 / spanY;
                    end
                    curAxis(1) = centerX-spanX;
                    curAxis(2) = centerX+spanX;
                    curAxis(3) = centerY-spanY;
                    curAxis(4) = centerY+spanY;
                elseif yExtent > xExtent*aspect_ratio
                    centerX = mean(curAxis(1:2));
                    centerY = mean(curAxis(3:4));
                    spanX = (curAxis(2)-curAxis(1))/2;
                    spanY = (curAxis(4)-curAxis(3))/2;
                    % enlarge the X extent
                    spanX = spanX*yExtent/(xExtent*aspect_ratio); % new span
                    if spanX > 180
                        spanY = spanY * 180 / spanX;
                        spanX = spanX * 180 / spanX;
                    end
                    curAxis(1) = centerX-spanX;
                    curAxis(2) = centerX+spanX;
                    curAxis(3) = centerY-spanY;
                    curAxis(4) = centerY+spanY;
                end            
                % Enforce Latitude constraints of EPSG:900913
                if curAxis(3) < -85
                    curAxis(3:4) = curAxis(3:4) + (-85 - curAxis(3));
                end
                if curAxis(4) > 85
                    curAxis(3:4) = curAxis(3:4) + (85 - curAxis(4));
                end
                axis(axHandle, curAxis); % update axis as quickly as possible, before downloading new image
                drawnow
            end
            function zoomlevel = get_zoomlevel(curAxis, width, height)
                [xExtent,yExtent] = latLonToMeters(curAxis(3:4), curAxis(1:2) );
                minResX = diff(xExtent) / width;
                minResY = diff(yExtent) / height;
                minRes = max([minResX minResY]);
                tileSize = 256;
                initialResolution = 2 * pi * 6378137 / tileSize; % 156543.03392804062 for tileSize 256 pixels
                zoomlevel = floor(log2(initialResolution/minRes));
                % Enforce valid zoom levels: 1 <= zoom <= 12
                zoomlevel = min(max(zoomlevel, 1), 16);
            end
            function [x,y] = latLonToMeters(lat, lon )
                % Converts given lat/lon in WGS84 Datum to XY in Spherical Mercator EPSG:900913"
                originShift = 2 * pi * 6378137 / 2.0; % 20037508.342789244
                x = lon * originShift / 180;
                y = log(tan((90 + lat) * pi / 360 )) / (pi / 180);
                y = y * originShift / 180;
            end
        end         
        
        function saveFig(fileName,varargin)
            % Save figures to PNG and FIG (only if not too big), according to
            % default settings.
            %
            % UtilPlot.saveFig(fileName,'name','value')
            %
            % INPUTS:
            % - filename: Filename (including path if necessary) of outputfile. 
            %   Do not include extension like .png or .fig.
            % - 'name','value', optional name-value input arguments, including
            %   - addFig: Add a .fig file. By default, a .fig is generated,
            %     except for large figures like pcolors or contours.
            %   - hfig: Figure handle. Current figure is used if not provided.
            %   - cropFig: If true. Whitespace is cropped from figure
            
            p = inputParser;
            addRequired(p,'filename',@ischar);
            addOptional(p,'addFig',nan);
            addOptional(p,'hfig',gcf);
            addOptional(p,'cropFig',false);
            
            parse(p,fileName,varargin{:});
            
            addFig = p.Results.addFig;
            hfig = p.Results.hfig;
            cropFig = p.Results.cropFig;
            
            % If addFig is not provided, choose if a .fig is added
            if isnan(addFig)
                addFig = true;
                heavyTypes = {'surface','patch','image'};
                a = findall(hfig);
                for ia = 1:numel(a)
                    for ih = 1:numel(heavyTypes)
                        if strcmpi(a(ia).Type,heavyTypes(ih))
                            addFig = false;
                            continue
                            
                        end
                        if ~addFig
                            continue;
                        end
                    end
                end
                
            end
            
            % Remove extension if needed
            [pathstr,name,~] = fileparts(fileName);
            fileName = fullfile(pathstr,name);
            % add path
            if ~isempty(pathstr)
                Util.makeDir(fileName);
            end
            
            % Print PNG
            print(hfig,fileName,'-dpng','-r300');
            % crop if needed
            if cropFig
                crop([fileName,'.png']);
            end
            % Save to FIG (if needed);
            if addFig
                savefig(hfig,fileName);
            end
            
        end
        
        function setCoordinateLabel(plotOptions,label)
            %set label for the coordinate
            plotOptions = Util.setDefault(plotOptions,'xVariableName','X');
            plotOptions = Util.setDefault(plotOptions,'xVarUnit','');
            
            plotOptions = Util.setDefault(plotOptions,'yVariableName','Y');
            plotOptions = Util.setDefault(plotOptions,'yVarUnit','');
            
            plotOptions = Util.setDefault(plotOptions,'zVariableName','Z');
            plotOptions = Util.setDefault(plotOptions,'zVarUnit','');
            
            switch label
                case 'X'
                    plotOptions = Util.setDefault(plotOptions,'showXLabel','true');
                    if strcmp(plotOptions.showXLabel, 'true')
                        plotOptions = Util.setDefault(plotOptions,'xLabel','');
                        if ~isempty(plotOptions.xLabel)
                            xlabel(plotOptions.xLabel);
                        else
                            if ~isempty(plotOptions.xVarUnit)
                                xlabel([plotOptions.xVariableName, ' [', plotOptions.xVarUnit, ']']);
                            else
                                xlabel(plotOptions.xVariableName);
                            end
                        end
                    end
                case 'Y'
                    plotOptions = Util.setDefault(plotOptions,'showYLabel','true');
                    if strcmp(plotOptions.showYLabel, 'true')
                        plotOptions = Util.setDefault(plotOptions,'yLabel','');
                        if ~isempty(plotOptions.yLabel)
                            ylabel(plotOptions.yLabel);
                        else
                            if ~isempty(plotOptions.yVarUnit)
                                ylabel([plotOptions.yVariableName, ' [', plotOptions.yVarUnit, ']']);
                            else
                                ylabel(plotOptions.yVariableName);
                            end
                        end
                    end
                case 'Z'
                    plotOptions = Util.setDefault(plotOptions,'showZLabel','false');
                    if strcmp(plotOptions.showZLabel, 'true')
                        plotOptions = Util.setDefault(plotOptions,'zLabel','');
                        if ~isempty(plotOptions.zLabel)
                            zlabel(plotOptions.zLabel);
                        else
                            if ~isempty(plotOptions.zVarUnit)
                                zlabel([plotOptions.zVariableName, ' [', plotOptions.zVarUnit, ']']);
                            else
                                zlabel(plotOptions.zVariableName);
                            end
                        end
                    end
                otherwise
                    error('The selected coordinate is not valid');
            end
        end
        
        function [dataToLoad, options, axesProperties, textInAxes, rectanglesInAxes, imagesInAxes, globalConfig] = setInitTemplate(dataToLoad, options, axesProperties, textInAxes, rectanglesInAxes, imagesInAxes, globalConfig)
            %Initialize the template with the right datatypes and default
            %data structures
            
            %set the default values in all the data to load
            if ~isempty(dataToLoad)
                dataFieldsAxes = fieldnames(dataToLoad);
                for jj=1:length(dataFieldsAxes)
                    fieldsAxes = strcat('axes', num2str(jj-1));
                    
                    dataFields = fieldnames(dataToLoad.(fieldsAxes));
                    axesData = dataToLoad.(fieldsAxes);
                    dataLoaded = [];
                    
                    for i=1:length(dataFields)
                        fieldsDataInAxes = strcat('dataInPlot', num2str(i-1));
                        sizeDataInAxes = size(axesData.(fieldsDataInAxes));
                        
                        sizeDataLoaded = size(dataLoaded);
                        currentDataInAxes = axesData.(fieldsDataInAxes);
                        
                        %if there is a subset in the user selection
                        if isfield(currentDataInAxes, 'subsetSelected')
                            if ~isempty(currentDataInAxes.subsetSelected) && isa(currentDataInAxes.subsetSelected,'char')
                                dataToLoad.(fieldsAxes).(fieldsDataInAxes).subsetSelected = str2num(currentDataInAxes.subsetSelected);
                            end
                        end
                    end
                end
            else
                %return an empty struct if the variable does not exist
                dataToLoad = struct;
            end
            
            if ~isempty(options)
                sizeOptions = size(options);
                for i=1:sizeOptions(2)
                    plotOptions(i) = options(i).options;
                    plotOptions(i) = Util.setDefaultNumberField(plotOptions(i), 'xInterval');
                    plotOptions(i) = Util.setDefaultNumberField(plotOptions(i), 'useXLimSubset');
                    
                    if ~isfield(plotOptions(i), 'isLayer') || isempty(plotOptions(i).isLayer)
                        % plotOptions(i).isLayer = 'false';
                    end
                end
            else
                %return an empty struct if the variable does not exist
                options = struct;
            end
            
            %set the default values in the layout axes
            sizeProperties = size(axesProperties);
            for i=1:sizeProperties(2)
                axesProperties(i) = Util.setDefaultNumberField(axesProperties(i), 'width');
                axesProperties(i) = Util.setDefaultNumberField(axesProperties(i), 'height');
                axesProperties(i) = Util.setDefaultNumberField(axesProperties(i), 'x');
                axesProperties(i) = Util.setDefaultNumberField(axesProperties(i), 'y');
                axesProperties(i).pos = [];
            end
            
            %set the default values fields type text
            sizeTextInAxes = size(textInAxes);
            for i=1:sizeTextInAxes(2)
                textInAxes(i) = Util.setDefaultNumberField(textInAxes(i), 'width');
                textInAxes(i) = Util.setDefaultNumberField(textInAxes(i), 'height');
                textInAxes(i) = Util.setDefaultNumberField(textInAxes(i), 'x');
                textInAxes(i) = Util.setDefaultNumberField(textInAxes(i), 'y');
                textInAxes(i) = Util.setDefaultNumberField(textInAxes(i), 'fontSize');
            end
            
            %set the default values in the rectangles
            sizeRectangles = size(rectanglesInAxes);
            for i=1:sizeRectangles(2)
                rectanglesInAxes(i) = Util.setDefaultNumberField(rectanglesInAxes(i), 'width');
                rectanglesInAxes(i) = Util.setDefaultNumberField(rectanglesInAxes(i), 'height');
                rectanglesInAxes(i) = Util.setDefaultNumberField(rectanglesInAxes(i), 'x');
                rectanglesInAxes(i) = Util.setDefaultNumberField(rectanglesInAxes(i), 'y');
            end
            
            %set the default values in the images
            sizeImages = size(imagesInAxes);
            for i=1:sizeImages(2)
                imagesInAxes(i) = Util.setDefaultNumberField(imagesInAxes(i), 'width');
                imagesInAxes(i) = Util.setDefaultNumberField(imagesInAxes(i), 'height');
                imagesInAxes(i) = Util.setDefaultNumberField(imagesInAxes(i), 'x');
                imagesInAxes(i) = Util.setDefaultNumberField(imagesInAxes(i), 'y');
            end
            
            globalConfig = Util.setDefaultNumberField(globalConfig, 'pageWidth');
            globalConfig = Util.setDefaultNumberField(globalConfig, 'pageHeight');
        end
        
        function setLegendDetails(plotOptions, legendAxes)
            %apply extra configuration to the legend
            if nargin == 1
                legendAxes = gca;
            end
            %set legend details for the plot
            if strcmpi(plotOptions.applyLegend, 'true')
                plotOptions = Util.setDefault(plotOptions,'newLegendText','');
                if ~isempty(plotOptions.newLegendText)
                    hleg = legend(legendAxes, plotOptions.newLegendText);
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
                            end
                        end
                    end
                end
            end
        end
        
        function setTitle(plotOptions)
            %set the title in the axes.
            conf = Configuration;
            %get the mean of the x data to show in the title.
            titleDate = mean(plotOptions.xData(:));
            
            plotOptions = Util.setDefault(plotOptions,'showTitle','true');
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
                    if strcmp(plotOptions.xVariableName, 'Time')
                        if ~isempty(plotOptions.titleFormat)
                            strTitle  = datestr(titleDate,plotOptions.titleFormat);
                        else
                            %if the user no select a format, by default show
                            %the format given by the subsetType
                            strTitle  = datestr(titleDate,conf.TITLE_FORMATS{nrFormat});
                        end
                    end
                end
                title(strTitle);
            end
        end
        
        function setXtick(plotOptions, subset, xVar, xData, jj, nrFormat)
            %Funtion to set xTick to the plot
            %INPUT:
            % plotOptions: struct with all options of the plot
            % subset: subset selected to plot
            % xVar: name of the variable in the x axes
            % xData: data obtain after appy the getData of subset
            % jj: subset index
            % nrFormat: nr to indicate the way to show the ticks
            conf = Configuration;
            format = conf.XTICK_FORMATS;
            
            if ~isfield(plotOptions, 'xInterval') || isempty(plotOptions.xInterval)
                xtick = subset.(xVar).value(jj):1:subset.(xVar).value(jj+1);
            else
                options.start = subset.(xVar).value(jj);
                options.end   = subset.(xVar).value(jj+1);
                xtick         = UtilPlot.getXtick(options, plotOptions);
            end
            
            xlim([min(xData(:)),max(xData(:))])
            set(gca,'xtick',xtick);
            set(gca,'xticklabel',datestr(xtick',format{nrFormat}));
        end
        
        function cmap = topoBathyMap(cmin,ctrans,cmax,topoColors)
            % Dual colormap for topography and bathymetry
            % cmap = topoBathyMap(cmin,ctrans,cmax)
            %INPUT
            % - cmin: Lower boundary for bathy colormap (deepest depth)
            % - ctrans: Transition from bathy to top colormap (shoreline)
            % - cmax: Upper boundary for topo colormap (highest point)
            % Example:
            % x = [-1000:100:1000];
            % y = [-1000:100:1000];
            % [X,Y]=meshgrid(x,y);
            % z = 0.005*Y-2+exp(-(X/1000).^2);
            % pcolor(x,y,z);
            % shading interp;
            % UtilPlot.topoBathyMap(-10,0,5);
            % colorbar;
            
            maxDep = ctrans-cmin;
            maxTopo = cmax-ctrans;
            totalGrad = cmax-cmin;
            
            if nargin<4
                c2 = colormap_cpt('mars_2',round((maxTopo/totalGrad)*250));
            else
                c2 = nan(round((maxTopo/totalGrad)*250),3);
                for i = 1:size(c2,2)
                    c2(:,i) = interp1(...
                        linspace(0,1,size(topoColors,1)),...
                        topoColors(:,i),...
                        linspace(0,1,round((maxTopo/totalGrad)*250)));
                end
                
            end
            
            
            
            
            c1 = colormap_cpt('bath_112',round((abs(maxDep)/totalGrad)*250));
            cmap = [c1;flipud(c2)];
            
            colormap(cmap);
            caxis([cmin cmax]);
        end
        
        function sctOut = transformData(sctIn)
            % wrapper for bug fixes and ugly maps
            %INPUT
            %sctIn: structure with the fields
            % - xData: x-data to plot (optional)
            % - yData: y-data to plot (optional)
            % - xLim: obligatory if xdata is present: limits on x axis
            % - xTick: obligatory if xdata is present: ticks on x axis
            % - yLim: obligatory if ydata is present: limits on y axis
            % - yTick: obligatory if ydata is present: limits on y axis
            % - scaleFac : factor to apply in scaling default is  1
            % - scaleMinX
            % - scaleMinY
            %
            %sctOut structure with the same data as sctIn, however
            %-xData and yData are scaled
            % additional field with scaled ticks and axis limits are added
            % -xLimScaled
            % -yLimScaled
            % -xTickScaled
            % -yTickScaled
            
            
            % process defaults
            if isfield(sctIn,'scaleFac')
                scaleFac = sctIn.scaleFac;
            else
                scaleFac = 1;
            end
            
            sctOut = sctIn;
            % transform x data
            if isfield(sctIn,'xData')
                x = sctIn.xData;
                if ~isfield(sctIn,'xTick')
                    error('Field xTick is obligatory')
                end
                if ~isfield(sctIn,'xLim')
                    error('Field xlim is obligatory')
                end
                if isfield(sctIn,'scaleMinX')
                    xRef = floor(min(x(:)));
                else
                    xRef = 0;
                end
                sctOut.xData = scaleFac.*x-xRef;
                sctOut.xLimScaled = scaleFac.*sctIn.xLim-xRef;
                sctOut.xTickScaled = scaleFac.*sctIn.xTick-xRef;
            end
            
            % transform x data
            if isfield(sctIn,'yData')
                y = sctIn.yData;
                if ~isfield(sctIn,'yTick')
                    error('Field yTick is obligatory')
                end
                if ~isfield(sctIn,'yLim')
                    error('Field ylim is obligatory')
                end
                if isfield(sctIn,'scaleMinY')
                    yRef = floor(min(y));
                else
                    yRef = 0;
                end
                sctOut.yData = scaleFac.*y-yRef;
                sctOut.yLimScaled = scaleFac.*sctIn.yLim-yRef;
                sctOut.yTickScaled = scaleFac.*sctIn.yTick-yRef;
            end
        end
        
        function ruler(isSpheric)
            % Calculates the distance by clicking
            %
            % ruler(isSpheric)
            %
            % INPUT
            % isSpheric(optional): tell if spherical coordinates need to be
            % taken into account
            
            %
            % find first point
            if nargin ==0
                isSpheric = false;
            end
            [x1,y1,w] =fastGinput(1);
            if w == 1
                [x2,y2,w] =fastGinput(1);
                if w==1
                    if isSpheric
                        d2 = Calculate.circle_distance(y1,x1,y2,x2);
                        uiwait(msgbox({['The distance is ',num2str(d),' deg'],...
                            ['The distance is ',num2str(d2),' m']},...
                            'Distance','modal'));
                    else
                        dx = x2-x1;
                        dy = y2-y1;
                        d  = sqrt((dx)^2+(dy)^2);
                        phi = 180/pi*atan2(dy,dx);
                    
                    uiwait(msgbox({['The distance is ',num2str(d),' ??'];
                        ['Dx = ',num2str(dx),' ??'];
                        ['Dy = ',num2str(dy),' ??'];
                        ['phi = ',num2str(phi),' deg'];
                        },...
                        'Distance','modal'));
                    end
                end
            end
        end
        
        function [x,y,c] = getLinesContour(C)
            % extract lines out of a contourmatrix
            %
            % [x,y,c] = getLinesContour(C)
            %
            %
            % OUTPUT: 
            % -x,y: cell array with x coordniantes y coordinates of each
            % line
            % -c: array with contour value of each line
            %
            % EXAMPLE
            %
            % [x,y] = meshgrid(1:10);
            % C = contourf(x,y,x.^+y.^2);
            % [x,y,c] = UtilPlot.getLinesContour(C);
            
            i = 1;
            n = 0;
            LARGE = 10000;
            x = cell(LARGE,1);
            y = cell(LARGE,1);
            c = zeros(LARGE,1);
            while i<size(C,2)
                n = n + 1;
                nrX = C(2,i);
                i2 = i+nrX;
                x{n} =  C(1,i+1:i2);
                y{n} =  C(2,i+1:i2);
                c(n) =  C(1,i);
                i = i2+1;
            end
            x(n+1:end) = [];
            y(n+1:end) = [];
            c(n+1:end) = [];
        end
        
        function myColor = getIMDCcolors(colorname)
            % this gives  the color code for IMDC colors
            if nargin == 0
                colorname = '';
            end
            myColor = [139, 122, 94;255,255,255;53, 74, 107]./255;
            switch lower(colorname)
                case 'blue'
                    myColor = myColor(3,:);
                case 'brown'
                    myColor = myColor(1,:);
                case 'old-flag'
                     myColor = [171, 160, 136;255,255,255;0, 144 209]./255;
                case 'old-blue'
                    myColor = [0, 144 209]./255;
                case 'old-brown'
                     myColor = [171, 160, 136]./255;
            end
        end
    end
end
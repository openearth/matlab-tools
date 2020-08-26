function setPlotOptions(currentAxesHandle, plotOptions)
%set different options to the plot
try
    clear conf;
    conf = Configuration;
    
    %get the names
    xVariableName = plotOptions.xVarInfo.longname;
    yVariableName = plotOptions.yVarInfo.longname;
    
    plotOptions.xVarUnit = '';
    if isfield(plotOptions.xVarInfo, 'unit')
        plotOptions.xVarUnit = plotOptions.xVarInfo.unit;
    end;
    
    plotOptions.yVarUnit = '';
    if isfield(plotOptions.yVarInfo, 'unit')
        plotOptions.yVarUnit = plotOptions.yVarInfo.unit;
    end;
    
    zVariableName = '';
    if isfield(plotOptions, 'zVarInfo')
        zVariableName = plotOptions.zVarInfo.longname;
        
        plotOptions.zVarUnit = '';
        if isfield(plotOptions.zVarInfo, 'unit')
            plotOptions.zVarUnit = plotOptions.zVarInfo.unit;
        end;
    end;
    
    %get the data
    xData = [];
    if isfield(plotOptions.xVarInfo, 'data')
        xData = plotOptions.xVarInfo.data;
    end;
    
    yData = [];
    if isfield(plotOptions.yVarInfo, 'data')
        yData = plotOptions.yVarInfo.data;
    end;
    
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
        end;
    end;
    
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
                end;
            end;
        end;
        %set the title
        title(strTitle);
    end;
    
    currentAxes.posAxBeforeLegend = get(currentAxesHandle, 'position');
    
    %set legend options
    plotOptions = Util.setDefault(plotOptions,'applyLegend','true');
    %UtilPlot.setLegendDetails(plotOptions);
    
    %set legend details for the plot
    if strcmpi(plotOptions.applyLegend, 'true')
        if isempty(plotOptions.legendText)
            plotOptions.legendText = plotOptions.yVarInfo.longname;
        end;
        
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
        end;
    end;
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
    end;
    
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
            newZtick = [plotOptions.zlimStart:plotOptions.zInterval:plotOptions.zlimEnd];
            set(plotOptions.hColorBar, 'ytick', newZtick);
        end;
    end;
    
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
    end;
    
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
            
        end;
        set(currentAxesHandle,'YAxisLocation', plotOptions.yAxisLocation);
    end
    
    %set the Y ticks if the user defined
    if ~isempty(plotOptions.ylimStart) && ~isempty(plotOptions.ylimEnd)
        yTicks = [plotOptions.ylimStart:plotOptions.yInterval:plotOptions.ylimEnd];
        if ~isempty(hNewRightAxes)
            set(hNewRightAxes,'ytick',yTicks);
        else
            set(currentAxesHandle,'ytick',yTicks);
        end;
    end
        
    if flagSecondAxes == 0
        if ~isnan(yStart) && ~isnan(yEnd)
            if yEnd > yStart
                ylim([yStart,yEnd]);
            end;
        end
    end;    
    
catch
    sct = lasterror;
    errordlg(['Error! ' sct.message])
    return;
end;

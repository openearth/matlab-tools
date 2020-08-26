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
        end;
        if ~isnan(zLimit)
            caxis(zLimit);
        end;
        %apply shading
        UtilPlot.applyShading(plotOptions);
        %apply colormap IMDC fix
        if ~strcmpi(plotOptions.xVar, 'Time')
            myColorMap = UtilPlot.colormapIMDC(plotOptions.colorMapStyle, nrColors);
            colormap(myColorMap);
        end;
        hColor = colorbar;
        
        if ~isnan(ztick)
            set(hColor,'ztick',length(ztick)+1);
            set(hColor,'ytick',ztick);
        end;
        
        if ~isnan(zLimit)
            set(hColor,'ylim',zLimit);
        end;
        
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
end;

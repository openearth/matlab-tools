function hEsri=EHY_plot_esri_map(varargin)
%% EHY_plot_esri_map
%
% This functions plots a esri world image in your current figure
%
% Example1: EHY_plot_esri_map
% Example2: hEsri = EHY_plot_esri_map
%
% EXAMPLE - plot a map showing some capitals in Europe:
%    lat = [48.8708   51.5188   41.9260   40.4312   52.523   37.982];
%    lon = [2.4131    -0.1300    12.4951   -3.6788    13.415   23.715];
%    plot(lon,lat,'.r','MarkerSize',20)
%    EHY_plot_esri_map
%
% created by Julien Groenenboom, April 2019

%% default settings
OPT.FaceAlpha = 0.5; % transparancy index 
OPT.rescale   = 1;   % change axes to get correct projection
OPT.axes      = gca; 
OPT           = setproperty(OPT,varargin);

%% rescale
if OPT.rescale % based on (EHY_)plot_google_map
    
    curAxis=axis(OPT.axes);
    
    % adjust current axis limit to avoid strectched maps
    [xExtent,yExtent] = latLonToMeters(curAxis(3:4), curAxis(1:2) );
    xExtent = diff(xExtent); % just the size of the span
    yExtent = diff(yExtent); 
    % get axes aspect ratio
    drawnow
    org_units = get(OPT.axes,'Units');
    set(OPT.axes,'Units','Pixels')
    ax_position = get(OPT.axes,'position');        
    set(OPT.axes,'Units',org_units)
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
    axis(OPT.axes, curAxis); % update axis as quickly as possible, before downloading new image
    drawnow
end

%% plot Esri map
% Make use of QuickPlot-functionality, since wms.m is in private folder,
% make a temporary copy of the wms.m-function
copyfile([fileparts(which('d3d_qp')) filesep 'private' filesep 'wms.m'],pwd)
[IMG,lon,lat] = wms('image',wms('tms','esri_worldimagery'),'',get(gca,'xlim'),get(gca,'ylim'));
delete([pwd filesep 'wms.m'])
hEsri = surface(lon,lat,zeros(length(lat),length(lon)),'cdata',IMG,'facecolor','texturemap', ...
    'edgecolor','none','cLimInclude','off');
set(hEsri,'FaceAlpha', OPT.FaceAlpha, 'AlphaDataMapping', 'none');

end

function [x,y] = latLonToMeters(lat, lon )
% Converts given lat/lon in WGS84 Datum to XY in Spherical Mercator EPSG:900913"
originShift = 2 * pi * 6378137 / 2.0; % 20037508.342789244
x = lon * originShift / 180;
y = log(tan((90 + lat) * pi / 360 )) / (pi / 180);
y = y * originShift / 180;
end
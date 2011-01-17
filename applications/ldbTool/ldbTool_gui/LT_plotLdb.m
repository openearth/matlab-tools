function LT_plotLdb
%LT_PLOTLDB ldbTool GUI function to plot a ldb
%
% See also: LDBTOOL

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arjan Mol
%
%       arjan.mol@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Code
[but,fig]=gcbo;

set(findobj(fig,'tag','LT_zoomBut'),'String','Zoom is off','value',0);
zoom off
set(gcf,'pointer','arrow');

% find previous plotHandles and delete all
axes(findobj(fig,'tag','LT_plotWindow'));
plotHandles=get(findobj(fig,'tag','LT_plotWindow'),'UserData');
if isempty(plotHandles)
    plotHandles{1}=[];
    set(findobj(fig,'tag','LT_plotWindow'),'UserData',plotHandles);
else
    axLim=axis;
end
try
    delete(plotHandles{:});
end

% get data, and reduce data to only the fifth column of every layer (no need to plot the undo-memory)
data=get(fig,'userdata');
data=data(:,5);

% get the plotsettings and use default if isempty (in case of 1 layer)
plotSettings=get(findobj(fig,'tag','LT_layerPlotSettingsMenu'),'userdata');
if isempty(plotSettings)
    plotSettings{1}='''k-''';
end

% determine number of layers and which is the current layer
numOfLayers=length(data)-1; % reduce with 1, because the first layer is the polygon layer
curLayer=get(findobj(fig,'tag','LT_layerSelectMenu'),'value');
curLayer=curLayer+1; % +1, because first layer is reserved for polygon

% plotting...
hold on;
for ii=1:numOfLayers
    eval(['plotHandles{ii}=plot(data(ii+1).ldb(:,1),data(ii+1).ldb(:,2),' plotSettings{ii} ');']);
    set(plotHandles{ii},'ZData',repmat(2,size(get(plotHandles{ii},'XData'))));
end

if get(findobj(fig,'tag','LT_showOriBox'),'value')==1
    plotHandles{numOfLayers+1}=plot(data(curLayer).oriLDB(:,1),data(curLayer).oriLDB(:,2),'r:');
else
    plotHandles{numOfLayers+1}=[];
end

if get(findobj(fig,'tag','LT_filledBox'),'value')==1%filled??
    col=0.7*[1 1 1]+0.3*get(plotHandles{curLayer-1},'color');
    plotHandles{numOfLayers+2}=filledldb(data(curLayer).ldb,col,col,[],[1]);
else
    plotHandles{numOfLayers+2}=[];
end

if get(findobj(fig,'tag','LTSP_plotStartEndBox'),'value')==1;
    plotHandles{numOfLayers+3}=plot([data(curLayer).ldbBegin(:,1) ; data(curLayer).ldbEnd(:,1)],[data(curLayer).ldbBegin(:,2) ; data(curLayer).ldbEnd(:,2)],'linestyle','none','color','r','Marker','o','markerfacecolor','g','markeredgecolor','r','markersize',9);
    set(plotHandles{numOfLayers+3},'ZData',repmat(5,size(get(plotHandles{numOfLayers+3},'XData'))));
else
    plotHandles{numOfLayers+3}=[];
end

if get(findobj(fig,'tag','LT_showPolygonBox'),'value')==1;
    plotHandles{numOfLayers+4}=plot([data(1).ldb(:,1) ; data(1).ldb(:,1)],[data(1).ldb(:,2) ; data(1).ldb(:,2)]);
    set(plotHandles{numOfLayers+4},'marker','.','linewidth',2,'color',[1 0 0.5]);
else
    plotHandles{numOfLayers+4}=[];
end

% set(gca,'DataAspectRatioMode','manual','DataAspectRatio',[1 1 1]);
% axis fill;
set(gca,'tag','LT_plotWindow');
set(findobj(fig,'tag','LT_plotWindow'),'userdata',plotHandles);
set(fig,'renderer','painters');

function ddb_makeMapPanel
%DDB_MAKEMAPPANEL  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_makeMapPanel
%
%   Input:

%
%
%
%
%   Example
%   ddb_makeMapPanel
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%

handles=getHandles;

% Map panel

% First make large panel to contain map axis, colorbar etc.
% The large panel will be a child of the active model gui
if verLessThan('matlab', '8.4')
    handles.GUIHandles.mapPanel=uipanel('Units','pixels','Position',[5 175 870 440],'Parent',handles.model.delft3dflow.GUI.element(1).element.handle,'BorderType','none','BackgroundColor','none');
else
    handles.GUIHandles.mapPanel=uipanel('Units','pixels','Position',[5 175 870 440],'Parent',handles.model.delft3dflow.GUI.element(1).element.handle,'BorderType','none','BackgroundColor',handles.backgroundColor);
end

% Add map axis

handles.GUIHandles.mapAxisPanel=uipanel('Units','pixels','Position',[70 200 870 440],'Parent',handles.GUIHandles.mapPanel,'BorderType','beveledin','BorderWidth',2,'BackgroundColor','w');

ax=axes;
set(ax,'Parent',handles.GUIHandles.mapAxisPanel);
set(ax,'Units','pixels');
%set(ax,'NextPlot','replace');
set(ax,'NextPlot','add');
set(ax,'Position',[1 1 10 10]);
set(ax,'Box','off');
set(ax,'TickLength',[0 0]);
set(ax,'Tag','map');

view(2);
set(ax,'xlim',handles.screenParameters.xLim,'ylim',handles.screenParameters.yLim,'zlim',[handles.screenParameters.cMin handles.screenParameters.cMax]);
hold on;

handles.GUIHandles.mapAxis=ax;

% Adding colorbar
setHandles(handles);
ddb_colorBar('make');
% set(gcf,'Visible','off');

handles=getHandles;

% Coordinate text
handles.GUIHandles.textXCoordinate = uicontrol(gcf,'Units','pixels','Parent',handles.GUIHandles.mapPanel,'Style','text', ...
    'String',['X : ' num2str(0)],'Position',[300 655 100 15],'BackgroundColor',handles.backgroundColor,'HorizontalAlignment','left');
handles.GUIHandles.textYCoordinate = uicontrol(gcf,'Units','pixels','Parent',handles.GUIHandles.mapPanel,'Style','text', ...
    'String',['Y : ' num2str(0)],'Position',[380 655 100 15],'BackgroundColor',handles.backgroundColor,'HorizontalAlignment','left');
handles.GUIHandles.textZCoordinate = uicontrol(gcf,'Units','pixels','Parent',handles.GUIHandles.mapPanel,'Style','text', ...
    'String',['Z : ' num2str(0)],'Position',[460 655 100 15],'BackgroundColor',handles.backgroundColor,'HorizontalAlignment','left');
handles.GUIHandles.textCoordinateSystem = uicontrol(gcf,'Units','pixels','Parent',handles.GUIHandles.mapPanel,'Style','text', ...
    'String','WGS 84 - Geographic','Position',[100 655 200 15],'BackgroundColor',handles.backgroundColor,'HorizontalAlignment','left');
handles.GUIHandles.textBathymetry = uicontrol(gcf,'Units','pixels','Parent',handles.GUIHandles.mapPanel,'Style','text', ...
    'String',['Bathymetry : ' handles.bathymetry.dataset(1).name],'Position',[620 655 400 15],'BackgroundColor',handles.backgroundColor,'HorizontalAlignment','left');
handles.GUIHandles.textAnchor = uicontrol(gcf,'Units','pixels','Parent',handles.GUIHandles.mapPanel,'Style','text', ...
    'String','','Position',[800 655 100 15],'BackgroundColor',handles.backgroundColor,'HorizontalAlignment','left');

% Text box

screensize=get(0,'ScreenSize');
ihres=1;
if screensize(3)>1900
    ihres=1.2;
end

handles.GUIHandles.textAnn1=annotation('textbox',[0.02 0.3 0.7 0.2]);
set(handles.GUIHandles.textAnn1,'Units','pixels','HitTest','off');
set(handles.GUIHandles.textAnn1,'Position',[50 235*ihres 1000 20]);
set(handles.GUIHandles.textAnn1,'VerticalAlignment','bottom');
set(handles.GUIHandles.textAnn1,'FontSize',12,'FontWeight','bold','LineStyle','none','Color',[1 1 0]);

handles.GUIHandles.textAnn2=annotation('textbox',[0.02 0.3 0.7 0.2]);
set(handles.GUIHandles.textAnn2,'Units','pixels','HitTest','off');
set(handles.GUIHandles.textAnn2,'Position',[50 215*ihres 1000 20]);
set(handles.GUIHandles.textAnn2,'VerticalAlignment','bottom');
set(handles.GUIHandles.textAnn2,'FontSize',12,'FontWeight','bold','LineStyle','none','Color',[1 1 0]);

handles.GUIHandles.textAnn3=annotation('textbox',[0.02 0.3 0.7 0.2]);
set(handles.GUIHandles.textAnn3,'Units','pixels','HitTest','off');
set(handles.GUIHandles.textAnn3,'Position',[50 195*ihres 1000 20]);
set(handles.GUIHandles.textAnn3,'VerticalAlignment','bottom');
set(handles.GUIHandles.textAnn3,'FontSize',12,'FontWeight','bold','LineStyle','none','Color',[1 1 0]);

% Now initialize the dummy data
% Bathymetry
xx=[0 1];
yy=[0 1];
cdata=zeros(2,2,3);
handles.mapHandles.backgroundImage=image(xx,yy,cdata);hold on;
set(handles.mapHandles.backgroundImage,'Tag','backgroundimage','HitTest','off');

% Shoreline
%handles.mapHandles.shoreline=plot3(0,0,500,'k');hold on;
handles.mapHandles.shoreline=plot(0,0,'k');hold on;
set(handles.mapHandles.shoreline,'HitTest','off','Tag','shoreline');

% Cities
for i=1:length(handles.mapData.cities.lon)
    tx=text(handles.mapData.cities.lon(i),handles.mapData.cities.lat(i),[' ' handles.mapData.cities.name{i}]);
    set(tx,'HorizontalAlignment','left','VerticalAlignment','bottom');
    set(tx,'FontSize',7,'Clipping','on','HitTest','off');
    set(tx,'Tag','textWorldCitiesText');
    handles.mapHandles.textCities(i)=tx;
end
zc=zeros(size(handles.mapData.cities.lon))+500;
handles.mapHandles.cities=plot3(handles.mapData.cities.lon,handles.mapData.cities.lat,zc,'o');
set(handles.mapHandles.cities,'MarkerSize',4,'MarkerEdgeColor','none','MarkerFaceColor','r');
set(handles.mapHandles.cities,'Tag','WorldCities','HitTest','off');

set(handles.mapHandles.cities,'Visible','off');
set(handles.mapHandles.textCities,'Visible','off');

setHandles(handles);



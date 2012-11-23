function handles = ddb_initializeScreen(handles)
%DDB_INITIALIZESCREEN  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_initializeScreen(handles)
%
%   Input:
%   handles =
%
%   Output:
%   handles =
%
%   Example
%   ddb_initializeScreen
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

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%% Setting some screen parameters

% Model tabs
for i=1:length(handles.Model)
    element=handles.Model(i).GUI.element;
    subFields{1}='Model';
    subFields{2}='Input';
    subIndices={i,1};
    if ~isempty(element)
        element=addUIElements(gcf,element,'subFields',subFields,'subIndices',subIndices,'getFcn',@getHandles,'setFcn',@setHandles);
        set(element(1).handle,'Visible','off');
        handles.Model(i).GUI.element=element;
    end
end

% Map panel

% First make large panel to contain map axis, colorbar etc.
% The large panel will be a child of the active model gui

handles.GUIHandles.mapPanel=uipanel('Units','pixels','Position',[10 10 870 440],'Parent',handles.Model(i).GUI.element(1).handle);

% Add map axis

ax=axes;
set(ax,'Parent',handles.GUIHandles.mapPanel);
set(ax,'Units','pixels');
set(ax,'NextPlot','replace');
set(ax,'Position',[70 200 870 440]);
handles.GUIHandles.Axis=ax;

handles.GUIHandles.textAnn=annotation('textbox',[0.02 0.02 0.4 0.2]);

handles.screenParameters.cMin=-10000;
handles.screenParameters.cMax=10000;
handles.screenParameters.automaticColorLimits=1;
handles.screenParameters.colorMap='Earth';

handles.screenParameters.xLim=[-180 180];
handles.screenParameters.yLim=[-90 90];

view(2);
set(handles.GUIHandles.Axis,'xlim',[-180 180],'ylim',[-90 90],'zlim',[-12000 10000]);
hold on;
zoom v6 on;

load([handles.settingsDir 'colormaps' filesep 'earth.mat']);
handles.GUIData.ColorMaps.Earth=earth;

setHandles(handles);

x=0;
y=0;
z=zeros(size(x))+500;

plt=plot3(x,y,z,'k');hold on;
set(plt,'HitTest','off');
set(plt,'Tag','WorldCoastLine');

ddb_updateDataInScreen;

handles=getHandles;

load([handles.settingsDir 'geo' filesep 'worldcoastline.mat']);
handles.GUIData.WorldCoastLine5000000(:,1)=wclx;
handles.GUIData.WorldCoastLine5000000(:,2)=wcly;

setHandles(handles);

c=load([handles.settingsDir 'geo' filesep 'cities.mat']);
for i=1:length(c.cities)
    handles.GUIData.cities.Lon(i)=c.cities(i).Lon;
    handles.GUIData.cities.Lat(i)=c.cities(i).Lat;
    handles.GUIData.cities.Name{i}=c.cities(i).Name;
end



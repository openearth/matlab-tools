function ddb_TideStationsToolbox(varargin)
%DDB_TIDESTATIONSTOOLBOX  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_TideStationsToolbox(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_TideStationsToolbox
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    handles=getHandles;
    setUIElements(handles.Model(md).GUI.elements.tabs(1).elements);
    h=handles.Toolbox(tb).Input.tideStationHandle;
    if isempty(h)
        plotTideStations;
        selectTideStation
    else
        ddb_plotTideStations('activate');
    end
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'makeobservationpoints'}
            addObservationPoints;
        case{'selecttidedatabase'}
            selectTideDatabase;
        case{'selecttidestation'}
            selectTideStation;
        case{'viewtidesignal'}
            viewTideSignal;
        case{'exporttidesignal'}
            exportTideSignal;
        case{'exportalltidesignals'}
            exportAllTideSignals;
    end
end

%%
function addObservationPoints

handles=getHandles;
fstr=['ddb_' handles.Model(md).name '_addTideStations.m'];
if exist(fstr)
    feval(str2func(fstr(1:end-2)));
else
    GiveWarning('text',['Adding tide stations as observation points not supported for ' handles.Model(md).longName]);
    return
end

%%
function exportAllTideSignals

handles=getHandles;
fstr=['ddb_' handles.Model(md).name '_exportTideSignals.m'];
if exist(fstr)
    feval(str2func(fstr(1:end-2)));
else
    GiveWarning('text',['Exporting tide data within grid not supported for ' handles.Model(md).longName]);
    return
end

%%
function viewTideSignal

handles=getHandles;
t0=handles.Toolbox(tb).Input.startTime;
t1=handles.Toolbox(tb).Input.stopTime;
dt=handles.Toolbox(tb).Input.timeStep/1440;
tim=t0:dt:t1;
iac=handles.Toolbox(tb).Input.activeDatabase;
ii=handles.Toolbox(tb).Input.activeTideStation;

latitude=handles.Toolbox(tb).Input.database(iac).y(ii);
wl=makeTidePrediction(tim,handles.Toolbox(tb).Input.components,handles.Toolbox(tb).Input.amplitudes,handles.Toolbox(tb).Input.phases,latitude);

stationName=handles.Toolbox(tb).Input.database(iac).stationList{ii};
ddb_plotTimeSeries(tim,wl,stationName);

%%
function exportTideSignal
handles=getHandles;
t0=handles.Toolbox(tb).Input.startTime;
t1=handles.Toolbox(tb).Input.stopTime;
dt=handles.Toolbox(tb).Input.timeStep/1440;
tim=t0:dt:t1;
iac=handles.Toolbox(tb).Input.activeDatabase;
ii=handles.Toolbox(tb).Input.activeTideStation;

latitude=handles.Toolbox(tb).Input.database(iac).y(ii);
wl=makeTidePrediction(tim,handles.Toolbox(tb).Input.components,handles.Toolbox(tb).Input.amplitudes,handles.Toolbox(tb).Input.phases,latitude, ...
    'timezone',handles.Toolbox(tb).Input.timeZone);

stationName=handles.Toolbox(tb).Input.database(iac).stationList{ii};
shortName=handles.Toolbox(tb).Input.database(iac).stationShortNames{ii};
fname=[shortName '.tek'];
exportTEK(wl',tim',fname,stationName);

%%
function selectTideStationFromMap(imagefig, varargins)

h=gco;

if strcmp(get(h,'Tag'),'TideStations')
    
    handles=getHandles;
    
    % Find the nearest tide station n
    pos = get(handles.GUIHandles.mapAxis, 'CurrentPoint');
    iac=handles.Toolbox(tb).Input.activeDatabase;
    posx=pos(1,1);
    posy=pos(1,2);
    dxsq=(handles.Toolbox(tb).Input.database(iac).xLocLocal-posx).^2;
    dysq=(handles.Toolbox(tb).Input.database(iac).yLocLocal-posy).^2;
    dist=(dxsq+dysq).^0.5;
    [y,n]=min(dist);
    handles.Toolbox(tb).Input.activeTideStation=n;
    
    setHandles(handles);
    
    selectTideStation;
    
    setUIElement('selecttidestation');
    
end

%%
function selectTideStation

handles=getHandles;

% Delete active station marker
try
    delete(handles.Toolbox(tb).Input.activeTideStationHandle);
end
handles.Toolbox(tb).Input.activeTideStationHandle=[];

% Plot new active station
n=handles.Toolbox(tb).Input.activeTideStation;
iac=handles.Toolbox(tb).Input.activeDatabase;
plt=plot3(handles.Toolbox(tb).Input.database(iac).xLocLocal(n),handles.Toolbox(tb).Input.database(iac).yLocLocal(n),1000,'o');
set(plt,'MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','r','Tag','ActiveTideStation');
handles.Toolbox(tb).Input.activeTideStationHandle=plt;

setHandles(handles);

refreshComponentSet;

%%
function selectTideDatabase

handles=getHandles;

handles.Toolbox(tb).Input.activeTideStation=1;

% First delete existing stations
try
    delete(handles.Toolbox(tb).Input.activeTideStationHandle);
end
try
    delete(handles.Toolbox(tb).Input.tideStationHandle);
end
handles.Toolbox(tb).Input.tideStationHandle=[];
handles.Toolbox(tb).Input.activeTideStationHandle=[];

setHandles(handles);

setUIElement('selecttidestation');

plotTideStations;

selectTideStation;


%%
function plotTideStations

handles=getHandles;

iac=handles.Toolbox(tb).Input.activeDatabase;

x=handles.Toolbox(tb).Input.database(iac).xLoc;
y=handles.Toolbox(tb).Input.database(iac).yLoc;
z=zeros(size(x))+500;

cs0.name=handles.Toolbox(tb).Input.database(iac).coordinateSystem;
cs0.type=handles.Toolbox(tb).Input.database(iac).coordinateSystemType;
[x,y]=ddb_coordConvert(x,y,cs0,handles.screenParameters.coordinateSystem);

handles.Toolbox(tb).Input.database(iac).xLocLocal=x;
handles.Toolbox(tb).Input.database(iac).yLocLocal=y;

plt=plot3(x,y,z,'o');hold on;
set(plt,'MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','y');
set(plt,'Tag','TideStations');
set(plt,'ButtonDownFcn',{@selectTideStationFromMap});
handles.Toolbox(tb).Input.tideStationHandle=plt;

n=handles.Toolbox(tb).Input.activeTideStation;
plt=plot3(x(n),y(n),1000,'o');
set(plt,'MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','r','Tag','ActiveTideStation','HitTest','off');
handles.Toolbox(tb).Input.activeTideStationHandle=plt;

setHandles(handles);

%%
function refreshComponentSet

handles=getHandles;

iac=handles.Toolbox(tb).Input.activeDatabase;

% Read data from nc file
fname=[handles.Toolbox(tb).dataDir handles.Toolbox(tb).Input.database(iac).shortName '.nc'];
ii=handles.Toolbox(tb).Input.activeTideStation;
ncomp=length(handles.Toolbox(tb).Input.database(iac).components);
amp00=nc_varget(fname,'amplitude',[0 ii-1],[ncomp 1]);
phi00=nc_varget(fname,'phase',[0 ii-1],[ncomp 1]);

% Find non-zero amplitudes
ii=find(amp00~=0);
for j=1:length(ii)
    k=ii(j);
    cmp0{j}=handles.Toolbox(tb).Input.database(iac).components{k};
    amp0(j)=amp00(k);
    phi0(j)=phi00(k);
end

% Sort by amplitude
[amp,isort] = sort(amp0,2,'descend');
for j=1:length(isort)
    k=isort(j);
    cmp{j}=cmp0{k};
    phi(j)=phi0(k);
end

handles.Toolbox(tb).Input.components=[];
handles.Toolbox(tb).Input.amplitudes=[];
handles.Toolbox(tb).Input.phases=[];
for i=1:length(isort)
    handles.Toolbox(tb).Input.components{i}=cmp{i};
    handles.Toolbox(tb).Input.amplitudes(i)=amp(i);
    handles.Toolbox(tb).Input.phases(i)=phi(i);
end

setHandles(handles);

setUIElement('tidetable');



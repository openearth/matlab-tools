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
    h=handles.Toolbox(tb).Input.tidestationshandle;
    ddb_plotTideStations('activate');
    if isempty(h)
        % First time to plot tide stations
        refreshStationList;
        refreshStationText;
        plotTideStations;
        refreshComponentSet;
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
        case{'exportcomponentset'}
            exportComponentSet;
        case{'selectstationlistoption'}
            refreshStationList;
            refreshStationText;
        case{'drawpolygon'}
            drawPolygon;
        case{'deletepolygon'}
            deletePolygon;
    end
end

%%
function addObservationPoints
handles=getHandles;

switch lower(handles.Model(md).name)
    case{'delft3dflow'}
        [filename, pathname, filterindex] = uiputfile('*.obs', 'Observation File Name',[handles.Model(md).Input(ad).attName '.obs']);
        if pathname~=0
            ddb_Delft3DFLOW_addTideStations;
            handles=getHandles;
            handles.Model(md).Input(ad).obsFile=filename;
            ddb_saveObsFile(handles,ad);
            setHandles(handles);
        end
    case{'dflowfm'}
        [filename, pathname, filterindex] = uiputfile('*.xyn', 'Observation File Name',[handles.Model(md).Input(ad).attName '.xyn']);
        if pathname~=0
            ddb_DFlowFM_addTideStations;
            handles=getHandles;
            handles.Model(md).Input(ad).obsfile=filename;
            ddb_DFlowFM_saveObsFile(handles,ad);
            setHandles(handles);
        end
    otherwise
        ddb_giveWarning('text',['Sorry, generation of observation points from tide stations is not supported for ' handles.Model(md).longName ' ...']);
end

%%
function exportTideSignal

handles=getHandles;

iac=handles.Toolbox(tb).Input.activeDatabase;

if ~isempty(handles.Toolbox(tb).Input.polygonx)
    
    xpol=handles.Toolbox(tb).Input.polygonx;
    ypol=handles.Toolbox(tb).Input.polygony;
    
    x=handles.Toolbox(tb).Input.database(iac).xLocLocal;
    y=handles.Toolbox(tb).Input.database(iac).yLocLocal;
    
    istation=find(inpolygon(x,y,xpol,ypol)==1);
    
else
    istation=handles.Toolbox(tb).Input.activeTideStation;
end

wb = awaitbar(0,'Exporting time series ...');

for ii=1:length(istation)

    istat=istation(ii);

    stationName=handles.Toolbox(tb).Input.database(iac).stationList{istat};
    
    str=['Station ' stationName ' - ' num2str(ii) ' of ' num2str(length(istation)) ' ...'];
    [hh,abort2]=awaitbar(ii/(length(istation)),wb,str);

    if abort2 % Abort the process by clicking abort button
        break;
    end;
    if isempty(hh); % Break the process when closing the figure
        break;
    end;
    
    t0=handles.Toolbox(tb).Input.startTime;
    t1=handles.Toolbox(tb).Input.stopTime;
    dt=handles.Toolbox(tb).Input.timeStep/1440;
    tim=t0:dt:t1;
    iac=handles.Toolbox(tb).Input.activeDatabase;
    
    timezonestation=handles.Toolbox(tb).Input.database(iac).timezone(istat);
    
    latitude=handles.Toolbox(tb).Input.database(iac).y(istat);
    
    [cmp,amp,phi]=getComponents(handles,iac,istat);
    
    wl=makeTidePrediction(tim,cmp,amp,phi,latitude, ...
        'timezone',handles.Toolbox(tb).Input.timeZone,'maincomponents',handles.Toolbox(tb).Input.usemaincomponents,'timezonestation',timezonestation);
    wl=wl+handles.Toolbox(tb).Input.verticalOffset;
    
    stationName=handles.Toolbox(tb).Input.database(iac).stationList{istat};
    if handles.Toolbox(tb).Input.showstationnames
        fname=handles.Toolbox(tb).Input.database(iac).stationShortNames{istat};
    else
        fname=handles.Toolbox(tb).Input.database(iac).idCodes{istat};
    end
    
    switch handles.Toolbox(tb).Input.tidesignalformat
        case{'tek'}
            exportTEK(wl',tim',[fname '.tek'],stationName);
        case{'mat'}
            s=[];
            s.parameters(1).parameter.name=fname;
            s.parameters(1).parameter.time=tim';
            s.parameters(1).parameter.val=wl';            
            s.parameters(1).parameter.quantity='scalar';            
            s.parameters(1).parameter.size=[length(tim) 0 0 0 0];
            save([fname '.mat'],'-struct','s');
    end    
    
end

try
    close(wb);
end

%%
function exportComponentSet

handles=getHandles;

iac=handles.Toolbox(tb).Input.activeDatabase;

if ~isempty(handles.Toolbox(tb).Input.polygonx)
    
    xpol=handles.Toolbox(tb).Input.polygonx;
    ypol=handles.Toolbox(tb).Input.polygony;
    
    x=handles.Toolbox(tb).Input.database(iac).xLocLocal;
    y=handles.Toolbox(tb).Input.database(iac).yLocLocal;
    
    istation=find(inpolygon(x,y,xpol,ypol)==1);
    
else
    istation=handles.Toolbox(tb).Input.activeTideStation;
end

wb = awaitbar(0,'Exporting tidal components ...');

for ii=1:length(istation)
    
    istat=istation(ii);
    
    stationName=handles.Toolbox(tb).Input.database(iac).stationList{istat};
    
    str=['Station ' stationName ' - ' num2str(ii) ' of ' num2str(length(istation)) ' ...'];
    [hh,abort2]=awaitbar(ii/(length(istation)),wb,str);
    
    if abort2 % Abort the process by clicking abort button
        break;
    end;
    if isempty(hh); % Break the process when closing the figure
        break;
    end;
    
    if handles.Toolbox(tb).Input.showstationnames
        fname=handles.Toolbox(tb).Input.database(iac).stationShortNames{istat};
    else
        fname=handles.Toolbox(tb).Input.database(iac).idCodes{istat};
    end

    [cmp,amp,phi]=getComponents(handles,iac,istat);
    
    s.station.name=fname;
    s.station.id=handles.Toolbox(tb).Input.database(iac).idCodes{istat};
    s.station.longname=handles.Toolbox(tb).Input.database(iac).stationList{istat};
    s.station.x=handles.Toolbox(tb).Input.database(iac).xLocLocal(istat);
    s.station.y=handles.Toolbox(tb).Input.database(iac).yLocLocal(istat);
    s.station.component=cmp;
    s.station.amplitude=amp;
    s.station.phase=phi;
    
    switch handles.Toolbox(tb).Input.tidalcomponentsformat
        case{'tek'}
            fid=fopen([fname '_tidalcomponents.txt'],'wt');
            for ic=1:length(s.station.component)
                cmpstr=[s.station.component{ic} repmat(' ',1,8-length(s.station.component{ic}))];
                fprintf(fid,'%s %8.4f %8.1f\n',cmpstr,s.station.amplitude(ic),s.station.phase(ic));
            end
            fclose(fid);
        case{'mat'}
            save([fname '_tidalcomponents.mat'],'-struct','s');
    end    
    
    % Store data from all stations in one file
    cmps={'m2','s2','k2','n2','k1','o1','p1','q1'};
    for j=1:length(cmps)
        icmp=strmatch(lower(cmps{j}),lower(cmp),'exact');
        samples(j).component=cmps{j};
        samples(j).x(ii)=s.station.x;
        samples(j).y(ii)=s.station.y;
        if isempty(icmp)
            samples(j).amp(ii)=NaN;
            samples(j).phi(ii)=NaN;
        else
            samples(j).amp(ii)=amp(icmp);
            samples(j).phi(ii)=phi(icmp);
        end
    end    
end

% Restructure samples
for icmp=1:length(cmps)
    % Amplitudes
    k=icmp*2-1;
    s.parameters(k).parameter.name=[cmps{icmp} ' - Amplitude'];
    s.parameters(k).parameter.x=samples(icmp).x;
    s.parameters(k).parameter.y=samples(icmp).y;
    s.parameters(k).parameter.val=samples(icmp).amp;
    s.parameters(k).parameter.quantity='scalar';
    s.parameters(k).parameter.size=[0 0 0 0 0];    
    % Phases
    k=icmp*2;
    s.parameters(k).parameter.name=[cmps{icmp} ' - Phase'];
    s.parameters(k).parameter.x=samples(icmp).x;
    s.parameters(k).parameter.y=samples(icmp).y;
    s.parameters(k).parameter.val=samples(icmp).phi;
    s.parameters(k).parameter.quantity='scalar';
    s.parameters(k).parameter.size=[0 0 0 0 0];    
end

save('allstations_tidalcomponents_samples.mat','-struct','s');

try
    close(wb);
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
wl=wl+handles.Toolbox(tb).Input.verticalOffset;

stationName=handles.Toolbox(tb).Input.database(iac).stationList{ii};
ddb_plotTimeSeries(tim,wl,stationName);

%%
function selectTideStationFromMap(h,nr)
handles=getHandles;
handles.Toolbox(tb).Input.activeTideStation=nr;
setHandles(handles);
selectTideStation;

%%
function selectTideStation
handles=getHandles;
gui_pointcloud(handles.Toolbox(tb).Input.tidestationshandle,'change','activepoint',handles.Toolbox(tb).Input.activeTideStation);
refreshComponentSet;
refreshStationText;

%%
function selectTideDatabase
handles=getHandles;
handles.Toolbox(tb).Input.activeTideStation=1;
%handles.Toolbox(tb).Input.stationlist=handles.Toolbox(tb).Input.database(handles.Toolbox(tb).Input.activeDatabase).stationList;
% First delete existing stations
try
    delete(handles.Toolbox(tb).Input.tidestationshandle);
end
handles.Toolbox(tb).Input.tidestationshandle=[];
setHandles(handles);

refreshStationList;
plotTideStations;
selectTideStation;

%%
function plotTideStations

handles=getHandles;

iac=handles.Toolbox(tb).Input.activeDatabase;

% x and y in original coordinate system of database
x=handles.Toolbox(tb).Input.database(iac).xLoc;
y=handles.Toolbox(tb).Input.database(iac).yLoc;

cs0.name=handles.Toolbox(tb).Input.database(iac).coordinateSystem;
cs0.type=handles.Toolbox(tb).Input.database(iac).coordinateSystemType;
% x and y in active coordinate system
[x,y]=ddb_coordConvert(x,y,cs0,handles.screenParameters.coordinateSystem);

handles.Toolbox(tb).Input.database(iac).xLocLocal=x;
handles.Toolbox(tb).Input.database(iac).yLocLocal=y;

xy=[x y];

h=gui_pointcloud('plot','xy',xy,'selectcallback',@selectTideStationFromMap,'tag','tidestations', ...
    'MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','y', ...
    'ActiveMarkerSize',6,'ActiveMarkerEdgeColor','k','ActiveMarkerFaceColor','r', ...
    'activepoint',handles.Toolbox(tb).Input.activeTideStation);

handles.Toolbox(tb).Input.tidestationshandle=h;

setHandles(handles);

%%
function refreshComponentSet

handles=getHandles;

iac=handles.Toolbox(tb).Input.activeDatabase;

ii=handles.Toolbox(tb).Input.activeTideStation;

[cmp,amp,phi]=getComponents(handles,iac,ii);

handles.Toolbox(tb).Input.components=[];
handles.Toolbox(tb).Input.amplitudes=[];
handles.Toolbox(tb).Input.phases=[];
for i=1:length(cmp)
    handles.Toolbox(tb).Input.components{i}=cmp{i};
    handles.Toolbox(tb).Input.amplitudes(i)=amp(i);
    handles.Toolbox(tb).Input.phases(i)=phi(i);
end

setHandles(handles);

gui_updateActiveTab;

%%
function [cmp,amp,phi]=getComponents(handles,iac,ii)

fname=[handles.Toolbox(tb).dataDir handles.Toolbox(tb).Input.database(iac).shortName '.nc'];

ncomp=length(handles.Toolbox(tb).Input.database(iac).components);

% Read data from nc file
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

%%
function refreshStationList
handles=getHandles;
if handles.Toolbox(tb).Input.showstationnames
    handles.Toolbox(tb).Input.stationlist=handles.Toolbox(tb).Input.database(handles.Toolbox(tb).Input.activeDatabase).stationList;
else
    handles.Toolbox(tb).Input.stationlist=handles.Toolbox(tb).Input.database(handles.Toolbox(tb).Input.activeDatabase).idCodes;
end
setHandles(handles);

%%
function refreshStationText

handles=getHandles;

iac=handles.Toolbox(tb).Input.activeDatabase;
istat=handles.Toolbox(tb).Input.activeTideStation;

if handles.Toolbox(tb).Input.showstationnames
    handles.Toolbox(tb).Input.textstation=['Station ID : ' handles.Toolbox(tb).Input.database(iac).idCodes{istat}];
else
    handles.Toolbox(tb).Input.textstation=['Station Name : ' handles.Toolbox(tb).Input.database(iac).stationList{istat}];
end
setHandles(handles);
gui_updateActiveTab;

%%
function drawPolygon

handles=getHandles;

ddb_zoomOff;

h=findobj(gcf,'Tag','tidestationspolygon');
if ~isempty(h)
    delete(h);
end

handles.Toolbox(tb).Input.polygonx=[];
handles.Toolbox(tb).Input.polygony=[];
handles.Toolbox(tb).Input.polygonlength=0;

handles.Toolbox(tb).Input.polygonhandle=gui_polyline('draw','tag','tidestationspolygon','marker','o', ...
    'createcallback',@createPolygon,'changecallback',@changePolygon, ...
    'closed',1);

setHandles(handles);

%%
function createPolygon(h,x,y)
handles=getHandles;
handles.Toolbox(tb).Input.polygonhandle=h;
handles.Toolbox(tb).Input.polygonx=x;
handles.Toolbox(tb).Input.polygony=y;
handles.Toolbox(tb).Input.polygonlength=length(x);
setHandles(handles);
gui_updateActiveTab;

%%
function deletePolygon
handles=getHandles;
handles.Toolbox(tb).Input.polygonx=[];
handles.Toolbox(tb).Input.polygony=[];
handles.Toolbox(tb).Input.polygonlength=0;
h=findobj(gcf,'Tag','tidestationspolygon');
if ~isempty(h)
    delete(h);
end
setHandles(handles);

%%
function changePolygon(h,x,y,varargin)
handles=getHandles;
handles.Toolbox(tb).Input.polygonx=x;
handles.Toolbox(tb).Input.polygony=y;
handles.Toolbox(tb).Input.polygonlength=length(x);
setHandles(handles);


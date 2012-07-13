function ddb_ObservationStationsToolbox(varargin)
%DDB_OBSERVATIONSTATIONSTOOLBOX  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_ObservationStationsToolbox(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_ObservationStationsToolbox
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
    h=handles.Toolbox(tb).Input.observationstationshandle;
    ddb_plotObservationStations('activate');
    if isempty(h)
        plotObservationStations;
        refreshObservations;        
    end
    gui_updateActiveTab;
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'makeobservationpoints'}
            addObservationPoints;
        case{'selectobservationdatabase'}
            selectObservationDatabase;
        case{'selectobservationstation'}
            selectObservationStation;
        case{'selectparameter'}
            opt2=lower(varargin{2});
            selectParameter(opt2);
        case{'viewsignal'}
            viewObservationSignal;
        case{'exportsignal'}
            exportObservationSignal;
    end
end

%%
function addObservationPoints

handles=getHandles;

switch lower(handles.Model(md).name)
    case{'delft3dflow'}
        [filename, pathname, filterindex] = uiputfile('*.obs', 'Observation File Name',[handles.Model(md).Input(ad).attName '.obs']);
        if pathname~=0
            ddb_Delft3DFLOW_addObservationStations;
            handles=getHandles;
            handles.Model(md).Input(ad).obsFile=filename;
            ddb_saveObsFile(handles,ad);
            setHandles(handles);
        end
    otherwise
        ddb_giveWarning('text',['Sorry, generation of observation points from stations is not supported for ' handles.Model(md).longName ' ...']);
end

%%
function viewObservationSignal

handles=getHandles;
t0=handles.Toolbox(tb).Input.startTime;
t1=handles.Toolbox(tb).Input.stopTime;
iac=handles.Toolbox(tb).Input.activeDatabase;
ii=handles.Toolbox(tb).Input.activeObservationStation;
idcode=handles.Toolbox(tb).Input.database(iac).idCodes{ii};
% url=[handles.Toolbox(tb).Input.database(iac).URL idcode '/' idcode 't9999.nc'];
% url=[handles.Toolbox(tb).Input.database(iac).URL idcode '/' idcode 'h9999.nc'];
time=[];
data=[];

wb = waitbox('Downloading data ...');

try
    
%    [time,data]=getTimeSeriesFromNDBC(handles.Toolbox(tb).Input.database(iac).URL,t0,t1,idcode,'wave_height');

    switch lower(handles.Toolbox(tb).Input.database(iac).shortName)
        case{'ndbc'}
            [time,data]=getTimeSeriesFromNDBC(handles.Toolbox(tb).Input.database(iac).URL,t0,t1,idcode,'wave_height');
        case{'co-ops'}
            [time,data]=getWLFromCoops(idcode,t0,t1);
    end

    %     time = nc_varget(url,'time');
    %     time=double(time);
    %     time=datenum(1970,1,1)+time/86400;
    %     it1=find(time<=t0,1,'last');
    %     it2=find(time>=t1,1,'first');
    %     j=handles.Toolbox(tb).Input.activeParameter;
    %     par='wave_height';
    % %    data = nc_varget(url,handles.Toolbox(tb).Input.database(iac).parameters(ii).Name{j},[it1-1 0 0],[it2-it1+1 1 1]);
    %     data = nc_varget(url,par,[it1-1 0 0],[it2-it1+1 1 1]);
    %     time=time(it1:it2);
    close(wb);
    if ~isempty(time) && ~isempty(data)
        stationName=handles.Toolbox(tb).Input.database(iac).stationNames{ii};
        ddb_plotTimeSeries(time,data,stationName);
    end
        
catch
    
    close(wb);
    
end


%%
function exportObservationSignal

handles=getHandles;
t0=handles.Toolbox(tb).Input.startTime;
t1=handles.Toolbox(tb).Input.stopTime;
iac=handles.Toolbox(tb).Input.activeDatabase;
ii=handles.Toolbox(tb).Input.activeObservationStation;
idcode=handles.Toolbox(tb).Input.database(iac).idCodes{ii};

time=[];
data=[];

wb = waitbox('Downloading data ...');

try
    
    switch lower(handles.Toolbox(tb).Input.database(iac).shortName)
        case{'ndbc'}
            [time,data]=getTimeSeriesFromNDBC(handles.Toolbox(tb).Input.database(iac).URL,t0,t1,idcode,'wave_height');
        case{'co-ops'}
            [time,data]=getWLFromCoops(idcode,t0,t1);
    end
    
    %     time = nc_varget(url,'time');
    %     time=double(time);
    %     time=datenum(1970,1,1)+time/86400;
    %     it1=find(time<=t0,1,'last');
    %     it2=find(time>=t1,1,'first');
    %     par='wave_height';
    % %    data = nc_varget(url,handles.Toolbox(tb).Input.database(iac).parameters(ii).Name{1},[it1-1 0 0],[it2-it1+1 1 1]);
    %     data = nc_varget(url,par,[it1-1 0 0],[it2-it1+1 1 1]);
    %     time=time(it1:it2);
    close(wb);
catch
    close(wb);
end

if ~isempty(time) && ~isempty(data)
    stationName=handles.Toolbox(tb).Input.database(iac).stationNames{ii};
    shortName=idcode;
    fname=[shortName '.tek'];
    exportTEK(data,time,fname,stationName);
end

%%
function selectObservationStationFromMap(h,nr)
handles=getHandles;
handles.Toolbox(tb).Input.activeObservationStation=nr;    
setHandles(handles);    
selectObservationStation;
gui_updateActiveTab;

%%
function selectObservationStation
handles=getHandles;
iac=handles.Toolbox(tb).Input.activeDatabase;

gui_pointcloud(handles.Toolbox(tb).Input.observationstationshandle,'change','activepoint',handles.Toolbox(tb).Input.activeObservationStation);

handles.Toolbox(tb).Input.activeParameter=1;
parameters=handles.Toolbox(tb).Input.database(iac).parameters(handles.Toolbox(tb).Input.activeObservationStation);
for j=1:length(parameters.Name)
    if parameters.Status(j)
        handles.Toolbox(tb).Input.activeParameter=j;
        break
    end
end

setHandles(handles);

refreshObservations;

%%
function selectObservationDatabase
handles=getHandles;
handles.Toolbox(tb).Input.activeObservationStation=1;
% First delete existing stations
try
    delete(handles.Toolbox(tb).Input.observationstationshandle);
end
handles.Toolbox(tb).Input.observationstationshandle=[];
setHandles(handles);
plotObservationStations;
selectObservationStation;

%%
function plotObservationStations

handles=getHandles;

iac=handles.Toolbox(tb).Input.activeDatabase;

x=handles.Toolbox(tb).Input.database(iac).xLoc;
y=handles.Toolbox(tb).Input.database(iac).yLoc;

cs0.name=handles.Toolbox(tb).Input.database(iac).coordinateSystem;
cs0.type=handles.Toolbox(tb).Input.database(iac).coordinateSystemType;
[x,y]=ddb_coordConvert(x,y,cs0,handles.screenParameters.coordinateSystem);

handles.Toolbox(tb).Input.database(iac).xLocLocal=x;
handles.Toolbox(tb).Input.database(iac).yLocLocal=y;

xy=[x' y'];

h=gui_pointcloud('plot','xy',xy,'selectcallback',@selectObservationStationFromMap,'tag','observationstations', ...
    'MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','y', ...
    'ActiveMarkerSize',6,'ActiveMarkerEdgeColor','k','ActiveMarkerFaceColor','r', ...
    'activepoint',handles.Toolbox(tb).Input.activeObservationStation);

handles.Toolbox(tb).Input.observationstationshandle=h;

setHandles(handles);

%%
function refreshObservations

handles=getHandles;
iac=handles.Toolbox(tb).Input.activeDatabase;
ii=handles.Toolbox(tb).Input.activeObservationStation;
parameters=handles.Toolbox(tb).Input.database(iac).parameters(ii);
for j=1:length(parameters.Name)
    iradio=num2str(j,'%0.2i');
    handles.Toolbox(tb).Input.(['radio' iradio]).value=0;
    handles.Toolbox(tb).Input.(['radio' iradio]).text=parameters.Name{j};
    if parameters.Status(j)
        handles.Toolbox(tb).Input.(['radio' iradio]).enable=1;
    else
        handles.Toolbox(tb).Input.(['radio' iradio]).enable=0;
    end
end
for j=length(parameters.Name)+1:14
    iradio=num2str(j,'%0.2i');
    handles.Toolbox(tb).Input.(['radio' iradio]).value=-1;
    handles.Toolbox(tb).Input.(['radio' iradio]).text=['radio' iradio];
    handles.Toolbox(tb).Input.(['radio' iradio]).enable=0;
end

iradio=num2str(handles.Toolbox(tb).Input.activeParameter,'%0.2i');
handles.Toolbox(tb).Input.(['radio' iradio]).value=1;

setHandles(handles);


%%
function selectParameter(opt)

handles=getHandles;

iopt=str2double(opt);
handles.Toolbox(tb).Input.activeParameter=iopt;

for j=1:14
    iradio=num2str(j,'%0.2i');
    if handles.Toolbox(tb).Input.(['radio' iradio]).value==1
        handles.Toolbox(tb).Input.(['radio' iradio]).value=0;
    end
end
iradio=num2str(iopt,'%0.2i');
handles.Toolbox(tb).Input.(['radio' iradio]).value=1;

setHandles(handles);

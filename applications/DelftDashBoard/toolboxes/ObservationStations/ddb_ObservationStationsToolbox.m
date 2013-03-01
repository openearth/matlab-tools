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
    ddb_plotObservationStations('activate');
    h=handles.Toolbox(tb).Input.observationstationshandle;
    if isempty(h)
        plotObservationStations;
        refreshObservations;
        refreshStationList;
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
        case{'exportallsignals'}
            exportAllObservationSignals;
        case{'drawpolygon'}
            drawPolygon;
        case{'deletepolygon'}
            deletePolygon;
        case{'exportoptions'}
            editExportOptions;
        case{'selectstationlistoption'}
            refreshStationList;
            refreshStationText;
    end
end

%%
function selectObservationDatabase

handles=getHandles;

% First delete existing stations
try
    delete(handles.Toolbox(tb).Input.observationstationshandle);
end

handles.Toolbox(tb).Input.activeobservationstation=handles.Toolbox(tb).Input.database(handles.Toolbox(tb).Input.activedatabase).activeobservationstation;

handles.Toolbox(tb).Input.observationstationshandle=[];

setHandles(handles);

refreshStationList;
plotObservationStations;
selectObservationStation;

%%
function refreshStationList

handles=getHandles;
if handles.Toolbox(tb).Input.showstationnames
    handles.Toolbox(tb).Input.stationlist=handles.Toolbox(tb).Input.database(handles.Toolbox(tb).Input.activedatabase).stationnames;
else
    handles.Toolbox(tb).Input.stationlist=handles.Toolbox(tb).Input.database(handles.Toolbox(tb).Input.activedatabase).stationids;
end
setHandles(handles);

%%
function addObservationPoints

handles=getHandles;

switch lower(handles.Model(md).name)
    case{'delft3dflow'}
        if isempty(handles.Model(md).Input(ad).grdFile)
            ddb_giveWarning('text','Please first generate or load a model grid!');
        else
            [filename, pathname, filterindex] = uiputfile('*.obs', 'Observation File Name',[handles.Model(md).Input(ad).attName '.obs']);
            if pathname~=0
                ddb_Delft3DFLOW_addObservationStations;
                handles=getHandles;
                handles.Model(md).Input(ad).obsFile=filename;
                ddb_saveObsFile(handles,ad);
                setHandles(handles);
            end
        end
    otherwise
        ddb_giveWarning('text',['Sorry, generation of observation points from stations is not supported for ' handles.Model(md).longName ' ...']);
end

%%
function selectObservationStationFromMap(h,nr)
handles=getHandles;
handles.Toolbox(tb).Input.activeobservationstation=nr;    
setHandles(handles);    
selectObservationStation;
gui_updateActiveTab;

%%
function selectObservationStation

handles=getHandles;

iac=handles.Toolbox(tb).Input.activedatabase;

istat=handles.Toolbox(tb).Input.activeobservationstation;
gui_pointcloud(handles.Toolbox(tb).Input.observationstationshandle,'change','activepoint',istat);

handles.Toolbox(tb).Input.database(iac).activeobservationstation=istat;

handles.Toolbox(tb).Input.activeparameter=1;
parameters=handles.Toolbox(tb).Input.database(iac).parameters(istat);
for j=1:length(parameters.name)
    if parameters.status(j)
        handles.Toolbox(tb).Input.activeparameter=j;
        break
    end
end

setHandles(handles);

refreshObservations;

refreshStationText;

%%
function refreshStationText

handles=getHandles;

iac=handles.Toolbox(tb).Input.activedatabase;
istat=handles.Toolbox(tb).Input.activeobservationstation;

if handles.Toolbox(tb).Input.showstationnames
    handles.Toolbox(tb).Input.textstation=['Station ID : ' handles.Toolbox(tb).Input.database(iac).stationids{istat}];
else
    handles.Toolbox(tb).Input.textstation=['Station Name : ' handles.Toolbox(tb).Input.database(iac).stationnames{istat}];
end

setHandles(handles);

%%
function plotObservationStations

handles=getHandles;

iac=handles.Toolbox(tb).Input.activedatabase;

x=handles.Toolbox(tb).Input.database(iac).xlocal;
y=handles.Toolbox(tb).Input.database(iac).ylocal;

[x,y]=ddb_coordConvert(x,y,handles.Toolbox(tb).Input.database(iac).coordinatesystem,handles.screenParameters.coordinateSystem);

handles.Toolbox(tb).Input.database(iac).xLocLocal=x;
handles.Toolbox(tb).Input.database(iac).yLocLocal=y;

xy=[x' y'];

h=gui_pointcloud('plot','xy',xy,'selectcallback',@selectObservationStationFromMap,'tag','observationstations', ...
    'MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','y', ...
    'ActiveMarkerSize',6,'ActiveMarkerEdgeColor','k','ActiveMarkerFaceColor','r', ...
    'activepoint',handles.Toolbox(tb).Input.activeobservationstation);

handles.Toolbox(tb).Input.observationstationshandle=h;

setHandles(handles);

%%
function refreshObservations

handles=getHandles;
iac=handles.Toolbox(tb).Input.activedatabase;
ii=handles.Toolbox(tb).Input.activeobservationstation;
parameters=handles.Toolbox(tb).Input.database(iac).parameters(ii);
for j=1:length(parameters.name)
    iradio=num2str(j,'%0.2i');
    handles.Toolbox(tb).Input.(['radio' iradio]).value=0;
    handles.Toolbox(tb).Input.(['radio' iradio]).text=parameters.name{j};
    if parameters.status(j)
        handles.Toolbox(tb).Input.(['radio' iradio]).enable=1;
    else
        handles.Toolbox(tb).Input.(['radio' iradio]).enable=0;
    end
end
for j=length(parameters.name)+1:14
    iradio=num2str(j,'%0.2i');
    handles.Toolbox(tb).Input.(['radio' iradio]).value=-1;
    handles.Toolbox(tb).Input.(['radio' iradio]).text=['radio' iradio];
    handles.Toolbox(tb).Input.(['radio' iradio]).enable=0;
end

iradio=num2str(handles.Toolbox(tb).Input.activeparameter,'%0.2i');
handles.Toolbox(tb).Input.(['radio' iradio]).value=1;

setHandles(handles);

%%
function selectParameter(opt)

handles=getHandles;

iopt=str2double(opt);
handles.Toolbox(tb).Input.activeparameter=iopt;

for j=1:14
    iradio=num2str(j,'%0.2i');
    if handles.Toolbox(tb).Input.(['radio' iradio]).value==1
        handles.Toolbox(tb).Input.(['radio' iradio]).value=0;
    end
end
iradio=num2str(iopt,'%0.2i');
handles.Toolbox(tb).Input.(['radio' iradio]).value=1;

setHandles(handles);

%%
function drawPolygon

handles=getHandles;

ddb_zoomOff;

h=findobj(gcf,'Tag','observationspolygon');
if ~isempty(h)
    delete(h);
end

handles.Toolbox(tb).Input.polygonx=[];
handles.Toolbox(tb).Input.polygony=[];
handles.Toolbox(tb).Input.polygonlength=0;

handles.Toolbox(tb).Input.polygonhandle=gui_polyline('draw','tag','observationspolygon','marker','o', ...
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
h=findobj(gcf,'Tag','observationspolygon');
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

function data=downloadObservations(iac,istation,ipar,iquiet)

handles=getHandles;

t0=handles.Toolbox(tb).Input.starttime;
t1=handles.Toolbox(tb).Input.stoptime;
idcode=handles.Toolbox(tb).Input.database(iac).stationids{istation};
datum=handles.Toolbox(tb).Input.database(iac).datum;
subset=handles.Toolbox(tb).Input.database(iac).subset;
timezone=handles.Toolbox(tb).Input.database(iac).timezone;

data=[];

if ~isfield(handles.Toolbox(tb).Input,'downloadeddatasetnames')
    handles.Toolbox(tb).Input.downloadeddatasetnames=[];
end
if ~isfield(handles.Toolbox(tb).Input,'downloadeddatasets')
    handles.Toolbox(tb).Input.downloadeddatasets=[];
end

try    

    if ~iquiet
        wb = waitbox(['Downloading ' handles.Toolbox(tb).Input.database(iac).parameters(istation).name{ipar} ' from station ' handles.Toolbox(tb).Input.database(iac).stationnames{istation}]);
    end

    parameter=handles.Toolbox(tb).Input.database(iac).parameters(istation).name{ipar};
    
    downloadeddatasetname=[parameter '.' idcode '.' handles.Toolbox(tb).Input.database(iac).name '.' ...
        datestr(t0,'yyyymmddHHMMSS') '.' datestr(t1,'yyyymmddHHMMSS') '.' ...
        handles.Toolbox(tb).Input.database(iac).datum '.' handles.Toolbox(tb).Input.database(iac).subset '.' handles.Toolbox(tb).Input.database(iac).timezone];
    
    ii=strmatch(downloadeddatasetname,handles.Toolbox(tb).Input.downloadeddatasetnames,'exact');
    
    if isempty(ii)
        % data not yet there       
        f=handles.Toolbox(tb).Input.database(iac).callback;
        % Now download
        data=feval(f,'getobservations','tstart',t0,'tstop',t1,'id',idcode,'parameter',parameter,'datum',datum,'subset',subset,'timezone',timezone);        
        if ~isempty(data)
            n=length(handles.Toolbox(tb).Input.downloadeddatasets)+1;
            if isempty(data.stationname)
                data.stationname=handles.Toolbox(tb).Input.database(iac).stationnames{istation};
            end
            handles.Toolbox(tb).Input.downloadeddatasets(n).downloadeddataset=data;
            handles.Toolbox(tb).Input.downloadeddatasetnames{n}=downloadeddatasetname;
        end        
    else
        % data already there
        data=handles.Toolbox(tb).Input.downloadeddatasets(ii).downloadeddataset;

    end
    
    if ~iquiet
        close(wb);
    end
    
catch
    if ~iquiet
        close(wb);    
    end
end

setHandles(handles);

%%
function viewObservationSignal

handles=getHandles;

iac=handles.Toolbox(tb).Input.activedatabase;
istation=handles.Toolbox(tb).Input.activeobservationstation;
ipar=handles.Toolbox(tb).Input.activeparameter;

data=downloadObservations(iac,istation,ipar,0);

if ~isempty(data)
    ddb_plotTimeSeries2('makefigure',data);
else
    ddb_giveWarning('text','Sorry, there is no data available for this time period ...');
end

%%
function exportObservationSignal

handles=getHandles;

iac=handles.Toolbox(tb).Input.activedatabase;
istation=handles.Toolbox(tb).Input.activeobservationstation;
ipar=handles.Toolbox(tb).Input.activeparameter;
t0=handles.Toolbox(tb).Input.starttime;
t1=handles.Toolbox(tb).Input.stoptime;

data=downloadObservations(iac,istation,ipar,0);

if isempty(data)
    ddb_giveWarning('text','Sorry, there is no data available for this time period ...');
    return
end

parameter=handles.Toolbox(tb).Input.database(iac).parameters(istation).name{ipar};

parameter(parameter==' ')='';
fname=parameter;
if handles.Toolbox(tb).Input.includename
    name=lower(handles.Toolbox(tb).Input.database(iac).stationnames{istation});
    name=justletters(lower(name));
    fname=[fname '.' name];
end
if handles.Toolbox(tb).Input.includeid
    idcode=handles.Toolbox(tb).Input.database(iac).stationids{istation};
    fname=[fname '.' idcode];
end
if handles.Toolbox(tb).Input.includedatabase
    fname=[fname '.' handles.Toolbox(tb).Input.database(iac).name];
end
if handles.Toolbox(tb).Input.includetimestamp
    fname=[fname '.' datestr(t0,'yyyymmdd') '.' datestr(t1,'yyyymmdd')];
end

if ~isempty(data)
    switch(handles.Toolbox(tb).Input.exporttype)
        case{'mat'}
            [filename, pathname, filterindex] = uiputfile('*.mat', 'Select Mat File',[fname '.mat']);
            if filename==0
                return
            end
            filename=[pathname filename];
            save(filename,'-struct','data');
        case{'tek'}           
            [filename, pathname, filterindex] = uiputfile('*.tek', 'Select Tekal File',[fname '.tek']);
            if filename==0
                return
            end
            filename=[pathname filename];
            exportTEK2(data,filename);            
    end
end

%%
function exportAllObservationSignals

handles=getHandles;

iac=handles.Toolbox(tb).Input.activedatabase;

x=handles.Toolbox(tb).Input.database(iac).xLocLocal;
y=handles.Toolbox(tb).Input.database(iac).yLocLocal;

inpol=inpolygon(x,y,handles.Toolbox(tb).Input.polygonx,handles.Toolbox(tb).Input.polygony);

t0=handles.Toolbox(tb).Input.starttime;
t1=handles.Toolbox(tb).Input.stoptime;

wb = awaitbar(0,'Downloading data ...');

% Count how many datasets there are
nrdatasets=0;
for istation=1:length(inpol)
    if inpol(istation)
        if handles.Toolbox(tb).Input.exportallparameters
            nrdatasets=nrdatasets+length(handles.Toolbox(tb).Input.database(iac).parameters(istation).name);
        else
            % Find matching parameter for this station
            ipar0=handles.Toolbox(tb).Input.activeparameter;
            istat0=handles.Toolbox(tb).Input.activeobservationstation;
            iparmatch=strmatch(handles.Toolbox(tb).Input.database(iac).parameters(istat0).name{ipar0},handles.Toolbox(tb).Input.database(iac).parameters(istation).name,'exact');
            if ~isempty(iparmatch)
                nrdatasets=nrdatasets+1;
            end
        end        
    end
end

nr=0;

[hh,abort2]=awaitbar(0.001,wb,'Downloading data ...');

errorstrings=[];
for istation=1:length(inpol)
    
    
    
    % Loop through stations
    
    if inpol(istation)
        
        ok=1;
        if handles.Toolbox(tb).Input.exportallparameters
            ipar1=1;
            ipar2=length(handles.Toolbox(tb).Input.database(iac).parameters(istation).name);
        else
            % Find matching parameter for this station
            ipar0=handles.Toolbox(tb).Input.activeparameter;
            istat0=handles.Toolbox(tb).Input.activeobservationstation;
            iparmatch=strmatch(handles.Toolbox(tb).Input.database(iac).parameters(istat0).name{ipar0},handles.Toolbox(tb).Input.database(iac).parameters(istation).name,'exact');
            if isempty(iparmatch)
                ok=0;
            else
                ipar1=iparmatch;
                ipar2=ipar1;
            end
        end
        
        if ok
            for ipar=ipar1:ipar2
                
                % Loop through parameters
                nr=nr+1;
                
                parstr=handles.Toolbox(tb).Input.database(iac).parameters(istation).name{ipar};
                ststr=handles.Toolbox(tb).Input.database(iac).stationnames{istation};
                str=['Downloading ' parstr ' from ' ststr ' - dataset ' num2str(nr) ' of ' ...
                    num2str(nrdatasets) ' ...'];
                
                [hh,abort2]=awaitbar(nr/nrdatasets,wb,str);
                
                if abort2 % Abort the process by clicking abort button
                    break;
                end;
                if isempty(hh); % Break the process when closing the figure
                    break;
                end;
                
                data=downloadObservations(iac,istation,ipar,1);
                
                if isempty(data)
                    
                    n=length(errorstrings);
                    errorstrings{n+1}=[handles.Toolbox(tb).Input.database(iac).stationnames{istation} ' - ' handles.Toolbox(tb).Input.database(iac).parameters(istation).name{ipar}];
                    
                else
                    
                    parameter=handles.Toolbox(tb).Input.database(iac).parameters(istation).name{ipar};
                    
                    parameter(parameter==' ')='';
                    fname=parameter;
                    if handles.Toolbox(tb).Input.includename
                        name=lower(handles.Toolbox(tb).Input.database(iac).stationnames{istation});
                        name=justletters(lower(name));
                        fname=[fname '.' name];
                    end
                    if handles.Toolbox(tb).Input.includeid
                        idcode=handles.Toolbox(tb).Input.database(iac).stationids{istation};
                        fname=[fname '.' idcode];
                    end
                    if handles.Toolbox(tb).Input.includedatabase
                        fname=[fname '.' handles.Toolbox(tb).Input.database(iac).name];
                    end
                    if handles.Toolbox(tb).Input.includetimestamp
                        fname=[fname '.' datestr(t0,'yyyymmdd') '.' datestr(t1,'yyyymmdd')];
                    end
                    
                    if ~isempty(data)
                        switch(handles.Toolbox(tb).Input.exporttype)
                            case{'mat'}
                                filename=[fname '.mat'];
                                save(filename,'-struct','data');
                            case{'tek'}
                                filename=[fname '.tek'];
                                exportTEK2(data,filename);
                        end
                    end
                end
            end
        end
    end
    if abort2 % Abort the process by clicking abort button
        break;
    end;
    if isempty(hh); % Break the process when closing the figure
        break;
    end;
end

% close waitbar
if ~isempty(hh)
    close(wb);
end

if ~isempty(errorstrings)
    h.errorstrings=errorstrings;
    h.dummy=1;
    xmldir=handles.Toolbox(tb).xmlDir;
    xmlfile='observationstations.showerrors.xml';    
    [h,ok]=gui_newWindow(h,'xmldir',xmldir,'xmlfile',xmlfile,'iconfile',[handles.settingsDir filesep 'icons' filesep 'deltares.gif']);    
end
    
%%
function editExportOptions

handles=getHandles;

xmldir=handles.Toolbox(tb).xmlDir;
xmlfile='observationstations.exportoptions.xml';

h=handles.Toolbox(tb).Input;

[h,ok]=gui_newWindow(h,'xmldir',xmldir,'xmlfile',xmlfile,'iconfile',[handles.settingsDir filesep 'icons' filesep 'deltares.gif']);

if ok
    
    handles.Toolbox(tb).Input=h;
    
    setHandles(handles);

end

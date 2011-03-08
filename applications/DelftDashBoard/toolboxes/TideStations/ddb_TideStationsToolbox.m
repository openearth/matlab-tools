function ddb_TideStationsToolbox(varargin)

if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    handles=getHandles;
    setUIElements(handles.Toolbox(tb).GUI.elements);
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
        case{'drawrectangle'}
        case{'generateimage'}
        case{'selecttidedatabase'}
            selectTideDatabase;
        case{'selecttidestation'}
            selectTideStation;
        case{'viewtidesignal'}
            viewTideSignal;
    end    
end

%%
function Push_addObservationPoints_Callback(hObject,eventdata)
handles=getHandles;
handles=ddb_addObservationPoints(handles);
if handles.Model(md).Input(ad).nrObservationPoints>0
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','observationpoints','active',0,'visible',1);
end
% [filename, pathname, filterindex] = uiputfile('*.obs', 'Select Observation Points File',handles.Model(md).Input(ad).ObsFile);
% if pathname~=0
%     curdir=[lower(cd) '\'];
%    if ~strcmpi(curdir,pathname)
%         filename=[pathname filename];
%     end
%     handles.Model(md).Input(ad).ObsFile=filename;
%     ddb_saveObsFile(handles,ad);
% end
setHandles(handles);

%%
function viewTideSignal

handles=getHandles;
t0=handles.Toolbox(tb).Input.startTime;
t1=handles.Toolbox(tb).Input.stopTime;
dt=handles.Toolbox(tb).Input.timeStep/1440;
tim=t0:dt:t1;

wl=makeTidePrediction(tim,handles.Toolbox(tb).Input.components,handles.Toolbox(tb).Input.amplitudes,handles.Toolbox(tb).Input.phases);

stationName=handles.Toolbox(tb).Input.database(handles.Toolbox(tb).Input.activeDatabase).stationList{handles.Toolbox(tb).Input.activeTideStation};
ddb_plotTimeSeries(tim,wl,stationName);

%%
function ExportTimeSeries_Callback(hObject,eventdata)
handles=getHandles;
cmp=handles.Toolbox(tb).tideStations.componentSet(handles.Toolbox(tb).activeTideStation);
for i=1:length(cmp.component)
    comp{i}=cmp.component{i};
    A(i,1)=cmp.Amplitude(i);
    G(i,1)=cmp.Phase(i);
end
t0=handles.Toolbox(tb).startTime;
t1=handles.Toolbox(tb).stopTime;
dt=handles.Toolbox(tb).timeStep/60;
t1=t1+dt/24;
[prediction,times]=delftPredict2007(comp,A,G,t0,t1,dt);
blname=deblank(handles.Toolbox(tb).tideStations.Name{handles.Toolbox(tb).activeTideStation});
fname=blname;
fname=strrep(fname,' ','');
fname=strrep(fname,',','');
fname=[fname(1,:) '.tek'];

exportTEK(prediction(1:end-1)',times(1:end-1)',fname,blname);

%%
function ExportAllTimeSeries_Callback(hObject,eventdata)
handles=getHandles;
%if handles.Model(md).Input(ad).nrObservationPoints>0
    ddb_exportTideSignalAllStations(handles);
%end

%%
function selectTideStationFromMap(imagefig, varargins)

h=gco;

if strcmp(get(h,'Tag'),'TideStations')  

    handles=getHandles;

    % Find the nearest tide station n
    pos = get(handles.GUIHandles.mapAxis, 'CurrentPoint');
    posx=pos(1,1);
    posy=pos(1,2);
    iac=handles.Toolbox(tb).Input.activeDatabase;
    dxsq=(handles.Toolbox(tb).Input.database(iac).x-posx).^2;
    dysq=(handles.Toolbox(tb).Input.database(iac).y-posy).^2;
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
plt=plot3(handles.Toolbox(tb).Input.database(iac).x(n),handles.Toolbox(tb).Input.database(iac).y(n),1000,'o');
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
x=handles.Toolbox(tb).Input.database(iac).x;
y=handles.Toolbox(tb).Input.database(iac).y;
z=zeros(size(x))+500;
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
fname=[handles.toolBoxDir 'tidestations\' handles.Toolbox(tb).Input.database(iac).shortName '.nc'];
ii=handles.Toolbox(tb).Input.activeTideStation;
ncomp=length(handles.Toolbox(tb).Input.database(iac).components);
amp00=nc_varget(fname,'amplitude',[0 ii],[ncomp 1]);
phi00=nc_varget(fname,'phase',[0 ii],[ncomp 1]);

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
    cmp{j}=handles.Toolbox(tb).Input.database(iac).components{k};
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

%%
function wl=makeTidePrediction(tim,components,amplitudes,phases)

const=t_getconsts;
names=repmat(' ',length(amplitudes),4);
for i=1:length(amplitudes)
    cmp=components{i};
    if length(cmp)>4
        cmp=cmp(1:4);
    end
    name=[cmp repmat(' ',1,4-length(cmp))];
    ju=strmatch(name,const.name);
    if isempty(ju)
        disp(name)
        name=const.name(2,:);
        ju=2;
    end
    names(i,:)=name;
    freq(i,1)=const.freq(ju);
    tidecon(i,1)=amplitudes(i);
    tidecon(i,2)=0;
    tidecon(i,3)=phases(i);
    tidecon(i,4)=0;
end

wl=t_predic(tim,names,freq,tidecon);

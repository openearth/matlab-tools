function ddb_TideDatabaseToolbox

handles=getHandles;

ddb_plotTideDatabase(handles,'activate');

h=findobj(gca,'Tag','TideStations');
if isempty(h)
    handles=ChangeTideDatabase(handles);
    PlotTideStations(handles);
end

uipanel('Title','Tide Database','Units','pixels','Position',[50 20 960 160],'Tag','UIControl');

handles.GUIHandles.Pushddb_addObservationPoints = uicontrol(gcf,'Style','pushbutton','String','Make Observation Points','Position',   [290 140 140  20],'Tag','UIControl');
handles.GUIHandles.ViewTimeSeries           = uicontrol(gcf,'Style','pushbutton','String','View Tide Signal',       'Position',   [290 115 140  20],'Tag','UIControl');
handles.GUIHandles.ExportTimeSeries         = uicontrol(gcf,'Style','pushbutton','String','Export Tide Signal',     'Position',   [290  90 140  20],'Tag','UIControl');
handles.GUIHandles.ExportAllTimeSeries      = uicontrol(gcf,'Style','pushbutton','String','Export All Tide Signals','Position',   [290  65 140  20],'Tag','UIControl');

str=handles.Toolbox(tb).databases;
handles.GUIHandles.SelectTideDatabase       = uicontrol(gcf,'Style','popupmenu', 'String',str,'Position',   [290  40 140  20],'BackgroundColor',[1 1 1],'Tag','UIControl');
ii=handles.Toolbox(tb).activeDatabase;
set(handles.GUIHandles.SelectTideDatabase,'Value',ii);

handles.GUIHandles.ListTideStations         = uicontrol(gcf,'Style','listbox','String',handles.Toolbox(tb).tideStations.name,   'Position',   [ 70  30 200 130],'BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.GUIHandles.ListTideStations,'Value',handles.Toolbox(tb).activeTideStation);

handles.GUIHandles.TextAmplitude = uicontrol(gcf,'Style','text','String','Amplitude','Position',[720 145  80 20],'HorizontalAlignment','center','Tag','UIControl');
handles.GUIHandles.TextPhase     = uicontrol(gcf,'Style','text','String','Phase',    'Position',[800 145  80 20],'HorizontalAlignment','center','Tag','UIControl');

handles.GUIHandles.TextStartTime     = uicontrol(gcf,'Style','text','String','Start Time',         'Position',    [440 136  80 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextStopTime      = uicontrol(gcf,'Style','text','String','Stop Time',          'Position',    [440 111  80 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextTimeStep      = uicontrol(gcf,'Style','text','String','Time Step (min)',    'Position',    [440  86  80 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.EditStartTime     = uicontrol(gcf,'Style','edit','String',D3DTimeString(handles.Toolbox(tb).startTime),'Position',[525 140 110 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditStopTime      = uicontrol(gcf,'Style','edit','String',D3DTimeString(handles.Toolbox(tb).stopTime), 'Position',[525 115 110 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditTimeStep      = uicontrol(gcf,'Style','edit','String',num2str(handles.Toolbox(tb).timeStep),       'Position',[525  90 110 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

set(handles.GUIHandles.Pushddb_addObservationPoints,  'Callback',{@Push_addObservationPoints_Callback});
set(handles.GUIHandles.ViewTimeSeries,            'Callback',{@ViewTimeSeries_Callback});
set(handles.GUIHandles.ExportTimeSeries,          'Callback',{@ExportTimeSeries_Callback});
set(handles.GUIHandles.ExportAllTimeSeries,       'Callback',{@ExportAllTimeSeries_Callback});
set(handles.GUIHandles.ListTideStations,          'Callback',{@ListTideStations_Callback});
set(handles.GUIHandles.SelectTideDatabase,        'Callback',{@SelectTideDatabase_Callback});
set(handles.GUIHandles.EditStartTime,    'Callback',{@EditStartTime_Callback});
set(handles.GUIHandles.EditStopTime,     'Callback',{@EditStopTime_Callback});
set(handles.GUIHandles.EditTimeStep,     'Callback',{@EditTimeStep_Callback});

handles=RefreshComponentSet(handles);

SetUIBackgroundColors;

setHandles(handles);

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
function ViewTimeSeries_Callback(hObject,eventdata)
handles=getHandles;
ii=get(handles.GUIHandles.ListTideStations,'Value');
cmp=handles.Toolbox(tb).tideStations.componentSet(handles.Toolbox(tb).activeTideStation);
for i=1:length(cmp.Component)
    comp{i}=cmp.Component{i};
    A(i,1)=cmp.Amplitude(i);
    G(i,1)=cmp.Phase(i);
end
t0=handles.Toolbox(tb).startTime;
t1=handles.Toolbox(tb).stopTime;
dt=handles.Toolbox(tb).timeStep/60;
t1=t1+dt/24;
[prediction,times]=delftPredict2007(comp,A,G,t0,t1,dt);
ddb_plotTimeSeries(times(1:end-1),prediction(1:end-1),handles.Toolbox(tb).tideStations.name{handles.Toolbox(tb).activeTideStation});

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
function SelectTideStation(imagefig, varargins)
h=gco;
if strcmp(get(h,'Tag'),'TideStations')  
    handles=getHandles;
    pos = get(gca, 'CurrentPoint');
    posx=pos(1,1);
    posy=pos(1,2);
    dxsq=(handles.Toolbox(tb).tideStations.xy(:,1)-posx).^2;
    dysq=(handles.Toolbox(tb).tideStations.xy(:,2)-posy).^2;
    dist=(dxsq+dysq).^0.5;
    [y,n]=min(dist);
    h0=findall(gcf,'Tag','ActiveTideStation');
    delete(h0);
    plt=plot3(handles.Toolbox(tb).tideStations.xy(n,1),handles.Toolbox(tb).tideStations.xy(n,2),1000,'o');
    set(plt,'MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','r','Tag','ActiveTideStation');
    set(handles.GUIHandles.ListTideStations,'Value',n);
    handles.Toolbox(tb).activeTideStation=n;
    handles=RefreshComponentSet(handles);
    setHandles(handles);
end

%%
function SelectTideDatabase_Callback(hObject,eventdata)
handles=getHandles;
str=handles.Toolbox(tb).activeDatabase;
strs=handles.Toolbox(tb).databases;
ii=get(hObject,'Value');
if ~strcmpi(strs{ii},str)
    handles.Toolbox(tb).activeDatabase=ii;
    handles=ChangeTideDatabase(handles);
    PlotTideStations(handles);
    set(handles.GUIHandles.ListTideStations,'String',handles.Toolbox(tb).tideStations.name);
    set(handles.GUIHandles.ListTideStations,'Value',1);
    handles=RefreshComponentSet(handles);
    setHandles(handles);
end

%%
function ListTideStations_Callback(hObject,eventdata)
handles=getHandles;
ii=get(hObject,'Value');
h0=findall(gcf,'Tag','ActiveTideStation');
delete(h0);
plt=plot3(handles.Toolbox(tb).tideStations.xy(ii,1),handles.Toolbox(tb).tideStations.xy(ii,2),1000,'o');
set(plt,'MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','r','Tag','ActiveTideStation');
handles.Toolbox(tb).activeTideStation=ii;
handles=RefreshComponentSet(handles);
setHandles(handles);

%%
function EditStartTime_Callback(hObject,eventdata)
handles=getHandles;
handles.Toolbox(tb).startTime=D3DTimeString(get(hObject,'String'));
setHandles(handles);

%%
function EditStopTime_Callback(hObject,eventdata)
handles=getHandles;
handles.Toolbox(tb).stopTime=D3DTimeString(get(hObject,'String'));
setHandles(handles);

%%
function EditTimeStep_Callback(hObject,eventdata)
handles=getHandles;
handles.Toolbox(tb).timeStep=str2double(get(hObject,'String'));
setHandles(handles);

%%
function handles=ChangeTideDatabase(handles)

s=handles.Toolbox(tb).database{handles.Toolbox(tb).activeDatabase};
handles.Toolbox(tb).tideStations=s;
x=handles.Toolbox(tb).tideStations.x;
y=handles.Toolbox(tb).tideStations.y;
cs.name=s.coordinateSystem;
cs.type=s.coordinateSystemType;
[x,y]=ddb_coordConvert(x,y,cs,handles.screenParameters.coordinateSystem);
handles.Toolbox(tb).tideStations.xy=[x y];
handles.Toolbox(tb).activeTideStation=1;

%%
function PlotTideStations(handles)

h=findall(gca,'Tag','TideStations');
delete(h);
h=findall(gca,'Tag','ActiveTideStation');
delete(h);

x=handles.Toolbox(tb).tideStations.xy(:,1);
y=handles.Toolbox(tb).tideStations.xy(:,2);
z=zeros(size(x))+500;
plt=plot3(x,y,z,'o');hold on;
set(plt,'MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','y');
set(plt,'Tag','TideStations');
set(plt,'ButtonDownFcn',{@SelectTideStation});

n=handles.Toolbox(tb).activeTideStation;
plt=plot3(handles.Toolbox(tb).tideStations.xy(n,1),handles.Toolbox(tb).tideStations.xy(n,2),1000,'o');
set(plt,'MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','r','Tag','ActiveTideStation');

%%
function handles=RefreshComponentSet(handles)

cltp={'text','editreal','editreal'};
wdt=[50 80 80];
Callbacks={'','',''};

ii=handles.Toolbox(tb).activeTideStation;
nr=length(handles.Toolbox(tb).tideStations.componentSet(ii).Component);

for i=1:nr
    data{i,1}=handles.Toolbox(tb).tideStations.componentSet(ii).Component{i};
    data{i,2}=handles.Toolbox(tb).tideStations.componentSet(ii).Amplitude(i);
    data{i,3}=handles.Toolbox(tb).tideStations.componentSet(ii).Phase(i);
end

handles.GUIHandles.tideTable=table(gcf,'create','tag','table','position',[670 30],'nrrows',6,'columntypes',cltp,'width',wdt,'data',data,'Callbacks',Callbacks);
table(handles.GUIHandles.tideTable,'setdata',data);


function ddb_ObservationStationsToolbox

if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    handles=getHandles;
    setUIElements(handles.Toolbox(tb).GUI.elements);
    h=handles.Toolbox(tb).Input.observationStationHandle;
    if isempty(h)
        plotObservationStations;
        selectObservationStation;
    else
        ddb_plotObservationStations('activate');
    end
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
        case{'viewobservationsignal'}
%            viewObservationSignal;
        case{'exportobservationsignal'}
%            exportObservationSignal;
    end    
end

%%
function addObservationPoints

handles=getHandles;
fstr=['ddb_' handles.Model(md).name '_addObservationStations.m'];
if exist(fstr)
    feval(str2func(fstr(1:end-2)));
else
    GiveWarning('text',['Adding observation stations as observation points not supported for ' handles.Model(md).longName]);
    return
end

%%
function viewObservationSignal

handles=getHandles;
t0=handles.Toolbox(tb).Input.startTime;
t1=handles.Toolbox(tb).Input.stopTime;
dt=handles.Toolbox(tb).Input.timeStep/1440;
tim=t0:dt:t1;
iac=handles.Toolbox(tb).Input.activeDatabase;
ii=handles.Toolbox(tb).Input.activeObservationStation;

latitude=handles.Toolbox(tb).Input.database(iac).y(ii);
wl=makeObservationPrediction(tim,handles.Toolbox(tb).Input.components,handles.Toolbox(tb).Input.amplitudes,handles.Toolbox(tb).Input.phases,latitude);

stationName=handles.Toolbox(tb).Input.database(iac).stationList{ii};
ddb_plotTimeSeries(tim,wl,stationName);

%%
function exportObservationSignal
handles=getHandles;
t0=handles.Toolbox(tb).Input.startTime;
t1=handles.Toolbox(tb).Input.stopTime;
dt=handles.Toolbox(tb).Input.timeStep/1440;
tim=t0:dt:t1;
iac=handles.Toolbox(tb).Input.activeDatabase;
ii=handles.Toolbox(tb).Input.activeObservationStation;

latitude=handles.Toolbox(tb).Input.database(iac).y(ii);
wl=makeObservationPrediction(tim,handles.Toolbox(tb).Input.components,handles.Toolbox(tb).Input.amplitudes,handles.Toolbox(tb).Input.phases,latitude);

stationName=handles.Toolbox(tb).Input.database(iac).stationList{ii};
shortName=handles.Toolbox(tb).Input.database(iac).stationShortNames{ii};
fname=[shortName '.tek'];
exportTEK(wl',tim',fname,stationName);

%%
function selectObservationStationFromMap(imagefig, varargins)

h=gco;

if strcmp(get(h,'Tag'),'ObservationStations')  

    handles=getHandles;

    % Find the nearest observation station n
    pos = get(handles.GUIHandles.mapAxis, 'CurrentPoint');
    posx=pos(1,1);
    posy=pos(1,2);
    iac=handles.Toolbox(tb).Input.activeDatabase;
    dxsq=(handles.Toolbox(tb).Input.database(iac).xLoc-posx).^2;
    dysq=(handles.Toolbox(tb).Input.database(iac).yLoc-posy).^2;
    dist=(dxsq+dysq).^0.5;
    [y,n]=min(dist);
    handles.Toolbox(tb).Input.activeObservationStation=n;

    setHandles(handles);

    selectObservationStation;

    setUIElement('selectobservationstation');

end

%%
function selectObservationStation

handles=getHandles;

% Delete active station marker
try
    delete(handles.Toolbox(tb).Input.activeObservationStationHandle);
end
handles.Toolbox(tb).Input.activeObservationStationHandle=[];

% Plot new active station
n=handles.Toolbox(tb).Input.activeObservationStation;
iac=handles.Toolbox(tb).Input.activeDatabase;
plt=plot3(handles.Toolbox(tb).Input.database(iac).xLoc(n),handles.Toolbox(tb).Input.database(iac).yLoc(n),1000,'o');
set(plt,'MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','r','Tag','ActiveObservationStation');
handles.Toolbox(tb).Input.activeObservationStationHandle=plt;

setHandles(handles);

refreshObservations;

%%
function selectObservationDatabase

handles=getHandles;

handles.Toolbox(tb).Input.activeObservationStation=1;

% First delete existing stations
try
    delete(handles.Toolbox(tb).Input.activeObservationStationHandle);
end
try
    delete(handles.Toolbox(tb).Input.observationStationHandle);
end
handles.Toolbox(tb).Input.observationStationHandle=[];
handles.Toolbox(tb).Input.activeObservationStationHandle=[];

setHandles(handles);

setUIElement('selectobservationstation');

plotObservationStations;

selectObservationStation;


%%
function plotObservationStations

handles=getHandles;

iac=handles.Toolbox(tb).Input.activeDatabase;

x=handles.Toolbox(tb).Input.database(iac).xLoc;
y=handles.Toolbox(tb).Input.database(iac).yLoc;
z=zeros(size(x))+500;

plt=plot3(x,y,z,'o');hold on;
set(plt,'MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','y');
set(plt,'Tag','ObservationStations');
set(plt,'ButtonDownFcn',{@selectObservationStationFromMap});
handles.Toolbox(tb).Input.observationStationHandle=plt;

n=handles.Toolbox(tb).Input.activeObservationStation;
plt=plot3(x(n),y(n),1000,'o');
set(plt,'MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','r','Tag','ActiveObservationStation','HitTest','off');
handles.Toolbox(tb).Input.activeObservationStationHandle=plt;

setHandles(handles);

%%
function refreshObservations

handles=getHandles;

iac=handles.Toolbox(tb).Input.activeDatabase;

% 
% handles=getHandles;
% ddb_plotObservationsDatabase(handles,'activate');
% 
% h=findobj(gca,'Tag','ObservationStations');
% if isempty(h)
%     handles=ChangeObservationsDatabase(handles);
%     PlotObservationStations(handles);
% end
% 
% % h=findobj(gca,'Tag','ObservationStations');
% % if isempty(h)
% %     handles.Toolbox(tb).Stations=LoadObservations(handles);
% %     handles.Toolbox(tb).NrStations=length(handles.Toolbox(tb).Stations);
% % end
% % 
% % handles=PlotObservationStations(handles);
% 
% 
% uipanel('Title','Observations Database','Units','pixels','Position',[50 20 960 160],'Tag','UIControl');
% % 
% handles.GUIHandles.Pushddb_addObservationPoints = uicontrol(gcf,'Style','pushbutton','String','Make Observation Points','Position',   [290 140 140  20],'Tag','UIControl');
% % handles.ViewTimeSeries           = uicontrol(gcf,'Style','pushbutton','String','View Observations Signal',       'Position',   [290 115 140  20],'Tag','UIControl');
% % handles.ExportTimeSeries         = uicontrol(gcf,'Style','pushbutton','String','Export Observations Signal',     'Position',   [290  90 140  20],'Tag','UIControl');
% % handles.ExportAllTimeSeries      = uicontrol(gcf,'Style','pushbutton','String','Export All Observations Signals','Position',   [290  65 140  20],'Tag','UIControl');
% 
% str=handles.Toolbox(tb).Databases;
% handles.GUIHandles.SelectObservationsDatabase       = uicontrol(gcf,'Style','popupmenu', 'String',str,'Position',   [290  40 140  20],'BackgroundColor',[1 1 1],'Tag','UIControl');
% set(handles.GUIHandles.SelectObservationsDatabase,'Value',handles.Toolbox(tb).ActiveDatabase);
%  
% handles.GUIHandles.ListObservationStations         = uicontrol(gcf,'Style','listbox','String',handles.Toolbox(tb).ObservationStations.Name,   'Position',   [ 70  30 200 130],'BackgroundColor',[1 1 1],'Tag','UIControl');
% set(handles.GUIHandles.ListObservationStations,'Value',handles.Toolbox(tb).ActiveObservationStation);
%  
% % handles.TextStartTime     = uicontrol(gcf,'Style','text','String','Start Time',         'Position',    [440 136  80 20],'HorizontalAlignment','right','Tag','UIControl');
% % handles.TextStopTime      = uicontrol(gcf,'Style','text','String','Stop Time',          'Position',    [440 111  80 20],'HorizontalAlignment','right','Tag','UIControl');
% % handles.TextTimeStep      = uicontrol(gcf,'Style','text','String','Time Step (min)',    'Position',    [440  86  80 20],'HorizontalAlignment','right','Tag','UIControl');
% % handles.EditStartTime     = uicontrol(gcf,'Style','edit','String',D3DTimeString(handles.Toolbox(tb).StartTime),'Position',[525 140 110 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
% % handles.EditStopTime      = uicontrol(gcf,'Style','edit','String',D3DTimeString(handles.Toolbox(tb).StopTime), 'Position',[525 115 110 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
% % handles.EditTimeStep      = uicontrol(gcf,'Style','edit','String',num2str(handles.Toolbox(tb).TimeStep),       'Position',[525  90 110 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
% % 
% 
% set(handles.GUIHandles.Pushddb_addObservationPoints,  'Callback',{@Pushddb_addObservationPoints_Callback});
% % set(handles.ViewTimeSeries,            'Callback',{@ViewTimeSeries_Callback});
% % set(handles.ExportTimeSeries,          'Callback',{@ExportTimeSeries_Callback});
% % set(handles.ExportAllTimeSeries,       'Callback',{@ExportAllTimeSeries_Callback});
% set(handles.GUIHandles.ListObservationStations,          'Callback',{@ListObservationStations_Callback});
% set(handles.GUIHandles.SelectObservationsDatabase,        'Callback',{@SelectObservationsDatabase_Callback});
% % set(handles.EditStartTime,    'Callback',{@EditStartTime_Callback});
% % set(handles.EditStopTime,     'Callback',{@EditStopTime_Callback});
% % set(handles.EditTimeStep,     'Callback',{@EditTimeStep_Callback});
% % 
% set(gcf,'WindowButtonDownFcn',{@SelectObservationStation});
% 
% SetUIBackgroundColors;
% 
% handles=Refresh(handles);
% 
% setHandles(handles);
% 
% 
% %%
% function Pushddb_addObservationPoints_Callback(hObject,eventdata)
% 
% handles=getHandles;
% 
% xg=handles.Model(md).Input(ad).GridX;
% yg=handles.Model(md).Input(ad).GridY;
% zz=handles.Model(md).Input(ad).DepthZ;
% x=handles.Toolbox(tb).ObservationStations.xy(:,1);
% y=handles.Toolbox(tb).ObservationStations.xy(:,2);
% 
% [m,n,iindex]=ddb_findStations(x,y,xg,yg,zz);
% 
% nobs=handles.Model(md).Input(ad).NrObservationPoints;
% Names{1}='';
% for k=1:nobs
%     Names{k}=handles.Model(md).Input(ad).ObservationPoints(k).Name;
% end
% for i=1:length(m)
%     ii=iindex(i);
%     if isempty(strmatch(handles.Toolbox(tb).ObservationStations.Name{ii},Names,'exact'))
%         nobs=nobs+1;
%         handles.Model(md).Input(ad).ObservationPoints(nobs).M=m(i);
%         handles.Model(md).Input(ad).ObservationPoints(nobs).N=n(i);
%         handles.Model(md).Input(ad).ObservationPoints(nobs).x=x(ii);
%         handles.Model(md).Input(ad).ObservationPoints(nobs).y=y(ii);
%         leng=min(length(handles.Toolbox(tb).ObservationStations.Name{ii}),20);
%         handles.Model(md).Input(ad).ObservationPoints(nobs).Name=handles.Toolbox(tb).ObservationStations.Name{ii}(1:leng);
%     end
% end
% 
% handles.Model(md).Input(ad).NrObservationPoints=nobs;
% 
% if handles.Model(md).Input(ad).NrObservationPoints>0
%     ddb_plotFlowAttributes(handles,'ObservationPoints','plot',ad);
% end
% setHandles(handles);
% 
% %%
% function SelectObservationStation(imagefig, varargins)
% h=gco;
% if strcmp(get(h,'Tag'),'ObservationStations')  
%     handles=getHandles;
%     pos = get(gca, 'CurrentPoint');
%     posx=pos(1,1);
%     posy=pos(1,2);
%     dxsq=(handles.Toolbox(tb).ObservationStations.xy(:,1)-posx).^2;
%     dysq=(handles.Toolbox(tb).ObservationStations.xy(:,2)-posy).^2;
%     dist=(dxsq+dysq).^0.5;
%     [y,n]=min(dist);
%     h0=findall(gcf,'Tag','ActiveObservationStation');
%     delete(h0);
%     plt=plot3(handles.Toolbox(tb).ObservationStations.xy(n,1),handles.Toolbox(tb).ObservationStations.xy(n,2),1000,'o');
%     set(plt,'MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','r','Tag','ActiveObservationStation');
%     set(handles.GUIHandles.ListObservationStations,'Value',n);
%     handles.Toolbox(tb).ActiveObservationStation=n;
%     handles=Refresh(handles);
%     setHandles(handles);
% end
% 
% %%
% function SelectObservationsDatabase_Callback(hObject,eventdata)
% 
% handles=getHandles;
% str=handles.Toolbox(tb).ActiveDatabase;
% strs=handles.Toolbox(tb).Databases;
% ii=get(hObject,'Value');
% if ~strcmpi(strs{ii},str)
%     handles.Toolbox(tb).ActiveDatabase=ii;
%     handles=ChangeObservationsDatabase(handles);
%     handles.Toolbox(tb).NrStations=length(handles.Toolbox(tb).ObservationStations);
%     set(handles.GUIHandles.ListObservationStations,'String',handles.Toolbox(tb).ObservationStations.Name);
%     set(handles.GUIHandles.ListObservationStations,'Value',1);
%     PlotObservationStations(handles);
%     handles=Refresh(handles);
%     setHandles(handles);
% end
% 
% %%
% function ListObservationStations_Callback(hObject,eventdata)
% 
% handles=getHandles;
% ii=get(hObject,'Value');
% h0=findall(gcf,'Tag','ActiveObservationStation');
% delete(h0);
% plt=plot3(handles.Toolbox(tb).ObservationStations.xy(ii,1),handles.Toolbox(tb).ObservationStations.xy(ii,2),1000,'o');
% set(plt,'MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','r','Tag','ActiveObservationStation');
% handles.Toolbox(tb).ActiveObservationStation=ii;
% handles=Refresh(handles);
% setHandles(handles);
% 
% %%
% function handles=ChangeObservationsDatabase(handles)
% 
% s=handles.Toolbox(tb).Database{handles.Toolbox(tb).ActiveDatabase};
% handles.Toolbox(tb).ObservationStations=s;
% x=handles.Toolbox(tb).ObservationStations.x;
% y=handles.Toolbox(tb).ObservationStations.y;
% cs.Name=s.CoordinateSystem;
% cs.Type=s.CoordinateSystemType;
% [x,y]=ddb_coordConvert(x,y,cs,handles.ScreenParameters.CoordinateSystem);
% handles.Toolbox(tb).ObservationStations.xy=[x y];
% handles.Toolbox(tb).ActiveObservationStation=1;
% 
% %%
% function PlotObservationStations(handles)
% 
% h=findall(gca,'Tag','ObservationStations');
% delete(h);
% h=findall(gca,'Tag','ActiveObservationStation');
% delete(h);
% 
% x=handles.Toolbox(tb).ObservationStations.xy(:,1);
% y=handles.Toolbox(tb).ObservationStations.xy(:,2);
% z=zeros(size(x))+500;
% plt=plot3(x,y,z,'o');hold on;
% set(plt,'MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','y');
% set(plt,'Tag','ObservationStations');
% set(plt,'ButtonDownFcn',{@SelectObservationStation});
% 
% n=handles.Toolbox(tb).ActiveObservationStation;
% plt=plot3(handles.Toolbox(tb).ObservationStations.xy(n,1),handles.Toolbox(tb).ObservationStations.xy(n,2),1000,'o');
% set(plt,'MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','r','Tag','ActiveObservationStation');
% 
% %%
% function handles=Refresh(handles)
% 
% ii=handles.Toolbox(tb).ActiveObservationStation;
% 
% parameters=handles.Toolbox(tb).ObservationStations.Parameters(ii).Name;
% status=handles.Toolbox(tb).ObservationStations.Parameters(ii).Status;
% 
% np=length(parameters);
% 
% try
%     delete(handles.Toolbox(tb).radioHandles);
% end
% 
% handles.Toolbox(tb).radioHandles=[];
% 
% xp=450;
% yp=120;
% for ip=1:np
%     par=parameters{ip};
%     handles.Toolbox(tb).radioHandles(ip)=uicontrol(gcf,'Style','radiobutton','String',par,'Value',0,'Position',[xp yp 100  20],'Enable','on','Tag','UIControl','UserData',i);
%     if status(ip)>0
%         set(handles.Toolbox(tb).radioHandles(ip),'Enable','on');
%     else
%         set(handles.Toolbox(tb).radioHandles(ip),'Enable','off');
%     end
%     yp=yp-20;
%     if yp<40
%         yp=120;
%         xp=xp+100;
%     end
% end
% 
% if np>0
%     for ip=1:np
%         if status(ip)>0
%             set(handles.Toolbox(tb).radioHandles(ip),'Value',1);
%             break;
%         end
%     end
% end
% 
% % %%
% % function EditStartTime_Callback(hObject,eventdata)
% % handles=getHandles;
% % handles.Toolbox(tb).StartTime=D3DTimeString(get(hObject,'String'));
% % setHandles(handles);
% % 
% % %%
% % function EditStopTime_Callback(hObject,eventdata)
% % handles=getHandles;
% % handles.Toolbox(tb).StopTime=D3DTimeString(get(hObject,'String'));
% % setHandles(handles);
% % 
% % %%
% % function EditTimeStep_Callback(hObject,eventdata)
% % handles=getHandles;
% % handles.Toolbox(tb).TimeStep=str2num(get(hObject,'String'));
% % setHandles(handles);
% % 
% % %%
% % function ViewTimeSeries_Callback(hObject,eventdata)
% % handles=getHandles;
% % ii=get(handles.ListObservationStations,'Value');
% % cmp=handles.ObservationStations.ComponentSet(handles.ActiveObservationStation);
% % for i=1:length(cmp.Component)
% %     comp{i}=cmp.Component{i};
% %     A(i,1)=cmp.Amplitude(i);
% %     G(i,1)=cmp.Phase(i);
% % end
% % t0=handles.Toolbox(tb).StartTime;
% % t1=handles.Toolbox(tb).StopTime;
% % dt=handles.Toolbox(tb).TimeStep/60;
% % t1=t1+dt/24;
% % [prediction,times]=delftPredict2007(comp,A,G,t0,t1,dt);
% % ddb_plotTimeSeries(times(1:end-1),prediction(1:end-1),handles.ObservationStations.Name{handles.ActiveObservationStation});
% % 
% % %%
% % function ExportTimeSeries_Callback(hObject,eventdata)
% % handles=getHandles;
% % cmp=handles.ObservationStations.ComponentSet(handles.ActiveObservationStation);
% % for i=1:length(cmp.Component)
% %     comp{i}=cmp.Component{i};
% %     A(i,1)=cmp.Amplitude(i);
% %     G(i,1)=cmp.Phase(i);
% % end
% % t0=handles.Toolbox(tb).StartTime;
% % t1=handles.Toolbox(tb).StopTime;
% % dt=handles.Toolbox(tb).TimeStep/60;
% % t1=t1+dt/24;
% % [prediction,times]=delftPredict2007(comp,A,G,t0,t1,dt);
% % blname=deblank(handles.ObservationStations.Name{handles.ActiveObservationStation});
% % fname=blname;
% % fname=strrep(fname,' ','');
% % fname=strrep(fname,',','');
% % fname=[fname(1,:) '.tek'];
% % 
% % ExportTek(prediction(1:end-1),times(1:end-1),fname,blname);
% % 
% % %%
% % function ExportAllTimeSeries_Callback(hObject,eventdata)
% % handles=getHandles;
% % if handles.Model(md).Input(ad).NrObservationPoints>0
% %     ExportObservationsSignalAllStations(handles);
% % end

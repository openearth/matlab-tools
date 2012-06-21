function ddb_Delft3DWAVE_timeframe(varargin)

if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
    % setUIElements('delft3dwave.timeframe');
else
    opt=varargin{1};
    switch lower(opt)
        case{'selectgrid'}
            selectGrid;
        case{'selectenclosure'}
            selectEnclosure;
        case{'generatelayers'}
            generateLayers;
        case{'editkmax'}
            editKMax;
        case{'changelayers'}
            changeLayers;
        case{'loadlayers'}
            loadLayers;
        case{'savelayers'}
            saveLayers;
    end
end

%{
ddb_refreshScreen('Time Frame');
handles=getHandles;

hp = uipanel('Title','Time Frame','Units','pixels','Position',[20 20 990 160],'Tag','UIControl');

handles.GUIHandles.TextWaterlevelCor      = uicontrol(gcf,'Style','text','String','Water level correction : ','Position',[40 140 140 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditWaterlevelCor      = uicontrol(gcf,'Style','edit', 'Position',[160 140 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextWaterlevelCorUnit  = uicontrol(gcf,'Style','text','String','[m]','Position',[220 140 30 15],'HorizontalAlignment','left','Tag','UIControl');

set(handles.GUIHandles.EditWaterlevelCor,'Max',1);
set(handles.GUIHandles.EditWaterlevelCor,'String',handles.Model(md).Input.WaterlevelCor);
set(handles.GUIHandles.EditWaterlevelCor,'CallBack',{@EditWaterlevelCor_CallBack});

setHandles(handles);

hp = uipanel('Title','Time points for WAVE computation','Units','pixels','Position',[40 40 445 90],'Tag','UIControl');

handles.GUIHandles.EditTimepoints  = uicontrol(gcf,'Style','listbox','Position',[45 45 175 70],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.GUIHandles.EditTimepoints,'Max',50);
set(handles.GUIHandles.EditTimepoints,'CallBack',{@EditTimepoints_CallBack});

handles.GUIHandles.PushAdd      = uicontrol(gcf,'Style','pushbutton',  'String','Add','Position',[230 95 70 20],'Tag','UIControl');
set(handles.GUIHandles.PushAdd,'Enable','on');
set(handles.GUIHandles.PushAdd,'CallBack',{@PushAdd_CallBack});

handles.GUIHandles.PushDelete   = uicontrol(gcf,'Style','pushbutton',  'String','Delete','Position',[230 70 70 20],'Tag','UIControl');
set(handles.GUIHandles.PushDelete,'Enable','off');
set(handles.GUIHandles.PushDelete,'CallBack',{@PushDelete_CallBack});

handles.GUIHandles.FlowTimePoints   = uicontrol(gcf,'Style','text',  'String','Flow Times :','Position',[230 95 70 20],'Tag','UIControl');
set(handles.GUIHandles.FlowTimePoints,'visible','off');
set(handles.GUIHandles.FlowTimePoints,'CallBack',{@FlowTimePoints_CallBack});

handles.GUIHandles.EditFlowTimepoints  = uicontrol(gcf,'Style','listbox','Position',[305 45 175 70],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.GUIHandles.EditFlowTimepoints,'Max',50);
set(handles.GUIHandles.EditFlowTimepoints,'visible','off');
% set(handles.GUIHandles.EditFlowTimepoints,'String',D3DTimeString(handles.Model(md).Input.AvailableFlowTimes,31));
set(handles.GUIHandles.EditFlowTimepoints,'CallBack',{@EditFlowTimepoints_CallBack});

setHandles(handles);

hp = uipanel('Title','Default hydrodynamic data for selected time period','Units','pixels','Position',[490 40 500 100],'Tag','UIControl');

handles.GUIHandles.TextTime        = uicontrol(gcf,'Style','text','String','Time : ','Position',[500 105 60 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditTime        = uicontrol(gcf,'Style','edit', 'Position',[570 105 105 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextTimeUnit    = uicontrol(gcf,'Style','text','String','[yyyy-mm-dd hh:mm:ss]','Position',[680 105 150 15],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIHandles.TextWaterLevel       = uicontrol(gcf,'Style','text','String','Water level : ','Position',[500 85 60 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditWaterLevel       = uicontrol(gcf,'Style','edit', 'Position',[570 85 40 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextWaterLevelUnit   = uicontrol(gcf,'Style','text','String','[m]','Position',[620 85 150 15],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIHandles.TextXvelocity        = uicontrol(gcf,'Style','text','String','X-velocity : ','Position',[500 65 60 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditXvelocity        = uicontrol(gcf,'Style','edit', 'Position',[570 65 40 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextXvelocityUnit    = uicontrol(gcf,'Style','text','String','[m/s]','Position',[620 65 150 15],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIHandles.TextYvelocity        = uicontrol(gcf,'Style','text','String','Y-velocity : ','Position',[500 45 60 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditYvelocity        = uicontrol(gcf,'Style','edit', 'Position',[570 45 40 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextYvelocityUnit    = uicontrol(gcf,'Style','text','String','[m/s]','Position',[620 45 150 15],'HorizontalAlignment','left','Tag','UIControl');

set(handles.GUIHandles.EditTime,'Max',1);
set(handles.GUIHandles.EditTime,'String',handles.Model(md).Input.Time{:});
set(handles.GUIHandles.EditTime,'CallBack',{@EditTime_CallBack});

set(handles.GUIHandles.EditWaterLevel,'Max',1);
set(handles.GUIHandles.EditWaterLevel,'String',handles.Model(md).Input.WaterLevel{:});
set(handles.GUIHandles.EditWaterLevel,'CallBack',{@EditWaterLevel_CallBack});

set(handles.GUIHandles.EditXvelocity,'Max',1);
set(handles.GUIHandles.EditXvelocity,'String',handles.Model(md).Input.Xvelocity{:});
set(handles.GUIHandles.EditXvelocity,'CallBack',{@EditXvelocity_CallBack});

set(handles.GUIHandles.EditYvelocity,'Max',1);
set(handles.GUIHandles.EditYvelocity,'String',handles.Model(md).Input.Yvelocity{:});
set(handles.GUIHandles.EditYvelocity,'CallBack',{@EditYvelocity_CallBack});

setHandles(handles);

Refresh(handles);

%%
function EditWaterlevelCor_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.WaterlevelCor=get(hObject,'String');
setHandles(handles);

function EditTimepoints_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.TimepointsIval=get(hObject,'value');
setHandles(handles);
Refresh(handles);

function PushAdd_CallBack(hObject,eventdata)
handles=getHandles;
if isempty(handles.Model(md).Input.Timepoints{:})
    handles.Model(md).Input.TimepointsIval = 1;
else
    handles.Model(md).Input.TimepointsIval=size(handles.Model(md).Input.Timepoints,2)+1;
end
handles.Model(md).Input.Time{handles.Model(md).Input.TimepointsIval}=cellstr(handles.Model(md).Input.TimeTemp);
handles.Model(md).Input.Timepoints{handles.Model(md).Input.TimepointsIval}=cellstr(handles.Model(md).Input.TimeTemp);
handles.Model(md).Input.WaterLevel{handles.Model(md).Input.TimepointsIval}=cellstr(handles.Model(md).Input.WaterLevelTemp);
handles.Model(md).Input.Xvelocity{handles.Model(md).Input.TimepointsIval}=cellstr(handles.Model(md).Input.XvelocityTemp);
handles.Model(md).Input.Yvelocity{handles.Model(md).Input.TimepointsIval}=cellstr(handles.Model(md).Input.YvelocityTemp);
set(handles.GUIHandles.PushDelete,'Enable','on');
setHandles(handles);
Refresh(handles);

function PushDelete_CallBack(hObject,eventdata)
handles=getHandles;
if size(handles.Model(md).Input.Timepoints,2)==1
    handles.Model(md).Input.Timepoints={''};
    handles.Model(md).Input.Time={''};
    handles.Model(md).Input.WaterLevel={''};
    handles.Model(md).Input.Xvelocity={''};
    handles.Model(md).Input.Yvelocity={''};
    handles.Model(md).Input.TimepointsIval = '';
else
    id = find([1:size(handles.Model(md).Input.Timepoints,2)]~=handles.Model(md).Input.TimepointsIval);
    handles.Model(md).Input.Timepoints=handles.Model(md).Input.Timepoints(id);
    handles.Model(md).Input.Time=handles.Model(md).Input.Time(id);
    handles.Model(md).Input.WaterLevel=handles.Model(md).Input.WaterLevel(id);
    handles.Model(md).Input.Xvelocity=handles.Model(md).Input.Xvelocity(id);
    handles.Model(md).Input.Yvelocity=handles.Model(md).Input.Yvelocity(id);
    handles.Model(md).Input.TimepointsIval = 1;
end
setHandles(handles);
Refresh(handles);
%}

function EditFlowTimepoints_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.AvailableFlowTimes=get(hObject,'String');
iAFT=get(hObject,'Value');
iTP=size(handles.Model(md).Input.Timepoints,1);
handles.Model(md).Input.Timepoints(iTP+1)=handles.Model(md).Input.AvailableFlowTimes(iAFT,:);
set(handles.GUIHandles.PushDelete,'Enable','on');
setHandles(handles);
Refresh(handles);

function EditTime_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.TimeTemp=get(hObject,'String');
setHandles(handles);

function EditWaterLevel_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.WaterLevelTemp=get(hObject,'String');
setHandles(handles);

function EditXvelocity_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.XvelocityTemp=get(hObject,'String');
setHandles(handles);

function EditYvelocity_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.YvelocityTemp=get(hObject,'String');
setHandles(handles);

%%
function Refresh(handles)
handles=getHandles;
if ~isempty(handles.Model(strcmp('Delft3DWAVE',{handles.Model.name})).Input.MDFFile)
    set(handles.GUIHandles.PushAdd,'visible','off');
    set(handles.GUIHandles.FlowTimePoints,'visible','on');
    set(handles.GUIHandles.EditFlowTimepoints,'visible','on');
elseif ~isempty(handles.Model(md).Input.TimepointsIval)
    set(handles.GUIHandles.EditTimepoints,'String',[handles.Model(md).Input.Timepoints{:}]');
    set(handles.GUIHandles.EditTime,'String',handles.Model(md).Input.Time{handles.Model(md).Input.TimepointsIval});
    set(handles.GUIHandles.EditWaterLevel,'String',handles.Model(md).Input.WaterLevel{handles.Model(md).Input.TimepointsIval});
    set(handles.GUIHandles.EditXvelocity,'String',handles.Model(md).Input.Xvelocity{handles.Model(md).Input.TimepointsIval});
    set(handles.GUIHandles.EditYvelocity,'String',handles.Model(md).Input.Yvelocity{handles.Model(md).Input.TimepointsIval});
    set(handles.GUIHandles.EditTimepoints,'value',handles.Model(md).Input.TimepointsIval);
    set(handles.GUIHandles.PushDelete,'Enable','on');
else
    set(handles.GUIHandles.EditTimepoints,'String','');
    set(handles.GUIHandles.EditTime,'String','');
    set(handles.GUIHandles.EditWaterLevel,'String','');
    set(handles.GUIHandles.EditXvelocity,'String','');
    set(handles.GUIHandles.EditYvelocity,'String','');
    set(handles.GUIHandles.PushDelete,'Enable','off');
end
setHandles(handles);




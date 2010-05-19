function ddb_editD3DFlowProcesses

ddb_refreshScreen('Processes');
handles=getHandles;

uipanel('Title','Constituents','Units','pixels','Position',[50 20 210 150],'Tag','UIControl');
handles.GUIHandles.ToggleSalinity     = uicontrol(gcf,'Style','checkbox', 'String','Salinity','Position',[60 130 130 20],'Tag','UIControl');
handles.GUIHandles.ToggleTemperature  = uicontrol(gcf,'Style','checkbox', 'String','Temperature','Position',[60 105 130 20],'Tag','UIControl');
handles.GUIHandles.TogglePollutants   = uicontrol(gcf,'Style','checkbox', 'String','Pollutants and Tracers','Position',[60 80 130 20],'Tag','UIControl');
handles.GUIHandles.ToggleSediments    = uicontrol(gcf,'Style','checkbox', 'String','Sediments','Position',[60 55 130 20],'Tag','UIControl');
handles.GUIHandles.PushEditPollutants = uicontrol(gcf,'Style','pushbutton',  'String','Edit','Position',[200 80 50 20],'Tag','UIControl');
handles.GUIHandles.PushEditSediments  = uicontrol(gcf,'Style','pushbutton',  'String','Edit','Position',[200 55 50 20],'Tag','UIControl');

uipanel('Title','Physical','Units','pixels','Position',[280 20 300 150],'Tag','UIControl');
handles.GUIHandles.ToggleWind = uicontrol(gcf,'Style','checkbox', 'String','Wind','Position',[290 130 130 20],'Tag','UIControl');
handles.GUIHandles.ToggleWaves = uicontrol(gcf,'Style','checkbox', 'String','Waves','Position',[290 105 130 20],'Tag','UIControl');
handles.GUIHandles.ToggleOnlineWave = uicontrol(gcf,'Style','checkbox', 'String','Online Delft3D-Wave','Position',[290 80 130 20],'Tag','UIControl');
handles.GUIHandles.ToggleRoller = uicontrol(gcf,'Style','checkbox', 'String','Roller Model','Position',[290 55 130 20],'Tag','UIControl');
handles.GUIHandles.ToggleSecondaryFlow = uicontrol(gcf,'Style','checkbox', 'String','Secondary Flow','Position',[430 130 140 20],'Tag','UIControl');
handles.GUIHandles.ToggleTidalForces = uicontrol(gcf,'Style','checkbox', 'String','Tide-generating Forces','Position',[430 105 140 20],'Tag','UIControl');
if strcmpi(handles.ScreenParameters.CoordinateSystem.Type,'Geographic')
    set(handles.GUIHandles.ToggleTidalForces,'Visible','on');
else
    set(handles.GUIHandles.ToggleTidalForces,'Visible','off');
end
uipanel('Title','Man-made','Units','pixels','Position',[600 20 210 150],'Tag','UIControl');
handles.GUIHandles.ToggleDredging = uicontrol(gcf,'Style','checkbox', 'String','Dredging and Dumping','Position',[610 130 160 20],'Tag','UIControl');

if handles.Model(md).Input(ad).Salinity.Include
    set(handles.GUIHandles.ToggleSalinity,'Value',1);
end
if handles.Model(md).Input(ad).Temperature.Include
    set(handles.GUIHandles.ToggleTemperature,'Value',1);
end
if handles.Model(md).Input(ad).Tracers
    set(handles.GUIHandles.TogglePollutants,'Value',1);
    set(handles.GUIHandles.PushEditPollutants,'Enable','on');
else
    set(handles.GUIHandles.PushEditPollutants,'Enable','off');
end
if handles.Model(md).Input(ad).Sediments
    set(handles.GUIHandles.ToggleSediments,'Value',1);
    set(handles.GUIHandles.PushEditSediments,'Enable','on');
else
    set(handles.GUIHandles.PushEditSediments,'Enable','off');
end

if handles.Model(md).Input(ad).Wind
    set(handles.GUIHandles.ToggleWind,'Value',1);
end
if handles.Model(md).Input(ad).Waves
    set(handles.GUIHandles.ToggleWaves,'Value',1);
end
if handles.Model(md).Input(ad).OnlineWave
    set(handles.GUIHandles.ToggleOnlineWave,'Value',1);
end
if handles.Model(md).Input(ad).Roller.Include
    set(handles.GUIHandles.ToggleRoller,'Value',1);
end
if handles.Model(md).Input(ad).SecondaryFlow
    set(handles.GUIHandles.ToggleSecondaryFlow,'Value',1);
end
if handles.Model(md).Input(ad).TidalForces
    set(handles.GUIHandles.ToggleTidalForces,'Value',1);
end
if handles.Model(md).Input(ad).Dredging
    set(handles.GUIHandles.ToggleDredging,'Value',1);
end

set(handles.GUIHandles.ToggleSalinity,    'Callback',{@ToggleSalinity_Callback});
set(handles.GUIHandles.ToggleTemperature, 'Callback',{@ToggleTemperature_Callback});
set(handles.GUIHandles.TogglePollutants,  'Callback',{@TogglePollutants_Callback});
set(handles.GUIHandles.ToggleSediments,   'Callback',{@ToggleSediments_Callback});
set(handles.GUIHandles.ToggleWind,        'Callback',{@ToggleWind_Callback});
set(handles.GUIHandles.ToggleWaves,       'Callback',{@ToggleWaves_Callback});
set(handles.GUIHandles.ToggleOnlineWave,  'Callback',{@ToggleOnlineWave_Callback});
set(handles.GUIHandles.ToggleRoller,      'Callback',{@ToggleRoller_Callback});
set(handles.GUIHandles.ToggleSecondaryFlow,'Callback',{@ToggleSecondaryFlow_Callback});
set(handles.GUIHandles.ToggleTidalForces, 'Callback',{@ToggleTidalForces_Callback});
set(handles.GUIHandles.ToggleDredging,    'Callback',{@ToggleDredging_Callback});
set(handles.GUIHandles.PushEditPollutants,'Callback',{@PushEditPollutants_Callback});
set(handles.GUIHandles.PushEditSediments, 'Callback',{@PushEditSediments_Callback});

SetUIBackgroundColors;

setHandles(handles);

%%
function ToggleSalinity_Callback(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).Salinity.Include=get(hObject,'Value');
setHandles(handles);

%%
function ToggleTemperature_Callback(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).Temperature.Include=get(hObject,'Value');
setHandles(handles);

%%
function TogglePollutants_Callback(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).Tracers=get(hObject,'Value');
if handles.Model(md).Input(ad).Tracers
    set(handles.GUIHandles.PushEditPollutants,'Enable','on');
    if handles.Model(md).Input(ad).NrTracers==0
        handles=ddb_editD3DFlowPollutants(handles);
        if handles.Model(md).Input(ad).NrTracers==0
            set(handles.GUIHandles.PushEditPollutants,'Enable','off');
            handles.Model(md).Input(ad).Tracers=0;
            set(hObject,'Value',0);
        end
    end
else
    set(handles.GUIHandles.PushEditPollutants,'Enable','off');
end
setHandles(handles);

%%
function ToggleSediments_Callback(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).Sediments=get(hObject,'Value');
if handles.Model(md).Input(ad).Sediments
    set(handles.GUIHandles.PushEditSediments,'Enable','on');
    if handles.Model(md).Input(ad).NrSediments==0
        handles=ddb_editD3DFlowSediments(handles);
        if handles.Model(md).Input(ad).NrSediments==0
            set(handles.GUIHandles.PushEditSediments,'Enable','off');
            handles.Model(md).Input(ad).Sediments=0;
            set(hObject,'Value',0);
        end
    end
else
    set(handles.GUIHandles.PushEditSediments,'Enable','off');
end
setHandles(handles);

%%
function ToggleWind_Callback(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).Wind=get(hObject,'Value');
setHandles(handles);

%%
function ToggleWaves_Callback(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).Waves=get(hObject,'Value');
setHandles(handles);

%%
function ToggleOnlineWave_Callback(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).OnlineWave=get(hObject,'Value');
setHandles(handles);

%%
function ToggleRoller_Callback(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).Roller.Include=get(hObject,'Value');
setHandles(handles);

%%
function ToggleSecondaryFlow_Callback(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).SecondaryFlow=get(hObject,'Value');
setHandles(handles);

%%
function ToggleTidalForces_Callback(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).TidalForces=get(hObject,'Value');
setHandles(handles);

%%
function ToggleDredging_Callback(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).Dredging=get(hObject,'Value');
setHandles(handles);

%%
function PushEditPollutants_Callback(hObject,eventdata)
handles=getHandles;
handles=ddb_editD3DFlowPollutants(handles);
if handles.Model(md).Input(ad).NrTracers==0
    set(hObject,'Enable','off');
    set(handles.GUIHandles.TogglePollutants,'Value',0);
    handles.Model(md).Input(ad).Tracers=0;
end
setHandles(handles);

%%
function PushEditSediments_Callback(hObject,eventdata)
handles=getHandles;
handles=ddb_editD3DFlowSediments(handles);
if handles.Model(md).Input(ad).NrSediments==0
    set(hObject,'Enable','off');
    set(handles.GUIHandles.ToggleSediments,'Value',0);
    handles.Model(md).Input(ad).Sediments=0;
end
setHandles(handles);





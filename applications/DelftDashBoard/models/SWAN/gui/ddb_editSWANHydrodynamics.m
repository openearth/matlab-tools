function ddb_editSWANHydrodynamics

ddb_refreshScreen('Hydrodynamics');
handles=getHandles;

uipanel('Title','Hydrodynamics','Units','pixels','Position',[20 20 990 160],'Tag','UIControl');

handles.Text = uicontrol(gcf,'Style','text','String','Select hydrodynamics results from FLOW','Position',[40 135  250 20],'HorizontalAlignment','left','Tag','UIControl');

handles.ToggleBathymetry  = uicontrol(gcf,'Style','checkbox', 'String','Bathymetry','Position',[40 120  250 15],'Tag','UIControl');
handles.ToggleWaterLevel  = uicontrol(gcf,'Style','checkbox', 'String','Water level','Position',[40 100  250 15],'Tag','UIControl');
handles.ToggleCurrent     = uicontrol(gcf,'Style','checkbox', 'String','Current','Position',[40 80  250 15],'Tag','UIControl');
handles.ToggleWind        = uicontrol(gcf,'Style','checkbox', 'String','Wind','Position',[40 60  250 15],'Tag','UIControl');
handles.PushEditData      = uicontrol(gcf,'Style','pushbutton',  'String','Select FLOW File','Position',[40 30 100 20],'Tag','UIControl');

set(handles.PushEditData,'Enable','off');

set(handles.ToggleBathymetry,  'Callback',{@ToggleBathymetry_Callback});
set(handles.ToggleWaterLevel,  'Callback',{@ToggleWaterLevel_Callback});
set(handles.ToggleCurrent,     'Callback',{@ToggleCurrent_Callback});
set(handles.ToggleWind,        'Callback',{@ToggleWind_Callback});
set(handles.PushEditData,      'Callback',{@PushEditData_Callback});

SetUIBackgroundColors;

handles=Refresh(handles);

setHandles(handles);

%%
function ToggleBathymetry_Callback(hObject,eventdata)
handles=getHandles;
handles.SWANInput.FlowBedLevel=get(hObject,'Value');
handles=Refresh(handles);
setHandles(handles);

%%
function ToggleWaterLevel_Callback(hObject,eventdata)
handles=getHandles;
handles.SWANInput.FlowWaterLevel=get(hObject,'Value');
handles=Refresh(handles);
setHandles(handles);

%%
function ToggleCurrent_Callback(hObject,eventdata)
handles=getHandles;
handles.SWANInput.FlowVelocity=get(hObject,'Value');
handles=Refresh(handles);
setHandles(handles);

%%
function ToggleWind_Callback(hObject,eventdata)
handles=getHandles;
handles.SWANInput.FlowWind=get(hObject,'Value');
handles=Refresh(handles);
setHandles(handles);

%%
function PushEditData_Callback(hObject,eventdata)
handles=getHandles;
handles=EditData(handles);
setHandles(handles);

%%
function handles=Refresh(handles)
set(handles.PushEditData,'Enable','off');
if handles.SWANInput.FlowBedLevel
    set(handles.ToggleBathymetry,'Value',1);
    set(handles.PushEditData,'Enable','on');
end
if handles.SWANInput.FlowWaterLevel
    set(handles.ToggleWaterLevel,'Value',1);
    set(handles.PushEditData,'Enable','on');
end
if handles.SWANInput.FlowVelocity
    set(handles.ToggleCurrent,'Value',1);
    set(handles.PushEditData,'Enable','on');
end
if handles.SWANInput.FlowWind
    set(handles.ToggleWind,'Value',1);
    set(handles.PushEditData,'Enable','on');
end

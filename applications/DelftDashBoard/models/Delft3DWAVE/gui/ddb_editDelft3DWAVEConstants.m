function ddb_editDelft3DWAVEConstants

ddb_refreshScreen('Physical Parameters','Wind');
handles=getHandles;

hp = uipanel('Units','pixels','Position',[35 35 960 100],'Tag','UIControl');

handles.GUIHandles.TextGravity      = uicontrol(gcf,'Style','text','String','Gravity : ','Position',[50 110 110 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditGravity      = uicontrol(gcf,'Style','edit', 'Position',[170 110 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextGravityUnit  = uicontrol(gcf,'Style','text','String','[m/s2]','Position',[230 110 40 15],'HorizontalAlignment','left','Tag','UIControl');
set(handles.GUIHandles.EditGravity,'Max',1);
set(handles.GUIHandles.EditGravity,'String',handles.Model(md).Input.Gravity);
set(handles.GUIHandles.EditGravity,'CallBack',{@EditGravity_CallBack});

handles.GUIHandles.TextWaterdensity        = uicontrol(gcf,'Style','text','String','Water density : ','Position',[50 90 110 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditWaterdensity        = uicontrol(gcf,'Style','edit', 'Position',[170 90 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextWaterdensityUnit    = uicontrol(gcf,'Style','text','String','[kg/m3]','Position',[230 90 40 15],'HorizontalAlignment','left','Tag','UIControl');
set(handles.GUIHandles.EditWaterdensity,'Max',1);
set(handles.GUIHandles.EditWaterdensity,'String',handles.Model(md).Input.Waterdensity);
set(handles.GUIHandles.EditWaterdensity,'CallBack',{@EditWaterdensity_CallBack});

handles.GUIHandles.TextNorthwaxis       = uicontrol(gcf,'Style','text','String','North w.r.t. x-axis : ','Position',[50 70 110 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditNorthwaxis       = uicontrol(gcf,'Style','edit', 'Position',[170 70 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextNorthwaxisUnit   = uicontrol(gcf,'Style','text','String','[deg]','Position',[230 70 40 15],'HorizontalAlignment','left','Tag','UIControl');
set(handles.GUIHandles.EditNorthwaxis,'Max',1);
set(handles.GUIHandles.EditNorthwaxis,'String',handles.Model(md).Input.Northwaxis);
set(handles.GUIHandles.EditNorthwaxis,'CallBack',{@EditNorthwaxis_CallBack});

handles.GUIHandles.TextMindepth       = uicontrol(gcf,'Style','text','String','Minimum depth : ','Position',[50 50 110 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditMindepth       = uicontrol(gcf,'Style','edit', 'Position',[170 50 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextMindepthUnit   = uicontrol(gcf,'Style','text','String','[m]','Position',[230 50 40 15],'HorizontalAlignment','left','Tag','UIControl');
set(handles.GUIHandles.EditMindepth,'Max',1);
set(handles.GUIHandles.EditMindepth,'String',handles.Model(md).Input.Mindepth);
set(handles.GUIHandles.EditMindepth,'CallBack',{@EditMindepth_CallBack});

handles.GUIHandles.TextConventions     = uicontrol(gcf,'Style','text','String','Conventions : ','Position',[300 110 90 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.ToggleNautical      = uicontrol(gcf,'Style','checkbox','String','Nautical','Position',[380 110 90 15],'Tag','UIControl');
handles.GUIHandles.ToggleCartesian     = uicontrol(gcf,'Style','checkbox','String','Cartesian','Position',[380 90 90 15],'Tag','UIControl');
if handles.Model(md).Input.Cartesian
    set(handles.GUIHandles.ToggleNautical,'Value',0);
    set(handles.GUIHandles.ToggleCartesian,'Value',1);
else
    set(handles.GUIHandles.ToggleNautical,'Value',1);
    set(handles.GUIHandles.ToggleCartesian,'Value',0);
end

handles.GUIHandles.TextWavesetup       = uicontrol(gcf,'Style','text','String','Wave set-up : ','Position',[300 60 90 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.ToggleNone          = uicontrol(gcf,'Style','checkbox','String','None','Position',[380 60 90 15],'Tag','UIControl');
handles.GUIHandles.ToggleActivated     = uicontrol(gcf,'Style','checkbox','String','Activated','Position',[380 40 90 15],'Tag','UIControl');
if handles.Model(md).Input.Activated
    set(handles.GUIHandles.ToggleNone,'Value',0);
    set(handles.GUIHandles.ToggleActivated,'Value',1);
else
    set(handles.GUIHandles.ToggleNone,'Value',1);
    set(handles.GUIHandles.ToggleActivated,'Value',0);
end

handles.GUIHandles.TextForces          = uicontrol(gcf,'Style','text','String','Forces : ','Position',[500 110 90 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.ToggleWaveenergy    = uicontrol(gcf,'Style','checkbox','String','Wave energy dissipation rate','Position',[550 110 200 15],'Tag','UIControl');
handles.GUIHandles.ToggleRadiation     = uicontrol(gcf,'Style','checkbox','String','Radiation stress','Position',[550 90 150 15],'Tag','UIControl');
if handles.Model(md).Input.Radiation
    set(handles.GUIHandles.ToggleWaveenergy,'Value',0);
    set(handles.GUIHandles.ToggleRadiation,'Value',1);
else
    set(handles.GUIHandles.ToggleWaveenergy,'Value',1);
    set(handles.GUIHandles.ToggleRadiation,'Value',0);
end

set(handles.GUIHandles.ToggleNautical,   'CallBack',{@ToggleNautical_CallBack});
set(handles.GUIHandles.ToggleCartesian,  'CallBack',{@ToggleCartesian_CallBack});
set(handles.GUIHandles.ToggleNone,       'CallBack',{@ToggleNone_CallBack});
set(handles.GUIHandles.ToggleActivated,  'CallBack',{@ToggleActivated_CallBack});
set(handles.GUIHandles.ToggleWaveenergy, 'CallBack',{@ToggleWaveenergy_CallBack});
set(handles.GUIHandles.ToggleRadiation,  'CallBack',{@ToggleRadiation_CallBack});

setHandles(handles);

%%

function EditGravity_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Gravity=get(hObject,'String');
setHandles(handles);

function EditWaterdensity_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Waterdensity=get(hObject,'String');
setHandles(handles);

function EditNorthwaxis_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Northwaxis=get(hObject,'String');
setHandles(handles);

function EditMindepth_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Mindepth=get(hObject,'String');
setHandles(handles);

function ToggleNautical_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Nautical=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleCartesian,'Value',0);
    handles.Model(md).Input.Cartesian=0;
end
setHandles(handles);

function ToggleCartesian_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Cartesian=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleNautical,'Value',0);
    handles.Model(md).Input.Nautical=0;
end
setHandles(handles);

function ToggleNone_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.None=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleActivated,'Value',0);
    handles.Model(md).Input.Activated=0;
end
setHandles(handles);

function ToggleActivated_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Activated=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleNone,'Value',0);
    handles.Model(md).Input.None=0;
end
setHandles(handles);

function ToggleWaveenergy_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Waveenergy=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleRadiation,'Value',0);
    handles.Model(md).Input.Radiation=0;
end
setHandles(handles);

function ToggleRadiation_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Radiation=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleWaveenergy,'Value',0);
    handles.Model(md).Input.Waveenergy=0;
end
setHandles(handles);







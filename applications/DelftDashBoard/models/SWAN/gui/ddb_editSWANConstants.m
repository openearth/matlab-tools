function EditSwanWind

ddb_refreshScreen('Physical Parameters','Wind');
handles=getHandles;

handles.TextGravity      = uicontrol(gcf,'Style','text','String','Gravity : ','Position',[50 110 110 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditGravity      = uicontrol(gcf,'Style','edit', 'Position',[170 110 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextGravityUnit  = uicontrol(gcf,'Style','text','String','[m/s2]','Position',[230 110 40 15],'HorizontalAlignment','left','Tag','UIControl');
set(handles.EditGravity,'Max',1);
set(handles.EditGravity,'String',handles.SwanInput(handles.ActiveDomain).Gravity);
set(handles.EditGravity,'CallBack',{@EditGravity_CallBack});

handles.TextWaterdensity        = uicontrol(gcf,'Style','text','String','Water density : ','Position',[50 90 110 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditWaterdensity        = uicontrol(gcf,'Style','edit', 'Position',[170 90 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextWaterdensityUnit    = uicontrol(gcf,'Style','text','String','[kg/m3]','Position',[230 90 40 15],'HorizontalAlignment','left','Tag','UIControl');
set(handles.EditWaterdensity,'Max',1);
set(handles.EditWaterdensity,'String',handles.SwanInput(handles.ActiveDomain).Waterdensity);
set(handles.EditWaterdensity,'CallBack',{@EditWaterdensity_CallBack});

handles.TextNorthwaxis       = uicontrol(gcf,'Style','text','String','North w.r.t. x-axis : ','Position',[50 70 110 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditNorthwaxis       = uicontrol(gcf,'Style','edit', 'Position',[170 70 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextNorthwaxisUnit   = uicontrol(gcf,'Style','text','String','[deg]','Position',[230 70 40 15],'HorizontalAlignment','left','Tag','UIControl');
set(handles.EditNorthwaxis,'Max',1);
set(handles.EditNorthwaxis,'String',handles.SwanInput(handles.ActiveDomain).Northwaxis);
set(handles.EditNorthwaxis,'CallBack',{@EditNorthwaxis_CallBack});

handles.TextMindepth       = uicontrol(gcf,'Style','text','String','Minimum depth : ','Position',[50 50 110 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditMindepth       = uicontrol(gcf,'Style','edit', 'Position',[170 50 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextMindepthUnit   = uicontrol(gcf,'Style','text','String','[m]','Position',[230 50 40 15],'HorizontalAlignment','left','Tag','UIControl');
set(handles.EditMindepth,'Max',1);
set(handles.EditMindepth,'String',handles.SwanInput(handles.ActiveDomain).Mindepth);
set(handles.EditMindepth,'CallBack',{@EditMindepth_CallBack});

handles.TextConventions     = uicontrol(gcf,'Style','text','String','Conventions : ','Position',[300 110 90 15],'HorizontalAlignment','left','Tag','UIControl');
handles.ToggleNautical      = uicontrol(gcf,'Style','checkbox','String','Nautical','Position',[380 110 90 15],'Tag','UIControl');
handles.ToggleCartesian     = uicontrol(gcf,'Style','checkbox','String','Cartesian','Position',[380 90 90 15],'Tag','UIControl');
if handles.SwanInput(handles.ActiveDomain).Cartesian
    set(handles.ToggleNautical,'Value',0);
    set(handles.ToggleCartesian,'Value',1);
else
    set(handles.ToggleNautical,'Value',1);
    set(handles.ToggleCartesian,'Value',0);
end

handles.TextWavesetup       = uicontrol(gcf,'Style','text','String','Wave set-up : ','Position',[300 60 90 15],'HorizontalAlignment','left','Tag','UIControl');
handles.ToggleNone          = uicontrol(gcf,'Style','checkbox','String','None','Position',[380 60 90 15],'Tag','UIControl');
handles.ToggleActivated     = uicontrol(gcf,'Style','checkbox','String','Activated','Position',[380 40 90 15],'Tag','UIControl');
if handles.SwanInput(handles.ActiveDomain).Activated
    set(handles.ToggleNone,'Value',0);
    set(handles.ToggleActivated,'Value',1);
else
    set(handles.ToggleNone,'Value',1);
    set(handles.ToggleActivated,'Value',0);
end

handles.TextForces          = uicontrol(gcf,'Style','text','String','Forces : ','Position',[500 110 90 15],'HorizontalAlignment','left','Tag','UIControl');
handles.ToggleWaveenergy    = uicontrol(gcf,'Style','checkbox','String','Wave energy dissipation rate','Position',[550 110 200 15],'Tag','UIControl');
handles.ToggleRadiation     = uicontrol(gcf,'Style','checkbox','String','Radiation stress','Position',[550 90 150 15],'Tag','UIControl');
if handles.SwanInput(handles.ActiveDomain).Radiation
    set(handles.ToggleWaveenergy,'Value',0);
    set(handles.ToggleRadiation,'Value',1);
else
    set(handles.ToggleWaveenergy,'Value',1);
    set(handles.ToggleRadiation,'Value',0);
end

set(handles.ToggleNautical,   'CallBack',{@ToggleNautical_CallBack});
set(handles.ToggleCartesian,  'CallBack',{@ToggleCartesian_CallBack});
set(handles.ToggleNone,       'CallBack',{@ToggleNone_CallBack});
set(handles.ToggleActivated,  'CallBack',{@ToggleActivated_CallBack});
set(handles.ToggleWaveenergy, 'CallBack',{@ToggleWaveenergy_CallBack});
set(handles.ToggleRadiation,  'CallBack',{@ToggleRadiation_CallBack});

setHandles(handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditGravity_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).Gravity=get(hObject,'String');
setHandles(handles);

function EditWaterdensity_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).Waterdensity=get(hObject,'String');
setHandles(handles);

function EditNorthwaxis_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).Northwaxis=get(hObject,'String');
setHandles(handles);

function EditMindepth_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).Mindepth=get(hObject,'String');
setHandles(handles);

function ToggleNautical_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).Nautical=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.ToggleCartesian,'Value',0);
    handles.SwanInput(handles.ActiveDomain).Cartesian=0;
end
setHandles(handles);

function ToggleCartesian_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).Cartesian=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.ToggleNautical,'Value',0);
    handles.SwanInput(handles.ActiveDomain).Nautical=0;
end
setHandles(handles);

function ToggleNone_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).None=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.ToggleActivated,'Value',0);
    handles.SwanInput(handles.ActiveDomain).Activated=0;
end
setHandles(handles);

function ToggleActivated_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).Activated=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.ToggleNone,'Value',0);
    handles.SwanInput(handles.ActiveDomain).None=0;
end
setHandles(handles);

function ToggleWaveenergy_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).Waveenergy=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.ToggleRadiation,'Value',0);
    handles.SwanInput(handles.ActiveDomain).Radiation=0;
end
setHandles(handles);

function ToggleRadiation_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).Radiation=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.ToggleWaveenergy,'Value',0);
    handles.SwanInput(handles.ActiveDomain).Waveenergy=0;
end
setHandles(handles);

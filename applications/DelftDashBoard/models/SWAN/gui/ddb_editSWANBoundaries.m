function EditSwanBoundaries

ddb_refreshScreen('Boundaries');
handles=getHandles;

hp = uipanel('Title','Boundaries','Units','pixels','Position',[20 20 990 160],'Tag','UIControl');

handles.EditBoundaries  = uicontrol(gcf,'Style','edit','Position',[30 30 160 130],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.EditBoundaries,'Max',50);
set(handles.EditBoundaries,'String',handles.SwanInput(handles.ActiveDomain).Boundaries);
set(handles.EditBoundaries,'CallBack',{@EditBoundaries_CallBack});

handles.PushAdd      = uicontrol(gcf,'Style','pushbutton',  'String','Add','Position',[200 110 70 20],'Tag','UIControl');
set(handles.PushAdd,'Enable','on');
set(handles.PushAdd,'CallBack',{@PushAdd_CallBack});

handles.PushDelete   = uicontrol(gcf,'Style','pushbutton',  'String','Delete','Position',[200 80 70 20],'Tag','UIControl');
set(handles.PushDelete,'Enable','off');
set(handles.PushDelete,'CallBack',{@PushDelete_CallBack});

hp = uipanel('Title','Data for selected boundary','Units','pixels','Position',[280 25 350 135],'Tag','UIControl');
 
handles.TextBndName       = uicontrol(gcf,'Style','text','String','Boundary name : ','Position',[290 120 120 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditBndName       = uicontrol(gcf,'Style','edit', 'Position',[420 120 150 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
 
handles.TextBndDefby      = uicontrol(gcf,'Style','text','String','Define boundary by : ','Position',[290 100 120 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditBndDefby      = uicontrol(gcf,'Style','popupmenu','String',' ','Position',[420 100 80 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.TextBndOrient     = uicontrol(gcf,'Style','text','String','Boundary orientation : ','Position',[290 75 120 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditBndOrient     = uicontrol(gcf,'Style','popupmenu','String',' ','Position',[420 75 80 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.TextBndStart      = uicontrol(gcf,'Style','text','String','Boundary start : ','Position',[290 50 80 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditBndStart1     = uicontrol(gcf,'Style','edit', 'Position',[420 50 40 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.EditBndStart2     = uicontrol(gcf,'Style','edit', 'Position',[470 50 40 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextBndStartUnit  = uicontrol(gcf,'Style','text','String','[m]','Position',[520 50 30 15],'HorizontalAlignment','left','Tag','UIControl');

handles.TextBndEnd        = uicontrol(gcf,'Style','text','String','Boundary end : ','Position',[290 30 80 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditBndEnd1       = uicontrol(gcf,'Style','edit', 'Position',[420 30 40 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.EditBndEnd2       = uicontrol(gcf,'Style','edit', 'Position',[470 30 40 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextBndEndUnit    = uicontrol(gcf,'Style','text','String','[m]','Position',[520 30 30 15],'HorizontalAlignment','left','Tag','UIControl');

set(handles.EditBndName,'Max',1);
set(handles.EditBndName,'String',handles.SwanInput(handles.ActiveDomain).BndName);
set(handles.EditBndName,'CallBack',{@EditBndName_CallBack});

set(handles.EditBndDefby,'Max',1);
set(handles.EditBndDefby,'String',handles.SwanInput(handles.ActiveDomain).BndDefby);
set(handles.EditBndDefby,'CallBack',{@EditBndDefby_CallBack});

set(handles.EditBndOrient,'Max',1);
set(handles.EditBndOrient,'String',handles.SwanInput(handles.ActiveDomain).BndOrient);
set(handles.EditBndOrient,'CallBack',{@EditBndOrient_CallBack});

set(handles.EditBndStart1,'Max',1);
set(handles.EditBndStart1,'String',handles.SwanInput(handles.ActiveDomain).BndStart1);
set(handles.EditBndStart1,'CallBack',{@EditBndStart1_CallBack});

set(handles.EditBndStart2,'Max',1);
set(handles.EditBndStart2,'String',handles.SwanInput(handles.ActiveDomain).BndStart2);
set(handles.EditBndStart2,'CallBack',{@EditBndStart2_CallBack});

set(handles.EditBndEnd1,'Max',1);
set(handles.EditBndEnd1,'String',handles.SwanInput(handles.ActiveDomain).BndEnd1);
set(handles.EditBndEnd1,'CallBack',{@EditBndEnd1_CallBack});

set(handles.EditBndEnd2,'Max',1);
set(handles.EditBndEnd2,'String',handles.SwanInput(handles.ActiveDomain).BndEnd2);
set(handles.EditBndEnd2,'CallBack',{@EditBndEnd2_CallBack});

hp = uipanel('Title','Boundary conditions','Units','pixels','Position',[635 25 365 135],'Tag','UIControl');

handles.TextCondBnd            = uicontrol(gcf,'Style','text','String','Conditions along boundary : ','Position',[650 120 140 15],'HorizontalAlignment','left','Tag','UIControl');
handles.ToggleUniform          = uicontrol(gcf,'Style','radiobutton', 'String','Uniform','Position',[800 120 130 15],'Tag','UIControl');
handles.ToggleSpacevarying     = uicontrol(gcf,'Style','radiobutton', 'String','Space-varying','Position',[800 100 130 15],'Tag','UIControl');

handles.TextSpecifSpec         = uicontrol(gcf,'Style','text','String','Specification of spectra : ','Position',[650 80 140 15],'HorizontalAlignment','left','Tag','UIControl');
handles.ToggleParametric       = uicontrol(gcf,'Style','radiobutton', 'String','Parametric','Position',[800 80 130 15],'Tag','UIControl');
handles.ToggleFromFile         = uicontrol(gcf,'Style','radiobutton', 'String','From file','Position',[800 60 130 15],'Tag','UIControl');

handles.PushEditConditions     = uicontrol(gcf,'Style','pushbutton', 'String','Edit conditions','Position',[670 30 130 20],'Tag','UIControl');
handles.PushEditSpectralSpace  = uicontrol(gcf,'Style','pushbutton', 'String','Edit spectral space','Position',[820 30 130 20],'Tag','UIControl');

NoPush1 = 1;
NoPush2 = 1;
if handles.SwanInput(handles.ActiveDomain).Uniform
    set(handles.ToggleUniform,'Value',1);
    set(handles.PushEditConditions,'Enable','on');
    set(handles.PushEditSpectralSpace,'Enable','on');
elseif handles.SwanInput(handles.ActiveDomain).Spacevarying
    set(handles.ToggleSpacevarying,'Value',1);
    set(handles.PushEditConditions,'Enable','on');
    set(handles.PushEditSpectralSpace,'Enable','on');
else
    NoPush1 = 0;
end
if handles.SwanInput(handles.ActiveDomain).Parametric
    set(handles.ToggleParametric,'Value',1);
    set(handles.PushEditConditions,'Enable','on');
    set(handles.PushEditSpectralSpace,'Enable','on');
elseif handles.SwanInput(handles.ActiveDomain).Spacevarying
    set(handles.ToggleFromFile,'Value',1);
    set(handles.PushEditConditions,'Enable','on');
    set(handles.PushEditSpectralSpace,'Enable','on');
else
    NoPush2 = 0;
end
if (NoPush1 == 0 & NoPush2 == 0)
    set(handles.PushEditConditions,'Enable','off');
    set(handles.PushEditSpectralSpace,'Enable','off'); 
end

set(handles.ToggleUniform,        'CallBack',{@ToggleUniform_CallBack});
set(handles.ToggleSpacevarying,   'CallBack',{@ToggleSpacevarying_CallBack});
set(handles.ToggleParametric,     'CallBack',{@ToggleParametric_CallBack});
set(handles.ToggleFromFile,       'CallBack',{@ToggleFromFile_CallBack});
set(handles.PushEditConditions,   'CallBack',{@PushEditConditions_CallBack});
set(handles.PushEditSpectralSpace,'CallBack',{@PushEditSpectralSpace_CallBack});

setHandles(handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditBoundaries_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).Boundaries=get(hObject,'String');
setHandles(handles);

function PushAdd_CallBack(hObject,eventdata)
handles=getHandles;
handles=Add(handles);
setHandles(handles);

function PushDelete_CallBack(hObject,eventdata)
handles=getHandles;
handles=Delete(handles);
setHandles(handles);

function EditBndName_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).BndName=get(hObject,'String');
setHandles(handles);

function EditBndDefby_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).BndDefby=get(hObject,'String');
setHandles(handles);

function EditBndOrient_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).BndOrient=get(hObject,'String');
setHandles(handles);

function EditBndStart1_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).BndStart1=get(hObject,'String');
setHandles(handles);

function EditBndStart2_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).BndStart2=get(hObject,'String');
setHandles(handles);

function EditBndEnd1_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).BndEnd1=get(hObject,'String');
setHandles(handles);

function EditBndEnd2_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).BndEnd2=get(hObject,'String');
setHandles(handles);

function ToggleUniform_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).Uniform=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.ToggleUniform,'Value',1);
    set(handles.ToggleSpacevarying,'Value',0);
    set(handles.PushEditConditions,'Enable','on');
    set(handles.PushEditSpectralSpace,'Enable','on');
    handles.SwanInput(handles.ActiveDomain).Spacevarying=0;
end
setHandles(handles);

function ToggleSpacevarying_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).Spacevarying=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.ToggleUniform,'Value',0);
    set(handles.ToggleSpacevarying,'Value',1);
    set(handles.PushEditConditions,'Enable','on');
    set(handles.PushEditSpectralSpace,'Enable','on');
    handles.SwanInput(handles.ActiveDomain).Uniform=0;
end
setHandles(handles);

function ToggleParametric_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).Parametric=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.ToggleParametric,'Value',1);
    set(handles.ToggleFromFile,'Value',0);
    set(handles.PushEditConditions,'Enable','on');
    set(handles.PushEditSpectralSpace,'Enable','on');
    handles.SwanInput(handles.ActiveDomain).FromFile=0;
end
setHandles(handles);

function ToggleFromFile_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).FromFile=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.ToggleParametric,'Value',0);
    set(handles.ToggleFromFile,'Value',1);
    set(handles.PushEditConditions,'Enable','on');
    set(handles.PushEditSpectralSpace,'Enable','on');
    handles.SwanInput(handles.ActiveDomain).Parametric=0;
end
setHandles(handles);

function PushEditConditions_CallBack(hObject,eventdata)
% handles=getHandles;
EditSwanConditions;
% setHandles(handles);

function PushEditSpectralSpace_CallBack(hObject,eventdata)
% handles=getHandles;
EditSwanSpectralSpace;
% setHandles(handles);


function EditSwanSpectralresolution

ddb_refreshScreen('Grids','Spectral resolution');
handles=getHandles;

hp = uipanel('Title','Directional space','Units','pixels','Position',[355 40 310 80],'Tag','UIControl');

handles.ToggleCircle         = uicontrol(gcf,'Style','radiobutton', 'String','Circle','Position',[365 85 60 15],'Tag','UIControl');
handles.ToggleSector         = uicontrol(gcf,'Style','radiobutton', 'String','Sector','Position',[365 65 60 15],'Tag','UIControl');
handles.TextStartDir         = uicontrol(gcf,'Style','text','string','Start Direction: ','Position',[420 85 75 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditStartDir         = uicontrol(gcf,'Style','edit','Position',[495 85 30 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextStartCounter     = uicontrol(gcf,'Style','text','string','[deg] [couter clockwise]','Position',[535 85 120 15],'HorizontalAlignment','left','Tag','UIControl');
handles.TextEndDir           = uicontrol(gcf,'Style','text','string','End Direction: ','Position',[420 65 75 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditEndDir           = uicontrol(gcf,'Style','edit','Position',[495 65 30 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextEndCounter       = uicontrol(gcf,'Style','text','string','[deg] [couter clockwise]','Position',[535 65 120 15],'HorizontalAlignment','left','Tag','UIControl');
handles.TextNumberDir        = uicontrol(gcf,'Style','text','string','Number of directions: ','Position',[365 45 120 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditNumberDir        = uicontrol(gcf,'Style','edit','Position',[475 45 40 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');

if handles.SwanInput(handles.ActiveDomain).Circle
    set(handles.ToggleCircle,'Value',1);
elseif handles.SwanInput(handles.ActiveDomain).Sector
    set(handles.ToggleSector,'Value',1);
end

set(handles.ToggleCircle, 'CallBack',{@ToggleCircle_CallBack});
set(handles.ToggleSector, 'CallBack',{@ToggleSector_CallBack});

set(handles.EditStartDir,'Max',1);
set(handles.EditStartDir,'String',handles.SwanInput(handles.ActiveDomain).StartDir);
set(handles.EditStartDir,'CallBack',{@EditStartDir_CallBack});

set(handles.EditEndDir,'Max',1);
set(handles.EditEndDir,'String',handles.SwanInput(handles.ActiveDomain).EndDir);
set(handles.EditEndDir,'CallBack',{@EditEndDir_CallBack});

set(handles.EditNumberDir,'Max',1);
set(handles.EditNumberDir,'String',handles.SwanInput(handles.ActiveDomain).NumberDir);
set(handles.EditNumberDir,'CallBack',{@EditNumberDir_CallBack});

hp = uipanel('Title','Frequency space','Units','pixels','Position',[670 40 310 80],'Tag','UIControl');

handles.TextLowFreq          = uicontrol(gcf,'Style','text','string','Lowest frequency: ','Position',[675 85 130 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditLowFreq          = uicontrol(gcf,'Style','edit','Position',[810 85 30 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextHz1              = uicontrol(gcf,'Style','text','string','[Hz]','Position',[845 85 50 15],'HorizontalAlignment','left','Tag','UIControl');
handles.TextHighFreq         = uicontrol(gcf,'Style','text','string','Highest Frequency: ','Position',[675 65 130 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditHighFreq         = uicontrol(gcf,'Style','edit','Position',[810 65 30 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextHz2              = uicontrol(gcf,'Style','text','string','[Hz]','Position',[845 65 50 15],'HorizontalAlignment','left','Tag','UIControl');
handles.TextNumberFreq       = uicontrol(gcf,'Style','text','string','Number of frequency bins: ','Position',[675 45 130 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditNumberFreq       = uicontrol(gcf,'Style','edit','Position',[810 45 30 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');

set(handles.EditLowFreq,'Max',1);
set(handles.EditLowFreq,'String',handles.SwanInput(handles.ActiveDomain).LowFreq);
set(handles.EditLowFreq,'CallBack',{@EditLowFreq_CallBack});

set(handles.EditHighFreq,'Max',1);
set(handles.EditHighFreq,'String',handles.SwanInput(handles.ActiveDomain).HighFreq);
set(handles.EditHighFreq,'CallBack',{@EditHighFreq_CallBack});

set(handles.EditNumberFreq,'Max',1);
set(handles.EditNumberFreq,'String',handles.SwanInput(handles.ActiveDomain).NumberFreq);
set(handles.EditNumberFreq,'CallBack',{@EditNumberFreq_CallBack});

setHandles(handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ToggleCircle_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).Circle=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.ToggleCircle,'Value',1);
    set(handles.ToggleSector,'Value',0);
    handles.SwanInput(handles.ActiveDomain).Sector=0;
end
setHandles(handles);

function ToggleSector_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).Sector=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.ToggleCircle,'Value',0);
    set(handles.ToggleSector,'Value',1);
    handles.SwanInput(handles.ActiveDomain).Circle=0;
end
setHandles(handles);

function EditStartDir_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).StartDir=get(hObject,'String');
setHandles(handles);

function EditEndDir_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).EndDir=get(hObject,'String');
setHandles(handles);

function EditNumberDir_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).NumberDir=get(hObject,'String');
setHandles(handles);

function EditLowFreq_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).LowFreq=get(hObject,'String');
setHandles(handles);

function EditHighFreq_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).HighFreq=get(hObject,'String');
setHandles(handles);

function EditNumberFreq_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).NumberFreq=get(hObject,'String');
setHandles(handles);


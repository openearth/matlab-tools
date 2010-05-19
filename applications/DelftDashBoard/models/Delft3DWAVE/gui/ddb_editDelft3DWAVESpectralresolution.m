function ddb_editDelft3DWAVESpectralresolution

ddb_refreshScreen('Grids','Spectral resolution');
handles=getHandles;

id=handles.Model(md).Input.ActiveDomain;

hp = uipanel('Title','Grids','Units','pixels','Position',[20 20 990 160],'Tag','UIControl');

handles.GUIHandles.TextComputationalGrids = uicontrol(gcf,'Style','text','string','Computational grids :','Position',[40 145 100 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditComputationalGrids = uicontrol(gcf,'Style','listbox','Position',[40 90 200 50],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.GUIHandles.EditComputationalGrids,'Max',3);
set(handles.GUIHandles.EditComputationalGrids,'String',handles.Model(md).Input.ComputationalGrids,'Value',id);
set(handles.GUIHandles.EditComputationalGrids,'CallBack',{@EditComputationalGrids_CallBack});

handles.GUIHandles.PushAdd      = uicontrol(gcf,'Style','pushbutton',  'String','Add','Position',[250 120 70 20],'Tag','UIControl');
set(handles.GUIHandles.PushAdd,'Enable','off');

handles.GUIHandles.PushDelete   = uicontrol(gcf,'Style','pushbutton',  'String','Delete','Position',[250 90 70 20],'Tag','UIControl');
set(handles.GUIHandles.PushDelete,'Enable','off');

handles.GUIHandles.TextCoordinateSystem = uicontrol(gcf,'Style','text','string',['Co-ordinate System : '],'Position',[40 70 150 15],'HorizontalAlignment','left','Tag','UIControl');

setHandles(handles);

hp = uipanel('Title','Grid data','Units','pixels','Position',[340 25 655 140],'Tag','UIControl');

hp = uipanel('Title','Directional space','Units','pixels','Position',[355 40 310 80],'Tag','UIControl');

handles.GUIHandles.ToggleCircle         = uicontrol(gcf,'Style','radiobutton', 'String','Circle','Position',[365 85 60 15],'Tag','UIControl');
handles.GUIHandles.ToggleSector         = uicontrol(gcf,'Style','radiobutton', 'String','Sector','Position',[365 65 60 15],'Tag','UIControl');
handles.GUIHandles.TextStartDir         = uicontrol(gcf,'Style','text','string','Start Direction: ','Position',[420 85 75 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditStartDir         = uicontrol(gcf,'Style','edit','Position',[495 85 30 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextStartCounter     = uicontrol(gcf,'Style','text','string','[deg] [couter clockwise]','Position',[535 85 120 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextEndDir           = uicontrol(gcf,'Style','text','string','End Direction: ','Position',[420 65 75 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditEndDir           = uicontrol(gcf,'Style','edit','Position',[495 65 30 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextEndCounter       = uicontrol(gcf,'Style','text','string','[deg] [couter clockwise]','Position',[535 65 120 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextNumberDir        = uicontrol(gcf,'Style','text','string','Number of directions: ','Position',[365 45 120 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditNumberDir        = uicontrol(gcf,'Style','edit','Position',[475 45 40 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');

if handles.Model(md).Input.Domain(id).Circle
    set(handles.GUIHandles.ToggleCircle,'Value',1);
    set(handles.GUIHandles.TextStartDir,'enable','off');
    set(handles.GUIHandles.EditStartDir,'enable','off');
    set(handles.GUIHandles.TextEndDir,'enable','off');
    set(handles.GUIHandles.EditEndDir,'enable','off');    
elseif handles.Model(md).Input.Domain(id).Sector
    set(handles.GUIHandles.ToggleSector,'Value',1);
    set(handles.GUIHandles.TextStartDir,'enable','on');
    set(handles.GUIHandles.EditStartDir,'enable','on');
    set(handles.GUIHandles.TextEndDir,'enable','on');
    set(handles.GUIHandles.EditEndDir,'enable','on');    
end

set(handles.GUIHandles.ToggleCircle, 'CallBack',{@ToggleCircle_CallBack});
set(handles.GUIHandles.ToggleSector, 'CallBack',{@ToggleSector_CallBack});

set(handles.GUIHandles.EditStartDir,'Max',1);
set(handles.GUIHandles.EditStartDir,'String',handles.Model(md).Input.Domain(id).StartDir);
set(handles.GUIHandles.EditStartDir,'CallBack',{@EditStartDir_CallBack});

set(handles.GUIHandles.EditEndDir,'Max',1);
set(handles.GUIHandles.EditEndDir,'String',handles.Model(md).Input.Domain(id).EndDir);
set(handles.GUIHandles.EditEndDir,'CallBack',{@EditEndDir_CallBack});

set(handles.GUIHandles.EditNumberDir,'Max',1);
set(handles.GUIHandles.EditNumberDir,'String',handles.Model(md).Input.Domain(id).NumberDir);
set(handles.GUIHandles.EditNumberDir,'CallBack',{@EditNumberDir_CallBack});

setHandles(handles);

hp = uipanel('Title','Frequency space','Units','pixels','Position',[670 40 310 80],'Tag','UIControl');

handles.GUIHandles.TextLowFreq          = uicontrol(gcf,'Style','text','string','Lowest frequency: ','Position',[675 85 130 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditLowFreq          = uicontrol(gcf,'Style','edit','Position',[810 85 30 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextHz1              = uicontrol(gcf,'Style','text','string','[Hz]','Position',[845 85 50 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextHighFreq         = uicontrol(gcf,'Style','text','string','Highest Frequency: ','Position',[675 65 130 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditHighFreq         = uicontrol(gcf,'Style','edit','Position',[810 65 30 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextHz2              = uicontrol(gcf,'Style','text','string','[Hz]','Position',[845 65 50 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextNumberFreq       = uicontrol(gcf,'Style','text','string','Number of frequency bins: ','Position',[675 45 130 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditNumberFreq       = uicontrol(gcf,'Style','edit','Position',[810 45 30 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');

set(handles.GUIHandles.EditLowFreq,'Max',1);
set(handles.GUIHandles.EditLowFreq,'String',handles.Model(md).Input.Domain(id).LowFreq);
set(handles.GUIHandles.EditLowFreq,'CallBack',{@EditLowFreq_CallBack});

set(handles.GUIHandles.EditHighFreq,'Max',1);
set(handles.GUIHandles.EditHighFreq,'String',handles.Model(md).Input.Domain(id).HighFreq);
set(handles.GUIHandles.EditHighFreq,'CallBack',{@EditHighFreq_CallBack});

set(handles.GUIHandles.EditNumberFreq,'Max',1);
set(handles.GUIHandles.EditNumberFreq,'String',handles.Model(md).Input.Domain(id).NumberFreq);
set(handles.GUIHandles.EditNumberFreq,'CallBack',{@EditNumberFreq_CallBack});

setHandles(handles);

Refresh(handles)

%%
function EditComputationalGrids_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.ActiveDomain=get(hObject,'Value');
setHandles(handles);
Refresh(handles)

function ToggleCircle_CallBack(hObject,eventdata)
handles=getHandles;
id=handles.Model(md).Input.ActiveDomain;
handles.Model(md).Input.Domain(id).Circle=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleCircle,'Value',1);
    set(handles.GUIHandles.ToggleSector,'Value',0);
    set(handles.GUIHandles.TextStartDir,'enable','off');
    set(handles.GUIHandles.EditStartDir,'enable','off');
    set(handles.GUIHandles.TextEndDir,'enable','off');
    set(handles.GUIHandles.EditEndDir,'enable','off');    
    handles.Model(md).Input.Domain(id).Sector=0;
end
setHandles(handles);

function ToggleSector_CallBack(hObject,eventdata)
handles=getHandles;
id=handles.Model(md).Input.ActiveDomain;
handles.Model(md).Input.Domain(id).Sector=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleCircle,'Value',0);
    set(handles.GUIHandles.ToggleSector,'Value',1);
    set(handles.GUIHandles.TextStartDir,'enable','on');
    set(handles.GUIHandles.EditStartDir,'enable','on');
    set(handles.GUIHandles.TextEndDir,'enable','on');
    set(handles.GUIHandles.EditEndDir,'enable','on');    
    handles.Model(md).Input.Domain(id).Circle=0;
end
setHandles(handles);

function EditStartDir_CallBack(hObject,eventdata)
handles=getHandles;
id=handles.Model(md).Input.ActiveDomain;
handles.Model(md).Input.Domain(id).StartDir=get(hObject,'String');
setHandles(handles);

function EditEndDir_CallBack(hObject,eventdata)
handles=getHandles;
id=handles.Model(md).Input.ActiveDomain;
id=handles.Model(md).Input.ActiveDomain;
handles.Model(md).Input.Domain(id).EndDir=get(hObject,'String');
setHandles(handles);

function EditNumberDir_CallBack(hObject,eventdata)
handles=getHandles;
id=handles.Model(md).Input.ActiveDomain;
handles.Model(md).Input.Domain(id).NumberDir=get(hObject,'String');
setHandles(handles);

function EditLowFreq_CallBack(hObject,eventdata)
handles=getHandles;
id=handles.Model(md).Input.ActiveDomain;
handles.Model(md).Input.Domain(id).LowFreq=get(hObject,'String');
setHandles(handles);

function EditHighFreq_CallBack(hObject,eventdata)
handles=getHandles;
id=handles.Model(md).Input.ActiveDomain;
handles.Model(md).Input.Domain(id).HighFreq=get(hObject,'String');
setHandles(handles);

function EditNumberFreq_CallBack(hObject,eventdata)
handles=getHandles;
id=handles.Model(md).Input.ActiveDomain;
handles.Model(md).Input.Domain(id).NumberFreq=get(hObject,'String');
setHandles(handles);

function Refresh(handles)
handles=getHandles;
id=handles.Model(md).Input.ActiveDomain;
if isempty(handles.Model(md).Input.Domain(id).Circle)
    handles.Model(md).Input.Domain(id).Circle=1;
    handles.Model(md).Input.Domain(id).Sector=0;
    set(handles.GUIHandles.ToggleCircle,'Value',1);
    set(handles.GUIHandles.TextStartDir,'enable','off');
    set(handles.GUIHandles.EditStartDir,'enable','off');
    set(handles.GUIHandles.TextEndDir,'enable','off');
    set(handles.GUIHandles.EditEndDir,'enable','off');    
end
set(handles.GUIHandles.ToggleCircle,'Value',handles.Model(md).Input.Domain(id).Circle);
set(handles.GUIHandles.ToggleSector,'Value',handles.Model(md).Input.Domain(id).Sector);
set(handles.GUIHandles.EditStartDir,'String',handles.Model(md).Input.Domain(id).StartDir);
set(handles.GUIHandles.EditEndDir,'String',handles.Model(md).Input.Domain(id).EndDir);
if isempty(handles.Model(md).Input.Domain(id).NumberDir)
   handles.Model(md).Input.Domain(id).NumberDir=handles.Model(md).Input.Domain(1).NumberDir;
end
set(handles.GUIHandles.EditNumberDir,'String',handles.Model(md).Input.Domain(id).NumberDir);
if isempty(handles.Model(md).Input.Domain(id).LowFreq)
   handles.Model(md).Input.Domain(id).LowFreq=handles.Model(md).Input.Domain(1).LowFreq;
end
set(handles.GUIHandles.EditLowFreq,'String',handles.Model(md).Input.Domain(id).LowFreq);
if isempty(handles.Model(md).Input.Domain(id).HighFreq)
   handles.Model(md).Input.Domain(id).HighFreq=handles.Model(md).Input.Domain(1).HighFreq;
end
set(handles.GUIHandles.EditHighFreq,'String',handles.Model(md).Input.Domain(id).HighFreq);
if isempty(handles.Model(md).Input.Domain(id).NumberFreq)
   handles.Model(md).Input.Domain(id).NumberFreq=handles.Model(md).Input.Domain(1).NumberFreq;
end
set(handles.GUIHandles.EditNumberFreq,'String',handles.Model(md).Input.Domain(id).NumberFreq);
setHandles(handles);



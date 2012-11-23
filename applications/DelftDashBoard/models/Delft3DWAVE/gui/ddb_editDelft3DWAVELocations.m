function ddb_editDelft3DWAVELocations

handles=getHandles;
fig0=gcf;

fig1=MakeNewWindow('Output locations',[400 350],[handles.settingsDir filesep 'icons' filesep 'deltares.gif']);

hp = uipanel('Units','pixels','Position',[5 5 390 340],'Tag','UIControl');

handles.GUIHandles.TextOutputLoc   = uicontrol(gcf,'Style','text','String','Output locations : ','Position',[50 310 130 15],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIHandles.ToggleLocFromFile            = uicontrol(gcf,'Style','radiobutton', 'String','From File','Position',[50 280 130 15],'Tag','UIControl');
set(handles.GUIHandles.ToggleLocFromFile,'Value',handles.Model(md).Input.LocFromFile);
set(handles.GUIHandles.ToggleLocFromFile,        'CallBack',{@ToggleLocFromFile_CallBack});

handles.GUIHandles.PushSelectLocFile     = uicontrol(gcf,'Style','pushbutton', 'String','Select File','Position',[180 280 120 20],'Tag','UIControl');
handles.GUIHandles.TextSelectLocFile     = uicontrol(gcf,'Style','text','String',['File : ' handles.Model(md).Input.LocFileName],'Position',[70 240 300 20],'HorizontalAlignment','left','Tag','UIControl');
set(handles.GUIHandles.PushSelectLocFile,     'Callback',{@PushSelectLocFile_Callback});

handles.GUIHandles.ToggleLocSpecified     = uicontrol(gcf,'Style','radiobutton', 'String','Specified below','Position',[50 200 130 15],'Tag','UIControl');
set(handles.GUIHandles.ToggleLocSpecified,'Value',handles.Model(md).Input.LocSpecified);
set(handles.GUIHandles.ToggleLocSpecified, 'CallBack',{@ToggleLocSpecified_CallBack});

handles.GUIHandles.EditLocations  = uicontrol(gcf,'Style','listbox','Position',[70 80 120 100],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.GUIHandles.EditLocations,'Max',50);
if isempty(handles.Model(md).Input.Locations)
    set(handles.GUIHandles.EditLocations,'String','');
else
    set(handles.GUIHandles.EditLocations,'String',[handles.Model(md).Input.Locations{:}]');
end
set(handles.GUIHandles.EditLocations,'CallBack',{@EditLocations_CallBack});

handles.GUIHandles.PushAdd      = uicontrol(gcf,'Style','pushbutton',  'String','Add','Position',[210 160 70 20],'Tag','UIControl');
set(handles.GUIHandles.PushAdd,'CallBack',{@PushAdd_CallBack});

handles.GUIHandles.PushDelete   = uicontrol(gcf,'Style','pushbutton',  'String','Delete','Position',[210 130 70 20],'Tag','UIControl');
set(handles.GUIHandles.PushDelete,'CallBack',{@PushDelete_CallBack});

handles.GUIHandles.TextCoordLoc1   = uicontrol(gcf,'Style','text','String','Coordinates :   X :','Position',[210 100 130 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextCoordLoc2   = uicontrol(gcf,'Style','text','String','Y :','Position',[283 80 30 15],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIHandles.EditLocX       = uicontrol(gcf,'Style','edit', 'Position',[310 100 50 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.GUIHandles.EditLocX,'Max',1);
set(handles.GUIHandles.EditLocX,'String',num2str(handles.Model(md).Input.LocXTemp));
set(handles.GUIHandles.EditLocX,'CallBack',{@EditLocX_CallBack});

handles.GUIHandles.EditLocY       = uicontrol(gcf,'Style','edit', 'Position',[310 80 50 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.GUIHandles.EditLocY,'Max',1);
set(handles.GUIHandles.EditLocY,'String',num2str(handles.Model(md).Input.LocYTemp));
set(handles.GUIHandles.EditLocY,'CallBack',{@EditLocY_CallBack});

if handles.Model(md).Input.LocSpecified==1
    set(handles.GUIHandles.TextSelectLocFile,'Enable','off');
    set(handles.GUIHandles.PushSelectLocFile,'Enable','off');
    set(handles.GUIHandles.PushAdd,'Enable','on');
    set(handles.GUIHandles.PushDelete,'Enable','on');
    set(handles.GUIHandles.TextCoordLoc1,'Enable','on');
    set(handles.GUIHandles.TextCoordLoc2,'Enable','on');
    set(handles.GUIHandles.EditLocX,'Enable','on');
    set(handles.GUIHandles.EditLocY,'Enable','on');
else
    set(handles.GUIHandles.TextSelectLocFile,'Enable','on');
    set(handles.GUIHandles.PushSelectLocFile,'Enable','on');
    set(handles.GUIHandles.PushAdd,'Enable','off');
    set(handles.GUIHandles.PushDelete,'Enable','off');
    set(handles.GUIHandles.TextCoordLoc1,'Enable','off');
    set(handles.GUIHandles.TextCoordLoc2,'Enable','off');
    set(handles.GUIHandles.EditLocX,'Enable','off');
    set(handles.GUIHandles.EditLocY,'Enable','off');    
end

handles.GUIHandles.PushClose      = uicontrol(gcf,'Style','pushbutton',  'String','Close','Position',[160 20 80 20],'Tag','UIControl');
set(handles.GUIHandles.PushClose,'Enable','on');
set(handles.GUIHandles.PushClose,'CallBack',{@PushClose_CallBack});

guidata(findobj('Tag','Output locations'),handles);
    

%%

function EditLocations_CallBack(hObject,eventdata)
handles=guidata(findobj('Tag','Output locations'));
handles.Model(md).Input.LocationsIval=get(hObject,'Value');
guidata(findobj('Tag','Output locations'),handles);
Refresh(handles);

function ToggleLocFromFile_CallBack(hObject,eventdata)
handles=guidata(findobj('Tag','Output locations'));
handles.Model(md).Input.LocFromFile=get(hObject,'value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleLocFromFile,'Value',1);
    set(handles.GUIHandles.ToggleLocSpecified,'Value',0);
    handles.Model(md).Input.LocSpecified=0;
end
guidata(findobj('Tag','Output locations'),handles);
Refresh(handles);

function ToggleLocSpecified_CallBack(hObject,eventdata)
handles=guidata(findobj('Tag','Output locations'));
handles.Model(md).Input.LocSpecified=get(hObject,'value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleLocFromFile,'Value',0);
    set(handles.GUIHandles.ToggleLocSpecified,'Value',1);
    handles.Model(md).Input.LocFromFile=0;
end
guidata(findobj('Tag','Output locations'),handles);
Refresh(handles);

function PushSelectLocFile_Callback(hObject,eventdata)
handles=guidata(findobj('Tag','Output locations'));
[filename, pathname, filterindex] = uigetfile('*.loc', 'Select BND File');
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input.LocFileName=filename;
    set(handles.GUIHandles.TextSelectLocFile,'String',['File : ' handles.Model(md).Input.LocFileName]);
end
guidata(findobj('Tag','Output locations'),handles);

function PushAdd_CallBack(hObject,eventdata)
handles=guidata(findobj('Tag','Output locations'));
if isempty(handles.Model(md).Input.Locations)
    handles.Model(md).Input.LocationsIval = 1;
elseif isempty(handles.Model(md).Input.Locations{1})
    handles.Model(md).Input.LocationsIval = 1;
else
    handles.Model(md).Input.LocationsIval=size(handles.Model(md).Input.Locations,2)+1;
end
id = handles.Model(md).Input.LocationsIval;
handles.Model(md).Input.Locations{id}=cellstr(['Location ' num2str(id)]);
handles.Model(md).Input.LocX(id)=handles.Model(md).Input.LocXTemp;
handles.Model(md).Input.LocY(id)=handles.Model(md).Input.LocYTemp;
guidata(findobj('Tag','Output locations'),handles);
Refresh(handles);

function PushDelete_CallBack(hObject,eventdata)
handles=guidata(findobj('Tag','Output locations'));
id = find([1:size(handles.Model(md).Input.Locations,2)]~=handles.Model(md).Input.LocationsIval);
handles.Model(md).Input.Locations=handles.Model(md).Input.Locations(1:end-1);
if size(handles.Model(md).Input.Locations,2)==0
    handles.Model(md).Input.LocationsIval='';
else
    handles.Model(md).Input.LocationsIval=1;
end
handles.Model(md).Input.LocX=handles.Model(md).Input.LocX(id);
handles.Model(md).Input.LocY=handles.Model(md).Input.LocY(id);
guidata(findobj('Tag','Output locations'),handles);
Refresh(handles);

function EditLocX_CallBack(hObject,eventdata)
handles=guidata(findobj('Tag','Output locations'));
handles.Model(md).Input.LocXTemp=str2num(get(hObject,'string'));
guidata(findobj('Tag','Output locations'),handles);

function EditLocY_CallBack(hObject,eventdata)
handles=guidata(findobj('Tag','Output locations'));
handles.Model(md).Input.LocYTemp=str2num(get(hObject,'string'));
guidata(findobj('Tag','Output locations'),handles);

function PushClose_CallBack(hObject,eventdata)
handles=guidata(findobj('Tag','Output locations'));
setHandles(handles);
close;


%%
function Refresh(handles)
handles=guidata(findobj('Tag','Output locations'));
if handles.Model(md).Input.LocSpecified==1
    set(handles.GUIHandles.TextSelectLocFile,'Enable','off');
    set(handles.GUIHandles.PushSelectLocFile,'Enable','off');
    set(handles.GUIHandles.PushAdd,'Enable','on');
    set(handles.GUIHandles.PushDelete,'Enable','on');
    set(handles.GUIHandles.TextCoordLoc1,'Enable','on');
    set(handles.GUIHandles.TextCoordLoc2,'Enable','on');
    set(handles.GUIHandles.EditLocX,'Enable','on');
    set(handles.GUIHandles.EditLocY,'Enable','on');
    set(handles.GUIHandles.TextSelectLocFile,'String','');
    if isempty(handles.Model(md).Input.Locations)
        set(handles.GUIHandles.EditLocations,'String','');
        set(handles.GUIHandles.EditLocX,'String','');
        set(handles.GUIHandles.EditLocY,'String','');          
    else
        set(handles.GUIHandles.EditLocations,'String',[handles.Model(md).Input.Locations{:}]');
        id = handles.Model(md).Input.LocationsIval;
        set(handles.GUIHandles.EditLocations,'Value',id);
        set(handles.GUIHandles.EditLocX,'String',num2str(handles.Model(md).Input.LocX(id)));
        set(handles.GUIHandles.EditLocY,'String',num2str(handles.Model(md).Input.LocY(id)));         
    end 
else
    set(handles.GUIHandles.TextSelectLocFile,'Enable','on');
    set(handles.GUIHandles.PushSelectLocFile,'Enable','on');
    set(handles.GUIHandles.PushAdd,'Enable','off');
    set(handles.GUIHandles.PushDelete,'Enable','off');
    set(handles.GUIHandles.TextCoordLoc1,'Enable','off');
    set(handles.GUIHandles.TextCoordLoc2,'Enable','off');
    set(handles.GUIHandles.EditLocX,'Enable','off');
    set(handles.GUIHandles.EditLocY,'Enable','off');
    set(handles.GUIHandles.TextSelectLocFile,'String',['File : ' handles.Model(md).Input.LocFileName]);
    set(handles.GUIHandles.EditLocations,'String','');
    set(handles.GUIHandles.EditLocX,'String','');
    set(handles.GUIHandles.EditLocY,'String',''); 
end
guidata(findobj('Tag','Output locations'),handles);


function ddb_editDelft3DWAVEConditions

handles=getHandles;
SettingsDir=getINIValue(handles.IniFile,'SettingsDir');
fig0=gcf;

if handles.Model(md).Input.UniformTemp==1
    
    if handles.Model(md).Input.ParametricTemp==1
    
    fig1=MakeNewWindow('Uniform boundary conditions',[400 300],[SettingsDir '\icons\deltares.gif']);
    
    hp = uipanel('Units','pixels','Position',[5 5 390 290],'Tag','UIControl');
        
    handles.GUIHandles.TextHs1       = uicontrol(gcf,'Style','text','String','Significant wave height : ','Position',[20 240 220 15],'HorizontalAlignment','left','Tag','UIControl');
    handles.GUIHandles.EditHs1       = uicontrol(gcf,'Style','edit', 'Position',[250 240 50 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
    handles.GUIHandles.TextHs1Unit   = uicontrol(gcf,'Style','text','String','[m]','Position',[320 240 30 15],'HorizontalAlignment','left','Tag','UIControl');
    set(handles.GUIHandles.EditHs1,'Max',1);
    set(handles.GUIHandles.EditHs1,'String',num2str(handles.Model(md).Input.HsTemp));
    set(handles.GUIHandles.EditHs1,'CallBack',{@EditHs1_CallBack});
    
    handles.GUIHandles.TextTp1       = uicontrol(gcf,'Style','text','String','Peak period Tp : ','Position',[20 200 220 15],'HorizontalAlignment','left','Tag','UIControl');
    handles.GUIHandles.EditTp1       = uicontrol(gcf,'Style','edit', 'Position',[250 200 50 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
    handles.GUIHandles.TextTp1Unit   = uicontrol(gcf,'Style','text','String','[s]','Position',[320 200 30 15],'HorizontalAlignment','left','Tag','UIControl');
    set(handles.GUIHandles.EditTp1,'Max',1);
    set(handles.GUIHandles.EditTp1,'String',num2str(handles.Model(md).Input.TpTemp));
    set(handles.GUIHandles.EditTp1,'CallBack',{@EditTp1_CallBack});
    
    handles.GUIHandles.TextDir1       = uicontrol(gcf,'Style','text','String','Direction (nautical) : ','Position',[20 160 220 15],'HorizontalAlignment','left','Tag','UIControl');
    handles.GUIHandles.EditDir1       = uicontrol(gcf,'Style','edit', 'Position',[250 160 50 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
    handles.GUIHandles.TextDir1Unit   = uicontrol(gcf,'Style','text','String','[deg]','Position',[320 160 30 15],'HorizontalAlignment','left','Tag','UIControl');
    set(handles.GUIHandles.EditDir1,'Max',1);
    set(handles.GUIHandles.EditDir1,'String',num2str(handles.Model(md).Input.DirTemp));
    set(handles.GUIHandles.EditDir1,'CallBack',{@EditDir1_CallBack});
    
    handles.GUIHandles.TextSpread1       = uicontrol(gcf,'Style','text','String','Directional spreading : ','Position',[20 120 220 15],'HorizontalAlignment','left','Tag','UIControl');
    handles.GUIHandles.EditSpread1       = uicontrol(gcf,'Style','edit', 'Position',[250 120 50 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
    handles.GUIHandles.TextSpread1Unit   = uicontrol(gcf,'Style','text','String','[-]','Position',[320 120 30 15],'HorizontalAlignment','left','Tag','UIControl');
    set(handles.GUIHandles.EditSpread1,'Max',1);
    set(handles.GUIHandles.EditSpread1,'String',num2str(handles.Model(md).Input.SpreadTemp));
    set(handles.GUIHandles.EditSpread1,'CallBack',{@EditSpread1_CallBack});
    
    handles.GUIHandles.PushClose1      = uicontrol(gcf,'Style','pushbutton',  'String','Close','Position',[160 60 80 20],'Tag','UIControl');
    set(handles.GUIHandles.PushClose1,'Enable','on');
    set(handles.GUIHandles.PushClose1,'CallBack',{@PushClose1_CallBack});
    
    guidata(findobj('Tag','Uniform boundary conditions'),handles);
    
    else
        
    fig1=MakeNewWindow('Uniform boundary conditions',[400 200],[SettingsDir '\icons\deltares.gif']);
    
    hp = uipanel('Units','pixels','Position',[5 5 390 190],'Tag','UIControl');
   
    handles.GUIHandles.PushSelectBndFile     = uicontrol(gcf,'Style','pushbutton', 'String','Select Filename','Position',[20 130 120 20],'Tag','UIControl');
    handles.GUIHandles.TextSelectBndFile     = uicontrol(gcf,'Style','text','String',['File : ' handles.Model(md).Input.BndFileTemp],'Position',[20 80 370 20],'HorizontalAlignment','left','Tag','UIControl');
    set(handles.GUIHandles.PushSelectBndFile,     'Callback',{@PushSelectBndFile_Callback});
    
    handles.GUIHandles.PushClose1      = uicontrol(gcf,'Style','pushbutton',  'String','Close','Position',[160 20 80 20],'Tag','UIControl');
    set(handles.GUIHandles.PushClose1,'Enable','on');
    set(handles.GUIHandles.PushClose1,'CallBack',{@PushClose1_CallBack});
    
    guidata(findobj('Tag','Uniform boundary conditions'),handles);
    
    end
    
else

    if handles.Model(md).Input.ParametricTemp==1
    
    fig1=MakeNewWindow('Space-varying boundary conditions',[400 450],[SettingsDir '\icons\deltares.gif']);
    
    hp = uipanel('Units','pixels','Position',[5 5 390 440],'Tag','UIControl');

    handles.GUIHandles.EditSections1  = uicontrol(gcf,'Style','listbox','Position',[20 330 120 100],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
    set(handles.GUIHandles.EditSections1,'Max',50);
    if isempty(handles.Model(md).Input.Sections)
        set(handles.GUIHandles.EditSections1,'String','');
    else
        set(handles.GUIHandles.EditSections1,'String',[handles.Model(md).Input.Sections{:}]');
    end
    set(handles.GUIHandles.EditSections1,'CallBack',{@EditSections1_CallBack});
        
    handles.GUIHandles.PushAdd1      = uicontrol(gcf,'Style','pushbutton',  'String','Add','Position',[150 410 70 20],'Tag','UIControl');
    set(handles.GUIHandles.PushAdd1,'Enable','on');
    set(handles.GUIHandles.PushAdd1,'CallBack',{@PushAdd1_CallBack});
    
    handles.GUIHandles.PushDelete1   = uicontrol(gcf,'Style','pushbutton',  'String','Delete','Position',[150 380 70 20],'Tag','UIControl');
    set(handles.GUIHandles.PushDelete1,'Enable','on');
    set(handles.GUIHandles.PushDelete1,'CallBack',{@PushDelete1_CallBack});
    
    handles.GUIHandles.TextDistSec            = uicontrol(gcf,'Style','text','String','Distance from all sections : ','Position',[250 380 130 15],'HorizontalAlignment','left','Tag','UIControl');
    handles.GUIHandles.ToggleClock            = uicontrol(gcf,'Style','radiobutton', 'String','Clockwise','Position',[250 355 130 15],'Tag','UIControl');
    handles.GUIHandles.ToggleCounterClock     = uicontrol(gcf,'Style','radiobutton', 'String','Counter clockwise','Position',[250 330 130 15],'Tag','UIControl');
    set(handles.GUIHandles.ToggleClock,'Value',handles.Model(md).Input.ClockTemp);
    set(handles.GUIHandles.ToggleCounterClock,'Value',handles.Model(md).Input.CounterClockTemp);
    set(handles.GUIHandles.ToggleClock,        'CallBack',{@ToggleClock_CallBack});
    set(handles.GUIHandles.ToggleCounterClock, 'CallBack',{@ToggleCounterClock_CallBack});
    
    handles.GUIHandles.TextDist       = uicontrol(gcf,'Style','text','String','Distance from corner point : ','Position',[20 280 220 15],'HorizontalAlignment','left','Tag','UIControl');
    handles.GUIHandles.EditDist       = uicontrol(gcf,'Style','edit', 'Position',[250 280 50 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
    handles.GUIHandles.TextDistUnit   = uicontrol(gcf,'Style','text','String','[m]','Position',[320 280 30 15],'HorizontalAlignment','left','Tag','UIControl');
    set(handles.GUIHandles.EditDist,'Max',1);
    set(handles.GUIHandles.EditDist,'String',num2str(handles.Model(md).Input.DistTemp));
    set(handles.GUIHandles.EditDist,'CallBack',{@EditDist_CallBack});
    
    handles.GUIHandles.TextHs2       = uicontrol(gcf,'Style','text','String','Significant wave height : ','Position',[20 240 220 15],'HorizontalAlignment','left','Tag','UIControl');
    handles.GUIHandles.EditHs2       = uicontrol(gcf,'Style','edit', 'Position',[250 240 50 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
    handles.GUIHandles.TextHs2Unit   = uicontrol(gcf,'Style','text','String','[m]','Position',[320 240 30 15],'HorizontalAlignment','left','Tag','UIControl');
    set(handles.GUIHandles.EditHs2,'Max',1);
    set(handles.GUIHandles.EditHs2,'String',num2str(handles.Model(md).Input.HsTemp));
    set(handles.GUIHandles.EditHs2,'CallBack',{@EditHs2_CallBack});
    
    handles.GUIHandles.TextTp2       = uicontrol(gcf,'Style','text','String','Peak period Tp : ','Position',[20 200 220 15],'HorizontalAlignment','left','Tag','UIControl');
    handles.GUIHandles.EditTp2       = uicontrol(gcf,'Style','edit', 'Position',[250 200 50 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
    handles.GUIHandles.TextTp2Unit   = uicontrol(gcf,'Style','text','String','[s]','Position',[320 200 30 15],'HorizontalAlignment','left','Tag','UIControl');
    set(handles.GUIHandles.EditTp2,'Max',1);
    set(handles.GUIHandles.EditTp2,'String',num2str(handles.Model(md).Input.TpTemp));
    set(handles.GUIHandles.EditTp2,'CallBack',{@EditTp2_CallBack});
    
    handles.GUIHandles.TextDir2       = uicontrol(gcf,'Style','text','String','Direction (nautical) : ','Position',[20 160 220 15],'HorizontalAlignment','left','Tag','UIControl');
    handles.GUIHandles.EditDir2       = uicontrol(gcf,'Style','edit', 'Position',[250 160 50 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
    handles.GUIHandles.TextDir2Unit   = uicontrol(gcf,'Style','text','String','[deg]','Position',[320 160 30 15],'HorizontalAlignment','left','Tag','UIControl');
    set(handles.GUIHandles.EditDir2,'Max',1);
    set(handles.GUIHandles.EditDir2,'String',num2str(handles.Model(md).Input.DirTemp));
    set(handles.GUIHandles.EditDir2,'CallBack',{@EditDir2_CallBack});
    
    handles.GUIHandles.TextSpread2       = uicontrol(gcf,'Style','text','String','Directional spreading : ','Position',[20 120 220 15],'HorizontalAlignment','left','Tag','UIControl');
    handles.GUIHandles.EditSpread2       = uicontrol(gcf,'Style','edit', 'Position',[250 120 50 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
    handles.GUIHandles.TextSpread2Unit   = uicontrol(gcf,'Style','text','String','[-]','Position',[320 120 30 15],'HorizontalAlignment','left','Tag','UIControl');
    set(handles.GUIHandles.EditSpread2,'Max',1);
    set(handles.GUIHandles.EditSpread2,'String',num2str(handles.Model(md).Input.SpreadTemp));
    set(handles.GUIHandles.EditSpread2,'CallBack',{@EditSpread2_CallBack});
    
    handles.GUIHandles.PushClose2      = uicontrol(gcf,'Style','pushbutton',  'String','Close','Position',[160 60 80 20],'Tag','UIControl');
    set(handles.GUIHandles.PushClose2,'Enable','on');
    set(handles.GUIHandles.PushClose2,'CallBack',{@PushClose2_CallBack});
    
    guidata(findobj('Tag','Space-varying boundary conditions'),handles);
    
    else

    fig1=MakeNewWindow('Space-varying boundary conditions',[400 350],[SettingsDir '\icons\deltares.gif']);
    
    hp = uipanel('Units','pixels','Position',[5 5 390 340],'Tag','UIControl');

    handles.GUIHandles.EditSections2  = uicontrol(gcf,'Style','listbox','Position',[20 230 120 100],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
    set(handles.GUIHandles.EditSections2,'Max',50);
    if isempty(handles.Model(md).Input.Sections)
        set(handles.GUIHandles.EditSections2,'String','');
    else
        set(handles.GUIHandles.EditSections2,'String',[handles.Model(md).Input.Sections{:}]');
    end
    set(handles.GUIHandles.EditSections2,'CallBack',{@EditSections2_CallBack});
        
    handles.GUIHandles.PushAdd2      = uicontrol(gcf,'Style','pushbutton',  'String','Add','Position',[150 310 70 20],'Tag','UIControl');
    set(handles.GUIHandles.PushAdd2,'Enable','on');
    set(handles.GUIHandles.PushAdd2,'CallBack',{@PushAdd2_CallBack});
    
    handles.GUIHandles.PushDelete2   = uicontrol(gcf,'Style','pushbutton',  'String','Delete','Position',[150 280 70 20],'Tag','UIControl');
    set(handles.GUIHandles.PushDelete2,'Enable','on');
    set(handles.GUIHandles.PushDelete2,'CallBack',{@PushDelete2_CallBack});
    
    handles.GUIHandles.TextDistSec            = uicontrol(gcf,'Style','text','String','Distance from all sections : ','Position',[250 280 130 15],'HorizontalAlignment','left','Tag','UIControl');
    handles.GUIHandles.ToggleClock            = uicontrol(gcf,'Style','radiobutton', 'String','Clockwise','Position',[250 255 130 15],'Tag','UIControl');
    handles.GUIHandles.ToggleCounterClock     = uicontrol(gcf,'Style','radiobutton', 'String','Counter clockwise','Position',[250 230 130 15],'Tag','UIControl');
    set(handles.GUIHandles.ToggleClock,'Value',handles.Model(md).Input.ClockTemp);
    set(handles.GUIHandles.ToggleCounterClock,'Value',handles.Model(md).Input.CounterClockTemp);
    set(handles.GUIHandles.ToggleClock,        'CallBack',{@ToggleClock_CallBack});
    set(handles.GUIHandles.ToggleCounterClock, 'CallBack',{@ToggleCounterClock_CallBack});
        
    handles.GUIHandles.PushSelectBndFile     = uicontrol(gcf,'Style','pushbutton', 'String','Select Filename','Position',[20 130 120 20],'Tag','UIControl');
    handles.GUIHandles.TextSelectBndFile     = uicontrol(gcf,'Style','text','String',['File : ' handles.Model(md).Input.BndFileTemp],'Position',[20 80 370 20],'HorizontalAlignment','left','Tag','UIControl');
    set(handles.GUIHandles.PushSelectBndFile,     'Callback',{@PushSelectBndFile2_Callback});
    
    handles.GUIHandles.PushClose2      = uicontrol(gcf,'Style','pushbutton',  'String','Close','Position',[160 20 80 20],'Tag','UIControl');
    set(handles.GUIHandles.PushClose2,'Enable','on');
    set(handles.GUIHandles.PushClose2,'CallBack',{@PushClose2_CallBack});
    
    guidata(findobj('Tag','Space-varying boundary conditions'),handles);
    
    end
    
end

%%
function EditHs1_CallBack(hObject,eventdata)
handles=guidata(findobj('Tag','Uniform boundary conditions'));
handles.Model(md).Input.HsTemp=str2num(get(hObject,'string'));
guidata(findobj('Tag','Uniform boundary conditions'),handles);

function EditTp1_CallBack(hObject,eventdata)
handles=guidata(findobj('Tag','Uniform boundary conditions'));
handles.Model(md).Input.TpTemp=str2num(get(hObject,'string'));
guidata(findobj('Tag','Uniform boundary conditions'),handles);

function EditDir1_CallBack(hObject,eventdata)
handles=guidata(findobj('Tag','Uniform boundary conditions'));
handles.Model(md).Input.DirTemp=str2num(get(hObject,'string'));
guidata(findobj('Tag','Uniform boundary conditions'),handles);

function EditSpread1_CallBack(hObject,eventdata)
handles=guidata(findobj('Tag','Uniform boundary conditions'));
handles.Model(md).Input.SpreadTemp=str2num(get(hObject,'string'));
guidata(findobj('Tag','Uniform boundary conditions'),handles);

function PushClose1_CallBack(hObject,eventdata)
handles=guidata(findobj('Tag','Uniform boundary conditions'));
setHandles(handles);
close;

%%
function PushSelectBndFile_Callback(hObject,eventdata)
handles=guidata(findobj('Tag','Uniform boundary conditions'));
[filename, pathname, filterindex] = uigetfile('*.bnd', 'Select BND File');
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input.BndFileTemp=filename;
    set(handles.GUIHandles.TextSelectBndFile,'String',['File : ' handles.Model(md).Input.BndFileTemp]);
    guidata(findobj('Tag','Uniform boundary conditions'),handles);
end

%%
function EditSections1_CallBack(hObject,eventdata)
handles=guidata(findobj('Tag','Space-varying boundary conditions'));
handles.Model(md).Input.SectionsIval=get(hObject,'Value');
guidata(findobj('Tag','Space-varying boundary conditions'),handles);
Refresh1(handles);

function PushAdd1_CallBack(hObject,eventdata)
handles=guidata(findobj('Tag','Space-varying boundary conditions'));
if isempty(handles.Model(md).Input.Sections)
    handles.Model(md).Input.SectionsIval = 1;
elseif isempty(handles.Model(md).Input.Sections{1})
    handles.Model(md).Input.SectionsIval = 1;
else
    handles.Model(md).Input.SectionsIval=size(handles.Model(md).Input.Sections,2)+1;
end
handles.Model(md).Input.Sections{handles.Model(md).Input.SectionsIval}=cellstr(['Section ' num2str(handles.Model(md).Input.SectionsIval)]);
handles.Model(md).Input.SecClock{handles.Model(md).Input.SectionsIval}=num2cell(handles.Model(md).Input.ClockTemp);
handles.Model(md).Input.SecCounterClock{handles.Model(md).Input.SectionsIval}=num2cell(handles.Model(md).Input.CounterClockTemp);
handles.Model(md).Input.SecDist{handles.Model(md).Input.SectionsIval}=num2cell(handles.Model(md).Input.DistTemp);
handles.Model(md).Input.SecHs{handles.Model(md).Input.SectionsIval}=num2cell(handles.Model(md).Input.HsTemp);
handles.Model(md).Input.SecTp{handles.Model(md).Input.SectionsIval}=num2cell(handles.Model(md).Input.TpTemp);
handles.Model(md).Input.SecDir{handles.Model(md).Input.SectionsIval}=num2cell(handles.Model(md).Input.DirTemp);
handles.Model(md).Input.SecSpread{handles.Model(md).Input.SectionsIval}=num2cell(handles.Model(md).Input.SpreadTemp);
set(handles.GUIHandles.PushDelete1,'Enable','on');
guidata(findobj('Tag','Space-varying boundary conditions'),handles);
Refresh1(handles);

function PushDelete1_CallBack(hObject,eventdata)
handles=guidata(findobj('Tag','Space-varying boundary conditions'));
id = find([1:size(handles.Model(md).Input.Sections,2)]~=handles.Model(md).Input.SectionsIval);
handles.Model(md).Input.Sections=handles.Model(md).Input.Sections(1:end-1);
handles.Model(md).Input.SecClock=handles.Model(md).Input.SecClock(id);
handles.Model(md).Input.SecCounterClock=handles.Model(md).Input.SecCounterClock(id);
handles.Model(md).Input.SecDist=handles.Model(md).Input.SecDist(id);
handles.Model(md).Input.SecHs=handles.Model(md).Input.SecHs(id);
handles.Model(md).Input.SecTp=handles.Model(md).Input.SecTp(id);
handles.Model(md).Input.SecDir=handles.Model(md).Input.SecDir(id);
handles.Model(md).Input.SecSpread=handles.Model(md).Input.SecSpread(id);
if size(handles.Model(md).Input.Sections,2)==0
    handles.Model(md).Input.SectionsIval='';
else
    handles.Model(md).Input.SectionsIval=1;
end
guidata(findobj('Tag','Space-varying boundary conditions'),handles);
Refresh1(handles);

function ToggleClock_CallBack(hObject,eventdata)
handles=guidata(findobj('Tag','Space-varying boundary conditions'));
handles.Model(md).Input.ClockTemp=get(hObject,'value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleClock,'Value',1);
    set(handles.GUIHandles.ToggleCounterClock,'Value',0);
    handles.Model(md).Input.CounterClockTemp=0;
end
guidata(findobj('Tag','Space-varying boundary conditions'),handles);

function ToggleCounterClock_CallBack(hObject,eventdata)
handles=guidata(findobj('Tag','Space-varying boundary conditions'));
handles.Model(md).Input.CounterClockTemp=get(hObject,'value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleClock,'Value',0);
    set(handles.GUIHandles.ToggleCounterClock,'Value',1);
    handles.Model(md).Input.ClockTemp=0;
end
guidata(findobj('Tag','Space-varying boundary conditions'),handles);

function EditDist_CallBack(hObject,eventdata)
handles=guidata(findobj('Tag','Space-varying boundary conditions'));
handles.Model(md).Input.DistTemp=str2num(get(hObject,'string'));
guidata(findobj('Tag','Space-varying boundary conditions'),handles);

function EditHs2_CallBack(hObject,eventdata)
handles=guidata(findobj('Tag','Space-varying boundary conditions'));
handles.Model(md).Input.HsTemp=str2num(get(hObject,'string'));
guidata(findobj('Tag','Space-varying boundary conditions'),handles);

function EditTp2_CallBack(hObject,eventdata)
handles=guidata(findobj('Tag','Space-varying boundary conditions'));
handles.Model(md).Input.TpTemp=str2num(get(hObject,'string'));
guidata(findobj('Tag','Space-varying boundary conditions'),handles);

function EditDir2_CallBack(hObject,eventdata)
handles=guidata(findobj('Tag','Space-varying boundary conditions'));
handles.Model(md).Input.DirTemp=str2num(get(hObject,'string'));
guidata(findobj('Tag','Space-varying boundary conditions'),handles);

function EditSpread2_CallBack(hObject,eventdata)
handles=guidata(findobj('Tag','Space-varying boundary conditions'));
handles.Model(md).Input.SpreadTemp=str2num(get(hObject,'string'));
guidata(findobj('Tag','Space-varying boundary conditions'),handles);

function PushClose2_CallBack(hObject,eventdata)
handles=guidata(findobj('Tag','Space-varying boundary conditions'));
setHandles(handles);
close;

%%
function Refresh1(handles)
handles=guidata(findobj('Tag','Space-varying boundary conditions'));
if ~isempty(handles.Model(md).Input.SectionsIval)
    set(handles.GUIHandles.EditSections1,'String',[handles.Model(md).Input.Sections{:}]');
    set(handles.GUIHandles.EditSections1,'Value',handles.Model(md).Input.SectionsIval);
    set(handles.GUIHandles.EditDist,'String',cell2mat(handles.Model(md).Input.SecDist{handles.Model(md).Input.SectionsIval}));
    set(handles.GUIHandles.EditHs2,'String',cell2mat(handles.Model(md).Input.SecHs{handles.Model(md).Input.SectionsIval}));
    set(handles.GUIHandles.EditTp2,'String',cell2mat(handles.Model(md).Input.SecTp{handles.Model(md).Input.SectionsIval}));
    set(handles.GUIHandles.EditDir2,'String',cell2mat(handles.Model(md).Input.SecDir{handles.Model(md).Input.SectionsIval}));
    set(handles.GUIHandles.EditSpread2,'String',cell2mat(handles.Model(md).Input.SecSpread{handles.Model(md).Input.SectionsIval}));
    set(handles.GUIHandles.ToggleClock,'Value',cell2mat(handles.Model(md).Input.SecClock{handles.Model(md).Input.SectionsIval}));
    set(handles.GUIHandles.ToggleCounterClock,'value',cell2mat(handles.Model(md).Input.SecCounterClock{handles.Model(md).Input.SectionsIval}));
else
    set(handles.GUIHandles.EditSections1,'String','');
    set(handles.GUIHandles.EditDist,'String','');
    set(handles.GUIHandles.EditHs2,'String','');
    set(handles.GUIHandles.EditTp2,'String','');
    set(handles.GUIHandles.EditDir2,'String','');
    set(handles.GUIHandles.EditSpread2,'String','');
    set(handles.GUIHandles.ToggleClock,'Value',1);
    set(handles.GUIHandles.ToggleCounterClock,'value',0);
end
guidata(findobj('Tag','Space-varying boundary conditions'),handles);

%%
function EditSections2_CallBack(hObject,eventdata)
handles=guidata(findobj('Tag','Space-varying boundary conditions'));
handles.Model(md).Input.SectionsIval=get(hObject,'Value');
guidata(findobj('Tag','Space-varying boundary conditions'),handles);
Refresh2(handles);

function PushSelectBndFile2_Callback(hObject,eventdata)
handles=guidata(findobj('Tag','Space-varying boundary conditions'));
[filename, pathname, filterindex] = uigetfile('*.bnd', 'Select BND File');
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input.BndFileTemp=filename;
    set(handles.GUIHandles.TextSelectBndFile,'String',['File : ' handles.Model(md).Input.BndFileTemp]);
    guidata(findobj('Tag','Space-varying boundary conditions'),handles);
end

function PushAdd2_CallBack(hObject,eventdata)
handles=guidata(findobj('Tag','Space-varying boundary conditions'));
if isempty(handles.Model(md).Input.Sections)
    handles.Model(md).Input.SectionsIval = 1;
elseif isempty(handles.Model(md).Input.Sections{1})
    handles.Model(md).Input.SectionsIval = 1;
else
    handles.Model(md).Input.SectionsIval=size(handles.Model(md).Input.Sections,2)+1;
end
handles.Model(md).Input.Sections{handles.Model(md).Input.SectionsIval}=cellstr(['Section ' num2str(handles.Model(md).Input.SectionsIval)]);
handles.Model(md).Input.SecClock{handles.Model(md).Input.SectionsIval}=num2cell(handles.Model(md).Input.ClockTemp);
handles.Model(md).Input.SecCounterClock{handles.Model(md).Input.SectionsIval}=num2cell(handles.Model(md).Input.CounterClockTemp);
handles.Model(md).Input.SecFile{handles.Model(md).Input.SectionsIval}=handles.Model(md).Input.BndFileTemp;
set(handles.GUIHandles.PushDelete2,'Enable','on');
guidata(findobj('Tag','Space-varying boundary conditions'),handles);
Refresh2(handles);

function PushDelete2_CallBack(hObject,eventdata)
handles=guidata(findobj('Tag','Space-varying boundary conditions'));
id = find([1:size(handles.Model(md).Input.Sections,2)]~=handles.Model(md).Input.SectionsIval);
handles.Model(md).Input.Sections=handles.Model(md).Input.Sections(1:end-1);
handles.Model(md).Input.SecClock=handles.Model(md).Input.SecClock(id);
handles.Model(md).Input.SecCounterClock=handles.Model(md).Input.SecCounterClock(id);
handles.Model(md).Input.SecDist=handles.Model(md).Input.SecFile(id);
if size(handles.Model(md).Input.Sections,2)==0
    handles.Model(md).Input.SectionsIval='';
else
    handles.Model(md).Input.SectionsIval=1;
end
guidata(findobj('Tag','Space-varying boundary conditions'),handles);
Refresh2(handles);

%%
function Refresh2(handles)
handles=guidata(findobj('Tag','Space-varying boundary conditions'));
if ~isempty(handles.Model(md).Input.SectionsIval)
    set(handles.GUIHandles.EditSections2,'String',[handles.Model(md).Input.Sections{:}]');
    set(handles.GUIHandles.EditSections2,'Value',handles.Model(md).Input.SectionsIval);
    set(handles.GUIHandles.ToggleClock,'Value',cell2mat(handles.Model(md).Input.SecClock{handles.Model(md).Input.SectionsIval}));
    set(handles.GUIHandles.ToggleCounterClock,'value',cell2mat(handles.Model(md).Input.SecCounterClock{handles.Model(md).Input.SectionsIval}));
    set(handles.GUIHandles.TextSelectBndFile,'String',['File : ' handles.Model(md).Input.SecFile{handles.Model(md).Input.SectionsIval}]);
else
    set(handles.GUIHandles.EditSections2,'String','');
    set(handles.GUIHandles.ToggleClock,'Value',1);
    set(handles.GUIHandles.ToggleCounterClock,'value',0);
    set(handles.GUIHandles.TextSelectBndFile,'String',['File : ']);
end
guidata(findobj('Tag','Space-varying boundary conditions'),handles);


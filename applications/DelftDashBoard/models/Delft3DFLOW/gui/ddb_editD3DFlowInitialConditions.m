function ddb_editD3DFlowInitialConditions

ddb_refreshScreen('Init. Conditions');
handles=getHandles;

hp = uipanel('Title','Initial Conditions','Units','pixels','Position',[50 20 900 150],'Tag','UIControl');
str={'Uniform Values','Initial Conditions File','Restart File','Map File'};
handles.GUIHandles.SelectType = uicontrol(gcf,'Style','popupmenu','String',str,'Position',[70 120 120 20],'BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.PushSelectFile     = uicontrol(gcf,'Style','pushbutton','String','File','Position',[200 120 60 20],'Tag','UIControl');
handles.GUIHandles.TextFile   = uicontrol(gcf,'Style','text','Position',[270 116 400 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditZ0     = uicontrol(gcf,'Style','edit','String','0.0','Position',[70 90 60 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditU0     = uicontrol(gcf,'Style','edit','String','0.0','Position',[70 60 60 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditV0     = uicontrol(gcf,'Style','edit','String','0.0','Position',[70 30 60 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextZ0     = uicontrol(gcf,'Style','text','String','Water Level (m)', 'Position',[140 86 100 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextU0     = uicontrol(gcf,'Style','text','String','U-Velocity (m/s)','Position',[140 56 100 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextV0     = uicontrol(gcf,'Style','text','String','V-Velocity (m/s)','Position',[140 26 100 20],'HorizontalAlignment','left','Tag','UIControl');

set(handles.GUIHandles.SelectType,    'CallBack',{@SelectType_CallBack});
set(handles.GUIHandles.PushSelectFile,'CallBack',{@PushSelectFile_CallBack});
set(handles.GUIHandles.EditZ0,        'CallBack',{@EditZ0_CallBack});
set(handles.GUIHandles.EditU0,        'CallBack',{@EditU0_CallBack});
set(handles.GUIHandles.EditV0,        'CallBack',{@EditV0_CallBack});

set(handles.GUIHandles.EditU0,'Visible','off');
set(handles.GUIHandles.EditV0,'Visible','off');
set(handles.GUIHandles.TextU0,'Visible','off');
set(handles.GUIHandles.TextV0,'Visible','off');

handles=RefreshInitialConditions(handles);

SetUIBackgroundColors;

setHandles(handles);

%%
function SelectType_CallBack(hObject,eventdata)
handles=getHandles;
i=get(hObject,'Value');
id=ad;
ini0=handles.Model(md).Input(id).InitialConditions;
handles.Model(md).Input(id).initialConditionsType=i;
switch i,
    case 1
        handles.Model(md).Input(id).InitialConditions='unif';
    case 2
        handles.Model(md).Input(id).InitialConditions='ini';
    case 3
        handles.Model(md).Input(id).InitialConditions='rst';
    case 4
        handles.Model(md).Input(id).InitialConditions='trim';
end
handles=RefreshInitialConditions(handles);
setHandles(handles);

%%
function EditZ0_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).Zeta0=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditU0_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).U0=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditV0_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).V0=str2num(get(hObject,'String'));
setHandles(handles);


%%
function PushSelectFile_CallBack(hObject,eventdata)

handles=getHandles;
id=ad;
switch lower(handles.Model(md).Input(id).InitialConditions),
    case{'ini'}
        [filename, pathname, filterindex] = uigetfile('*.ini', 'Select Initial Conditions File');
        if pathname~=0
            curdir=[lower(cd) '\'];
            if ~strcmp(lower(curdir),lower(pathname))
                filename=[pathname filename];
            end
            handles.Model(md).Input(id).IniFile=filename;
        end
    case{'rst'}
        [filename, pathname, filterindex] = uigetfile('tri-rst.*', 'Select Restart File');
        if pathname~=0
            curdir=[lower(cd) '\'];
            if ~strcmp(lower(curdir),lower(pathname))
                filename=[pathname filename];
            end
            ii=findstr(filename,'tri-rst.');
            handles.Model(md).Input(id).RstId=filename(ii+8:end);
        end
    case{'trim'}
        [filename, pathname, filterindex] = uigetfile('trim-*.dat', 'Select Trim File');
        if pathname~=0
            curdir=[lower(cd) '\'];
            if ~strcmp(lower(curdir),lower(pathname))
                filename=[pathname filename];
            end
            ii=findstr(filename,'.dat');
            handles.Model(md).Input(id).TrimId=filename(1:ii-1);
        end
end
handles=RefreshInitialConditions(handles);
setHandles(handles);

%%
function handles=RefreshInitialConditions(handles)

id=ad;

set(handles.GUIHandles.EditZ0,'String',num2str(handles.Model(md).Input(id).Zeta0));
set(handles.GUIHandles.EditU0,'String',num2str(handles.Model(md).Input(id).U0));
set(handles.GUIHandles.EditV0,'String',num2str(handles.Model(md).Input(id).V0));

switch lower(handles.Model(md).Input(id).InitialConditions),
    case{'unif'}
        ii=1;
        str='';
    case{'ini'}
        ii=2;
        str=handles.Model(md).Input(ad).IniFile;
    case{'rst'}
        ii=3;
        if length(handles.Model(md).Input(ad).RstId)>0
            str=['tri-rst.' handles.Model(md).Input(ad).RstId];
        else
            str='';
        end
    case{'trim'}
        ii=4;
        if length(handles.Model(md).Input(ad).TrimId)>0
            str=[handles.Model(md).Input(ad).TrimId '.dat'];
        else
            str='';
        end
end
set(handles.GUIHandles.SelectType,'Value',ii);

switch lower(handles.Model(md).Input(id).InitialConditions),
    case{'unif'}
        set(handles.GUIHandles.EditZ0,'Enable','on','BackgroundColor',[1 1 1]);
        set(handles.GUIHandles.EditU0,'Enable','on','BackgroundColor',[1 1 1]);
        set(handles.GUIHandles.EditV0,'Enable','on','BackgroundColor',[1 1 1]);
        set(handles.GUIHandles.TextZ0,'Enable','on');
        set(handles.GUIHandles.TextU0,'Enable','on');
        set(handles.GUIHandles.TextV0,'Enable','on');
        set(handles.GUIHandles.TextFile,'String',['File : '],'Enable','off');
        set(handles.GUIHandles.PushSelectFile,'Enable','off');
    case{'ini','trim','rst'}
        set(handles.GUIHandles.EditZ0,'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
        set(handles.GUIHandles.EditU0,'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
        set(handles.GUIHandles.EditV0,'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
        set(handles.GUIHandles.TextZ0,'Enable','off');
        set(handles.GUIHandles.TextU0,'Enable','off');
        set(handles.GUIHandles.TextV0,'Enable','off');
        set(handles.GUIHandles.TextFile,'String',['File : ' str],'Enable','on');
        set(handles.GUIHandles.PushSelectFile,'Enable','on');
end

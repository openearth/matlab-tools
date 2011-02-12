function handles=ddb_editD3DFlowPollutants(handles)

MakeNewWindow('Processes :  Pollutants and Tracers',[360 290],'modal',[handles.SettingsDir '\icons\deltares.gif']);

% h2=guidata(findobj('Tag','MainWindow'));
% 
% 
% handles.Tracers=h2.Model(find(strcmp('Delft3DFLOW',{handles.Model.Name}))).Input(ad).Tracers;
% handles.Tracer=h2.Model(find(strcmp('Delft3DFLOW',{handles.Model.Name}))).Input(ad).Tracer;
% handles.NrTracers=h2.Model(find(strcmp('Delft3DFLOW',{handles.Model.Name}))).Input(ad).NrTracers;

if handles.Model(md).Input(ad).NrTracers>0
    for i=1:handles.Model(md).Input(ad).NrTracers
        str{i}=handles.Model(md).Input(ad).Tracer(i).Name;
        handles.Model(md).Input(ad).Tracer(i).New=0;
    end
else
    str{1}='';
end

handles.GUIHandles.ListTracers    = uicontrol(gcf,'Style','listbox','String',str,    'Position',[30 30 150 200]);
handles.GUIHandles.EditTracerName = uicontrol(gcf,'Style','edit',   'String',str{1},'HorizontalAlignment','left','Position',[30 240 150 20]);

handles.GUIHandles.PushRename     = uicontrol(gcf,'Style','pushbutton','String','Rename','Position',[200 240 60 20]);
handles.GUIHandles.PushAdd        = uicontrol(gcf,'Style','pushbutton','String','Add',   'Position',[200 215 60 20]);
handles.GUIHandles.PushDelete     = uicontrol(gcf,'Style','pushbutton','String','Delete','Position',[200 190 60 20]);

handles.GUIHandles.PushOK     = uicontrol(gcf,'Style','pushbutton','String','OK',    'Position',[270 30 60 30]);
handles.GUIHandles.PushCancel = uicontrol(gcf,'Style','pushbutton','String','Cancel','Position',[200 30 60 30]);

set(handles.GUIHandles.ListTracers, 'CallBack',{@ListTracers_Callback});
set(handles.GUIHandles.PushRename,  'CallBack',{@PushRename_Callback});
set(handles.GUIHandles.PushAdd,     'CallBack',{@PushAdd_Callback});
set(handles.GUIHandles.PushDelete,  'CallBack',{@PushDelete_Callback});

set(handles.GUIHandles.PushOK,      'CallBack',{@PushOK_Callback});
set(handles.GUIHandles.PushCancel,  'CallBack',{@PushCancel_Callback});

SetUIBackgroundColors;

guidata(gcf,handles);

%%
function PushAdd_Callback(hObject,eventdata)
handles=guidata(gcf);

name=deblank(get(handles.GUIHandles.EditTracerName,'String'));
if ~isempty(name)
    iex=0;
    for i=1:handles.Model(md).Input(ad).NrTracers
        if strcmpi(handles.Model(md).Input(ad).Tracer(i).Name,name)
            iex=1;
        end
    end
    if ~iex
        handles.Model(md).Input(ad).NrTracers=handles.Model(md).Input(ad).NrTracers+1;
        ii=handles.Model(md).Input(ad).NrTracers;
        handles.Model(md).Input(ad).Tracer(ii).Name=name;
        handles.Model(md).Input(ad).Tracer(ii).New=1;
        str=[];
        for i=1:handles.Model(md).Input(ad).NrTracers
            str{i}=handles.Model(md).Input(ad).Tracer(i).Name;
        end
        set(handles.GUIHandles.ListTracers,'String',str);
        set(handles.GUIHandles.ListTracers,'Value',ii);
        guidata(gcf,handles);
    else
        GiveWarning('text','A constituent with this name already exists!')
    end
end

%%
function PushRename_Callback(hObject,eventdata)
handles=guidata(gcf);
ii=get(handles.GUIHandles.ListTracers,'Value');
name=deblank(get(handles.GUIHandles.EditTracerName,'String'));
if ~isempty(name)
    handles.Model(md).Input(ad).Tracer(ii).Name=name;
    str=[];
    for i=1:handles.Model(md).Input(ad).NrTracers
        str{i}=handles.Model(md).Input(ad).Tracer(i).Name;
    end
    set(handles.GUIHandles.ListTracers,'String',str);
    guidata(gcf,handles);
end

%%
function PushDelete_Callback(hObject,eventdata)
handles=guidata(gcf);


ii=get(handles.GUIHandles.ListTracers,'Value');
nr=handles.Model(md).Input(ad).NrTracers;
if nr>0
    if nr==1
        handles.Model(md).Input(ad).Tracer=[];
        iac=1;
    else
        for i=ii:nr-1
            handles.Model(md).Input(ad).Tracer(i)=handles.Model(md).Input(ad).Tracer(i+1);
        end
        handles.Tracer=handles.Model(md).Input(ad).Tracer(1:end-1);
        iac=ii;
    end
    if iac>nr-1
        iac=nr-1;
    end
    iac=max(iac,1);
    handles.Model(md).Input(ad).NrTracers=nr-1;
    str{1}=' ';
    for i=1:handles.Model(md).Input(ad).NrTracers
        str{i}=handles.Model(md).Input(ad).Tracer(i).Name;
    end
    set(handles.GUIHandles.ListTracers,'Value',iac);
    set(handles.GUIHandles.ListTracers,'String',str);
    guidata(gcf,handles);
end

%%
function ListTracers_Callback(hObject,eventdata)
handles=guidata(gcf);


ii=get(hObject,'Value');
str=get(hObject,'String');
set(handles.GUIHandles.EditTracerName,'String',str{ii});

%%
function PushOK_Callback(hObject,eventdata)
%h2=guidata(findobj('Tag','MainWindow'));
h2=getHandles;
handles=guidata(gcf);


h2.Model(find(strcmp('Delft3DFLOW',{handles.Model.Name}))).Input(ad).Tracer=handles.Model(md).Input(ad).Tracer;
h2.Model(find(strcmp('Delft3DFLOW',{handles.Model.Name}))).Input(ad).NrTracers=handles.Model(md).Input(ad).NrTracers;
for ii=1:handles.Model(md).Input(ad).NrTracers
    if handles.Model(md).Input(ad).Tracer(ii).New
        h2=ddb_initializeTracer(h2,ii);
    end
end
if handles.Model(md).Input(ad).NrTracers==0
    h2.Model(find(strcmp('Delft3DFLOW',{handles.Model.Name}))).Input(ad).Tracers=0;
    set(h2.GUIHandles.TogglePollutants,'Value',0);
    set(h2.GUIHandles.PushEditPollutants,'Enable','off');
else
    h2.Model(find(strcmp('Delft3DFLOW',{handles.Model.Name}))).Input(ad).Tracers=1;
    set(h2.GUIHandles.TogglePollutants,'Value',1);
    set(h2.GUIHandles.PushEditPollutants,'Enable','on');
end
setHandles(h2);
%guidata(findobj('Tag','MainWindow'),h2);
closereq;

%%
function PushCancel_Callback(hObject,eventdata)
closereq;


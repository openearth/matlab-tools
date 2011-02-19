function ddb_Delft3DFLOW_editSediments

handles=getHandles;

MakeNewWindow('Processes :  Sediments',[360 290],'modal',[handles.settingsDir '\icons\deltares.gif']);

if handles.Model(md).Input(ad).nrSediments>0
    for i=1:handles.Model(md).Input(ad).nrSediments
        str{i}=handles.Model(md).Input(ad).sediment(i).name;
        handles.Model(md).Input(ad).sediment(i).new=0;
    end
else
    str{1}='';
end

handles.GUIHandles.ListSediments    = uicontrol(gcf,'Style','listbox','String',str,    'Position',[30 30 150 200],'BackgroundColor',[1 1 1]);
handles.GUIHandles.EditSedimentName = uicontrol(gcf,'Style','edit','HorizontalAlignment','left','Position',[30 240 150 20],'BackgroundColor',[1 1 1]);

handles.GUIHandles.selectSedimentType = uicontrol(gcf,'Style','popupmenu',   'String',{'non-cohesive','cohesive'},'Position',[200 240 100 20],'BackgroundColor',[1 1 1]);

handles.GUIHandles.PushRename     = uicontrol(gcf,'Style','pushbutton','String','Rename','Position',[200 210 60 20]);
handles.GUIHandles.PushAdd        = uicontrol(gcf,'Style','pushbutton','String','Add',   'Position',[200 185 60 20]);
handles.GUIHandles.PushDelete     = uicontrol(gcf,'Style','pushbutton','String','Delete','Position',[200 160 60 20]);

handles.GUIHandles.PushOK     = uicontrol(gcf,'Style','pushbutton','String','OK',    'Position',[270 30 60 30]);
handles.GUIHandles.PushCancel = uicontrol(gcf,'Style','pushbutton','String','Cancel','Position',[200 30 60 30]);

set(handles.GUIHandles.ListSediments, 'CallBack',{@ListSediments_Callback});
set(handles.GUIHandles.PushRename,  'CallBack',{@PushRename_Callback});
set(handles.GUIHandles.PushAdd,     'CallBack',{@PushAdd_Callback});
set(handles.GUIHandles.PushDelete,  'CallBack',{@PushDelete_Callback});
set(handles.GUIHandles.selectSedimentType, 'CallBack',{@selectSedimentType_Callback});

set(handles.GUIHandles.PushOK,      'CallBack',{@PushOK_Callback});
set(handles.GUIHandles.PushCancel,  'CallBack',{@PushCancel_Callback});

guidata(gcf,handles);

refreshSedimentType(handles);
refreshSedimentName(handles);

uiwait(gcf);

%%
function PushAdd_Callback(hObject,eventdata)
handles=guidata(gcf);

name=deblank(get(handles.GUIHandles.EditSedimentName,'String'));
if length(name)>8
    if strcmpi(name(1:8),'sediment')
        if ~isempty(name)
            iex=0;
            for i=1:handles.Model(md).Input(ad).nrSediments
                if strcmpi(handles.Model(md).Input(ad).sediment(i).name,name)
                    iex=1;
                end
            end
            if ~iex
                handles.Model(md).Input(ad).nrSediments=handles.Model(md).Input(ad).nrSediments+1;
                ii=handles.Model(md).Input(ad).nrSediments;
                handles.Model(md).Input(ad).sediment(ii).name=name;
                
                it=get(handles.GUIHandles.selectSedimentType,'Value');
                if it==1
                    handles.Model(md).Input(ad).sediment(ii).type='non-cohesive';
                else
                    handles.Model(md).Input(ad).sediment(ii).type='cohesive';
                end
                
                handles.Model(md).Input(ad).sediment(ii).new=1;
                str=[];
                for i=1:handles.Model(md).Input(ad).nrSediments
                    str{i}=handles.Model(md).Input(ad).sediment(i).name;
                end
                set(handles.GUIHandles.ListSediments,'String',str);
                set(handles.GUIHandles.ListSediments,'Value',ii);
                guidata(gcf,handles);
            else
                GiveWarning('text','A constituent with this name already exists!')
            end
        end
    else
        set(handles.GUIHandles.EditSedimentName,'String','Sediment');
        GiveWarning('text','Name must start with "Sediment"!')
    end
else
    set(handles.GUIHandles.EditSedimentName,'String','Sediment');
    GiveWarning('text','Name must start with "Sediment"!')    
end

%%
function PushRename_Callback(hObject,eventdata)
handles=guidata(gcf);
ii=get(handles.GUIHandles.ListSediments,'Value');
name=deblank(get(handles.GUIHandles.EditSedimentName,'String'));
if length(name)>8
    if strcmpi(name(1:8),'sediment')
        if ~isempty(name)
            handles.Model(md).Input(ad).sediment(ii).name=name;
            str=[];
            for i=1:handles.Model(md).Input(ad).nrSediments
                str{i}=handles.Model(md).Input(ad).sediment(i).name;
            end
            set(handles.GUIHandles.ListSediments,'String',str);
            guidata(gcf,handles);
        end
    else
        set(handles.GUIHandles.EditSedimentName,'String',handles.Model(md).Input(ad).sediment(ii).name);
        GiveWarning('text','Name must start with "Sediment"!')
    end
else
    set(handles.GUIHandles.EditSedimentName,'String',handles.Model(md).Input(ad).sediment(ii).name);
    GiveWarning('text','Name must start with "Sediment"!')
end

%%
function PushDelete_Callback(hObject,eventdata)
handles=guidata(gcf);
ii=get(handles.GUIHandles.ListSediments,'Value');
nr=handles.Model(md).Input(ad).nrSediments;
if nr>0
    if nr==1
        handles.Model(md).Input(ad).sediment=[];
        iac=1;
    else
        for i=ii:nr-1
            handles.Model(md).Input(ad).sediment(i)=handles.Model(md).Input(ad).sediment(i+1);
        end
        handles.sediment=handles.Model(md).Input(ad).sediment(1:end-1);
        iac=ii;
    end
    if iac>nr-1
        iac=nr-1;
    end
    iac=max(iac,1);
    handles.Model(md).Input(ad).nrSediments=nr-1;
    str{1}=' ';
    for i=1:handles.Model(md).Input(ad).nrSediments
        str{i}=handles.Model(md).Input(ad).sediment(i).name;
    end
    set(handles.GUIHandles.ListSediments,'Value',iac);
    set(handles.GUIHandles.ListSediments,'String',str);
    guidata(gcf,handles);
    refreshSedimentType(handles);
    refreshSedimentName(handles);
end

%%
function ListSediments_Callback(hObject,eventdata)
handles=guidata(gcf);
if handles.Model(md).Input(ad).nrSediments>0
    ii=get(hObject,'Value');
    str=get(hObject,'String');
    set(handles.GUIHandles.EditSedimentName,'String',str{ii});
    refreshSedimentType(handles);
end

%%
function selectSedimentType_Callback(hObject,eventdata)
handles=guidata(gcf);
ii=get(hObject,'Value');
iac=get(handles.GUIHandles.ListSediments,'Value');
if ii==1
    handles.Model(md).Input(ad).sediment(iac).type='non-cohesive';
else
    handles.Model(md).Input(ad).sediment(iac).type='cohesive';
end
guidata(gcf,handles);

%%
function PushOK_Callback(hObject,eventdata)

h2=getHandles;
handles=guidata(gcf);

h2.Model(md).Input(ad).sediment=handles.Model(md).Input(ad).sediment;
h2.Model(md).Input(ad).nrSediments=handles.Model(md).Input(ad).nrSediments;
h2.Model(md).Input(ad).sedimentNames=[];
for ii=1:handles.Model(md).Input(ad).nrSediments
    if handles.Model(md).Input(ad).sediment(ii).new
        h2=ddb_initializeSediment(h2,ad,ii);
    end
    h2.Model(md).Input(ad).sedimentNames{ii}=handles.Model(md).Input(ad).sediment.name;
end
if handles.Model(md).Input(ad).nrSediments==0
    h2.Model(md).Input(ad).sediments.include=0;
else
    h2.Model(md).Input(ad).sediments.include=1;
end
setHandles(h2);

closereq;

%%
function PushCancel_Callback(hObject,eventdata)
closereq;

%%
function refreshSedimentType(handles)
if handles.Model(md).Input(ad).nrSediments>0
    ii=get(handles.GUIHandles.ListSediments,'Value');
    switch handles.Model(md).Input(ad).sediment(ii).type
        case{'non-cohesive'}
            set(handles.GUIHandles.selectSedimentType,'Value',1);
        case{'cohesive'}
            set(handles.GUIHandles.selectSedimentType,'Value',2);
    end
end

%%
function refreshSedimentName(handles)
if handles.Model(md).Input(ad).nrSediments>0
    ii=get(handles.GUIHandles.ListSediments,'Value');
    set(handles.GUIHandles.EditSedimentName,'String',handles.Model(md).Input(ad).sediment(ii).name);
else
    set(handles.GUIHandles.EditSedimentName,'String','Sediment');
end

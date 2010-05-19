function ddb_editD3DFlowObservationPoints

ddb_refreshScreen('Monitoring','Stations');
handles=getHandles;

ii=strmatch('Delft3DFLOW',{handles.Model.Name},'exact');

uipanel('Title','','Units','pixels','Position',[220 30 180 70],'Tag','UIControl');

handles.GUIHandles.EditObsName  = uicontrol(gcf,'Style','edit','Position',[260  70 130 20],'HorizontalAlignment','left', 'BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditObsM     = uicontrol(gcf,'Style','edit','Position',[260  40  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditObsN     = uicontrol(gcf,'Style','edit','Position',[340  40  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.TextName     = uicontrol(gcf,'Style','text','String','Name',    'Position',[225  66 30 20],'HorizontalAlignment','right', 'Tag','UIControl');
handles.GUIHandles.TextM        = uicontrol(gcf,'Style','text','String','M',       'Position',[235  36 20 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextN        = uicontrol(gcf,'Style','text','String','N',       'Position',[315  36 20 20],'HorizontalAlignment','right','Tag','UIControl');

handles.GUIHandles.ListObservationPoints = uicontrol(gcf,'Style','listbox','Position',[60 30 150 110],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextListObservation = uicontrol(gcf,'Style','text','String','Observation Points', 'Position',[60 141 150 12],'HorizontalAlignment','center','Tag','UIControl');

handles.GUIHandles.PushAddObservationPoint    = uicontrol(gcf,'Style','pushbutton','String','Add','Position',   [410 105 70 20],'Tag','UIControl');
handles.GUIHandles.PushDeleteObservationPoint = uicontrol(gcf,'Style','pushbutton','String','Delete','Position',[410  80 70 20],'Tag','UIControl');
handles.GUIHandles.PushChangeObservationPoint = uicontrol(gcf,'Style','pushbutton','String','Change','Position',[410  55 70 20],'Tag','UIControl');
handles.GUIHandles.PushSelectObservationPoint = uicontrol(gcf,'Style','pushbutton','String','Select','Position',[410  30 70 20],'Tag','UIControl');

handles.GUIHandles.PushOpenObservationPoints   = uicontrol(gcf,'Style','pushbutton','String','Open',   'Position',[500  80 70 20],'Tag','UIControl');
handles.GUIHandles.PushSaveObservationPoints   = uicontrol(gcf,'Style','pushbutton','String','Save',   'Position',[500  55 70 20],'Tag','UIControl');
handles.GUIHandles.PushImportObservationPoints = uicontrol(gcf,'Style','pushbutton','String','Import', 'Position',[580  80 70 20],'Tag','UIControl');
handles.GUIHandles.PushExportObservationPoints = uicontrol(gcf,'Style','pushbutton','String','Export', 'Position',[580  55 70 20],'Tag','UIControl');
handles.GUIHandles.TextObsFile                 = uicontrol(gcf,'Style','text','String',['File : ' handles.Model(md).Input(ad).ObsFile],'Position',[500 27 300 20],'HorizontalAlignment','left','Tag','UIControl');

set(handles.GUIHandles.ListObservationPoints,'CallBack',{@ListObservationPoints_CallBack});
set(handles.GUIHandles.ListObservationPoints,'BusyAction','Cancel');
set(handles.GUIHandles.PushAddObservationPoint,'CallBack',{@PushAddObservationPoint_CallBack});
set(handles.GUIHandles.PushDeleteObservationPoint,'CallBack',{@PushDeleteObservationPoint_CallBack});
set(handles.GUIHandles.PushChangeObservationPoint,'CallBack',{@PushChangeObservationPoint_CallBack});
set(handles.GUIHandles.PushSelectObservationPoint,'CallBack',{@PushSelectObservationPoint_CallBack});
set(handles.GUIHandles.PushOpenObservationPoints,'CallBack',{@PushOpenObservationPoints_CallBack});
set(handles.GUIHandles.PushSaveObservationPoints,'CallBack',{@PushSaveObservationPoints_CallBack});
set(handles.GUIHandles.EditObsM,  'CallBack',{@EditObsM_CallBack});
set(handles.GUIHandles.EditObsN,  'CallBack',{@EditObsN_CallBack});
set(handles.GUIHandles.EditObsName,  'CallBack',{@EditObsName_CallBack});

handles.GUIData.DeleteSelectedObservationPoint=0;

set(handles.GUIHandles.PushChangeObservationPoint,'Enable','off');
set(handles.GUIHandles.PushImportObservationPoints,'Enable','off');
set(handles.GUIHandles.PushExportObservationPoints,'Enable','off');

if handles.GUIData.ActiveObservationPoint>handles.Model(md).Input(ad).NrObservationPoints
    handles.GUIData.ActiveObservationPoint=handles.Model(md).Input(ad).NrObservationPoints;
end

setHandles(handles);

if handles.Model(md).Input(ad).NrObservationPoints>0
    ddb_plotFlowAttributes(handles,'ObservationPoints','activate',ad,0,handles.GUIData.ActiveObservationPoint);
end

SetUIBackgroundColors;

RefreshObservationPoints(handles);

%%
function ListObservationPoints_CallBack(hObject,eventdata)
handles=getHandles;
handles.GUIData.ActiveObservationPoint=get(hObject,'Value');
RefreshObservationPoints(handles);
handles.GUIData.DeleteSelectedObservationPoint=1;
setHandles(handles);
ddb_plotFlowAttributes(handles,'ObservationPoints','activate',ad,0,handles.GUIData.ActiveObservationPoint);

%%
function EditObsM_CallBack(hObject,eventdata)
handles=getHandles;
n=get(handles.GUIHandles.ListObservationPoints,'Value');
handles.Model(md).Input(ad).ObservationPoints(n).M=str2double(get(hObject,'String'));
handles.GUIData.DeleteSelectedObservationPoint=0;
setHandles(handles);
ddb_plotFlowAttributes(handles,'ObservationPoints','plot',ad,n,n);

%%
function EditObsN_CallBack(hObject,eventdata)
handles=getHandles;
n=get(handles.GUIHandles.ListObservationPoints,'Value');
handles.Model(md).Input(ad).ObservationPoints(n).N=str2double(get(hObject,'String'));
handles.GUIData.DeleteSelectedObservationPoint=0;
setHandles(handles);
ddb_plotFlowAttributes(handles,'ObservationPoints','plot',ad,n,n);

%%
function EditObsName_CallBack(hObject,eventdata)
handles=getHandles;
n=get(handles.GUIHandles.ListObservationPoints,'Value');
handles.Model(md).Input(ad).ObservationPoints(n).Name=get(hObject,'String');
for k=1:handles.Model(md).Input(ad).NrObservationPoints
    str{k}=handles.Model(md).Input(ad).ObservationPoints(k).Name;
end
set(handles.GUIHandles.ListObservationPoints,'String',str);
handles.GUIData.DeleteSelectedObservationPoint=0;
setHandles(handles);
ddb_plotFlowAttributes(handles,'ObservationPoints','plot',ad,n,n);

%%
function PushOpenObservationPoints_CallBack(hObject,eventdata)
handles=getHandles;
[filename, pathname, filterindex] = uigetfile('*.obs', 'Select Observation Points File');
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input(ad).ObsFile=filename;
    handles.Model(md).Input(ad).ObservationPoints=[];
    handles=ddb_readObsFile(handles);
    handles.GUIData.ActiveObservationPoint=1;
    handles.GUIData.DeleteSelectedObservationPoint=0;
    RefreshObservationPoints(handles);
    set(handles.GUIHandles.TextObsFile,'String',['File : ' filename]);
    handles.GUIData.DeleteSelectedObservationPoint=0;
    setHandles(handles);
    ddb_plotFlowAttributes(handles,'ObservationPoints','plot',ad,0,1);
end

%%
function PushSaveObservationPoints_CallBack(hObject,eventdata)
handles=getHandles;
[filename, pathname, filterindex] = uiputfile('*.obs', 'Select Observation Points File',handles.Model(md).Input(ad).ObsFile);
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input(ad).ObsFile=filename;
    ddb_saveObsFile(handles,ad);
    set(handles.GUIHandles.TextObsFile,'String',['File : ' filename]);
    handles.GUIData.DeleteSelectedObservationPoint=0;
    setHandles(handles);
end

%%
function PushSelectObservationPoint_CallBack(hObject,eventdata)
ddb_zoomOff;
handles=getHandles;
handles.GUIData.DeleteSelectedObservationPoint=0;
handles.Mode='s';
set(gcf, 'windowbuttondownfcn',   {@SelectObservationPoint});
setHandles(handles);

%%
function PushChangeObservationPoint_CallBack(hObject,eventdata)
ddb_zoomOff;
handles=getHandles;
handles.GUIData.DeleteSelectedObservationPoint=0;
handles.Mode='c';
set(gcf, 'windowbuttondownfcn',   {@SelectObservationPoint});
setHandles(handles);

%%
function PushAddObservationPoint_CallBack(hObject,eventdata)
ddb_zoomOff;
h=findobj('Tag','MainWindow');
handles=getHandles;
handles.GUIData.DeleteSelectedObservationPoint=0;
xg=handles.Model(md).Input(ad).GridX;
yg=handles.Model(md).Input(ad).GridY;
guidata(h,handles);
ClickPoint('cell','Grid',xg,yg,'Callback',@AddObservationPoint,'multiple');

%%
function PushDeleteObservationPoint_CallBack(hObject,eventdata)
ddb_zoomOff;
handles=getHandles;
handles.Mode='d';
setHandles(handles);
if handles.GUIData.DeleteSelectedObservationPoint==1 && handles.Model(md).Input(ad).NrObservationPoints>0
    handles=DeleteObservationPoint(handles);
    setHandles(handles);
end
ddb_deleteDelft3DFLOWObject(ad,'ObservationPoint',@DeleteObject);

%%
function DeleteObject(ii)
handles=getHandles;
handles.GUIData.ActiveObservationPoint=ii;
set(handles.GUIHandles.ListObservationPoints,'Value',ii);
handles=DeleteObservationPoint(handles);
setHandles(handles);

%%
function AddObservationPoint(m,n)

handles=getHandles;
if ~isnan(m)
    id=ad;
    nr=handles.Model(md).Input(id).NrObservationPoints+1;
    handles.Model(md).Input(id).NrObservationPoints=nr;
    handles.Model(md).Input(id).ObservationPoints(nr).M=m;
    handles.Model(md).Input(id).ObservationPoints(nr).N=n;
    xz=0.25*(handles.Model(md).Input(id).GridX(m,n)+handles.Model(md).Input(id).GridX(m,n-1)+handles.Model(md).Input(id).GridX(m-1,n)+handles.Model(md).Input(id).GridX(m-1,n-1));
    yz=0.25*(handles.Model(md).Input(id).GridY(m,n)+handles.Model(md).Input(id).GridY(m,n-1)+handles.Model(md).Input(id).GridY(m-1,n)+handles.Model(md).Input(id).GridY(m-1,n-1));
    handles.Model(md).Input(id).ObservationPoints(nr).x=xz;
    handles.Model(md).Input(id).ObservationPoints(nr).y=yz;
    handles.Model(md).Input(id).ObservationPoints(nr).Name=[num2str(m) ',' num2str(n)];
    handles.GUIData.ActiveObservationPoint=nr;
    setHandles(handles);
    ddb_plotFlowAttributes(handles,'ObservationPoints','plot',ad,nr,nr);
end
RefreshObservationPoints(handles);
setHandles(handles);

%%
function SelectObservationPoint(hObject,eventdata)

handles=getHandles;
if strcmp(get(gco,'Tag'),'ObservationPoint')
    id=ad;
    ud=get(gco,'UserData');
    handles.GUIData.ActiveObservationPoint=ud(2);
    RefreshObservationPoints(handles);
    setHandles(handles);
    if handles.Mode=='c'
        ddb_plotFlowAttributes(handles,'ObservationPoints','activate',ad,0,handles.GUIData.ActiveObservationPoint);
        xg=handles.Model(md).Input(ad).GridX;
        yg=handles.Model(md).Input(ad).GridY;
        set(gcf, 'windowbuttondownfcn',   {@ClickPoint,@AddObservationPoint,'cell',xg,yg});
    elseif handles.Mode=='s'
        ddb_plotFlowAttributes(handles,'ObservationPoints','activate',ad,0,handles.GUIData.ActiveObservationPoint);
    elseif handles.Mode=='d'
        ddb_plotFlowAttributes(handles,'ObservationPoints','plot',ad,0,handles.GUIData.ActiveObservationPoint);
    end
end
setHandles(handles);

%%
function handles=DeleteObservationPoint(handles)

id=ad;
nrobs=handles.Model(md).Input(id).NrObservationPoints;

iac0=handles.GUIData.ActiveObservationPoint;
iacnew=handles.GUIData.ActiveObservationPoint;
if iacnew==nrobs
    iacnew=nrobs-1;
end
ddb_plotFlowAttributes(handles,'ObservationPoints','delete',id,handles.GUIData.ActiveObservationPoint,iacnew);

if nrobs>1
    for j=iac0:nrobs-1
        handles.Model(md).Input(id).ObservationPoints(j).M=handles.Model(md).Input(id).ObservationPoints(j+1).M;
        handles.Model(md).Input(id).ObservationPoints(j).N=handles.Model(md).Input(id).ObservationPoints(j+1).N;
        handles.Model(md).Input(id).ObservationPoints(j).x=handles.Model(md).Input(id).ObservationPoints(j+1).x;
        handles.Model(md).Input(id).ObservationPoints(j).y=handles.Model(md).Input(id).ObservationPoints(j+1).y;
        handles.Model(md).Input(id).ObservationPoints(j).Name=handles.Model(md).Input(id).ObservationPoints(j+1).Name;
    end
    handles.Model(md).Input(id).ObservationPoints=handles.Model(md).Input(id).ObservationPoints(1:end-1);
else
    handles.Model(md).Input(id).ObservationPoints=[];
end
handles.Model(md).Input(id).NrObservationPoints=handles.Model(md).Input(id).NrObservationPoints-1;
if handles.Model(md).Input(id).NrObservationPoints>0
    if handles.GUIData.ActiveObservationPoint==handles.Model(md).Input(id).NrObservationPoints+1
        handles.GUIData.ActiveObservationPoint=handles.GUIData.ActiveObservationPoint-1;
    end
end
RefreshObservationPoints(handles);

%%
function RefreshObservationPoints(handles)

id=ad;
nr=handles.Model(md).Input(id).NrObservationPoints;
n=max(handles.GUIData.ActiveObservationPoint,1);

if nr>0
    set(handles.GUIHandles.ListObservationPoints,'Value',n);
    for k=1:nr
        str{k}=handles.Model(md).Input(id).ObservationPoints(k).Name;
    end
    set(handles.GUIHandles.ListObservationPoints,'String',str);
    set(handles.GUIHandles.EditObsName,'String',handles.Model(md).Input(id).ObservationPoints(n).Name);
    set(handles.GUIHandles.EditObsM,'String',handles.Model(md).Input(id).ObservationPoints(n).M);
    set(handles.GUIHandles.EditObsN,'String',handles.Model(md).Input(id).ObservationPoints(n).N);
    set(handles.GUIHandles.EditObsName,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.EditObsM,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.EditObsN,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.TextName,'Enable','on');
    set(handles.GUIHandles.TextM,   'Enable','on');
    set(handles.GUIHandles.TextN,   'Enable','on');
    set(handles.GUIHandles.PushSaveObservationPoints,   'Enable','on');
else
    set(handles.GUIHandles.EditObsName,'String','');
    set(handles.GUIHandles.EditObsName,'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
    set(handles.GUIHandles.EditObsM,'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
    set(handles.GUIHandles.EditObsN,'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
    set(handles.GUIHandles.TextName,'Enable','off');
    set(handles.GUIHandles.TextM,   'Enable','off');
    set(handles.GUIHandles.TextN,   'Enable','off');
    set(handles.GUIHandles.ListObservationPoints,'String','');
    set(handles.GUIHandles.ListObservationPoints,'Value',1);
    set(handles.GUIHandles.EditObsM,'String',[]);
    set(handles.GUIHandles.EditObsN,'String',[]);
    set(handles.GUIHandles.PushSaveObservationPoints,   'Enable','off');
end

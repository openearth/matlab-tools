function ddb_editD3DFlowTransportConditionsTimeSeries

h=getHandles;

kmax=h.Model(md).Input(ad).KMax;
handles.KMax=kmax;

ii=h.Model(md).Input(ad).activeOpenBoundary;
handles.Bnd=h.Model(md).Input(ad).openBoundaries(ii);

handles.activeConstituent=1;

k=0;
if h.Model(md).Input(ad).salinity.include
    k=k+1;
    handles.Constituents{k}='Salinity';
    handles.Constituent(k)=handles.Bnd.salinity;
end
if h.Model(md).Input(ad).temperature.include
    k=k+1;
    handles.Constituents{k}='Temperature';
    handles.Constituent(k)=handles.Bnd.temperature;
end
if h.Model(md).Input(ad).sediments
    for j=1:h.Model(md).Input(ad).nrSediments
        k=k+1;
        handles.Constituents{k}=h.Model(md).Input(ad).sediment(j).name;
        handles.Constituent(k)=handles.Bnd.sediment(j);
    end
end
if h.Model(md).Input(ad).tracers
    for j=1:h.Model(md).Input(ad).nrTracers
        k=k+1;
        handles.Constituents{k}=h.Model(md).Input(ad).tracer(j).name;
        handles.Constituent(k)=handles.Bnd.tracer(j);
    end
end

% prf=handles.Bnd.profile;

%MakeNewWindow('Time Series Transport Boundary Conditions',[590 490],'modal',[h.settingsDir '\icons\deltares.gif']);
MakeNewWindow('Time Series Transport Boundary Conditions',[590 490],[h.settingsDir '\icons\deltares.gif']);

uipanel('Title','Time Series', 'Units','pixels','Position',[40 80 510 230],'Tag','UIControl');

cltp={'edittime','editreal','editreal','editreal','editreal'};
callbacks={@EditTable,@EditTable,@EditTable,@EditTable,@EditTable};
wdt=[120 60 60 60 60];
for i=1:2
    data{i,1}=now;
    data{i,2}=0;
    data{i,3}=0;
    data{i,4}=0;
    data{i,5}=0;
end
handles.GUIHandles.table=table(gcf,'create','tag','table','position',[50 90],'nrrows',8,'columntypes',cltp,'width',wdt,'data',data,'callbacks',callbacks,'includebuttons',1);

handles.GUIHandles.TextTime                = uicontrol(gcf,'Style','text','String','Time','Position',[50 265 120 15],'HorizontalAlignment','center');
handles.GUIHandles.Textyyyy                = uicontrol(gcf,'Style','text','String','yyyy mm dd HH MM SS','Position',[50 250 120 15],'HorizontalAlignment','center');

handles.GUIHandles.TextEndASurface         = uicontrol(gcf,'Style','text','String','End A',  'Position',[170 265 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextSurfaceA            = uicontrol(gcf,'Style','text','String','Surface','Position',[170 250 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextEndBSurface         = uicontrol(gcf,'Style','text','String','End B',  'Position',[230 265 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextSurfaceB            = uicontrol(gcf,'Style','text','String','Surface','Position',[230 250 60 15],'HorizontalAlignment','center');

handles.GUIHandles.TextEndABottom          = uicontrol(gcf,'Style','text','String','End A',  'Position',[290 265 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextBottomA             = uicontrol(gcf,'Style','text','String','Bottom', 'Position',[290 250 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextEndBBottom          = uicontrol(gcf,'Style','text','String','End B',  'Position',[350 265 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextBottomB             = uicontrol(gcf,'Style','text','String','Bottom', 'Position',[350 250 60 15],'HorizontalAlignment','center');

uipanel('Title','Boundary Section','Units','pixels','Position',[40 320 390 150]);
handles.GUIHandles.TextBoundary      = uicontrol(gcf,'Style','text','String','Boundary :' ,'Position',[50 430 200 20],'HorizontalAlignment','left');
handles.GUIHandles.TextBoundaryName  = uicontrol(gcf,'Style','text','String',handles.Bnd.name,'Position',[125 430 150 20],'HorizontalAlignment','left');
handles.GUIHandles.TextConstituent   = uicontrol(gcf,'Style','text','String','Quantity :','Position',[50 406 200 20],'HorizontalAlignment','left');
handles.GUIHandles.SelectConstituent = uicontrol(gcf,'Style','popupmenu','String',handles.Constituents,'Position',[125 410 100 20],'BackgroundColor',[1 1 1]);
handles.GUIHandles.TextProfile     = uicontrol(gcf,'Style','text','String','Profile :','Position',[50 381 200 20],'HorizontalAlignment','left');
handles.profiles={'Uniform','Linear','Step','Per Layer'};
handles.GUIHandles.SelectProfile   = uicontrol(gcf,'Style','popupmenu','String',handles.profiles,'Position',[125 385 100 20],'BackgroundColor',[1 1 1]);
handles.GUIHandles.TextProfileJump = uicontrol(gcf,'Style','text','String','Step (m) :','Position',[50 356 200 20],'HorizontalAlignment','left');
handles.GUIHandles.EditProfileJump = uicontrol(gcf,'Style','edit','String',' ','Position',[125 360 100 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1]);
for k=1:kmax
    str{k}=num2str(k);
end
handles.GUIHandles.TextLayer   = uicontrol(gcf,'Style','text','String','Layer : ','Position',[50 331 50 20],'HorizontalAlignment','left');
handles.GUIHandles.SelectLayer = uicontrol(gcf,'Style','popupmenu','String',str,'Position',[125 335 30 20],'BackgroundColor',[1 1 1]);

handles.GUIHandles.PushOK     = uicontrol(gcf,'Style','pushbutton','String','OK',    'Position',[370 30 60 20]);
handles.GUIHandles.PushCancel = uicontrol(gcf,'Style','pushbutton','String','Cancel','Position',[300 30 60 20]);

set(handles.GUIHandles.PushOK,              'Callback',{@PushOK_Callback});
set(handles.GUIHandles.PushCancel,          'Callback',{@PushCancel_Callback});
set(handles.GUIHandles.SelectLayer,         'Callback',{@SelectLayer_Callback});
set(handles.GUIHandles.SelectConstituent,   'Callback',{@SelectConstituent_Callback});
set(handles.GUIHandles.SelectProfile,       'Callback',{@SelectProfile_Callback});
set(handles.GUIHandles.EditProfileJump,     'Callback',{@EditProfileJump_Callback});

SetUIBackgroundColors;

RefreshAll(handles);

guidata(gcf,handles);

%%
function PushOK_Callback(hObject,eventdata)

handles=guidata(gcf);
h=getHandles;
ib=h.Model(md).Input(ad).activeOpenBoundary;
ic=0;
if h.Model(md).Input(ad).salinity.include
    ic=ic+1;
    h.Model(md).Input(ad).openBoundaries(ib).salinity=handles.Constituent(ic);
end
if h.Model(md).Input(ad).temperature.include
    ic=ic+1;
    h.Model(md).Input(ad).openBoundaries(ib).temperature=handles.Constituent(ic);
end
if h.Model(md).Input(ad).sediments
    for j=1:h.Model(md).Input(ad).nrSediments
        ic=ic+1;
        h.Model(md).Input(ad).openBoundaries(ib).sediment(j)=handles.Constituent(ic);
    end
end
if h.Model(md).Input(ad).tracers
    for j=1:h.Model(md).Input(ad).nrTracers
        ic=ic+1;
        h.Model(md).Input(ad).openBoundaries(ib).tracer(j)=handles.Constituent(ic);
    end
end
setHandles(h);
closereq;

%%
function PushCancel_Callback(hObject,eventdata)
closereq;

%%
function SelectConstituent_Callback(hObject,eventdata)
handles=guidata(gcf);
k=get(hObject,'Value');
handles.activeConstituent=k;
RefreshAll(handles);
guidata(gcf,handles);

%%
function SelectLayer_Callback(hObject,eventdata)
handles=guidata(gcf);
RefreshTable(handles);
guidata(gcf,handles);

%%
function SelectProfile_Callback(hObject,eventdata)
handles=guidata(gcf);
k=get(hObject,'Value');
ic=handles.activeConstituent;
switch k
    case 1
        handles.Constituent(ic).profile='Uniform';
    case 2
        handles.Constituent(ic).profile='Linear';
    case 3
        handles.Constituent(ic).profile='Step';
    case 4
        handles.Constituent(ic).profile='3D-Profile';
end
nr=handles.Constituent(ic).nrTimeSeries;
switch handles.Constituent(ic).profile
    case{'Linear','Step'}
        if size(handles.Constituent(ic).timeSeriesA,2)<2
            handles.Constituent(ic).timeSeriesA(:,2)=handles.Constituent(ic).timeSeriesA(:,1);
            handles.Constituent(ic).timeSeriesB(:,2)=handles.Constituent(ic).timeSeriesB(:,1);
        end
    case{'3D-Profile'}
        kmax=handles.KMax;
        if size(handles.Constituent(ic).timeSeriesA,2)<kmax
            if kmax>1
                for i=2:kmax
                    handles.Constituent(ic).timeSeriesA(:,i)=handles.Constituent(ic).timeSeriesA(:,1);
                    handles.Constituent(ic).timeSeriesB(:,i)=handles.Constituent(ic).timeSeriesB(:,1);
                end
            end
        end
end
guidata(gcf,handles);
RefreshAll(handles);

%%
function EditProfileJump_Callback(hObject,eventdata)
handles=guidata(gcf);
ic=handles.activeConstituent;
str=get(hObject,'String');
handles.Constituent(ic).discontinuity=str2double(str);
guidata(gcf,handles);

%%
function EditTable
handles=guidata(gcf);
k=get(handles.GUIHandles.SelectLayer,'Value');
ic=handles.activeConstituent;
data=table(handles.GUIHandles.table,'getdata');
nr=size(data,1);
for i=1:nr
    switch lower(handles.Constituent(ic).profile)
        case{'linear','step'}
            handles.Constituent(ic).timeSeriesT(i)=data{i,1};
            handles.Constituent(ic).timeSeriesA(i,1)=data{i,2};
            handles.Constituent(ic).timeSeriesB(i,1)=data{i,3};
            handles.Constituent(ic).timeSeriesA(i,2)=data{i,4};
            handles.Constituent(ic).timeSeriesB(i,2)=data{i,5};
        otherwise
            handles.Constituent(ic).timeSeriesT(i)=data{i,1};
            handles.Constituent(ic).timeSeriesA(i,k)=data{i,2};
            handles.Constituent(ic).timeSeriesB(i,k)=data{i,3};
    end
end
handles.Constituent(ic).nrTimeSeries=nr;
guidata(gcf,handles);

%%
function RefreshAll(handles)

ic=handles.activeConstituent;
if handles.KMax>1
    set(handles.GUIHandles.TextProfile,'Enable','on');
    set(handles.GUIHandles.SelectProfile,'Enable','on');
    set(handles.GUIHandles.SelectProfile,'String',handles.profiles);
    prf=handles.Constituent(ic).profile;
    switch lower(prf)
        case{'uniform'}
            set(handles.GUIHandles.SelectProfile,'Value',1);
        case{'linear'}
            set(handles.GUIHandles.SelectProfile,'Value',2);
        case{'step'}
            set(handles.GUIHandles.SelectProfile,'Value',3);
        case{'3d-profile'}
            set(handles.GUIHandles.SelectProfile,'Value',4);
    end
    switch lower(prf)
        case{'uniform','linear','step'}
            set(handles.GUIHandles.SelectLayer,'Enable','off');
            set(handles.GUIHandles.SelectLayer,'Value',1);
            set(handles.GUIHandles.TextLayer,  'Enable','off');
        case{'3d-profile'}
            set(handles.GUIHandles.SelectLayer,'Enable','on');
            set(handles.GUIHandles.TextLayer,  'Enable','on');
    end
    switch lower(prf)
        case{'uniform','3d-profile'}
            set(handles.GUIHandles.TextBottomA,   'Visible','off');
            set(handles.GUIHandles.TextEndABottom,'Visible','off');
            set(handles.GUIHandles.TextBottomB,   'Visible','off');
            set(handles.GUIHandles.TextEndBBottom,'Visible','off');
            set(handles.GUIHandles.TextSurfaceA,  'Visible','off');
            set(handles.GUIHandles.TextSurfaceB,  'Visible','off');
        otherwise
            set(handles.GUIHandles.TextBottomA,   'Visible','on');
            set(handles.GUIHandles.TextEndABottom,'Visible','on');
            set(handles.GUIHandles.TextBottomB,   'Visible','on');
            set(handles.GUIHandles.TextEndBBottom,'Visible','on');
            set(handles.GUIHandles.TextSurfaceA,  'Visible','on');
            set(handles.GUIHandles.TextSurfaceB,  'Visible','on');
    end
    if strcmpi(prf,'step')
        set(handles.GUIHandles.TextProfileJump,'Enable','on');
        set(handles.GUIHandles.EditProfileJump,'Enable','on');
        set(handles.GUIHandles.EditProfileJump,'String',num2str(handles.Constituent(ic).discontinuity));
    else
        set(handles.GUIHandles.TextProfileJump,'Enable','off');
        set(handles.GUIHandles.EditProfileJump,'Enable','off');
        set(handles.GUIHandles.EditProfileJump,'String','');
    end
else
    set(handles.GUIHandles.TextProfile,'Enable','off');
    set(handles.GUIHandles.SelectProfile,'Enable','off');
    set(handles.GUIHandles.TextProfileJump,'Enable','off');
    set(handles.GUIHandles.EditProfileJump,'Enable','off');
    set(handles.GUIHandles.EditProfileJump,'String','');
end

RefreshTable(handles);

%%
function RefreshTable(handles)
k=get(handles.GUIHandles.SelectLayer,'Value');
ic=handles.activeConstituent;
enab=zeros(8,5)+1;
switch lower(handles.Constituent(ic).profile)
    case{'linear','step'}
        for i=1:handles.Constituent(ic).nrTimeSeries
            data{i,1}=handles.Constituent(ic).timeSeriesT(i);
            data{i,2}=handles.Constituent(ic).timeSeriesA(i,1);
            data{i,3}=handles.Constituent(ic).timeSeriesB(i,1);
            data{i,4}=handles.Constituent(ic).timeSeriesA(i,2);
            data{i,5}=handles.Constituent(ic).timeSeriesB(i,2);
        end
    otherwise
        for i=1:handles.Constituent(ic).nrTimeSeries
            data{i,1}=handles.Constituent(ic).timeSeriesT(i);
            data{i,2}=handles.Constituent(ic).timeSeriesA(i,k);
            data{i,3}=handles.Constituent(ic).timeSeriesB(i,k);
            data{i,4}=[];
            data{i,5}=[];
        end
        enab(:,end-1:end)=0;
end

%enable=[1 1 1 0 0];

table(handles.GUIHandles.table,'setdata',data);
table(handles.GUIHandles.table,'refresh','enable',enab);

function ddb_editD3DFlowConditionsAstronomic

h=getHandles;

handles=h.Model(md).Input(ad);
handles.GUIData.ActiveOpenBoundary=h.GUIData.ActiveOpenBoundary;

a=load([h.TideDir '\t_constituents.mat']);
handles.ComponentNames=cellstr(a.const.name);

if handles.NrAstronomicComponentSets==0
    handles.NrAstronomicComponentSets=1;
    handles.AstronomicComponentSets.Name='unnamed';
    handles.AstronomicComponentSets.Nr=2;
    handles.AstronomicComponentSets.Component{1}='M2';
    handles.AstronomicComponentSets.Component{2}='S2';
    handles.AstronomicComponentSets.Amplitude(1)=1.0;
    handles.AstronomicComponentSets.Amplitude(2)=1.0;
    handles.AstronomicComponentSets.Phase(1)=0.0;
    handles.AstronomicComponentSets.Phase(2)=0.0;
    handles.AstronomicComponentSets.Correction(1)=0;
    handles.AstronomicComponentSets.Correction(2)=0;
    handles.AstronomicComponentSets.AmplitudeCorrection(1)=0;
    handles.AstronomicComponentSets.AmplitudeCorrection(2)=0;
    handles.AstronomicComponentSets.PhaseCorrection(1)=0;
    handles.AstronomicComponentSets.PhaseCorrection(2)=0;
else
    for i=1:handles.NrAstronomicComponentSets
        str{i}=handles.AstronomicComponentSets(i).Name;
    end
    k1=strmatch('unnamed',str,'exact');
    if isempty(k1) && (strcmp(handles.OpenBoundaries(handles.GUIData.ActiveOpenBoundary).CompA,'unnamed') || strcmp(handles.OpenBoundaries(handles.GUIData.ActiveOpenBoundary).CompB,'unnamed'))
        n=handles.NrAstronomicComponentSets+1;
        handles.NrAstronomicComponentSets=n;
        handles.AstronomicComponentSets(n).Name='unnamed';
        handles.AstronomicComponentSets(n).Nr=2;
        handles.AstronomicComponentSets(n).Component{1}='M2';
        handles.AstronomicComponentSets(n).Component{2}='S2';
        handles.AstronomicComponentSets(n).Amplitude(1)=1.0;
        handles.AstronomicComponentSets(n).Amplitude(2)=1.0;
        handles.AstronomicComponentSets(n).Phase(1)=0.0;
        handles.AstronomicComponentSets(n).Phase(2)=0.0;
        handles.AstronomicComponentSets(n).Correction(1)=0;
        handles.AstronomicComponentSets(n).Correction(2)=0;
        handles.AstronomicComponentSets(n).AmplitudeCorrection(1)=0;
        handles.AstronomicComponentSets(n).AmplitudeCorrection(2)=0;
        handles.AstronomicComponentSets(n).PhaseCorrection(1)=0;
        handles.AstronomicComponentSets(n).PhaseCorrection(2)=0;
    end
end

MakeNewWindow('Astronomic Boundary Conditions',[750 600],'modal',[h.SettingsDir '\icons\deltares.gif']);

uipanel('Title','Component Sets','Units','pixels','Position',[20 370 360 210],'Tag','UIControl');
for i=1:handles.NrAstronomicComponentSets
    handles.ComponentSets{i}=handles.AstronomicComponentSets(i).Name;
end
ii=strmatch(handles.OpenBoundaries(handles.GUIData.ActiveOpenBoundary).CompA,handles.ComponentSets,'exact');
handles.ActiveComponentSet=handles.ComponentSets{ii};
handles.GUIHandles.TextSelectedComponentSets=uicontrol(gcf,'Style','text','String','Selected Component Sets','Position',[510 450 130 20],'HorizontalAlignment','center');
handles.GUIHandles.ListComponentSets      = uicontrol(gcf,'Style','listbox','String',handles.ComponentSets,'Value',ii,'Position',[40 390 150 150],'HorizontalAlignment','left',  'BackgroundColor',[1 1 1]);
handles.GUIHandles.TextComponentSets      = uicontrol(gcf,'Style','text','String','Available Sets','Position',[40 540 150 20], 'HorizontalAlignment','center');
handles.GUIHandles.PushAddComponentSet    = uicontrol(gcf,'Style','pushbutton','String','Add',   'Position',[210 520 60 20]);
handles.GUIHandles.PushDeleteComponentSet = uicontrol(gcf,'Style','pushbutton','String','Delete','Position',[210 490 60 20]);
handles.GUIHandles.EditComponentSetName   = uicontrol(gcf,'Style','edit','Position',[210 390 150 20],'BackgroundColor',[1 1 1],'HorizontalAlignment','left');
handles.GUIHandles.TextComponentSetName   = uicontrol(gcf,'Style','text','String','Selected Set','Position',[210 410 150 20],'HorizontalAlignment','center');

set(handles.GUIHandles.EditComponentSetName,'String',handles.ActiveComponentSet);
set(handles.GUIHandles.PushAddComponentSet,'Enable','off');
set(handles.GUIHandles.PushDeleteComponentSet,'Enable','off');

set(handles.GUIHandles.ListComponentSets,   'CallBack',{@ListComponentSets_CallBack});
set(handles.GUIHandles.EditComponentSetName,'CallBack',{@EditComponentSetName_CallBack});

handles.GUIHandles.PushViewTimeSeries    = uicontrol(gcf,'Style','pushbutton','String','View',   'Position',[210 460 60 20]);
set(handles.GUIHandles.PushViewTimeSeries,   'CallBack',{@PushViewTimeSeries_CallBack});

%

switch handles.OpenBoundaries(handles.GUIData.ActiveOpenBoundary).Type,
    case{'Z'}
        quant='Water Level';
        unit='m';
    case{'C'}
        quant='Velocity';
        unit='m/s';
    case{'N'}
        quant='Water Level Gradient';
        unit='-';
    case{'T'}
        quant='Total Discharge';
        unit='m^3/s';
    case{'Q'}
        quant='Discharge per Cell';
        unit='m^3/s';
    case{'R'}
        quant='Riemann';
        unit='m/s';
end

uipanel('Title','Boundary Section','Units','pixels','Position',[450 370 250 210]);
handles.GUIHandles.TextBoundary = uicontrol(gcf,'Style','text','String','Boundary :' ,'Position',[470 530 200 20],'HorizontalAlignment','left');
handles.GUIHandles.TextBoundaryName = uicontrol(gcf,'Style','text','String',handles.OpenBoundaries(handles.GUIData.ActiveOpenBoundary).Name,'Position',[545 530 150 20],'HorizontalAlignment','left');
handles.GUIHandles.TextQuantity   = uicontrol(gcf,'Style','text','String','Quantity :','Position',[470 510 200 20],'HorizontalAlignment','left');
handles.GUIHandles.TextQuantity   = uicontrol(gcf,'Style','text','String',quant,'Position',[545 510 150 20],'HorizontalAlignment','left');
handles.GUIHandles.TextForcingType = uicontrol(gcf,'Style','text','String','Forcing Type :','Position',[470 490 150 20],'HorizontalAlignment','left');
handles.GUIHandles.TextForcingType = uicontrol(gcf,'Style','text','String','Astronomic','Position',[545 490 150 20],'HorizontalAlignment','left');

handles.GUIHandles.TextBoundarySectionA=uicontrol(gcf,'Style','text','String','End A','Position',[470 427 100 20],'HorizontalAlignment','left');
handles.GUIHandles.SelectBoundarySectionA =uicontrol(gcf,'Style','popupmenu','String',handles.ComponentSets,'Position',[510 430 130 20],'BackgroundColor',[1 1 1]);
ii=strmatch(handles.OpenBoundaries(handles.GUIData.ActiveOpenBoundary).CompA,handles.ComponentSets,'exact');
if ~isempty(ii)
    set(handles.GUIHandles.SelectBoundarySectionA,'Value',ii);
else
    GiveWarning('Warning',[handles.OpenBoundaries(handles.GUIData.ActiveOpenBoundary).CompA ' does not exist!']);
    return
end

handles.GUIHandles.TextBoundarySectionB=uicontrol(gcf,'Style','text','String','End B','Position',[470 397 100 20],'HorizontalAlignment','left');
handles.GUIHandles.SelectBoundarySectionB =uicontrol(gcf,'Style','popupmenu','String',handles.ComponentSets,'Position',[510 400 130 20],'BackgroundColor',[1 1 1]);
ii=strmatch(handles.OpenBoundaries(handles.GUIData.ActiveOpenBoundary).CompB,handles.ComponentSets,'exact');
if ~isempty(ii)
    set(handles.GUIHandles.SelectBoundarySectionB,'Value',ii);
else
    GiveWarning('Warning',[handles.OpenBoundaries(handles.GUIData.ActiveOpenBoundary).CompA ' does not exist!']);
    return
end

set(handles.GUIHandles.SelectBoundarySectionA,'CallBack',{@SelectBoundarySectionA_CallBack});
set(handles.GUIHandles.SelectBoundarySectionB,'CallBack',{@SelectBoundarySectionB_CallBack});

handles.GUIHandles.panel2=uipanel('Title','Astronomical Data for Set ...','Units','pixels','Position',[20 80 710 280],'Tag','UIControl');
set(handles.GUIHandles.panel2,'Title',['Astronomical Data for Set ' handles.ActiveComponentSet]);

uipanel('Title','Conditions', 'Units','pixels','Position',[40 100 390 230],'Tag','UIControl');

RefreshComponentSet(handles);
guidata(findobj('Name','Astronomic Boundary Conditions'),handles);
RefreshCorrections;

handles.GUIHandles.TextComponentName       = uicontrol(gcf,'Style','text','String','Name','Position',[60 280 80 30],'HorizontalAlignment','center');
handles.GUIHandles.TextAmplitude           = uicontrol(gcf,'Style','text','String',['Amplitude (' unit ')'],'Position',[150 280 50 30],'HorizontalAlignment','center');
handles.GUIHandles.TextPhase               = uicontrol(gcf,'Style','text','String','Phase (deg)','Position',[230 280 50 30],'HorizontalAlignment','center');
handles.GUIHandles.TextCorrection          = uicontrol(gcf,'Style','text','String','Correction','Position',[280 280 50 30],'HorizontalAlignment','left');

uipanel('Title','Corrections','Units','pixels','Position',[450 100 250 230],'Tag','UIControl');
handles.GUIHandles.TextCorrectionName       = uicontrol(gcf,'Style','text','String','Name','Position',[470 280 80 30],'HorizontalAlignment','center');
handles.GUIHandles.TextCorrectionAmplitude  = uicontrol(gcf,'Style','text','String','Amplitude (m)','Position',[550 280 50 30],'HorizontalAlignment','center');
handles.GUIHandles.TextCorrectionPhase      = uicontrol(gcf,'Style','text','String','Phase (deg)','Position',[600 280 50 30],'HorizontalAlignment','center');

handles.GUIHandles.PushOK     = uicontrol(gcf,'Style','pushbutton','String','OK',    'Position',[670 30 60 30]);
handles.GUIHandles.PushCancel = uicontrol(gcf,'Style','pushbutton','String','Cancel','Position',[600 30 60 30]);

set(handles.GUIHandles.PushOK,              'CallBack',{@PushOK_CallBack});
set(handles.GUIHandles.PushCancel,          'CallBack',{@PushCancel_CallBack});

SetUIBackgroundColors;

guidata(findobj('Name','Astronomic Boundary Conditions'),handles);

%%
function ListComponentSets_CallBack(hObject,eventdata)
handles=guidata(findobj('Name','Astronomic Boundary Conditions'));
str=handles.ComponentSets;
str=str{get(hObject,'Value')};
%if ~strcmp(str,handles.ActiveComponentSet)
    [handles,ok]=ChangeData(handles);
    if ok==1
        handles.ActiveComponentSet=str;
        set(handles.GUIHandles.EditComponentSetName,'String',handles.ActiveComponentSet);
        set(handles.GUIHandles.panel2,'Title',['Astronomical Data for Set ' handles.ActiveComponentSet]);
        RefreshComponentSet(handles);
        guidata(findobj('Name','Astronomic Boundary Conditions'),handles);
        RefreshCorrections;
    else
        ii=strmatch(handles.ActiveComponentSet,handles.ComponentSets,'exact');
        set(hObject,'Value',ii);
    end
%end

%%
function EditComponentSetName_CallBack(hObject,eventdata)
handles=guidata(findobj('Name','Astronomic Boundary Conditions'));
ii=get(handles.GUIHandles.ListComponentSets,'Value');
name=get(hObject,'String');
handles.AstronomicComponentSets(ii).Name=name;
handles.ComponentSets{ii}=name;
set(handles.GUIHandles.ListComponentSets,'String',handles.ComponentSets);
set(handles.GUIHandles.SelectBoundarySectionA,'String',handles.ComponentSets);
set(handles.GUIHandles.SelectBoundarySectionB,'String',handles.ComponentSets);
k=get(handles.GUIHandles.SelectBoundarySectionA,'Value');
str=get(handles.GUIHandles.SelectBoundarySectionA,'String');
if strcmp(str{k},handles.ActiveComponentSet)
    handles.OpenBoundaries(handles.GUIData.ActiveOpenBoundary).CompA=name;
end
set(handles.GUIHandles.SelectBoundarySectionA,'String',handles.ComponentSets);
k=get(handles.GUIHandles.SelectBoundarySectionB,'Value');
str=get(handles.GUIHandles.SelectBoundarySectionB,'String');
if strcmp(str{k},handles.ActiveComponentSet)
    handles.OpenBoundaries(handles.GUIData.ActiveOpenBoundary).CompB=name;
end
set(handles.GUIHandles.SelectBoundarySectionB,'String',handles.ComponentSets);
handles.ActiveComponentSet=handles.ComponentSets{ii};
set(handles.GUIHandles.panel2,'Title',['Astronomical Data for Set ' handles.ActiveComponentSet]);
guidata(findobj('Name','Astronomic Boundary Conditions'),handles);

%%
function SelectBoundarySectionA_CallBack(hObject,eventdata,icomp)
handles=guidata(findobj('Name','Astronomic Boundary Conditions'));
ii=get(hObject,'Value');
str=get(hObject,'String');
handles.OpenBoundaries(handles.GUIData.ActiveOpenBoundary).CompA=str{ii};
guidata(findobj('Name','Astronomic Boundary Conditions'),handles);

%%
function SelectBoundarySectionB_CallBack(hObject,eventdata,icomp)
handles=guidata(findobj('Name','Astronomic Boundary Conditions'));
ii=get(hObject,'Value');
str=get(hObject,'String');
handles.OpenBoundaries(handles.GUIData.ActiveOpenBoundary).CompB=str{ii};
guidata(findobj('Name','Astronomic Boundary Conditions'),handles);

%%
function PushOK_CallBack(hObject,eventdata)

h2=guidata(findobj('Name','Astronomic Boundary Conditions'));

handles=getHandles;

[h2,ok]=ChangeData(h2);
if ok==1
    for i=1:h2.NrOpenBoundaries
        if strcmp(h2.OpenBoundaries(i).Forcing,'A')
            stra{i}=h2.OpenBoundaries(i).CompA;
            strb{i}=h2.OpenBoundaries(i).CompB;
        else
            stra{i}=' ';
            strb{i}=' ';
        end
    end
    for i=1:h2.NrAstronomicComponentSets
        str{i}=h2.AstronomicComponentSets(i).Name;
    end
    k1=strmatch('unnamed',stra,'exact');
    k2=strmatch('unnamed',strb,'exact');
    k3=strmatch('unnamed',str,'exact');
    if isempty(k1) && isempty(k2) && ~isempty(k3>0)
        % component set unname has become unnecessary
        for j=k3:h2.NrAstronomicComponentSets-1
            h2.AstronomicComponentSets(j)=h2.AstronomicComponentSets(j+1);
        end
        h2.AstronomicComponentSets=h2.AstronomicComponentSets(1:end-1);
        h2.NrAstronomicComponentSets=h2.NrAstronomicComponentSets-1;
    end
    handles.Model(md).Input(ad).AstronomicComponentSets=h2.AstronomicComponentSets;
    handles.Model(md).Input(ad).NrAstronomicComponentSets=h2.NrAstronomicComponentSets;
    handles.Model(md).Input(ad).OpenBoundaries=h2.OpenBoundaries;
    setHandles(handles);
    closereq;
end

%%

function PushCancel_CallBack(hObject,eventdata)
closereq;

%%

function RefreshComponentSet(handles)

cltp={'popupmenu','editreal','editreal','checkbox'};
wdt=[80 80 80 20];
callbacks={'','','',@RefreshCorrections};

ii=get(handles.GUIHandles.ListComponentSets,'Value');
for i=1:handles.AstronomicComponentSets(ii).Nr
    data{i,1}=handles.AstronomicComponentSets(ii).Component{i};
    data{i,2}=handles.AstronomicComponentSets(ii).Amplitude(i);
    data{i,3}=handles.AstronomicComponentSets(ii).Phase(i);
    data{i,4}=handles.AstronomicComponentSets(ii).Correction(i);
end
for i=1:length(handles.ComponentNames)
    ppm{i,1}=handles.ComponentNames{i};
    ppm{i,2}='';
    ppm{i,3}='';
end

tb=table(gcf,'table','find');
if ~isempty(tb)
    table(gcf,'table','change','data',data);
else
    table(gcf,'table','create','position',[50 110],'nrrows',8,'columntypes',cltp,'width',wdt,'data',data,'popuptext',ppm,'callbacks',callbacks,'includebuttons');
end

%%

function RefreshCorrections

handles=guidata(findobj('Name','Astronomic Boundary Conditions'));
[handles,ok]=ChangeData(handles);
guidata(findobj('Name','Astronomic Boundary Conditions'),handles);

cltp={'pushbutton','editreal','editreal'};
enab=zeros(8,3)+1;
enab(:,1)=0;
wdt=[80 60 60];
ii=get(handles.GUIHandles.ListComponentSets,'Value');
k=0;
for i=1:handles.AstronomicComponentSets(ii).Nr
    if handles.AstronomicComponentSets(ii).Correction(i)
        k=k+1;
        data{k,1}=handles.AstronomicComponentSets(ii).Component{i};
        data{k,2}=handles.AstronomicComponentSets(ii).AmplitudeCorrection(i);
        data{k,3}=handles.AstronomicComponentSets(ii).PhaseCorrection(i);
    end
end
if k>0
    tb=table(gcf,'correctiontable','find');
    if ~isempty(tb)
        table(gcf,'correctiontable','change','data',data);
    else
        table(gcf,'correctiontable','create','position',[460 110],'nrrows',8,'columntypes',cltp,'width',wdt,'data',data,'enable',enab);
    end
else
    table(gcf,'correctiontable','delete');
end

%%
function [handles,ok]=ChangeData(handles)
ok=1;
data=table(gcf,'table','getdata');
for i=1:size(data,1)
    for j=i:size(data,1)
        if strcmp(data{i,1},data{j,1}) && i~=j
            ok=0;
            GiveWarning('Warning',['Component ' data{i,1} ' found more than once!']);
            return;
        end
    end
end
ii=strmatch(handles.ActiveComponentSet,handles.ComponentSets,'exact');
handles.AstronomicComponentSets(ii).Nr=size(data,1);
handles.AstronomicComponentSets(ii).Component=[];
handles.AstronomicComponentSets(ii).Amplitude=[];
handles.AstronomicComponentSets(ii).Phase=[];
handles.AstronomicComponentSets(ii).Correction=[];
for i=1:handles.AstronomicComponentSets(ii).Nr
    handles.AstronomicComponentSets(ii).Component{i}=data{i,1};
    handles.AstronomicComponentSets(ii).Amplitude(i)=data{i,2};
    handles.AstronomicComponentSets(ii).Phase(i)=data{i,3};
    handles.AstronomicComponentSets(ii).Correction(i)=data{i,4};
    if handles.AstronomicComponentSets(ii).Correction(i)
        data2=table(gcf,'correctiontable','getdata');
        for j=1:size(data2,1)
            if strcmp(data2{j,1},handles.AstronomicComponentSets(ii).Component{i})
                handles.AstronomicComponentSets(ii).AmplitudeCorrection(i)=data2{j,2};
                handles.AstronomicComponentSets(ii).PhaseCorrection(i)=data2{j,3};
            end
        end
    end
end

%%
function PushViewTimeSeries_CallBack(hObject,eventdata)
handles=guidata(findobj('Name','Astronomic Boundary Conditions'));
h=guidata(findobj('Tag','MainWindow'));
ii=get(handles.GUIHandles.ListComponentSets,'Value');
for i=1:handles.AstronomicComponentSets(ii).Nr
    cmp{i}=handles.AstronomicComponentSets(ii).Component{i};
    A(i,1)=handles.AstronomicComponentSets(ii).Amplitude(i);
    G(i,1)=handles.AstronomicComponentSets(ii).Phase(i);
    data{i,4}=handles.AstronomicComponentSets(ii).Correction(i);
end
t0=h.Model(find(strcmp('Delft3DFLOW',{h.Model.Name}))).Input(h.ActiveDomain).StartTime;
t1=h.Model(find(strcmp('Delft3DFLOW',{h.Model.Name}))).Input(h.ActiveDomain).StopTime;
dt=h.Model(find(strcmp('Delft3DFLOW',{h.Model.Name}))).Input(h.ActiveDomain).TimeStep/60;

[prediction,times]=delftPredict2007(cmp,A,G,t0,t1,dt);
ddb_plotTimeSeries(times,prediction,'');

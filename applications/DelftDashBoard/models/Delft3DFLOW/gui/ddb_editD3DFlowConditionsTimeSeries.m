function ddb_editD3DFlowConditionsTimeSeries

h=getHandles;

kmax=h.Model(md).Input(ad).KMax;
handles.KMax=kmax;

ibnd=h.GUIData.ActiveOpenBoundary;

handles.Bnd=h.Model(md).Input(ad).OpenBoundaries(ibnd);

prf=handles.Bnd.Profile;

MakeNewWindow('Time Series Boundary Conditions',[470 470],'modal',[h.SettingsDir '\icons\deltares.gif']);

uipanel('Title','Time Series', 'Units','pixels','Position',[40 80 390 230],'Tag','UIControl');

cltp={'edittime','editreal','editreal'};
callbacks={@EditTable,@EditTable,@EditTable};
wdt=[120 60 60];
for i=1:handles.Bnd.NrTimeSeries
    data{i,1}=handles.Bnd.TimeSeriesT(i);
    data{i,2}=handles.Bnd.TimeSeriesA(i,1);
    data{i,3}=handles.Bnd.TimeSeriesB(i,1);
end
table2(gcf,'table','create','position',[50 90],'nrrows',8,'columntypes',cltp,'width',wdt,'data',data,'callbacks',callbacks,'includebuttons');

switch handles.Bnd.Type,
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

handles.GUIHandles.TextTime                = uicontrol(gcf,'Style','text','String','Time','Position',[60 275 120 15],'HorizontalAlignment','center');
handles.GUIHandles.Textyyyy                = uicontrol(gcf,'Style','text','String','yyyy mm dd HH MM SS','Position',[60 260 120 15],'HorizontalAlignment','center');
handles.GUIHandles.TextEndA                = uicontrol(gcf,'Style','text','String','End A','Position',[180 275 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextUnitA               = uicontrol(gcf,'Style','text','String',['(' unit ')'],'Position',[180 260 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextEndB                = uicontrol(gcf,'Style','text','String','End B','Position',[240 275 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextUnitB               = uicontrol(gcf,'Style','text','String',['(' unit ')'],'Position',[240 260 60 15],'HorizontalAlignment','center');

uipanel('Title','Boundary Section','Units','pixels','Position',[40 320 390 120]);
handles.GUIHandles.TextBoundary = uicontrol(gcf,'Style','text','String','Boundary :' ,'Position',[50 400 200 20],'HorizontalAlignment','left');
handles.GUIHandles.TextBoundaryName = uicontrol(gcf,'Style','text','String',handles.Bnd.Name,'Position',[125 400 150 20],'HorizontalAlignment','left');
handles.GUIHandles.TextQuantity   = uicontrol(gcf,'Style','text','String','Quantity :','Position',[50 380 200 20],'HorizontalAlignment','left');
handles.GUIHandles.TextQuantity   = uicontrol(gcf,'Style','text','String',quant,'Position',[125 380 150 20],'HorizontalAlignment','left');
handles.GUIHandles.TextForcingType = uicontrol(gcf,'Style','text','String','Forcing Type :','Position',[50 360 150 20],'HorizontalAlignment','left');
handles.GUIHandles.TextForcingType = uicontrol(gcf,'Style','text','String','Time Series','Position',[125 360 150 20],'HorizontalAlignment','left');

for k=1:kmax
    str{k}=num2str(k);
end
handles.GUIHandles.TextLayer   = uicontrol(gcf,'Style','text','String','Layer : ','Position',[50 331 50 20],'HorizontalAlignment','left');
handles.GUIHandles.SelectLayer = uicontrol(gcf,'Style','popupmenu','String',str,'Position',[125 335 30 20]);

if kmax==1 || ~strcmpi(prf,'3d-profile')
    set(handles.GUIHandles.TextLayer,'Enable','off');
    set(handles.GUIHandles.SelectLayer,'Enable','off');
end

handles.GUIHandles.PushOK     = uicontrol(gcf,'Style','pushbutton','String','OK',    'Position',[370 30 60 20]);
handles.GUIHandles.PushCancel = uicontrol(gcf,'Style','pushbutton','String','Cancel','Position',[300 30 60 20]);

set(handles.GUIHandles.PushOK,              'CallBack',{@PushOK_CallBack});
set(handles.GUIHandles.PushCancel,          'CallBack',{@PushCancel_CallBack});
set(handles.GUIHandles.SelectLayer,         'CallBack',{@SelectLayer_CallBack});

% handles.GUIHandles.PushImport = uicontrol(gcf,'Style','pushbutton','String','Import','Position',[670 100 60 30]);
% set(handles.GUIHandles.GUIHhandles.PushImport,'CallBack',{@PushImport_CallBack});

% handles.GUIHandles.PasteFromExcel = uicontrol(gcf,'Style','pushbutton','String','Paste','Position',[670 130 60 30]);
% set(handles.GUIHandles.GUIHhandles.PasteFromExcel ,'CallBack',{@PasteFromExcel_CallBack});

SetUIBackgroundColors;

guidata(gcf,handles);

%%
function PushOK_CallBack(hObject,eventdata)
h=guidata(gcf);
handles=getHandles;

ibnd=handles.GUIData.ActiveOpenBoundary;

handles.Model(md).Input(ad).OpenBoundaries(ibnd)=h.Bnd;

setHandles(handles);
closereq;

%%
function PushCancel_CallBack(hObject,eventdata)
closereq;

%%
function PushImport_CallBack(hObject,eventdata)

[data,ok]=ImportFromXLS;
if ok
    table2(gcf,'table','change','data',data);
else
    GiveWarning('Warning','Error importing xls file');
end

%%
function PasteFromExcel_CallBack(hObject,eventdata)
str=clipboard('paste');
try
    a=textscan(str,'%s%s%s','delimiter', '\t');
    for i=1:length(a{1})
        data{i,1}=str2double(char(a{1}(i)))+datenum('30-Dec-1899');
        data{i,2}=str2double(char(a{2}(i)));
        data{i,3}=str2double(char(a{3}(i)));
    end
    table2(gcf,'table','change','data',data);
catch
    GiveWarning('Warning','Could not copy selection');
end

%%
function SelectLayer_CallBack(hObject,eventdata)
handles=guidata(gcf);
k=get(hObject,'Value');
for i=1:handles.Bnd.NrTimeSeries
    data{i,1}=handles.Bnd.TimeSeriesT(i);
    data{i,2}=handles.Bnd.TimeSeriesA(i,k);
    data{i,3}=handles.Bnd.TimeSeriesB(i,k);
end
table2(gcf,'table','change','data',data);

%%
function EditTable
handles=guidata(gcf);
k=get(handles.GUIHandles.SelectLayer,'Value');
data=table2(gcf,'table','getdata');
nr=size(data,1);
for i=1:nr
    handles.Bnd.TimeSeriesT(i)=data{i,1};
    handles.Bnd.TimeSeriesA(i,k)=data{i,2};
    handles.Bnd.TimeSeriesB(i,k)=data{i,3};
end
handles.Bnd.NrTimeSeries=nr;
guidata(gcf,handles);


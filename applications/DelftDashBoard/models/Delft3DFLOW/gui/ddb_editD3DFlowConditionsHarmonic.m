function ddb_editD3DFlowConditionsHarmonic

h=getHandles;

handles=h.Model(md).Input(ad);
handles.GUIData.ActiveOpenBoundary=h.GUIData.ActiveOpenBoundary;

MakeNewWindow('Harmonic Boundary Conditions',[750 600],[h.SettingsDir '\icons\deltares.gif']);

uipanel('Title','Harmonics', 'Units','pixels','Position',[40 100 540 245],'Tag','UIControl');

cltp={'text','editreal','editreal','editreal','editreal','editreal'};
wdt=[70 60 60 60 60 60];
for i=1:handles.NrHarmonicComponents
    data{i,1}='';
    data{i,2}=handles.HarmonicComponents(i);
    data{i,3}=handles.OpenBoundaries(handles.GUIData.ActiveOpenBoundary).HarmonicAmpA(i);
    data{i,4}=handles.OpenBoundaries(handles.GUIData.ActiveOpenBoundary).HarmonicPhaseA(i);
    data{i,5}=handles.OpenBoundaries(handles.GUIData.ActiveOpenBoundary).HarmonicAmpB(i);
    data{i,6}=handles.OpenBoundaries(handles.GUIData.ActiveOpenBoundary).HarmonicPhaseB(i);
end
data{1,1}='Mean';
callbacks={'',@RefreshPeriod,'','','',''};
table(gcf,'table','create','position',[50 120],'nrrows',8,'columntypes',cltp,'width',wdt,'data',data,'callbacks',callbacks,'includebuttons');
RefreshPeriod;

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

handles.GUIHandles.Text2Period           = uicontrol(gcf,'Style','text','String','Period',      'Position',[ 50 310 70 15],'HorizontalAlignment','center');
handles.GUIHandles.TextFreq              = uicontrol(gcf,'Style','text','String','Frequency',   'Position',[120 310 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextFreq              = uicontrol(gcf,'Style','text','String','deg/hour',    'Position',[120 280 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextAmpEndA           = uicontrol(gcf,'Style','text','String','Amplitude',   'Position',[180 310 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextAmpEndA           = uicontrol(gcf,'Style','text','String','End A',       'Position',[180 295 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextAmpEndA           = uicontrol(gcf,'Style','text','String',['(' unit ')'],'Position',[180 280 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextPhaEndA           = uicontrol(gcf,'Style','text','String','Phase',       'Position',[240 310 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextPhaEndA           = uicontrol(gcf,'Style','text','String','End A',       'Position',[240 295 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextPhaEndA           = uicontrol(gcf,'Style','text','String',['(degrees)'], 'Position',[240 280 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextAmpEndB           = uicontrol(gcf,'Style','text','String','Amplitude',   'Position',[300 310 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextAmpEndB           = uicontrol(gcf,'Style','text','String','End B',       'Position',[300 295 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextAmpEndB           = uicontrol(gcf,'Style','text','String',['(' unit ')'],'Position',[300 280 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextPhaEndB           = uicontrol(gcf,'Style','text','String','Phase',       'Position',[360 310 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextPhaEndB           = uicontrol(gcf,'Style','text','String','End B',       'Position',[360 295 60 15],'HorizontalAlignment','center');
handles.GUIHandles.TextPhaEndB           = uicontrol(gcf,'Style','text','String',['(degrees)'], 'Position',[360 280 60 15],'HorizontalAlignment','center');

uipanel('Title','Boundary Section','Units','pixels','Position',[470 480 250 100]);
handles.GUIHandles.TextBoundary = uicontrol(gcf,'Style','text','String','Boundary :' ,'Position',[490 530 200 20],'HorizontalAlignment','left');
handles.GUIHandles.TextBoundaryName = uicontrol(gcf,'Style','text','String',handles.OpenBoundaries(handles.GUIData.ActiveOpenBoundary).Name,'Position',[565 530 150 20],'HorizontalAlignment','left');
handles.GUIHandles.TextQuantity   = uicontrol(gcf,'Style','text','String','Quantity :','Position',[490 510 200 20],'HorizontalAlignment','left');
handles.GUIHandles.TextQuantity   = uicontrol(gcf,'Style','text','String',quant,'Position',[565 510 150 20],'HorizontalAlignment','left');
handles.GUIHandles.TextForcingType = uicontrol(gcf,'Style','text','String','Forcing Type :','Position',[490 490 150 20],'HorizontalAlignment','left');
handles.GUIHandles.TextForcingType = uicontrol(gcf,'Style','text','String','Harmonic','Position',[565 490 150 20],'HorizontalAlignment','left');

handles.GUIHandles.PushOK     = uicontrol(gcf,'Style','pushbutton','String','OK',    'Position',[670 30 60 30]);
handles.GUIHandles.PushCancel = uicontrol(gcf,'Style','pushbutton','String','Cancel','Position',[600 30 60 30]);

set(handles.GUIHandles.PushOK,              'CallBack',{@PushOK_CallBack});
set(handles.GUIHandles.PushCancel,          'CallBack',{@PushCancel_CallBack});

SetUIBackgroundColors;

guidata(gcf,handles);

%%
function PushOK_CallBack(hObject,eventdata)

handles=getHandles;
data=table(gcf,'table','getdata');
handles.Model(md).Input(ad).HarmonicComponents=[];
% handles.GUIData.ActiveOpenBoundary.HarmonicAmpA=[];
% handles.GUIData.ActiveOpenBoundary.HarmonicPhaseA=[];
% handles.GUIData.ActiveOpenBoundary.HarmonicAmpB=[];
% handles.GUIData.ActiveOpenBoundary.HarmonicPhaseB=[];
j=handles.GUIData.ActiveOpenBoundary;
for i=1:size(data,1)
    handles.Model(md).Input(ad).HarmonicComponents(i)=data{i,2};
    handles.Model(md).Input(ad).OpenBoundaries(j).HarmonicAmpA(i)=data{i,3};
    handles.Model(md).Input(ad).OpenBoundaries(j).HarmonicPhaseA(i)=data{i,4};
    handles.Model(md).Input(ad).OpenBoundaries(j).HarmonicAmpB(i)=data{i,5};
    handles.Model(md).Input(ad).OpenBoundaries(j).HarmonicPhaseB(i)=data{i,6};
end
if size(data,1)<handles.Model(md).Input(ad).NrHarmonicComponents
    for j=1:handles.Model(md).Input(ad).NrOpenBoundaries
        if j~=handles.GUIData.ActiveOpenBoundary
            handles.Model(md).Input(ad).OpenBoundaries(j).HarmonicAmpA=handles.Model(md).Input(ad).OpenBoundaries(j).HarmonicAmpA(1:size(data,1));
            handles.Model(md).Input(ad).OpenBoundaries(j).HarmonicPhaseA=handles.Model(md).Input(ad).OpenBoundaries(j).HarmonicPhaseA(1:size(data,1));
            handles.Model(md).Input(ad).OpenBoundaries(j).HarmonicAmpB=handles.Model(md).Input(ad).OpenBoundaries(j).HarmonicAmpB(1:size(data,1));
            handles.Model(md).Input(ad).OpenBoundaries(j).HarmonicPhaseB=handles.Model(md).Input(ad).OpenBoundaries(j).HarmonicPhaseB(1:size(data,1));
        end
    end
elseif size(data,1)>handles.Model(md).Input(ad).NrHarmonicComponents
    for j=1:handles.Model(md).Input(ad).NrOpenBoundaries
        if j~=handles.GUIData.ActiveOpenBoundary
            for i=handles.Model(md).Input(ad).NrHarmonicComponents:size(data,1)
            handles.Model(md).Input(ad).OpenBoundaries(j).HarmonicAmpA(i)=0;
            handles.Model(md).Input(ad).OpenBoundaries(j).HarmonicPhaseA(i)=0;
            handles.Model(md).Input(ad).OpenBoundaries(j).HarmonicAmpB(i)=0;
            handles.Model(md).Input(ad).OpenBoundaries(j).HarmonicPhaseB(i)=0;
            end
        end
    end
end
handles.Model(md).Input(ad).NrHarmonicComponents=size(data,1);
setHandles(handles);
closereq;

%%
function PushCancel_CallBack(hObject,eventdata)
closereq;

%%
function RefreshPeriod

data=table(gcf,'table','getdata');
nr=size(data,1);
for i=2:min(nr,8)
    frq=data{i,2};
    if frq>0
        per=360/frq;
        perh=floor(per);
        perm=floor((per-perh)*60);
        k=(per-perh-perm/60);
        pers=round((per-perh-perm/60)*3600);
        data{i,1}=[num2str(perh,'%0.2i') 'h ' num2str(perm,'%0.2i') 'm ' num2str(pers,'%0.2i') 's '];
    else
        data{i,1}='';
    end
end
table(gcf,'table','change','data',data);

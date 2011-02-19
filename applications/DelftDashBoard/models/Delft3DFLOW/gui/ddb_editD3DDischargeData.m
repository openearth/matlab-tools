function ddb_editD3DDischargeData(ii)

handles=getHandles;

Flw=handles.Model(md).Input(ad);

Dis=Flw.Discharges(ii);
nr=length(Dis.TimeSeriesT);

k=2;
if Flw.Salinity.Include
    k=k+1;
end
if Flw.Temperature.Include
    k=k+1;
end
if Flw.sediments.include
    for j=1:Flw.NrSediments
        k=k+1;
    end
end
if Flw.Tracers
    for j=1:Flw.NrTracers
        k=k+1;
    end
end
if strcmpi(Dis.Type,'momentum')
    k=k+2;
end

fig=MakeNewWindow('Discharge',[k*80+200 260],'modal',[handles.SettingsDir '\icons\deltares.gif']);

k=0;

wd=80;
ht=230;

k=k+1;
for i=1:min(nr,8)
    data{i,k}=Dis.TimeSeriesT(i);
end
k=k+1;
uicontrol(gcf,'Style','text','String','Discharge','Position',[140+(k-2)*wd ht wd 15],'HorizontalAlignment','center','Tag','UIControl');
for i=1:min(nr,8)
    data{i,k}=Dis.TimeSeriesQ(i);
end
if Flw.Salinity.Include
    k=k+1;
    uicontrol(gcf,'Style','text','String','Salinity','Position',[140+(k-2)*wd ht wd 15],'HorizontalAlignment','center','Tag','UIControl');
    for i=1:min(nr,8)
        data{i,k}=Dis.Salinity.TimeSeries(i);
    end
end
if Flw.Temperature.Include
    k=k+1;
    uicontrol(gcf,'Style','text','String','Temperature','Position',[140+(k-2)*wd ht wd 15],'HorizontalAlignment','center','Tag','UIControl');
    for i=1:min(nr,8)
        data{i,k}=Dis.Temperature.TimeSeries(i);
    end
end
if Flw.sediments.include
    for j=1:Flw.NrSediments
        k=k+1;
        uicontrol(gcf,'Style','text','String',Flw.Sediment(j).Name,'Position',[140+(k-2)*wd ht wd 15],'HorizontalAlignment','center','Tag','UIControl');
        for i=1:min(nr,8)
            data{i,k}=Dis.Sediment(j).TimeSeries(i);
        end
    end
end
if Flw.Tracers
    for j=1:Flw.NrTracers
        k=k+1;
        uicontrol(gcf,'Style','text','String',Flw.Tracer(j).Name,'Position',[140+(k-2)*wd ht wd 15],'HorizontalAlignment','center','Tag','UIControl');
        for i=1:min(nr,8)
            data{i,k}=Dis.Tracer(j).TimeSeries(i);
        end
    end
end
if strcmpi(Dis.Type,'momentum')
    k=k+1;
    uicontrol(gcf,'Style','text','String','Cur. Magnitude','Position',[140+(k-2)*wd ht wd 15],'HorizontalAlignment','center','Tag','UIControl');
    for i=1:min(nr,8)
        data{i,k}=Dis.TimeSeriesM(i);
    end
    k=k+1;
    uicontrol(gcf,'Style','text','String','Cur. Direction','Position',[140+(k-2)*wd ht wd 15],'HorizontalAlignment','center','Tag','UIControl');
    for i=1:min(nr,8)
        data{i,k}=Dis.TimeSeriesD(i);
    end
end

cltp{1}='edittime';
wdt(1)=110;
callbacks{1}=[];
for i=2:k
    cltp{i}='editreal';
    wdt(i)=wd;
    callbacks{i}=[];
end

table2(gcf,'table','create','position',[30 70],'nrrows',8,'columntypes',cltp,'width',wdt,'data',data,'callbacks',callbacks,'includebuttons');

hok=uicontrol(gcf,'Style','pushbutton','String','OK',    'Position',[k*80+100 30 70 20]);
hca=uicontrol(gcf,'Style','pushbutton','String','Cancel','Position',[k*80+20 30 70 20]);

set(hok,'CallBack',{@PushOK_Callback});
set(hca,'CallBack',{@PushCancel_Callback});

SetUIBackgroundColors;

%%
function PushOK_Callback(hObject,eventdata)
handles=getHandles;
data=table2(gcf,'table','getdata');

nr=size(data,1);
id=ad;
ii=handles.GUIData.ActiveDischarge;

k=0;

k=k+1;
for i=1:nr
    handles.Model(md).Input(id).Discharges(ii).TimeSeriesT(i)=data{i,k};
end
k=k+1;
for i=1:nr
    handles.Model(md).Input(id).Discharges(ii).TimeSeriesQ(i)=data{i,k};
end
if handles.Model(md).Input(id).Salinity.Include
    k=k+1;
    for i=1:nr
        handles.Model(md).Input(id).Discharges(ii).Salinity.TimeSeries(i)=data{i,k};
    end
end
if handles.Model(md).Input(id).Temperature.Include
    k=k+1;
    for i=1:nr
        handles.Model(md).Input(id).Discharges(ii).Temperature.TimeSeries(i)=data{i,k};
    end
end
if handles.Model(md).Input(id).sediments.include
    for j=1:handles.Model(md).Input(id).NrSediments
        k=k+1;
        for i=1:nr
            handles.Model(md).Input(id).Discharges(ii).Sediment(j).TimeSeries(i)=data{i,k};
        end
    end
end
if handles.Model(md).Input(id).Tracers
    for j=1:handles.Model(md).Input(id).NrTracers
        k=k+1;
        for i=1:nr
            handles.Model(md).Input(id).Discharges(ii).Tracer(j).TimeSeries(i)=data{i,k};
        end
    end
end
if strcmpi(handles.Model(md).Input(id).Discharges(ii).Type,'momentum')
    k=k+1;
    for i=1:nr
        handles.Model(md).Input(id).Discharges(ii).TimeSeriesM(i)=data{i,k};
    end
    k=k+1;
    for i=1:nr
        handles.Model(md).Input(id).Discharges(ii).TimeSeriesM(i)=data{i,k};
    end
end

setHandles(handles);
closereq;

%%
function PushCancel_Callback(hObject,eventdata)
closereq;

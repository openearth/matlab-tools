function ddb_editD3DDischargeData(ii)

handles=getHandles;

Flw=handles.Model(md).Input(ad);

Dis=Flw.discharges(ii);
nr=length(Dis.timeSeriesT);

k=2;
if Flw.salinity.include
    k=k+1;
end
if Flw.temperature.include
    k=k+1;
end
if Flw.sediments.include
    for j=1:Flw.nrSediments
        k=k+1;
    end
end
if Flw.tracers
    for j=1:Flw.nrTracers
        k=k+1;
    end
end
if strcmpi(Dis.type,'momentum')
    k=k+2;
end

fig=MakeNewWindow('Discharge',[k*80+200 260],'modal',[handles.settingsDir '\icons\deltares.gif']);

k=0;

wd=80;
ht=230;

k=k+1;
for i=1:min(nr,8)
    data{i,k}=Dis.timeSeriesT(i);
end
k=k+1;
uicontrol(gcf,'Style','text','String','Discharge','Position',[140+(k-2)*wd ht wd 15],'HorizontalAlignment','center','Tag','UIControl');
for i=1:min(nr,8)
    data{i,k}=Dis.timeSeriesQ(i);
end
if Flw.salinity.include
    k=k+1;
    uicontrol(gcf,'Style','text','String','Salinity','Position',[140+(k-2)*wd ht wd 15],'HorizontalAlignment','center','Tag','UIControl');
    for i=1:min(nr,8)
        data{i,k}=Dis.salinity.timeSeries(i);
    end
end
if Flw.temperature.include
    k=k+1;
    uicontrol(gcf,'Style','text','String','Temperature','Position',[140+(k-2)*wd ht wd 15],'HorizontalAlignment','center','Tag','UIControl');
    for i=1:min(nr,8)
        data{i,k}=Dis.temperature.timeSeries(i);
    end
end
if Flw.sediments.include
    for j=1:Flw.nrSediments
        k=k+1;
        uicontrol(gcf,'Style','text','String',Flw.sediment(j).name,'Position',[140+(k-2)*wd ht wd 15],'HorizontalAlignment','center','Tag','UIControl');
        for i=1:min(nr,8)
            data{i,k}=Dis.sediment(j).timeSeries(i);
        end
    end
end
if Flw.tracers
    for j=1:Flw.nrTracers
        k=k+1;
        uicontrol(gcf,'Style','text','String',Flw.tracer(j).name,'Position',[140+(k-2)*wd ht wd 15],'HorizontalAlignment','center','Tag','UIControl');
        for i=1:min(nr,8)
            data{i,k}=Dis.tracer(j).timeSeries(i);
        end
    end
end
if strcmpi(Dis.type,'momentum')
    k=k+1;
    uicontrol(gcf,'Style','text','String','Cur. Magnitude','Position',[140+(k-2)*wd ht wd 15],'HorizontalAlignment','center','Tag','UIControl');
    for i=1:min(nr,8)
        data{i,k}=Dis.timeSeriesM(i);
    end
    k=k+1;
    uicontrol(gcf,'Style','text','String','Cur. Direction','Position',[140+(k-2)*wd ht wd 15],'HorizontalAlignment','center','Tag','UIControl');
    for i=1:min(nr,8)
        data{i,k}=Dis.timeSeriesD(i);
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

hh.table=table(gcf,'create','tag','table','position',[30 70],'nrrows',8,'columntypes',cltp,'width',wdt,'data',data,'callbacks',callbacks,'includebuttons',1);

%table2(gcf,'table','create','position',[30 70],'nrrows',8,'columntypes',cltp,'width',wdt,'data',data,'callbacks',callbacks,'includebuttons');

hok=uicontrol(gcf,'Style','pushbutton','String','OK',    'Position',[k*80+100 30 70 20]);
hca=uicontrol(gcf,'Style','pushbutton','String','Cancel','Position',[k*80+20 30 70 20]);

set(hok,'CallBack',{@PushOK_Callback});
set(hca,'CallBack',{@PushCancel_Callback});

guidata(gcf,hh);

SetUIBackgroundColors;

%%
function PushOK_Callback(hObject,eventdata)
handles=getHandles;
hh=guidata(gcf);
data=table(hh.table,'getdata');

nr=size(data,1);
id=ad;
ii=handles.Model(md).Input(id).activeDischarge;

k=0;

k=k+1;
for i=1:nr
    handles.Model(md).Input(id).discharges(ii).timeSeriesT(i)=data{i,k};
end
k=k+1;
for i=1:nr
    handles.Model(md).Input(id).discharges(ii).timeSeriesQ(i)=data{i,k};
end
if handles.Model(md).Input(id).salinity.include
    k=k+1;
    for i=1:nr
        handles.Model(md).Input(id).discharges(ii).salinity.timeSeries(i)=data{i,k};
    end
end
if handles.Model(md).Input(id).temperature.include
    k=k+1;
    for i=1:nr
        handles.Model(md).Input(id).discharges(ii).temperature.timeSeries(i)=data{i,k};
    end
end
if handles.Model(md).Input(id).sediments.include
    for j=1:handles.Model(md).Input(id).nrSediments
        k=k+1;
        for i=1:nr
            handles.Model(md).Input(id).discharges(ii).sediment(j).timeSeries(i)=data{i,k};
        end
    end
end
if handles.Model(md).Input(id).tracers
    for j=1:handles.Model(md).Input(id).nrTracers
        k=k+1;
        for i=1:nr
            handles.Model(md).Input(id).discharges(ii).tracer(j).timeSeries(i)=data{i,k};
        end
    end
end
if strcmpi(handles.Model(md).Input(id).discharges(ii).type,'momentum')
    k=k+1;
    for i=1:nr
        handles.Model(md).Input(id).discharges(ii).timeSeriesM(i)=data{i,k};
    end
    k=k+1;
    for i=1:nr
        handles.Model(md).Input(id).discharges(ii).timeSeriesM(i)=data{i,k};
    end
end

setHandles(handles);
closereq;

%%
function PushCancel_Callback(hObject,eventdata)
closereq;

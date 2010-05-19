function ddb_editD3DFlowGrid

ddb_refreshScreen('Domain','Grid');
handles=getHandles;

bgc=get(gcf,'Color');

handles.GUIHandles.PushOpenGrid          = uicontrol(gcf,'Style','pushbutton','String','Open Grid',          'Position',[70 120 130 20],'Tag','UIControl');
handles.GUIHandles.PushOpenGridEnclosure = uicontrol(gcf,'Style','pushbutton','String','Open Grid Enclosure','Position',[70 90 130 20],'Tag','UIControl');
handles.GUIHandles.TextGridFile          = uicontrol(gcf,'Style','text','String',['File : ' handles.Model(md).Input(ad).GrdFile],           'Position',[210 117  200 20],'HorizontalAlignment','left','BackgroundColor',bgc,'Tag','UIControl');
handles.GUIHandles.TextEnclosureFile     = uicontrol(gcf,'Style','text','String',['File : ' handles.Model(md).Input(ad).EncFile],      'Position',[210  87  200 20],'HorizontalAlignment','left','BackgroundColor',bgc,'Tag','UIControl');
handles.GUIHandles.GUIHandles.TextCoordinateSystem  = uicontrol(gcf,'Style','text','String',['Coordinate System : ' handles.ScreenParameters.CoordinateSystem.Type],'Position',[70 60  200 20],'HorizontalAlignment','left','BackgroundColor',bgc,'Tag','UIControl');
handles.GUIHandles.TextMMax              = uicontrol(gcf,'Style','text','String',['Grid points in M direction : ' num2str(handles.Model(md).Input(ad).MMax)],   'Position',[70 40  200 20],'HorizontalAlignment','left','BackgroundColor',bgc,'Tag','UIControl');
handles.GUIHandles.TextNMax              = uicontrol(gcf,'Style','text','String',['Grid points in N direction : ' num2str(handles.Model(md).Input(ad).NMax)],   'Position',[70 20  200 20],'HorizontalAlignment','left','BackgroundColor',bgc,'Tag','UIControl');

handles.GUIHandles.EditLatitude          = uicontrol(gcf,'Style','edit','String',num2str(handles.Model(md).Input(ad).Latitude), 'Position', [360 60 80 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditOrientation       = uicontrol(gcf,'Style','edit','String',num2str(handles.Model(md).Input(ad).Orientation), 'Position', [360  30 80 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextLatitude          = uicontrol(gcf,'Style','text','String','Latitude (deg)','Position',[275 57  80 20],'HorizontalAlignment','right','BackgroundColor',bgc,'Tag','UIControl');
handles.GUIHandles.TextOrientation       = uicontrol(gcf,'Style','text','String','Orientation (deg)','Position',[275  27  80 20],'HorizontalAlignment','right','BackgroundColor',bgc,'Tag','UIControl');

handles.GUIHandles.EditKMax              = uicontrol(gcf,'Style','edit','String',num2str(handles.Model(md).Input(ad).KMax), 'Position',     [545 120 40 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextKMax              = uicontrol(gcf,'Style','text','String','Number of layers','Position',[450  117  90 20],'HorizontalAlignment','right','BackgroundColor',bgc,'Tag','UIControl');

for i=1:handles.Model(md).Input(ad).KMax
    data{i,1}=handles.Model(md).Input(ad).Thick(i);
end
callbacks{1}=@ChangeLayers;
coltp{1}='editreal';
table(gcf,'table','create','position',[610 45],'nrrows',5,'columntypes',coltp,'width',50,'data',data,'callbacks',callbacks,'includenumbers');
handles.GUIHandles.TextTotal = uicontrol(gcf,'Style','text','String',['Sum : %'],'Position',[625  20  70 20],'HorizontalAlignment','right','BackgroundColor',bgc,'Tag','UIControl');

handles.GUIHandles.PushGenerateLayers = uicontrol(gcf,'Style','pushbutton','String','Generate Layers','Position',[485 90 100 20],'Tag','UIControl');
handles.GUIHandles.PushSaveLayers     = uicontrol(gcf,'Style','pushbutton','String','Save Layers','Position',[485 65 100 20],'Tag','UIControl');
handles.GUIHandles.PushLoadLayers     = uicontrol(gcf,'Style','pushbutton','String','Load Layers','Position',[485 40 100 20],'Tag','UIControl');

set(handles.GUIHandles.PushOpenGrid,         'CallBack',{@PushOpenGrid_CallBack});
set(handles.GUIHandles.PushOpenGridEnclosure,'CallBack',{@PushOpenGridEnclosure_CallBack});
set(handles.GUIHandles.EditOrientation,      'CallBack',{@EditOrientation_CallBack});
set(handles.GUIHandles.EditLatitude,         'CallBack',{@EditLatitude_CallBack});
set(handles.GUIHandles.EditKMax,             'CallBack',{@EditKMax_CallBack});

set(handles.GUIHandles.PushGenerateLayers,'CallBack',{@PushGenerateLayers_CallBack},'Enable','off');
set(handles.GUIHandles.PushLoadLayers,    'CallBack',{@PushLoadLayers_CallBack});
set(handles.GUIHandles.PushSaveLayers,    'CallBack',{@PushSaveLayers_CallBack});

if strcmp(handles.ScreenParameters.CoordinateSystem,'Spherical')
    set(handles.GUIHandles.EditLatitude,'Enable','off','BackgroundColor',[0.8 0.8 0.8],'String','');
    set(handles.GUIHandles.TextLatitude,'Enable','off');
end

set(handles.GUIHandles.EditOrientation,'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
set(handles.GUIHandles.TextOrientation,'Enable','off');

setHandles(handles);

SetUIBackgroundColors;

RefreshSumLayers;

%%
function PushOpenGrid_CallBack(hObject,eventdata)

handles=getHandles;

[filename, pathname, filterindex] = uigetfile('*.grd', 'Select Grid File');
[x,y,enc]=ddb_wlgrid('read',[pathname filename]);
curdir=[lower(cd) '\'];
if ~strcmpi(curdir,pathname)
    filename=[pathname filename];
end
handles.Model(md).Input(ad).GridX=x;
handles.Model(md).Input(ad).GridY=y;
handles.Model(md).Input(ad).GrdFile=filename;
handles.Model(md).Input(ad).MMax=size(x,1)+1;
handles.Model(md).Input(ad).NMax=size(x,2)+1;
[handles.Model(md).Input(ad).GridXZ,handles.Model(md).Input(ad).GridYZ]=GetXZYZ(x,y);
handles=ddb_determineKCS(handles);
nans=zeros(size(handles.Model(md).Input(ad).GridX));
nans(nans==0)=NaN;
handles.Model(md).Input(ad).Depth=nans;
handles.Model(md).Input(ad).DepthZ=nans;
set(handles.GUIHandles.TextMMax,'String',['Grid points in M direction : ' num2str(handles.Model(md).Input(ad).MMax)]);
set(handles.GUIHandles.TextNMax,'String',['Grid points in N direction : ' num2str(handles.Model(md).Input(ad).NMax)]);
set(handles.GUIHandles.TextGridFile,'String',['File : ' filename]);
setHandles(handles);
ddb_plotGrid(x,y,ad,'FlowGrid','plot');

%%
function PushOpenGridEnclosure_CallBack(hObject,eventdata)

handles=getHandles;
[filename, pathname, filterindex] = uigetfile('*.enc', 'Select Enclosure File');
curdir=[lower(cd) '\'];
if ~strcmpi(curdir,pathname)
    filename=[pathname filename];
end
handles.Model(md).Input(ad).EncFile=filename;
mn=ddb_enclosure('read',filename);
[handles.Model(md).Input(ad).GridX,handles.Model(md).Input(ad).GridY]=ddb_enclosure('apply',mn,handles.Model(md).Input(ad).GridX,handles.Model(md).Input(ad).GridY);
[handles.Model(md).Input(ad).GridXZ,handles.Model(md).Input(ad).GridYZ]=GetXZYZ(handles.Model(md).Input(ad).GridX,handles.Model(md).Input(ad).GridY);
set(handles.GUIHandles.TextEnclosureFile,'String',['File : ' filename]);
setHandles(handles);
%ddb_plotFlowGrid(ad,'k');

%%
function EditOrientation_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).Orientation=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditLatitude_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).Latitude=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditKMax_CallBack(hObject,eventdata)
handles=getHandles;

kmax0=handles.Model(md).Input(ad).KMax;
handles.Model(md).Input(ad).KMax=str2num(get(hObject,'String'));
kmax=handles.Model(md).Input(ad).KMax;
handles.Model(md).Input(ad).Thick=[];

if kmax~=kmax0
    if kmax==1
        handles.Model(md).Input(ad).Thick=100;
    else
        for i=1:kmax
            thick(i)=0.01*round(100*100/kmax);
        end
        sumlayers=sum(thick);
        dif=sumlayers-100;
        thick(kmax)=thick(kmax)-dif;
        for i=1:kmax
            handles.Model(md).Input(ad).Thick(i)=thick(i);
        end
    end
    handles.Model(md).Input(ad).SumLayers=sum(handles.Model(md).Input(ad).Thick);
    setHandles(handles);
    RefreshTable;
end

setHandles(handles);
RefreshSumLayers;

%%
function PushGenerateLayers_CallBack(hObject,eventdata)

%%
function PushSaveLayers_CallBack(hObject,eventdata)

handles=getHandles;
[filename, pathname, filterindex] = uiputfile('*.lyr', 'Select Layers File','');
if pathname~=0
    curdir=[lower(cd) '\'];
    filename=[pathname filename];
    for i=1:handles.Model(md).Input(ad).KMax
        thick(i)=handles.Model(md).Input(ad).Thick(i);
    end
    thick=thick';
    save(filename,'thick','-ascii');
end

%%
function PushLoadLayers_CallBack(hObject,eventdata)

handles=getHandles;
[filename, pathname, filterindex] = uigetfile('*.lyr', 'Select Layer File');
if pathname~=0
    layers=load([pathname filename]);
    kmax=length(layers);
    handles.Model(md).Input(ad).Thick=[];
    handles.Model(md).Input(ad).KMax=kmax;
    for i=1:kmax
        handles.Model(md).Input(ad).Thick(i)=layers(i);
    end
    handles.Model(md).Input(ad).SumLayers=sum(layers);
    setHandles(handles);
    set(handles.GUIHandles.EditKMax,'String',num2str(kmax));
    RefreshTable;
    RefreshSumLayers;
end

%%
function RefreshTable
handles=getHandles;
kmax=handles.Model(md).Input(ad).KMax;
for i=1:kmax
    data{i,1}=handles.Model(md).Input(ad).Thick(i);
    table(gcf,'table','change','data',data);
end

%%
function RefreshSumLayers

handles=getHandles;
suml=sum(handles.Model(md).Input(ad).Thick);
set(handles.GUIHandles.TextTotal,'String',['Sum : ' num2str(suml) '%']);
if suml~=100
    set(handles.GUIHandles.TextTotal,'ForegroundColor','r');
else
    set(handles.GUIHandles.TextTotal,'ForegroundColor','k');
end

%%
function ChangeLayers

handles=getHandles;
data=table(gcf,'table','getdata');
for i=1:handles.Model(md).Input(ad).KMax
    handles.Model(md).Input(ad).Thick(i)=data{i,1};
end
handles.Model(md).Input(ad).SumLayers=sum(handles.Model(md).Input(ad).Thick);
setHandles(handles);

RefreshSumLayers;

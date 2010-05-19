function ddb_bathymetryExport

ddb_refreshScreen('Toolbox','Export');

handles=getHandles;

ddb_plotBathymetry(handles,'activate');

handles.Toolbox(tb).ActiveZoomLevel=1;

handles.ListDatasets    = uicontrol(gcf,'Style','listbox','String','Export',         'Position',[40 80 200 70],'BackgroundColor',[1 1 1],'Tag','UIControl');
handles.SelectZoomLevel = uicontrol(gcf,'Style','popupmenu', 'String','Zoom Levels',    'Position',[40  50 200 20],'BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextCellSize    = uicontrol(gcf,'Style','text', 'String','Cell Size : ',    'Position',[40  25 200 20],'HorizontalAlignment','left','Tag','UIControl');

handles.PushDrawPolygon   = uicontrol(gcf,'Style','pushbutton','String','Draw Polygon',   'Position',[260 130 100 20],'Tag','UIControl');
handles.PushDeletePolygon = uicontrol(gcf,'Style','pushbutton','String','Delete Polygon', 'Position',[260 105 100 20],'Tag','UIControl');

handles.PushExport        = uicontrol(gcf,'Style','pushbutton','String','Export',         'Position',[260 50 100 20],'Tag','UIControl');

set(handles.ListDatasets,'Value',1);
set(handles.ListDatasets,'String',handles.Bathymetry.Datasets);

set(handles.PushDrawPolygon,   'CallBack',{@PushDrawPolygon_Callback});
set(handles.PushDeletePolygon, 'CallBack',{@PushDeletePolygon_Callback});
set(handles.ListDatasets,      'CallBack',{@ListDatasets_Callback});
set(handles.SelectZoomLevel,   'CallBack',{@SelectZoomLevel_Callback});
set(handles.PushExport,        'CallBack',{@PushExport_Callback});

RefreshAll(handles);

SetUIBackgroundColors;

setHandles(handles);

%%
function ListDatasets_Callback(hObject,eventdata)
handles=getHandles;
handles.Toolbox(tb).ActiveDataset=get(hObject,'Value');
handles.Toolbox(tb).ActiveZoomLevel=1;
RefreshAll(handles);
setHandles(handles);

%%
function SelectZoomLevel_Callback(hObject,eventdata)
handles=getHandles;
handles.Toolbox(tb).ActiveZoomLevel=get(hObject,'Value');
RefreshAll(handles);
setHandles(handles);

%%
function PushExport_Callback(hObject,eventdata)

[filename, pathname, filterindex] = uiputfile('*.xyz', 'Select Samples File','');

if pathname~=0

    wb = waitbox('Exporting samples ...');pause(0.1);
    handles=getHandles;

    cs.Name=handles.Bathymetry.Dataset(handles.Toolbox(tb).ActiveDataset).HorizontalCoordinateSystem.Name;
    cs.Type=handles.Bathymetry.Dataset(handles.Toolbox(tb).ActiveDataset).HorizontalCoordinateSystem.Type;

    [xx,yy]=ddb_coordConvert(handles.Toolbox(tb).PolygonX,handles.Toolbox(tb).PolygonY,handles.ScreenParameters.CoordinateSystem,cs);

    ii=handles.Toolbox(tb).ActiveDataset;
    str=handles.Bathymetry.Datasets;
    bset=str{ii};

    xlim(1)=min(xx);
    xlim(2)=max(xx);
    ylim(1)=min(yy);
    ylim(2)=max(yy);

    fname=[pathname filename];
    handles.OriginalBackgroundBathymetry=handles.ScreenParameters.BackgroundBathymetry;
    handles.BackgroundBathymetry=bset;

    zoomlevel=get(handles.SelectZoomLevel,'Value');

    [x,y,z,ok]=ddb_getBathy(handles,xlim,ylim,zoomlevel);

    [x,y]=ddb_coordConvert(x,y,cs,handles.ScreenParameters.CoordinateSystem);

    handles.ScreenParameters.BackgroundBathymetry=handles.OriginalBackgroundBathymetry;

    np=size(x,1)*size(x,2);

    x=reshape(x,[np,1]);
    y=reshape(y,[np,1]);
    z=reshape(z,[np,1]);

    in = inpolygon(x,y,handles.Toolbox(tb).PolygonX,handles.Toolbox(tb).PolygonY);

    x=x(in);
    y=y(in);
    z=z(in);
    isn=isnan(z);

%     if min(isn)==0
        x=x(~isn);
        y=y(~isn);
        z=z(~isn);
%     end

    data(:,1)=x;
    data(:,2)=y;
    data(:,3)=z;

    save(fname,'data','-ascii');

    close(wb);

    setHandles(handles);

end

%%
function PushDrawPolygon_Callback(hObject,eventdata)

handles=getHandles;
ddb_zoomOff;
h=findall(gcf,'Tag','BathymetryPolygon');
set(h,'HitTest','off');

[x,y]=DrawPolyline('g',1.5,'o','r');

if ~isempty(h)
    delete(h);
end

if ~isempty(x)
    handles.Toolbox(tb).PolygonX=x;
    handles.Toolbox(tb).PolygonY=y;
    handles.Toolbox(tb).PolygonX(end+1)=x(1);
    handles.Toolbox(tb).PolygonY(end+1)=y(1);
end

DrawBathymetryPolygon(handles);

setHandles(handles);

%%
function PushDeletePolygon_Callback(hObject,eventdata)

handles=getHandles;

handles.Toolbox(tb).PolygonX=[];
handles.Toolbox(tb).PolygonY=[];

DrawBathymetryPolygon(handles);

setHandles(handles);


%%
function DrawBathymetryPolygon(handles)

h=findall(gcf,'Tag','BathymetryPolygon');
if ~isempty(h)
    delete(h);
end
z=zeros(size(handles.Toolbox(tb).PolygonX))+100;
if ~isempty(handles.Toolbox(tb).PolygonX)
    h=plot3(handles.Toolbox(tb).PolygonX,handles.Toolbox(tb).PolygonY,z,'g');
    set(h,'LineWidth',1.5);
    set(h,'Tag','BathymetryPolygon');
    set(h,'HitTest','off');
    for i=1:length(handles.Toolbox(tb).PolygonX)
        h=plot3(handles.Toolbox(tb).PolygonX(i),handles.Toolbox(tb).PolygonY(i),200,'ro');
        set(h,'MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',4);
        set(h,'ButtonDownFcn',{@MoveVertex});
        set(h,'Tag','BathymetryPolygon');
        set(h,'UserData',i);
    end
end

%%
function MoveVertex(imagefig, varargins)
set(gcf, 'windowbuttonmotionfcn', {@FollowTrack});
set(gcf, 'windowbuttonupfcn',     {@StopTrack});
h=get(gcf,'CurrentObject');
ii=get(h,'UserData');
set(0,'UserData',ii);

%%
function FollowTrack(imagefig, varargins)
handles=getHandles;
pos = get(gca, 'CurrentPoint');
xi=pos(1,1);
yi=pos(1,2);
ii=get(0,'UserData');
handles.Toolbox(tb).PolygonX(ii)=xi;
handles.Toolbox(tb).PolygonY(ii)=yi;
if ii==1
    handles.Toolbox(tb).PolygonX(end)=xi;
    handles.Toolbox(tb).PolygonY(end)=yi;
end
if ii==length(handles.Toolbox(tb).PolygonX)
    handles.Toolbox(tb).PolygonX(1)=xi;
    handles.Toolbox(tb).PolygonY(1)=yi;
end
DrawBathymetryPolygon(handles);
setHandles(handles);
ddb_updateCoordinateText('arrow');

%%
function StopTrack(imagefig, varargins)
ddb_setWindowButtonUpDownFcn;
ddb_setWindowButtonMotionFcn;
set(0,'UserData',[]);

%%
function RefreshAll(handles)
ii=handles.Toolbox(tb).ActiveDataset;
jj=handles.Toolbox(tb).ActiveZoomLevel;
set(handles.ListDatasets,'Value',ii);
%if isempty(handles.Toolbox(tb).Dataset(ii).RefinementFactor)
nz=handles.Bathymetry.Dataset(ii).NrZoomLevels;
%else
%   nz
for i=1:nz
    zstr{i}=['Zoom Level ' num2str(i)];
end
set(handles.SelectZoomLevel,'Value',jj);
set(handles.SelectZoomLevel,'String',zstr);

if isempty(handles.Bathymetry.Dataset(ii).RefinementFactor)
    dg=handles.Bathymetry.Dataset(ii).ZoomLevel(jj).GridCellSize(1);
    mn=handles.Bathymetry.Dataset(ii).ZoomLevel(jj).GridCellSize(2);
    sc=handles.Bathymetry.Dataset(ii).ZoomLevel(jj).GridCellSize(3);
    
    cellSize=dms2degrees([dg mn sc]);
    cellSize=cellSize*100000;

    str=['Cell Size : ~ ' num2str(cellSize,'%10.0f') ' m'];
%    str=['Cell Size : ' num2str(dg) 'd ' num2str(mn) 'm ' num2str(sc) 's'];
    set(handles.TextCellSize,'String',str);
else

    tileMax=handles.Bathymetry.Dataset(ii).MaxTileSize;
    nLevels=handles.Bathymetry.Dataset(ii).NrZoomLevels;
    nRef=handles.Bathymetry.Dataset(ii).RefinementFactor;
    nCell=handles.Bathymetry.Dataset(ii).NrCells;

    tileSizes(1)=tileMax;
    for i=2:nLevels
        tileSizes(i)=tileSizes(i-1)/nRef;
    end
    cellSizes=tileSizes/nCell;
    cellSize=cellSizes(jj);
    
%     ym=mean(handles.Toolbox(tb).PolygonY);
    if strcmpi(handles.Bathymetry.Dataset(ii).HorizontalCoordinateSystem.Type,'geographic')
        cellSize=cellSize*100000;
    end

    str=['Cell Size : ~ ' num2str(cellSize,'%10.0f') ' m'];
    set(handles.TextCellSize,'String',str);

end


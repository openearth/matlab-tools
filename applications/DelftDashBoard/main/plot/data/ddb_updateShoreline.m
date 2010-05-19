function ddb_updateShoreline(handles)

tic

disp('Getting World Vector Shoreline ...');

xl=get(gca,'xlim');
yl=get(gca,'ylim');

% Bathymetry

WVSCoord.Name='WGS 84';
WVSCoord.Type='Geographic';

Coord=handles.ScreenParameters.CoordinateSystem;

if ~strcmpi(Coord.Name,WVSCoord.Name)
    dx=(xl(2)-xl(1))/10;
    dy=(yl(2)-yl(1))/10;
    [xtmp,ytmp]=meshgrid(xl(1)-dx:dx:xl(2)+dx,yl(1)-dy:dy:yl(2)+dy);
    [xtmp2,ytmp2]=ddb_coordConvert(xtmp,ytmp,Coord,WVSCoord);
    xl0(1)=min(min(xtmp2));
    xl0(2)=max(max(xtmp2));
    yl0(1)=min(min(ytmp2));
    yl0(2)=max(max(ytmp2));
else
    xl0=xl;
    yl0=yl;
end

dx=xl0(2)-xl0(1);

if dx<5
    res='f';
elseif dx<12
    res='h';
elseif dx<40
    res='i';
elseif dx<100
    res='l';
else
    res='c';
end

[x,y]=ddb_getWVS([handles.GeoDir 'wvs\' res '\'],xl0,yl0,res);

z=zeros(size(x))+500;
h=findobj(handles.GUIHandles.MainWindow,'Tag','WorldCoastLine');

[x,y]=ddb_coordConvert(x,y,WVSCoord,Coord);

set(h,'XData',x,'YData',y,'ZData',z);

toc

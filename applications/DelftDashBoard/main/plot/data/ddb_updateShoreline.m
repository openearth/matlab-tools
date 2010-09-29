function ddb_updateShoreline(handles)

tic

disp('Getting World Vector Shoreline ...');

iac=strmatch(lower(handles.ScreenParameters.Shoreline),lower(handles.Shorelines.longName),'exact');

%% Determine limits
xl=get(gca,'xlim');
yl=get(gca,'ylim');
handles.Shorelines.Shoreline(iac).HorizontalCoordinateSystem.Name;
ldbCoord.Name=handles.Shorelines.Shoreline(iac).HorizontalCoordinateSystem.Name;
ldbCoord.Type=handles.Shorelines.Shoreline(iac).HorizontalCoordinateSystem.Type;
Coord=handles.ScreenParameters.CoordinateSystem;
if ~strcmpi(Coord.Name,ldbCoord.Name)
    dx=(xl(2)-xl(1))/10;
    dy=(yl(2)-yl(1))/10;
    [xtmp,ytmp]=meshgrid(xl(1)-dx:dx:xl(2)+dx,yl(1)-dy:dy:yl(2)+dy);
    [xtmp2,ytmp2]=ddb_coordConvert(xtmp,ytmp,Coord,ldbCoord);
    xl0(1)=min(min(xtmp2));
    xl0(2)=max(max(xtmp2));
    yl0(1)=min(min(ytmp2));
    yl0(2)=max(max(ytmp2));
else
    xl0=xl;
    yl0=yl;
end

%% Find require scale
dx=xl0(2)-xl0(1);
switch lower(Coord.Type)
    case{'geo','geographic','geographic 2d','geographic 3d','spherical','latlon'}
        dx=dx*100000*cos(pi*0.5*(yl0(1)+yl0(2))/180);
end
screenWidth=0.4;
requiredScale=dx/screenWidth;
ires=find(handles.Shorelines.Shoreline(iac).Scale<requiredScale,1,'last');
if isempty(ires)
    ires=1;
end

%% Get Shoreline
[x,y]=ddb_getShoreline(handles,xl0,yl0,ires);
[x,y]=ddb_coordConvert(x,y,ldbCoord,Coord);

%% Plot shoreline
z=zeros(size(x))+500;
h=findobj(handles.GUIHandles.MainWindow,'Tag','shoreline');
set(h,'XData',x,'YData',y,'ZData',z);

toc

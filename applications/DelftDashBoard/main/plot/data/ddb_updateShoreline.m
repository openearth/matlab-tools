function ddb_updateShoreline(handles)

tic

disp('Getting World Vector Shoreline ...');

iac=strmatch(lower(handles.screenParameters.shoreline),lower(handles.shorelines.longName),'exact');

%% Determine limits
xl=get(gca,'xlim');
yl=get(gca,'ylim');
handles.shorelines.shoreline(iac).horizontalCoordinateSystem.name;
ldbCoord.name=handles.shorelines.shoreline(iac).horizontalCoordinateSystem.name;
ldbCoord.type=handles.shorelines.shoreline(iac).horizontalCoordinateSystem.type;
coord=handles.screenParameters.coordinateSystem;
if ~strcmpi(coord.name,ldbCoord.name)
    dx=(xl(2)-xl(1))/10;
    dy=(yl(2)-yl(1))/10;
    [xtmp,ytmp]=meshgrid(xl(1)-dx:dx:xl(2)+dx,yl(1)-dy:dy:yl(2)+dy);
    [xtmp2,ytmp2]=ddb_coordConvert(xtmp,ytmp,coord,ldbCoord);
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
switch lower(ldbCoord.type)
    case{'geo','geographic','geographic 2d','geographic 3d','spherical','latlon'}
        dx=dx*111111*cos(pi*0.5*(yl0(1)+yl0(2))/180);
end
screenWidth=0.4;
requiredScale=dx/screenWidth;
ires=find(handles.shorelines.shoreline(iac).scale<requiredScale,1,'last');
if isempty(ires)
    ires=1;
end

%% Get Shoreline
[x,y]=ddb_getShoreline(handles,xl0,yl0,ires);
[x,y]=ddb_coordConvert(x,y,ldbCoord,coord);

%% Plot shoreline
z=zeros(size(x))+500;
h=findobj(handles.GUIHandles.mainWindow,'Tag','shoreline');
set(h,'XData',x,'YData',y,'ZData',z);

toc

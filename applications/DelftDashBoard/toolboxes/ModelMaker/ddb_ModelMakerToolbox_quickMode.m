function ddb_ModelMakerToolbox_quickMode(varargin)

handles=getHandles;
ddb_zoomOff;

if isempty(varargin)
    % New tab selected
    ddb_refreshScreen;
    setUIElements('modelmakerpanel.quickmode');
    setHandles(handles);
    ddb_plotModelMaker('activate');
    if ~isempty(handles.Toolbox(tb).Input.gridOutlineHandle)
        setInstructions({'Left-click and drag markers to change corner points','Right-click and drag YELLOW marker to move entire box', ...
            'Right-click and drag RED markers to rotate box (note: rotating grid in geographic coordinate systems is NOT recommended!)'});
    end
else
    
    %Options selected

    opt=lower(varargin{1});
    
    switch opt
        case{'drawgridoutline'}
            drawGridOutline;
        case{'editgridoutline'}
            editGridOutline;
        case{'editresolution'}
            editResolution;
        case{'generategrid'}
            generateGrid;
        case{'generatebathymetry'}
            generateBathymetry;
        case{'generateopenboundaries'}
            generateOpenBoundaries;
        case{'generateboundaryconditions'}
            generateBoundaryConditions;
        case{'generateinitialconditions'}
            generateInitialConditions;
    end
    
end

%%
function drawGridOutline
handles=getHandles;
setInstructions({'','','Use mouse to draw grid outline on map'});
UIRectangle(handles.GUIHandles.mapAxis,'draw','Tag','GridOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',1,'callback',@updateGridOutline,'onstart',@deleteGridOutline, ...
    'ddx',handles.Toolbox(tb).Input.dX,'ddy',handles.Toolbox(tb).Input.dY);

%%
function updateGridOutline(x0,y0,dx,dy,rotation,h)

setInstructions({'Left-click and drag markers to change corner points','Right-click and drag YELLOW marker to move entire box', ...
    'Right-click and drag RED markers to rotate box (note: rotating grid in geographic coordinate systems is NOT recommended!)'});

handles=getHandles;

handles.Toolbox(tb).Input.gridOutlineHandle=h;

handles.Toolbox(tb).Input.xOri=x0;
handles.Toolbox(tb).Input.yOri=y0;
handles.Toolbox(tb).Input.rotation=rotation;
handles.Toolbox(tb).Input.nX=round(dx/handles.Toolbox(tb).Input.dX);
handles.Toolbox(tb).Input.nY=round(dy/handles.Toolbox(tb).Input.dY);
handles.Toolbox(tb).Input.lengthX=dx;
handles.Toolbox(tb).Input.lengthY=dy;

setHandles(handles);

setUIElement('modelmakerpanel.quickmode.editx0');
setUIElement('modelmakerpanel.quickmode.edity0');
setUIElement('modelmakerpanel.quickmode.editmmax');
setUIElement('modelmakerpanel.quickmode.editnmax');
setUIElement('modelmakerpanel.quickmode.editdx');
setUIElement('modelmakerpanel.quickmode.editdy');
setUIElement('modelmakerpanel.quickmode.editrotation');

%%
function deleteGridOutline
handles=getHandles;
if ~isempty(handles.Toolbox(tb).Input.gridOutlineHandle)
    try
        delete(handles.Toolbox(tb).Input.gridOutlineHandle);
    end
end

%%
function editGridOutline

handles=getHandles;

if ~isempty(handles.Toolbox(tb).Input.gridOutlineHandle)
    try
        delete(handles.Toolbox(tb).Input.gridOutlineHandle);
    end
end

handles.Toolbox(tb).Input.lengthX=handles.Toolbox(tb).Input.dX*handles.Toolbox(tb).Input.nX;
handles.Toolbox(tb).Input.lengthY=handles.Toolbox(tb).Input.dY*handles.Toolbox(tb).Input.nY;

lenx=handles.Toolbox(tb).Input.dX*handles.Toolbox(tb).Input.nX;
leny=handles.Toolbox(tb).Input.dY*handles.Toolbox(tb).Input.nY;
h=UIRectangle(handles.GUIHandles.mapAxis,'plot','Tag','GridOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',1,'callback',@updateGridOutline, ...
    'x0',handles.Toolbox(tb).Input.xOri,'y0',handles.Toolbox(tb).Input.yOri,'dx',lenx,'dy',leny,'rotation',handles.Toolbox(tb).Input.rotation, ...
    'ddx',handles.Toolbox(tb).Input.dX,'ddy',handles.Toolbox(tb).Input.dY);
handles.Toolbox(tb).Input.gridOutlineHandle=h;

setHandles(handles);

%%
function editResolution

handles=getHandles;

lenx=handles.Toolbox(tb).Input.lengthX;
leny=handles.Toolbox(tb).Input.lengthY;

dx=handles.Toolbox(tb).Input.dX;
dy=handles.Toolbox(tb).Input.dY;

nx=round(lenx/max(dx,1e-9));
ny=round(leny/max(dy,1e-9));

handles.Toolbox(tb).Input.nX=nx;
handles.Toolbox(tb).Input.nY=ny;

handles.Toolbox(tb).Input.lengthX=nx*dx;
handles.Toolbox(tb).Input.lengthY=ny*dy;

lenx=handles.Toolbox(tb).Input.lengthX;
leny=handles.Toolbox(tb).Input.lengthY;

if ~isempty(handles.Toolbox(tb).Input.gridOutlineHandle)
    try
        delete(handles.Toolbox(tb).Input.gridOutlineHandle);
    end
end

h=UIRectangle(handles.GUIHandles.mapAxis,'plot','Tag','GridOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',1,'callback',@updateGridOutline, ...
    'x0',handles.Toolbox(tb).Input.xOri,'y0',handles.Toolbox(tb).Input.yOri,'dx',handles.Toolbox(tb).Input.lengthX,'dy',handles.Toolbox(tb).Input.lengthY, ...
    'rotation',handles.Toolbox(tb).Input.rotation, ...
    'ddx',handles.Toolbox(tb).Input.dX,'ddy',handles.Toolbox(tb).Input.dY);
handles.Toolbox(tb).Input.gridOutlineHandle=h;

setHandles(handles);

setUIElement('modelmakerpanel.quickmode.editmmax');
setUIElement('modelmakerpanel.quickmode.editnmax');

%%
function generateGrid

handles=getHandles;

if handles.Toolbox(tb).Input.nX*handles.Toolbox(tb).Input.nY<=6000000
    f=str2func(['ddb_generateGrid' handles.Model(md).name]);
    try
        handles=feval(f,handles,ad,0,0,'ddb_test');
    catch
        GiveWarning('text',['Grid generation not supported for ' handles.Model(md).longName]);
        return
    end
    
    wb = waitbox('Generating grid ...');pause(0.1);
    
    xori=handles.Toolbox(tb).Input.xOri;
    nx=handles.Toolbox(tb).Input.nX;
    dx=handles.Toolbox(tb).Input.dX;
    yori=handles.Toolbox(tb).Input.yOri;
    ny=handles.Toolbox(tb).Input.nY;
    dy=handles.Toolbox(tb).Input.dY;
    rot=pi*handles.Toolbox(tb).Input.rotation/180;
    zmax=handles.Toolbox(tb).Input.zMax;
    
    % Find minimum grid resolution
    dmin=min(dx,dy);
    if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
        dmin=dmin*111111;
    end
%    dmin=dmin/2;
%     dmin=15000;

    % Find coordinates of corner points
    x(1)=xori;
    y(1)=yori;
    x(2)=x(1)+nx*dx*cos(pi*handles.Toolbox(tb).Input.rotation/180);
    y(2)=y(1)+nx*dx*sin(pi*handles.Toolbox(tb).Input.rotation/180);
    x(3)=x(2)+ny*dy*cos(pi*(handles.Toolbox(tb).Input.rotation+90)/180);
    y(3)=y(2)+ny*dy*sin(pi*(handles.Toolbox(tb).Input.rotation+90)/180);
    x(4)=x(3)+nx*dx*cos(pi*(handles.Toolbox(tb).Input.rotation+180)/180);
    y(4)=y(3)+nx*dx*sin(pi*(handles.Toolbox(tb).Input.rotation+180)/180);

    xl(1)=min(x);
    xl(2)=max(x);
    yl(1)=min(y);
    yl(2)=max(y);
    dbuf=(xl(2)-xl(1))/20;
    xl(1)=xl(1)-dbuf;
    xl(2)=xl(2)+dbuf;
    yl(1)=yl(1)-dbuf;
    yl(2)=yl(2)+dbuf;

    % Convert limits to cs of bathy data
    coord=handles.screenParameters.coordinateSystem;
    iac=strmatch(lower(handles.screenParameters.backgroundBathymetry),lower(handles.bathymetry.datasets),'exact');
    dataCoord.name=handles.bathymetry.dataset(iac).horizontalCoordinateSystem.name;
    dataCoord.type=handles.bathymetry.dataset(iac).horizontalCoordinateSystem.type;
    
    [xlb,ylb]=ddb_coordConvert(xl,yl,coord,dataCoord);
    
    [xx,yy,zz,ok]=ddb_getBathy(handles,xlb,ylb,'bathymetry',handles.screenParameters.backgroundBathymetry,'maxcellsize',dmin);

    % xx and yy are in coordinate system of bathymetry (usually WGS 84)
    % convert bathy grid to active coordinate system

    if ~strcmpi(dataCoord.name,coord.name) || ~strcmpi(dataCoord.type,coord.type)
        [xg,yg]=meshgrid(xl(1):dmin:xl(2),yl(1):dmin:yl(2));
        [xgb,ygb]=ddb_coordConvert(xg,yg,coord,dataCoord);
        zz=interp2(xx,yy,zz,xgb,ygb);
    else
        xg=xx;
        yg=yy;
    end
    
    [x,y]=MakeRectangularGrid(xori,yori,nx,ny,dx,dy,rot,zmax,xg,yg,zz);

    close(wb);

    handles=feval(f,handles,ad,x,y);

    setHandles(handles);
    
else
    GiveWarning('Warning','Maximum number of grid points (2,000,000) exceeded ! Please reduce grid resolution.');
end

%%
function generateBathymetry
handles=getHandles;
f=str2func(['ddb_generateBathymetry' handles.Model(md).name]);
try
    handles=feval(f,handles,ad,'ddb_test');
catch
    GiveWarning('text',['Bathymetry generation not supported for ' handles.Model(md).longName]);
    return
end
handles=feval(f,handles,ad);
setHandles(handles);

%%
function generateOpenBoundaries
handles=getHandles;
f=str2func(['ddb_generateBoundaryLocations' handles.Model(md).name]);
try
    handles=feval(f,handles,ad,'ddb_test');
catch
    GiveWarning('text',['Boundary generation not supported for ' handles.Model(md).longName]);
    return
end
x=handles.Model(md).Input(ad).gridX;
y=handles.Model(md).Input(ad).gridX;
handles=feval(f,handles,ad,x,y);
setHandles(handles);

%%
function generateBoundaryConditions
handles=getHandles;
f=str2func(['ddb_generateBoundaryConditions' handles.Model(md).name]);
try
    handles=feval(f,handles,ad,'ddb_test');
catch
    GiveWarning('text',['Boundary condition generation not supported for ' handles.Model(md).longName]);
    return
end
handles=feval(f,handles,ad);
setHandles(handles);

%%
function generateInitialConditions
handles=getHandles;
f=str2func(['ddb_generateInitialConditions' handles.Model(md).name]);
try
    handles=feval(f,handles,ad,'ddb_test','ddb_test');
catch
    GiveWarning('text',['Initial conditions generation not supported for ' handles.Model(md).longName]);
    return
end
if ~isempty(handles.Model(md).Input(ad).grdFile)
    attName=handles.Model(md).Input(ad).attName;
    handles.Model(md).Input(ad).iniFile=[attName '.ini'];
    handles.Model(md).Input(ad).initialConditions='ini';
    handles.Model(md).Input(ad).smoothingTime=0.0;
    handles=feval(f,handles,ad,handles.Model(md).Input(ad).iniFile);
else
    GiveWarning('Warning','First generate or load a grid');
end
setHandles(handles);

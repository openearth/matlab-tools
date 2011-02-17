function ddb_ModelMaker_quickMode(varargin)

handles=getHandles;
ddb_zoomOff;

if isempty(varargin)
    % New tab selected
    ddb_refreshScreen;
    setUIElements('modelmakerpanel.quickmode');
    setHandles(handles);
%    ddb_plotDredgePlume(handles,'activate');
else
    
    %Options selected

    opt=lower(varargin{1});
    
    switch opt
        case{'drawgridoutline'}
            drawGridOutline;
        case{'editgridoutline'}
            editGridOutline;
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
f1=@ddb_deleteGridOutline;
f2=@updateGridOutline;
f3=@updateGridOutline;
DrawRectangle('GridOutline',f1,f2,f3,'dx',handles.Toolbox(tb).Input.dX,'dy',handles.Toolbox(tb).Input.dY,'Color','g','Marker','o','MarkerColor','r','LineWidth',1.5,'Rotation','off');

%%
function updateGridOutline(x0,y0,lenx,leny,rotation)

handles=getHandles;

handles.Toolbox(tb).Input.xOri=x0;
handles.Toolbox(tb).Input.yOri=y0;
handles.Toolbox(tb).Input.rotation=rotation;
handles.Toolbox(tb).Input.nX=round(lenx/handles.Toolbox(tb).Input.dX);
handles.Toolbox(tb).Input.nY=round(leny/handles.Toolbox(tb).Input.dY);

setHandles(handles);

setUIElement('modelmakerpanel.quickmode.editx0');
setUIElement('modelmakerpanel.quickmode.edity0');
setUIElement('modelmakerpanel.quickmode.editmmax');
setUIElement('modelmakerpanel.quickmode.editnmax');
setUIElement('modelmakerpanel.quickmode.editdx');
setUIElement('modelmakerpanel.quickmode.editdy');
setUIElement('modelmakerpanel.quickmode.editrotation');


%%
function editGridOutline

handles=getHandles;
h=findobj(gca,'Tag','GridOutline');
if ~isempty(h)
    lenx=handles.Toolbox(tb).Input.dX*handles.Toolbox(tb).Input.nX;
    leny=handles.Toolbox(tb).Input.dY*handles.Toolbox(tb).Input.nY;
    PlotRectangle('GridOutline',handles.Toolbox(tb).Input.xOri,handles.Toolbox(tb).Input.yOri,lenx,leny,handles.Toolbox(tb).Input.rotation);
end


%%
function generateGrid

handles=getHandles;

if handles.Toolbox(tb).Input.nX*handles.Toolbox(tb).Input.nY<=2000000
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
    [x,y]=MakeRectangularGrid(xori,yori,nx,ny,dx,dy,rot,zmax,handles.GUIData.x,handles.GUIData.y,handles.GUIData.z);
    
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

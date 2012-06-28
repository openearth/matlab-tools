function ddb_Delft3DWAVE_boundaries(varargin)

if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
else
    opt=varargin{1};
    switch lower(opt)
        case{'add'}
            addBoundary;
        case{'delete'}
            deleteBoundary;
        case{'editboundaryconditions'}
            editBoundaryConditions;
        case{'drawxyboundary'}
            drawXYBoundary;
        case{'editxycoordinates'}
            editXYCoordinates;
    end
end

%%
function addBoundary

handles=getHandles;
nr=handles.Model(md).Input.nrboundaries;
nr=nr+1;
handles.Model(md).Input.boundaries=ddb_initializeDelft3DWAVEBoundary(handles.Model(md).Input.boundaries,nr);
handles.Model(md).Input.boundaries(nr).name=['Boundary ' num2str(nr)];
handles.Model(md).Input.boundarynames{nr}=['Boundary ' num2str(nr)];
handles.Model(md).Input.nrboundaries=nr;
handles.Model(md).Input.activeboundary=nr;
setHandles(handles);

%%
function deleteBoundary
handles=getHandles;
if handles.Model(md).Input.nrboundaries>0
    iac=handles.Model(md).Input.activeboundary;
    delete(handles.Model(md).Input.boundaries(iac).plothandle);
    handles.Model(md).Input.boundaries=removeFromStruc(handles.Model(md).Input.boundaries,iac);
    handles.Model(md).Input.boundarynames=removeFromCellArray(handles.Model(md).Input.boundarynames,iac);
    handles.Model(md).Input.nrboundaries=handles.Model(md).Input.nrboundaries-1;
    handles.Model(md).Input.activeboundary=max(min(handles.Model(md).Input.activeboundary,handles.Model(md).Input.nrboundaries),1);
    handles.Model(md).Input.activeboundaries=handles.Model(md).Input.activeboundary;
    if handles.Model(md).Input.nrboundaries==0
        handles.Model(md).Input.boundaries=ddb_initializeDelft3DWAVEBoundary(handles.Model(md).Input.boundaries,1);
    end
    setHandles(handles);
    gui_updateActiveTab;
%    ddb_Delft3DWAVE_plotBoundaries(handles,'update');
end

%%
function editBoundaryConditions

ddb_zoomOff;
handles=getHandles;

% Make new GUI
h=handles;

iac=handles.Model(md).Input.activeboundary;
switch lower(handles.Model(md).Input.boundaries(iac).periodtype)
    case{'peak'}
        h.Model(md).Input.periodtext='Wave Period Tp (s)';
    case{'mean'}
        h.Model(md).Input.periodtext='Wave Period Tm (s)';
end
switch lower(handles.Model(md).Input.boundaries(iac).dirspreadtype)
    case{'power'}
        h.Model(md).Input.dirspreadtext='Directional Spreading (-)';
    case{'degrees'}
        h.Model(md).Input.dirspreadtext='Directional Spreading (degrees)';
end

xmldir=handles.Model(md).xmlDir;
switch lower(handles.Model(md).Input.boundaries(iac).alongboundary)
    case{'uniform'}
        xmlfile='Delft3DWAVE.editboundaryconditionsuniform.xml';
        [h,ok]=gui_newWindow(h,'xmldir',xmldir,'xmlfile',xmlfile,'iconfile',[handles.settingsDir '\icons\deltares.gif']);
    case{'varying'}
        xmlfile='Delft3DWAVE.editboundaryconditionsvarying.xml';
        [h,ok]=gui_newWindow(h,'xmldir',xmldir,'xmlfile',xmlfile,'iconfile',[handles.settingsDir '\icons\deltares.gif'],'modal',0);
end


if ok
    handles=h;
    setHandles(handles);
end

%%
function drawXYBoundary
ddb_zoomOff;
handles=getHandles;
xg=handles.Model(md).Input.domains(1).gridx;
yg=handles.Model(md).Input.domains(1).gridy;
gui_dragLine('callback',@addXYBoundary,'method','alonggridline','gridx',xg,'gridy',yg);

%%
function addXYBoundary(x,y,m,n)
handles=getHandles;
h=gui_polyline('plot','x',x,'y',y,'tag','delft3dwaveboundary','Marker','o','changecallback',@changeXYBoundary,'closed',0, ...
    'color','r','markeredgecolor','r','markerfacecolor','r');
iac=handles.Model(md).Input.activeboundary;
if isfield(handles.Model(md).Input.boundaries(iac),'plothandle')
    if ~isempty(handles.Model(md).Input.boundaries(iac).plothandle)
        try
            delete(handles.Model(md).Input.boundaries(iac).plothandle);
        end
    end
end

handles.Model(md).Input.boundaries(iac).plothandle=h;
handles.Model(md).Input.boundaries(iac).startcoordx=x(1);
handles.Model(md).Input.boundaries(iac).endcoordx=x(2);
handles.Model(md).Input.boundaries(iac).startcoordy=y(1);
handles.Model(md).Input.boundaries(iac).endcoordy=y(2);
handles.Model(md).Input.boundaries(iac).startcoordm=m(1)-1;
handles.Model(md).Input.boundaries(iac).endcoordm=m(2)-1;
handles.Model(md).Input.boundaries(iac).startcoordn=n(1)-1;
handles.Model(md).Input.boundaries(iac).endcoordn=n(2)-1;
setHandles(handles);

gui_updateActiveTab;

%%
function changeXYBoundary(h,x,y,nr)
handles=getHandles;
for ii=1:handles.Model(md).Input.nrboundaries
    if handles.Model(md).Input.boundaries(ii).plothandle==h
        handles.Model(md).Input.boundaries(ii).startcoordx=x(1);
        handles.Model(md).Input.boundaries(ii).endcoordx=x(2);
        handles.Model(md).Input.boundaries(ii).startcoordy=y(1);
        handles.Model(md).Input.boundaries(ii).endcoordy=y(2);
        handles.Model(md).Input.activeboundary=ii;
        break
    end
end
setHandles(handles);
gui_updateActiveTab;

%%
function editXYCoordinates
handles=getHandles;
iac=handles.Model(md).Input.activeboundary;
h=handles.Model(md).Input.boundaries(iac).plothandle;
x(1)=handles.Model(md).Input.boundaries(iac).startcoordx;
x(2)=handles.Model(md).Input.boundaries(iac).endcoordx;
y(1)=handles.Model(md).Input.boundaries(iac).startcoordy;
y(2)=handles.Model(md).Input.boundaries(iac).endcoordy;
gui_polyline(h,'change','x',x,'y',y);

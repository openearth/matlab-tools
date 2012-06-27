function ddb_Delft3DWAVE_boundaries(varargin)

if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
else
    opt=varargin{1};
    switch lower(opt)
        case{'add'}
            addBoundary;
        case{'editboundaryconditions'}
            editBoundaryConditions;
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


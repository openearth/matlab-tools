function ddb_Delft3DWAVE_boundaries(varargin)

if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
else
    opt=varargin{1};
    switch lower(opt)
        case{'add'}
            addBoundary;
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


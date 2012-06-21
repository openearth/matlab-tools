function ddb_Delft3DWAVE_nesting(varargin)

if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
    % setUIElements('delft3dwave.grids.gridpanel.nesting');
else
    opt=varargin{1};
    switch lower(opt)
        case{'selectnestgrid'}
            selectNestGrid;
    end
end

%
function selectNestGrid
handles=getHandles;

handles.Model(md).Input.Domain(id).NestedValue = inst;
handles.Model(md).Input.Domain(id).GridNested = handles.Model(md).Input.Domain(inst).GrdFile;
handles.Model(md).Input.Domain(id).NstFile = handles.Model(md).Input.ComputationalGrids{inst};
set(handles.GUIHandles.TextGridNested,'value',inst);
set(handles.GUIHandles.textAssosGrid, 'String',['Associated bathymetry grid : ' handles.Model(md).Input.Domain(inst).GrdFile]);
set(handles.GUIHandles.textAssosData, 'String',['Associated bathymetry data : ' handles.Model(md).Input.Domain(inst).DepFile]);
setHandles(handles);

function ddb_TropicalCycloneToolbox_editTrackTable(varargin)

if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    ddb_plotTropicalCyclone('activate');
    setUIElements('tropicalcyclonepanel.tracktable');
    handles=getHandles;
    if strcmpi(handles.screenParameters.coordinateSystem.type,'cartesian')
        giveWarning('text','The Tropical Cyclone Toolbox currently only works for geographic coordinate systems!');
    end
else
    %Options selected
    opt=lower(varargin{1});    
    switch opt
        case{'edittracktable'}
            editTrackTable;
        case{'selectquadrant'}
            handles=getHandles;
            handles=ddb_setTrackTableValues(handles);
            setHandles(handles);
            ddb_updateTrackTables;
    end    
end

%%
function editTrackTable

handles=getHandles;

iq=handles.Toolbox(tb).Input.quadrant;

handles.Toolbox(tb).Input.trackVMax(:,iq)=handles.Toolbox(tb).Input.tableVMax;
handles.Toolbox(tb).Input.trackRMax(:,iq)=handles.Toolbox(tb).Input.tableRMax;
handles.Toolbox(tb).Input.trackPDrop(:,iq)=handles.Toolbox(tb).Input.tablePDrop;
handles.Toolbox(tb).Input.trackR100(:,iq)=handles.Toolbox(tb).Input.tableR100;
handles.Toolbox(tb).Input.trackR65(:,iq)=handles.Toolbox(tb).Input.tableR65;
handles.Toolbox(tb).Input.trackR50(:,iq)=handles.Toolbox(tb).Input.tableR50;
handles.Toolbox(tb).Input.trackR35(:,iq)=handles.Toolbox(tb).Input.tableR35;
handles.Toolbox(tb).Input.trackA(:,iq)=handles.Toolbox(tb).Input.tableA;
handles.Toolbox(tb).Input.trackB(:,iq)=handles.Toolbox(tb).Input.tableB;

setHandles(handles);

ddb_plotCycloneTrack;

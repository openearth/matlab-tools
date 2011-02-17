function ddb_Delft3DFLOW_processes(varargin)

ddb_zoomOff;

if isempty(varargin)
    ddb_refreshScreen;
else
    
    opt=varargin{1};
    
    switch(lower(opt))

        case{'edittracers'}
            ddb_editD3DFlowPollutants;
            setUIElement('delft3dflow.processes.checktracers');
            setUIElement('delft3dflow.processes.pushedittracers');


        case{'editsediments'}
            ddb_Delft3DFLOW_editSediments;
            setUIElement('delft3dflow.processes.checksediments');
            setUIElement('delft3dflow.processes.pusheditsediments');

        case{'checkconstituents'}

    end

    handles=getHandles;

    if handles.Model(md).Input(ad).salinity.include || handles.Model(md).Input(ad).temperature.include || ...
            handles.Model(md).Input(ad).sediments || handles.Model(md).Input(ad).tracers
        handles.Model(md).Input(ad).constituents=1;
    else
        handles.Model(md).Input(ad).constituents=0;
    end
    
    setHandles(handles);
    
end

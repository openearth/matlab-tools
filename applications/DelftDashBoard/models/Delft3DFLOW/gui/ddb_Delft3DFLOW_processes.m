function ddb_Delft3DFLOW_processes(varargin)

% handles=getHandles;

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


    end
end

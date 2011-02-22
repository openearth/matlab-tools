function ddb_Delft3DFLOW_storage(varargin)

if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
    setUIElements('delft3dflow.output.outputpanel.storage');
end

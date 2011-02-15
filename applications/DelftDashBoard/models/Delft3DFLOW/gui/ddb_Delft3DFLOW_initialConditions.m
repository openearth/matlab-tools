function ddb_Delft3DFLOW_initialConditions(varargin)

ddb_zoomOff;

if isempty(varargin)
    ddb_refreshScreen;
    setUIElements('delft3dflow.initialconditions');
end

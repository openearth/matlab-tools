function ddb_Delft3DFLOW_sediments(varargin)

if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
    setUIElements('delft3dflow.physicalparameters.physicalparameterspanel.sediments');
end

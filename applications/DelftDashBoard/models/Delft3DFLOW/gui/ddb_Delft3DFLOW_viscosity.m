function ddb_Delft3DFLOW_viscosity(varargin)

ddb_zoomOff;

if isempty(varargin)
    ddb_refreshScreen;
    setUIElements('delft3dflow.physicalparameters.physicalparameterspanel.viscosity');
end

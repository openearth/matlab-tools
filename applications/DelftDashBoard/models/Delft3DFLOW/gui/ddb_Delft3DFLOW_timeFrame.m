function ddb_Delft3DFLOW_timeFrame(varargin)

ddb_zoomOff;

setUIElements('delft3dflow.timeframe');

if isempty(varargin)
    ddb_refreshScreen;
end

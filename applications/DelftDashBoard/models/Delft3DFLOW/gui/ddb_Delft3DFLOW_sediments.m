function ddb_Delft3DFLOW_sediments(varargin)

if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
    setUIElements('delft3dflow.physicalparameters.physicalparameterspanel.sediments');
else
    opt=varargin{1};
    switch lower(opt)
        case{'opensedfile'}
            handles=getHandles;
            handles=ddb_readSedFile(handles,ad);
            setHandles(handles);
            setUIElements('delft3dflow.physicalparameters.physicalparameterspanel.sediments');
    end
end

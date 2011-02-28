function ddb_Delft3DFLOW_morphology(varargin)

ddb_zoomOff;

if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
    setUIElements('delft3dflow.physicalparameters.physicalparameterspanel.morphology');
else
    opt=varargin{1};
    switch lower(opt)
        case{'openmorfile'}
            handles=getHandles;
            handles=ddb_readMorFile(handles,ad);
            setHandles(handles);
            setUIElements('delft3dflow.physicalparameters.physicalparameterspanel.morphology');
        case{'savemorfile'}
            handles=getHandles;
            ddb_saveMorFile(handles,ad);
            setUIElements('delft3dflow.physicalparameters.physicalparameterspanel.morphology');
    end
end

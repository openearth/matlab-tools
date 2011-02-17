function ddb_Delft3DFLOW_bathymetry(varargin)

if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
    setUIElements('delft3dflow.domain.domainpanel.bathymetry');
else
    opt=varargin{1};
    switch lower(opt)
        case{'selectdepthfile'}
            selectDepthFile;
    end
end

%%
function selectDepthFile
handles=getHandles;
filename=handles.Model(md).Input(ad).depFile;
dp=ddb_wldep('read',filename,[handles.Model(md).Input(ad).MMax,handles.Model(md).Input(ad).NMax]);
handles.Model(md).Input(ad).depth=-dp(1:end-1,1:end-1);
handles.Model(md).Input(ad).depth(handles.Model(md).Input(ad).depth==999.999)=NaN;
handles.Model(md).Input(ad).depthZ=GetDepthZ(handles.Model(md).Input(ad).depth,handles.Model(md).Input(ad).dpsOpt);
setHandles(handles);
ddb_plotFlowBathymetry(handles,'plot',ad);

function ddb_Delft3DFLOW_selectDepthFile

handles=getHandles;

filename=handles.Model(md).Input(ad).DepFile;
dp=ddb_wldep('read',filename,[handles.Model(md).Input(ad).MMax,handles.Model(md).Input(ad).NMax]);
%        dp=max(dp,-10);
handles.Model(md).Input(ad).Depth=-dp(1:end-1,1:end-1);
%        handles.Model(md).Input(ad).Depth=handles.Model(md).Input(ad).Depth';
handles.Model(md).Input(ad).Depth(handles.Model(md).Input(ad).Depth==999.999)=NaN;
handles.Model(md).Input(ad).DepthZ=GetDepthZ(handles.Model(md).Input(ad).Depth,handles.Model(md).Input(ad).DpsOpt);
% set(handles.GUIHandles.TextDepthFile,'String',['File : ' handles.Model(md).Input(ad).DepFile]);

setHandles(handles);

ddb_plotFlowBathymetry(handles,'plot',ad);


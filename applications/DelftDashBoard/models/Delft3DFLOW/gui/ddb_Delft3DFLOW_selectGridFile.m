function ddb_Delft3DFLOW_selectGridFile

handles=getHandles;

filename=handles.Model(md).Input(ad).GrdFile;

[x,y,enc]=ddb_wlgrid('read',filename);

handles.Model(md).Input(ad).GridX=x;
handles.Model(md).Input(ad).GridY=y;
handles.Model(md).Input(ad).MMax=size(x,1)+1;
handles.Model(md).Input(ad).NMax=size(x,2)+1;
[handles.Model(md).Input(ad).GridXZ,handles.Model(md).Input(ad).GridYZ]=GetXZYZ(x,y);
handles=ddb_determineKCS(handles);
nans=zeros(size(handles.Model(md).Input(ad).GridX));
nans(nans==0)=NaN;
handles.Model(md).Input(ad).Depth=nans;
handles.Model(md).Input(ad).DepthZ=nans;

setHandles(handles);

setUIElement('delft3dflow.domain.domainpanel.grid.textgridm');
setUIElement('delft3dflow.domain.domainpanel.grid.textgridn');

ddb_plotGrid(x,y,ad,'FlowGrid','plot');

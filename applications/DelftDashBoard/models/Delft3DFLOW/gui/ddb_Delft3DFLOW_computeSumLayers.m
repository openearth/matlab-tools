function ddb_Delft3DFLOW_computeSumLayers

handles=getHandles;

handles.Model(md).Input(ad).SumLayers=sum(handles.Model(md).Input(ad).Thick);

setHandles(handles);

setUIElement('delft3dflow.domain.domainpanel.grid.sumlayers');

function ddb_UnibestCL_selectXyzFile

handles=getHandles;

filename=handles.Model(md).Input.XYZfile;
[XYZdata]=readXYZ(filename);
handles.Model(md).Input.XYZfile = filename;
handles.Model(md).Input.XYZdata = XYZdata;

setHandles(handles);

% ddb_plotFlowBathymetry(handles,'plot',ad);


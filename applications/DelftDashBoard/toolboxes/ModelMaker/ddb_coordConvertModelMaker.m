function handles=ddb_coordConvertModelMaker(handles)

ddb_plotModelMaker('delete');

ii=strmatch('ModelMaker',{handles.Toolbox(:).name},'exact');

handles.Toolbox(ii).Input.gridOutlineHandle=[];
handles.Toolbox(ii).Input.nX=1;
handles.Toolbox(ii).Input.dX=0.1;
handles.Toolbox(ii).Input.xOri=0.0;
handles.Toolbox(ii).Input.nY=1;
handles.Toolbox(ii).Input.dY=0.1;
handles.Toolbox(ii).Input.yOri=1.0;
handles.Toolbox(ii).Input.lengthX=0.1;
handles.Toolbox(ii).Input.lengthY=0.1;
handles.Toolbox(ii).Input.rotation=0.0;

function handles=ddb_initializeUnibestCLInput(handles,runid,varargin)

md=strmatch('UnibestCL',{handles.Model.Name},'exact');

handles.Model(md).Input.Runid = runid;
handles.Model(md).Input.NumberofClimates=0;
handles.Model(md).Input.ORKSTfile='';
handles.Model(md).Input.PROFHfile='';
handles.Model(md).Input.PROfile='';
handles.Model(md).Input.CFSfile='';
handles.Model(md).Input.CFEfile='';
handles.Model(md).Input.SCOfile='';
handles.Model(md).Input.RAYfile='';
handles.Model(md).Input.MDAfile='';
handles.Model(md).Input.XYZfile='';
handles.Model(md).Input.GKLfile='';
handles.Model(md).Input.RAYlocfile='';
handles.Model(md).Input.ORKSTdata='';
handles.Model(md).Input.PROFHdata='';
handles.Model(md).Input.PROdata='';
handles.Model(md).Input.CFSdata='';
handles.Model(md).Input.CFEdata='';
handles.Model(md).Input.SCOdata='';
handles.Model(md).Input.RAYdata='';
handles.Model(md).Input.MDAdata='';
handles.Model(md).Input.XYZdata='';
handles.Model(md).Input.GKLdata='';
% handles.Model(md).Input.RAYlocdata='';

handles.Model(md).Input.RAYlocdata.X1=[0,0,0,0];
handles.Model(md).Input.RAYlocdata.Y1=[0,0,0,0];
handles.Model(md).Input.RAYlocdata.X2=[0,0,0,0];
handles.Model(md).Input.RAYlocdata.Y2=[0,0,0,0];
handles.Model(md).Input.RAYlocdata.Ray={' ',' ',' ',' '};
handles.Model(md).Input.UniformDepth=10;
handles.Model(md).Input.depthSource='uniform';
handles.Model(md).Input.numberrays=6;
handles.Model(md).Input.RAYlocsource='create';
handles.Model(md).Input.selectedrayloc='';









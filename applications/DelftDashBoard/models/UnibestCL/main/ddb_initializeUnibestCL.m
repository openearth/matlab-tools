function handles=ddb_initializeUnibestCL(handles,varargin)

ii=strmatch('UnibestCL',{handles.Model.name},'exact');

handles.Model(ii).Input=[];
runid='tst';
handles=ddb_initializeUnibestCLInput(handles,runid);

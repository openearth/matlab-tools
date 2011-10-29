function handles=ddb_initializeTideDatabase(handles,varargin)

ii=strmatch('TideDatabase',{handles.Toolbox(:).name},'exact');

handles.Toolbox(ii).Input.activeModel=1;
handles.Toolbox(ii).Input.xLim(1)=0;
handles.Toolbox(ii).Input.yLim(1)=0;
handles.Toolbox(ii).Input.xLim(2)=0;
handles.Toolbox(ii).Input.yLim(2)=0;
handles.Toolbox(ii).Input.exportTypes={'tek'};
handles.Toolbox(ii).Input.activeExportType='tek';
handles.Toolbox(ii).Input.tideDatabaseBoxHandle=[];
handles.Toolbox(ii).Input.fourierFile='';
handles.Toolbox(ii).Input.fourierOutFile='';

function handles=ddb_initializeShoreline(handles,varargin)

ii=strmatch('Shoreline',{handles.Toolbox(:).name},'exact');

handles.Toolbox(ii).Input.activeDataset=1;
handles.Toolbox(ii).Input.polyLength=0;
handles.Toolbox(ii).Input.polygonFile='';

handles.Toolbox(ii).Input.activeScale=1;
handles.Toolbox(ii).Input.scaleText={'1'};

handles.Toolbox(ii).Input.exportTypes={'ldb'};
handles.Toolbox(ii).Input.activeExportType='ldb';

handles.Toolbox(ii).Input.usedDataset=[];
handles.Toolbox(ii).Input.usedDatasets={''};
handles.Toolbox(ii).Input.nrUsedDatasets=0;
handles.Toolbox(ii).Input.activeUsedDataset=1;

handles.Toolbox(ii).Input.newDataset.xmin=0;
handles.Toolbox(ii).Input.newDataset.xmax=0;
handles.Toolbox(ii).Input.newDataset.dx=0;
handles.Toolbox(ii).Input.newDataset.ymin=0;
handles.Toolbox(ii).Input.newDataset.ymax=0;
handles.Toolbox(ii).Input.newDataset.dy=0;


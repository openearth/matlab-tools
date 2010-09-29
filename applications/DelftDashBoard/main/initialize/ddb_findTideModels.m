function ddb_findTideModels

handles=getHandles;

handles=ddb_readTideModels(handles);

k=handles.TideModels.nrModels+1;

handles.TideModels.nrModels=k;

handles.TideModels.longName{k}='Constant';
handles.TideModels.Name{k}='constant';
handles.TideModels.Model(k).Name='constant';

handles.TideModels.ActiveTideModelBC=handles.TideModels.Name{1};
handles.TideModels.ActiveTideModelIC=handles.TideModels.Name{1};

setHandles(handles);

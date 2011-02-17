function ddb_findTideModels

handles=getHandles;

handles=ddb_readTideModels(handles);

% k=handles.tideModels.nrModels+1;
% handles.tideModels.nrModels=k;
% handles.tideModels.longName{k}='Constant';
% handles.tideModels.name{k}='constant';
% handles.tideModels.model(k).Name='constant';

% handles.tideModels.activeTideModelBC=1;
% handles.tideModels.activeTideModelIC=1;

disp([num2str(handles.tideModels.nrModels) ' tide models found!']);

setHandles(handles);

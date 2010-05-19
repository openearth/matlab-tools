function handles=ddb_findTideModels(handles)

a=dir([handles.TideDir '\model*']);

for i=1:length(a)
    handles.TideModelData.TideModels{i}=a(i).name;
end
handles.TideModelData.TideModels{i+1}='Constant';
if strmatch('Model_tpxo62',handles.TideModelData.TideModels,'exact')
    handles.TideModelData.ActiveTideModelBC='Model_tpxo62';
    handles.TideModelData.ActiveTideModelIC='Model_tpxo62';
elseif strmatch('Model_tpxo6.2',handles.TideModelData.TideModels,'exact')
    handles.TideModelData.ActiveTideModelBC='Model_tpxo6.2';
    handles.TideModelData.ActiveTideModelIC='Model_tpxo6.2';
else
    handles.TideModelData.ActiveTideModelBC=handles.TideModelData.TideModels{1};
    handles.TideModelData.ActiveTideModelIC=handles.TideModelData.TideModels{1};
end

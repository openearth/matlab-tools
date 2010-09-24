function ddb_selectWorkingDirectory

handles=getHandles;

directoryname = uigetdir(handles.WorkingDirectory, 'Select working directory');

if directoryname==0
    return
end

cd(directoryname)
handles.WorkingDirectory=directoryname;

setHandles(handles);

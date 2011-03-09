function ddb_selectWorkingDirectory

handles=getHandles;

directoryname = uigetdir(handles.workingDirectory, 'Select working directory');

if directoryname==0
    return
end

cd(directoryname)
handles.workingDirectory=directoryname;

setHandles(handles);

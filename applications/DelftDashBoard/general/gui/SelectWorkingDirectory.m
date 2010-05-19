function handles=SelectWorkingDirectory(handles)

directoryname = uigetdir(handles.WorkingDirectory, 'Select working directory');

if directoryname==0
    return
end

cd(directoryname)
handles.WorkingDirectory=directoryname;

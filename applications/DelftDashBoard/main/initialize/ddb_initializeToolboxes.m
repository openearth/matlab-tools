function ddb_initializeToolboxes
handles=getHandles;
for k=1:length(handles.Toolbox)
    f=handles.Toolbox(k).iniFcn;
    handles=f(handles);
end
setHandles(handles);

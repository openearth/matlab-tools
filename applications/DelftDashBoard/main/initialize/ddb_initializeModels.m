function ddb_initializeModels
handles=getHandles;
for k=1:length(handles.Model)
    f=handles.Model(k).iniFcn;
    handles=f(handles);
end
setHandles(handles);

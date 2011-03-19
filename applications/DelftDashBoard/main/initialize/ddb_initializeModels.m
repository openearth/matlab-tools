function ddb_initializeModels
handles=getHandles;
handles.activeDomain=1;
for k=1:length(handles.Model)
    f=handles.Model(k).iniFcn;
    handles=f(handles);
    handles.Model(k).nrDomains=1;
end
setHandles(handles);

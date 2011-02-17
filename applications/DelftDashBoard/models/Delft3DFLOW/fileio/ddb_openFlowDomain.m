function handles=ddb_openFlowDomain(handles,pathname,filename,option)

if strcmpi(option,'add')
    handles.activeDomain=handles.activeDomain+1;
else
    deleteAllObjects;
end

cd(pathname);

%DeleteAllObjects;
handles=ddb_initialize(handles,'all');
ii=findstr(filename,'.mdf');
handles.Model(md).Input(ad).runid=filename(1:ii-1);
handles=ddb_readMDF(handles,filename,1);
handles=ddb_readAttributeFiles(handles);

refreshDomains(handles);

setHandles(handles);
set(gca,'XLim',handles.screenParameters.xLim,'YLim',handles.screenParameters.yLim);

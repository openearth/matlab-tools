function handles=ddb_openFlowDomain(handles,pathname,filename,option)

mo=strmatch('Delft3DFLOW',{handles.Model.Name},'exact');

if strcmpi(option,'add')
    handles.ActiveDomain=handles.ActiveDomain+1;
    handles.GUIData.NrFlowDomains+1;
else
    DeleteAllObjects;
end

cd(pathname);

%DeleteAllObjects;
handles=ddb_initialize(handles,'all');
ii=findstr(filename,'.mdf');
handles.Model(md).Input(ad).Runid=filename(1:ii-1);
handles=ddb_readMDF(handles,filename,1);
handles=ddb_readAttributeFiles(handles);

RefreshDomains(handles);

setHandles(handles);
set(gca,'XLim',handles.ScreenParameters.XLim,'YLim',handles.ScreenParameters.YLim);

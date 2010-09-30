function ddb_Delft3DFLOW_selectGridEnclosure

handles=getHandles;

handles=getHandles;
[filename, pathname, filterindex] = uigetfile('*.enc', 'Select Enclosure File');
curdir=[lower(cd) '\'];
if ~strcmpi(curdir,pathname)
    filename=[pathname filename];
end
handles.Model(md).Input(ad).EncFile=filename;
mn=ddb_enclosure('read',filename);
[handles.Model(md).Input(ad).GridX,handles.Model(md).Input(ad).GridY]=ddb_enclosure('apply',mn,handles.Model(md).Input(ad).GridX,handles.Model(md).Input(ad).GridY);
[handles.Model(md).Input(ad).GridXZ,handles.Model(md).Input(ad).GridYZ]=GetXZYZ(handles.Model(md).Input(ad).GridX,handles.Model(md).Input(ad).GridY);
set(handles.GUIHandles.TextEnclosureFile,'String',['File : ' filename]);
setHandles(handles);
%ddb_plotFlowGrid(ad,'k');

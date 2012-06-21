function ddb_UnibestCL_pushgenerateprofiles(hObject,eventdata)

handles=getHandles;

XYZdata = handles.Model(md).Input.XYZdata;
XYZfile = handles.Model(md).Input.XYZfile;
RAYlocdata = handles.Model(md).Input.RAYlocdata;
PROdata = handles.Model(md).Input.PROdata;
[PROdata] = extractPRO_new(XYZdata,RAYlocdata,XYZfile,PROdata);
handles.Model(md).Input.PROdata = PROdata;
setHandles(handles);

%GUI updates
% setUIElements(handles.Model(md).GUI.elements.tabs(3).elements.tabs(3).elements)
handles.Model(md).Input.profilesgenerated=1;
if  handles.Model(md).Input.profilesgenerated==1
    elements = handles.Model(md).GUI.elements.tabs(3).elements.tabs(3).elements;    
    for ii = 1:length(elements)
        A(ii) = strcmp(elements(ii).tag,'unibestcl.profiles.profilepanel.profiles.pushselectprofile');
    end
    AA = find(A==1); 
    set(handles.Model(md).GUI.elements.tabs(3).elements.tabs(3).elements(AA).handle,'Enable','on');
end

setHandles(handles);


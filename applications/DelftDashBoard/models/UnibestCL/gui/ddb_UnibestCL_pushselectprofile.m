function ddb_UnibestCL_pushselectprofile(hObject,eventdata)

handles=getHandles;

pr = handles.Model(md).Input.activePROfile;
filename=handles.Model(md).Input.PROfile;
[pathstr, name, ext] = fileparts(filename);
filename = [name,ext];
PROdata=handles.Model(md).Input.PROdata; 
for ii = 1:length(PROdata)
    check=strcmp(filename,PROdata(ii).filename);
    if  check == 1
        pr = ii;
    end
end
handles.Model(md).Input.activePROfile = pr;
handles.Model(md).Input.PROfile = filename;

if  pr>0
    elements = handles.Model(md).GUI.elements.tabs(3).elements.tabs(3).elements;    
    for ii = 1:length(elements)
        A(ii) = strcmp(elements(ii).tag,'unibestcl.profiles.profilepanel.profiles.pusheditprofile');
    end
    AA = find(A==1);
    set(handles.Model(md).GUI.elements.tabs(3).elements.tabs(3).elements(AA).handle,'Enable','on');
end
setHandles(handles);
function ddb_UnibestCL_pushselectprofile(hObject,eventdata)

handles=getHandles;

pr = handles.Model(md).Input.activePROfile;
filename1=handles.Model(md).Input.PROfile;
[pathstr1, name1, ext1] = fileparts(filename1);
filename1 = [name1,ext1];
PROdata=handles.Model(md).Input.PROdata;
for ii = 1:length(PROdata)
    filename2 = PROdata(ii).filename;
    [pathstr2, name2, ext2] = fileparts(filename2);
    filename2 = [name2,ext2];
    check=strcmp(filename1,filename2);
    if  check == 1
        pr = ii;
    end
end
handles.Model(md).Input.activePROfile = pr;
handles.Model(md).Input.PROfile = filename1;

if  pr>0
    elements = handles.Model(md).GUI.elements.tabs(3).elements.tabs(3).elements;    
    for ii = 1:length(elements)
        A(ii) = strcmp(elements(ii).tag,'unibestcl.profiles.profilepanel.profiles.pusheditprofile');
    end
    AA = find(A==1);
    set(handles.Model(md).GUI.elements.tabs(3).elements.tabs(3).elements(AA).handle,'Enable','on');
end
% setUIElements(handles.Model(md).GUI.elements.tabs(3).elements.tabs(3).elements)
setHandles(handles);
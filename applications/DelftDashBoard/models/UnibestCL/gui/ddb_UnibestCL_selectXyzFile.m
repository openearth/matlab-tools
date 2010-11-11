function ddb_UnibestCL_selectXyzFile

handles=getHandles;

filename=handles.Model(md).Input.XYZfile;
[XYZdata]=readXYZ(filename);
handles.Model(md).Input.XYZfile = filename;
handles.Model(md).Input.XYZdata = XYZdata;
setHandles(handles);

%GUI updates
setUIElements(handles.Model(md).GUI.elements.tabs(3).elements.tabs(3).elements)
handles.Model(md).Input.XYZfileselected=1;
if  handles.Model(md).Input.XYZfileselected==1 && handles.Model(md).Input.RAYlocfileselected==1
    elements = handles.Model(md).GUI.elements.tabs(3).elements.tabs(3).elements;    
    for ii = 1:length(elements)
        A(ii) = strcmp(elements(ii).tag,'unibestcl.profiles.profilepanel.profiles.pushgenerateprofiles');
    end
    AA = find(A==1); 
    set(handles.Model(md).GUI.elements.tabs(3).elements.tabs(3).elements(AA).handle,'Enable','on');
end
setHandles(handles);



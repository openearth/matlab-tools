function ddb_UnibestCL_pushSaveRayLocationsAs(varargin)      

handles = getHandles;

RAYlocfile = handles.Model(md).Input.RAYlocfile;
RAYlocdata = handles.Model(md).Input.RAYlocdata;

[filename, pathname] = uiputfile('*.pol', 'Enter pol File','');
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input.RAYlocfile=filename;
    RAYlocfile = handles.Model(md).Input.RAYlocfile;
    writeRAYloc(RAYlocfile,RAYlocdata);
end
setHandles(handles);

%GUI updates
setUIElements(handles.Model(md).GUI.elements.tabs(3).elements.tabs(3).elements)
handles.Model(md).Input.RAYlocfileselected=1;
if  handles.Model(md).Input.XYZfileselected==1 && handles.Model(md).Input.RAYlocfileselected==1
    elements = handles.Model(md).GUI.elements.tabs(3).elements.tabs(3).elements;    
    for ii = 1:length(elements)
        A(ii) = strcmp(elements(ii).tag,'unibestcl.profiles.profilepanel.profiles.pushgenerateprofiles');
    end
    AA = find(A==1); 
    set(handles.Model(md).GUI.elements.tabs(3).elements.tabs(3).elements(AA).handle,'Enable','on');
end

setHandles(handles);


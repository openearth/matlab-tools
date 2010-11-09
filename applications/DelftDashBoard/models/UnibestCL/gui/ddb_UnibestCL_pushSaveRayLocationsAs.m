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
    ii=findstr(filename,'.pol');
%             handles.Model(md).Input(ad).Runid=filename(1:ii-1);
    handles.Model(md).Input.RAYlocfile=filename;
    RAYlocfile = handles.Model(md).Input.RAYlocfile;
    writeRAYloc(RAYlocfile,RAYlocdata);
end
setHandles(handles);

for jj = 1:length(handles.Model(md).GUI.elements.tabs(3).elements.tabs)
    setUIElements(handles.Model(md).GUI.elements.tabs(3).elements.tabs(jj).elements)
end



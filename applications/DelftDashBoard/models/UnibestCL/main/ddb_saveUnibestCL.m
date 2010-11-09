function ddb_saveUnibestCL(opt)

handles=getHandles;

switch lower(opt)
    case{'save'}
        ddb_saveLTR(handles);
    case{'saveas'}
        [filename, pathname, filterindex] = uiputfile('*.ltr', 'Select LTR File','');
        if pathname~=0
            curdir=[lower(cd) '\'];
            if ~strcmpi(curdir,pathname)
                filename=[pathname filename];
            end
            ii=findstr(filename,'.ltr');
            handles.Model(md).Input(ad).Runid=filename(1:ii-1);
            handles.Model(md).Input(ad).LTRFile=filename;
            handles=ddb_saveLTR(handles);
        end      
end

setHandles(handles);




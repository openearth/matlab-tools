function ddb_saveDelft3DWAVE(opt)

handles=getHandles;

id=1;

switch lower(opt)
    case{'save'}
        ddb_saveMDW(handles,id);
    case{'saveas'}
        [filename, pathname, filterindex] = uiputfile('*.mdw', 'Select MDW File','');
        if pathname~=0
            curdir=[lower(cd) '\'];
            if ~strcmpi(curdir,pathname)
                filename=[pathname filename];
            end
            ii=findstr(filename,'.mdw');
            handles.Delft3DWAVE.Input.Runid=filename(1:ii-1);
            handles.Delft3DWAVE.Input.MdwFile=filename;
            handles=ddb_saveMDW(handles,id);
        end
    case{'saveall'}
        ddb_saveMDW(handles,id);
        SaveWaveAttributeFiles(handles,id,'saveall');
    case{'saveallas'}
        [filename, pathname, filterindex] = uiputfile('*.mdw', 'Select MDW File','');
        if pathname~=0
            curdir=[lower(cd) '\'];
            if ~strcmpi(curdir,pathname)
                filename=[pathname filename];
            end
            ii=findstr(filename,'.mdw');
            handles.Delft3DWAVE.Input.Runid=filename(1:ii-1);
            handles.Delft3DWAVE.Input.MdwFile=filename;
            handles=ddb_saveMDW(handles,id);
        end
        SaveWaveAttributeFiles(handles,id,'saveallas');
end

setHandles(handles);

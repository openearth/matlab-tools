function ddb_saveDelft3DWAVE(opt)

handles=getHandles;

imd=strmatch('Delft3DWAVE',{handles.Model(:).name},'exact');

id=1;

switch lower(opt)
    case{'save'}
        ddb_saveMDW(handles);
    case{'saveas'}
        [filename, pathname, filterindex] = uiputfile('*.mdw', 'Select MDW File','');
        if pathname~=0
            curdir=[lower(cd) '\'];
            if ~strcmpi(curdir,pathname)
                filename=[pathname filename];
            end
            ii=findstr(filename,'.mdw');
            handles.Model(imd).Input.runid=filename(1:ii-1);
            handles.Model(imd).Input.mdwfile=filename;
            handles=ddb_saveMDW(handles);
        end
    case{'saveall'}
        ddb_saveMDW(handles);
        SaveWaveAttributeFiles(handles,'saveall');
    case{'saveallas'}
        [filename, pathname, filterindex] = uiputfile('*.mdw', 'Select MDW File','');
        if pathname~=0
            curdir=[lower(cd) '\'];
            if ~strcmpi(curdir,pathname)
                filename=[pathname filename];
            end
            ii=findstr(filename,'.mdw');
            handles.Model(imd).Input.runid=filename(1:ii-1);
            handles.Model(imd).Input.mdwfile=filename;
            handles=ddb_saveMDW(handles);
        end
        SaveWaveAttributeFiles(handles,id,'saveallas');
end

setHandles(handles);

function handles=ddb_saveSWAN(handles,opt)

handles=getHandles;

id=handles.ActiveDomain;

switch lower(opt)
    case{'save'}
        ddb_saveSWANFile(handles,id);
    case{'saveas'}
        [filename, pathname, filterindex] = uiputfile('*.swn', 'Select Swan *.swn File','');
        if pathname~=0
            curdir=[lower(cd) '\'];
            if ~strcmpi(curdir,pathname)
                filename=[pathname filename];
            end
            ii=findstr(filename,'.swn');
            handles.SWANInput(id).Runid=filename(1:ii-1);
            handles.SWANInput(id).InputFile=filename;
            handles=ddb_saveMDW(handles,id);
        end
    case{'saveall'}
        ddb_saveMDW(handles,id);
        SaveWaveAttributeFiles(handles,id,'saveall');
    case{'saveallas'}
        [filename, pathname, filterindex] = uiputfile('*.swn', 'Select Swan *.swn File','');
        if pathname~=0
            curdir=[lower(cd) '\'];
            if ~strcmpi(curdir,pathname)
                filename=[pathname filename];
            end
            ii=findstr(filename,'.swn');
            handles.SWANInput(id).Runid=filename(1:ii-1);
            handles.SWANInput(id).MdwFile=filename;
            handles=ddb_saveSWN(handles,id);
        end
        SaveWaveAttributeFiles(handles,id,'saveallas');
end

setHandles(handles);

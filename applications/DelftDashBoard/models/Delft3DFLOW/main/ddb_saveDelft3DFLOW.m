function ddb_saveDelft3DFLOW(opt)

handles=getHandles;

switch lower(opt)
    case{'save'}
        ddb_saveMDF(handles,ad);
    case{'saveas'}
        [filename, pathname, filterindex] = uiputfile('*.mdf', 'Select MDF File','');
        if pathname~=0
            curdir=[lower(cd) '\'];
            if ~strcmpi(curdir,pathname)
                filename=[pathname filename];
            end
            ii=findstr(filename,'.mdf');
            handles.Model(md).Input(ad).runid=filename(1:ii-1);
            handles.Model(md).Input(ad).mdfFile=filename;
            handles=ddb_saveMDF(handles,ad);
        end
    case{'saveall'}
        for i=1:handles.Model(md).nrDomains
            handles=ddb_saveAttributeFiles(handles,i,'saveall');
            handles=ddb_saveMDF(handles,i);
        end
    case{'saveallas'}
        [filename, pathname, filterindex] = uiputfile('*.mdf', 'Select MDF File','');
        if pathname~=0
            handles=ddb_saveAttributeFiles(handles,ad,'saveallas');
            curdir=[lower(cd) '\'];
            if ~strcmpi(curdir,pathname)
                filename=[pathname filename];
            end
            ii=findstr(filename,'.mdf');
            handles.Model(md).Input(ad).runid=filename(1:ii-1);
            handles.Model(md).Input(ad).mdfFile=filename;
            handles=ddb_saveMDF(handles,ad);
        end
    case{'savealldomains'}
        for i=1:handles.Model(md).nrDomains
            handles=ddb_saveAttributeFiles(handles,i,'saveall');
            handles=ddb_saveMDF(handles,i);
        end        
end

setHandles(handles);

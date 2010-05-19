function handles=ddb_saveXBeach(handles,opt)

ii=strmatch('XBeach',{handles.Model.Name},'exact');

switch lower(opt)
    case{'save'}
        ddb_saveParams(handles);
    case{'saveas'}
        [filename, pathname, filterindex] = uiputfile('*.*', 'Select Params File','');
        if pathname~=0
            curdir=[lower(cd) '\'];
            if ~strcmpi(curdir,pathname)
                filename=[pathname filename];
            end
            handles.Model(ii).Input(ad).Runid='tst';
            handles.Model(ii).Input(ad).ParamsFile=filename;
            ddb_saveParams(handles);
        end
    case{'saveall'}
        ddb_saveParams(handles);
    case{'saveallas'}
        [filename, pathname, filterindex] = uiputfile('*.*', 'Select Params File','');
        if pathname~=0
            curdir=[lower(cd) '\'];
            if ~strcmpi(curdir,pathname)
                filename=[pathname filename];
            end
            handles.Model(ii).Input(ad).Runid='tst';
            handles.Model(ii).Input(ad).ParamsFile=filename;
            handles=ddb_saveParams(handles);
        end
end


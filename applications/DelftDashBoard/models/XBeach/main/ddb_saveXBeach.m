function handles=ddb_saveXBeach(opt)

handles=getHandles;

switch lower(opt)
    case{'save'}
        handles.outDirectory = handles.workingDirectory;
        ddb_saveParams(handles);
    case{'saveas'}
        [filename, pathname] = uiputfile('*.txt*', 'Select directory to save model files','params.txt');
        handles.outDirectory = pathname;
        ddb_saveParams(handles);
%         if pathname~=0
%             curdir=[lower(cd) '\'];
%             if ~strcmpi(curdir,pathname)
%                 filename=[pathname filename];
%             end
%             handles.model.xbeach.domain(ad).Runid='tst';
%             handles.model.xbeach.domain(ad).ParamsFile=filename;
%             ddb_saveParams(handles);
%         end
    case{'saveall'}
        ddb_saveParams(handles);
    case{'saveallas'}
        [filename, pathname, filterindex] = uiputfile('*.*', 'Select Params File','');
        if pathname~=0
            curdir=[lower(cd) '\'];
            if ~strcmpi(curdir,pathname)
                filename=[pathname filename];
            end
            handles.model.xbeach.domain(ad).Runid='tst';
            handles.model.xbeach.domain(ad).ParamsFile=filename;
            handles=ddb_saveParams(handles);
        end
end

setHandles(handles);


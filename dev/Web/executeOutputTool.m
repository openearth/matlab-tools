function executeOutputTool(varInfo, metaInfo, options, debug)
%Function to execute the export function
if debug == 1
    try
        conf = Configuration;
        currentDate = datestr(now, 'dd-mmm-yyyy_HH-MM-SS');
        debug = 0;
        if isdir(fullfile(conf.DEBUG_FOLDER));
            save([fullfile(conf.DEBUG_FOLDER) 'executeOutputTool' '_' currentDate '.mat']);
        else
            mkdir(fullfile(conf.DEBUG_FOLDER));
            save([fullfile(conf.DEBUG_FOLDER) 'executeOutputTool' '_' currentDate '.mat']);
        end;
    catch
        sct = lasterror;
        errordlg([sct.message ' Error. The debug file could not be saved.']);
        return;
    end
end;
WebExport.getOutputFormat(varInfo, metaInfo, options);
end
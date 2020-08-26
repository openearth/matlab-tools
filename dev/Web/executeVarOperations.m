function executeVarOperations(from, to, coordinate, variable, options, debug)
%function to execute some calculations copy/move/interpolate variable
if debug == 1
    try
        conf = Configuration;
        currentDate = datestr(now, 'dd-mmm-yyyy_HH-MM-SS');
        debug = 0;
        if isdir(fullfile(conf.DEBUG_FOLDER));
            save([fullfile(conf.DEBUG_FOLDER) 'executeVarOperations' '_' currentDate '.mat']);
        else
            mkdir(fullfile(conf.DEBUG_FOLDER));
            save([fullfile(conf.DEBUG_FOLDER) 'executeVarOperations' '_' currentDate '.mat']);
        end;
    catch
        sct = lasterror;
        errordlg([sct.message ' Error. The debug file could not be saved.']);
        return;
    end
end;
WebDataset.variableOperations(from, to, coordinate, variable, options);


end
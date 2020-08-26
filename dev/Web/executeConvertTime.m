function executeConvertTime(source, options, debug)
%Function to execute the convert the time
if debug == 1
    try
        conf = Configuration;
        currentDate = datestr(now, 'dd-mmm-yyyy_HH-MM-SS');
        debug = 0;
        if isdir(fullfile(conf.DEBUG_FOLDER));
            save([fullfile(conf.DEBUG_FOLDER) 'executeConvertTime' '_' currentDate '.mat']);
        else
            mkdir(fullfile(conf.DEBUG_FOLDER));
            save([fullfile(conf.DEBUG_FOLDER) 'executeConvertTime' '_' currentDate '.mat']);
        end;
    catch
        sct = lasterror;
        errordlg([sct.message ' Error. The debug file could not be saved.']);
        return;
    end
end;
WebTime.convertTime(source, options);

end

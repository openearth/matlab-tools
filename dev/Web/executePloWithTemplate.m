function executePloWithTemplate(jsonFile, debug)
%Function to execute plotting with multiple axes including template
%transform the data to send to plot function
if debug == 1
    try
        conf = Configuration;
        currentDate = datestr(now, 'dd-mmm-yyyy_HH-MM-SS');
        debug = 0;
        if isdir(fullfile(conf.DEBUG_FOLDER));
            save([fullfile(conf.DEBUG_FOLDER) 'executePloWithTemplate' '_' currentDate '.mat']);
        else
            mkdir(fullfile(conf.DEBUG_FOLDER));
            save([fullfile(conf.DEBUG_FOLDER) 'executePloWithTemplate' '_' currentDate '.mat']);
        end;
    catch
        sct = lasterror;
        errordlg([sct.message ' Error. The debug file could not be saved.']);
        return;
    end
end;

%read all the data to plot
[myAxes options axesProperties textInAxes imagesInAxes rectanglesInAxes globalConfig saveOptions] = UtilPlot.readTemplateFile(jsonFile);

%get all the files avaliable to use the template generator
listSelectedFiles = UtilPlot.getFileList(myAxes);

%load all the data to plot
[allInfoPerFile nrFigures] = WebPlot.loadTemplateData(listSelectedFiles, myAxes, options);

%make the template
WebPlot.plotTemplate(allInfoPerFile, nrFigures, axesProperties, textInAxes, imagesInAxes, rectanglesInAxes, globalConfig, saveOptions)

end
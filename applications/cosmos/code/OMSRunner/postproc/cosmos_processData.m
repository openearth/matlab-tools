function hm=cosmos_processData(hm,m)

model=hm.models(m);

mdl=model.name;

if model.extractData
    try
        disp('Extracting Data ...');
        tic
        set(hm.textModelLoopStatus,'String',['Status : extracting data - ' mdl ' ...']);drawnow;
        switch lower(model.type)
            case{'delft3dflow','delft3dflowwave'}
                MakeDir(hm.archiveDir,model.continent,model.name,'archive',hm.cycStr,'timeseries');
                MakeDir(hm.archiveDir,model.continent,model.name,'archive',hm.cycStr,'sp2');
                MakeDir(hm.archiveDir,model.continent,model.name,'archive',hm.cycStr,'maps');
                MakeDir(hm.archiveDir,model.continent,model.name,'archive','appended','timeseries');
                MakeDir(hm.archiveDir,model.continent,model.name,'archive','appended','maps');
                cosmos_extractDataDelft3D(hm,m);
            case{'xbeach'}
                MakeDir(hm.archiveDir,model.continent,model.name,'archive',hm.cycStr,'timeseries');
                MakeDir(hm.archiveDir,model.continent,model.name,'archive',hm.cycStr,'maps');
                MakeDir(hm.archiveDir,model.continent,model.name,'archive','appended','timeseries');
                MakeDir(hm.archiveDir,model.continent,model.name,'archive','appended','maps');
                ExtractDataXBeach(hm,m);
            case{'ww3'}
                MakeDir(hm.archiveDir,model.continent,model.name,'archive',hm.cycStr,'timeseries');
                MakeDir(hm.archiveDir,model.continent,model.name,'archive',hm.cycStr,'sp2');
                MakeDir(hm.archiveDir,model.continent,model.name,'archive',hm.cycStr,'maps');
                MakeDir(hm.archiveDir,model.continent,model.name,'archive','appended','timeseries');
                MakeDir(hm.archiveDir,model.continent,model.name,'archive','appended','maps');
                cosmos_extractDataWW3(hm,m);
            case{'xbeachcluster'}
                MakeDir(hm.archiveDir,model.continent,model.name,'archive',hm.cycStr,'netcdf');
                MakeDir(hm.archiveDir,model.continent,model.name,'archive',hm.cycStr,'hazards');
                MakeDir(hm.archiveDir,model.continent,model.name,'archive',hm.cycStr,'timeseries');
                cosmos_extractDataXBeachCluster(hm,m);
        end
        cosmos_convertTimeSeriesMat2NC(hm,m);
        cosmos_copyNCTimeSeriesToOPeNDAP(hm,m);
    catch
        WriteErrorLogFile(hm,['Something went wrong with extracting data from ' model.name]);
        %     hm.models(m).status='failed';
        %     return;
    end
    hm.models(m).extractDuration=toc;
end

if model.archiveInput
    try
        disp('Archiving input ...');
        MakeDir(hm.archiveDir,model.continent,model.name,'archive',hm.cycStr,'input');
        fname=[hm.archiveDir model.continent filesep model.name filesep 'archive' filesep hm.cycStr filesep 'input' filesep model.name '.zip'];
        zip(fname,[model.dir 'lastrun' filesep 'input' filesep '*']);
    catch
        WriteErrorLogFile(hm,['Something went wrong with archiving input from ' model.name]);
    end
end

if model.DetermineHazards
    try
        disp('Determining hazards ...');
        tic
        set(hm.textModelLoopStatus,'String',['Status : determining hazards - ' mdl ' ...']);drawnow;
        switch lower(model.type)
            case{'delft3dflow','delft3dflowwave'}
                %                 MakeDir(hm.archiveDir,model.continent,model.name,'archive',hm.cycStr,'hazards');
                %                 cosmos_determineHazardsDelft3D(hm,m);
            case{'xbeach'}
                %                 MakeDir(hm.archiveDir,model.continent,model.name,'archive',hm.cycStr,'hazards');
                %                 determineHazardsXBeach(hm,m);
            case{'ww3'}
                %                 MakeDir(hm.archiveDir,model.continent,model.name,'archive',hm.cycStr,'hazards');
                %                 determineHazardsWW3(hm,m);
            case{'xbeachcluster'}
                MakeDir(hm.archiveDir,model.continent,model.name,'archive',hm.cycStr,'hazards');
                determineHazardsXBeachCluster(hm,m);
        end
    catch
        WriteErrorLogFile(hm,['Something went wrong with determining hazards from ' model.name]);
        %     hm.models(m).status='failed';
        %     return;
    end
    hm.models(m).hazardDuration=toc;
end

if model.runPost
    disp('Making figures ...');
    try
        tic
        set(hm.textModelLoopStatus,'String',['Status : making figures - ' mdl ' ...']);drawnow;
        cosmos_makeModelFigures(hm,m);
    catch
        WriteErrorLogFile(hm,['Something went wrong with making figures for ' model.name]);
        %         hm.models(m).status='failed';
        %         return;
    end
    hm.models(m).plotDuration=toc;
end

if model.DetermineHazards
    try
        disp('Determining hazards ...');
        tic
        set(hm.textModelLoopStatus,'String',['Status : determining hazards - ' mdl ' ...']);drawnow;
        cosmos_determineHazards(hm,m);
    catch
        WriteErrorLogFile(hm,['Something went wrong with determining hazards from ' model.name]);
    end
    hm.models(m).hazardDuration=toc;
end

if model.makeWebsite
    disp('Copying figures to local website ...');
    try
        set(hm.textModelLoopStatus,'String',['Status : copying to local website - ' mdl ' ...']);drawnow;
        cosmos_copyFiguresToLocalWebsite(hm,m);
    catch
        WriteErrorLogFile(hm,['Something went wrong while copying figures to local website of ' model.name]);
        %         hm.models(m).status='failed';
        %         return;
    end
    %%
    disp('Updating xml files on local website ...');
    try
        cosmos_updateModelsXML(hm,m);
        cosmos_updateScenarioXML(hm,m);

    catch
        WriteErrorLogFile(hm,['Something went wrong while updating models.xml on local website for ' hm.models(m).name]);
        %         hm.models(m).status='failed';
        %         return;
    end
end

if model.uploadFTP
    disp('Uploading figures to web server ...');
    try
        tic
        set(hm.textModelLoopStatus,'String',['Status : uploading to SCP server - ' mdl ' ...']);drawnow;
        %        PostFTP(hm,m);
        cosmos_postFigures(hm,m);
        if hm.models(m).forecastplot.plot
            cosmos_postFiguresForecast(hm,m);
        end
    catch
        WriteErrorLogFile(hm,['Something went wrong while upload to SCP server for ' model.name]);
        %         hm.models(m).status='failed';
        %         return;
    end
    hm.models(m).uploadDuration=toc;
    %%
    if ~strcmpi(hm.models(m).status,'failed') && ~isempty(timerfind('Tag', 'ModelLoop'))
        disp('Uploading xml files to web server ...');
        try
            cosmos_postXML(hm,m);
        catch
            WriteErrorLogFile(hm,['Something went wrong while uploading models.xml to website for ' hm.models(m).name]);
            %         hm.models(m).status='failed';
            %         return;
        end
    end
end

%%
if hm.models(m).forecastplot.plot && hm.models(m).forecastplot.archive
    MakeDir(hm.archiveDir,model.continent,model.name,'archive',hm.cycStr,'forecasts');
    cosmos_archiveForecastPlots(hm,m);
end


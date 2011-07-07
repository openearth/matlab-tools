function hm=ProcessData(hm,m)

Model=hm.Models(m);

mdl=Model.Name;

if Model.ExtractData
    try
        disp('Extracting Data ...');
        tic
        set(hm.TextModelLoopStatus,'String',['Status : extracting data - ' mdl ' ...']);drawnow;
        switch lower(Model.Type)
            case{'delft3dflow','delft3dflowwave'}
                MakeDir(hm.ArchiveDir,Model.Continent,Model.Name,'archive',hm.CycStr,'timeseries');
                MakeDir(hm.ArchiveDir,Model.Continent,Model.Name,'archive',hm.CycStr,'maps');
                MakeDir(hm.ArchiveDir,Model.Continent,Model.Name,'archive','appended','timeseries');
                MakeDir(hm.ArchiveDir,Model.Continent,Model.Name,'archive','appended','maps');
                ExtractDataDelft3D(hm,m);
            case{'xbeach'}
                MakeDir(hm.ArchiveDir,Model.Continent,Model.Name,'archive',hm.CycStr,'timeseries');
                MakeDir(hm.ArchiveDir,Model.Continent,Model.Name,'archive',hm.CycStr,'maps');
                MakeDir(hm.ArchiveDir,Model.Continent,Model.Name,'archive','appended','timeseries');
                MakeDir(hm.ArchiveDir,Model.Continent,Model.Name,'archive','appended','maps');
                ExtractDataXBeach(hm,m);
            case{'ww3'}
                MakeDir(hm.ArchiveDir,Model.Continent,Model.Name,'archive',hm.CycStr,'timeseries');
                MakeDir(hm.ArchiveDir,Model.Continent,Model.Name,'archive',hm.CycStr,'maps');
                MakeDir(hm.ArchiveDir,Model.Continent,Model.Name,'archive','appended','timeseries');
                MakeDir(hm.ArchiveDir,Model.Continent,Model.Name,'archive','appended','maps');
                ExtractDataWW3(hm,m);
            case{'xbeachcluster'}
                MakeDir(hm.ArchiveDir,Model.Continent,Model.Name,'archive',hm.CycStr,'netcdf');
                MakeDir(hm.ArchiveDir,Model.Continent,Model.Name,'archive',hm.CycStr,'hazards');
                MakeDir(hm.ArchiveDir,Model.Continent,Model.Name,'archive',hm.CycStr,'timeseries');
                extractDataXBeachCluster(hm,m);
        end
        convertTimeSeriesMat2NC(hm,m);
        copyNCTimeSeriesToOPeNDAP(hm,m)
    catch
        WriteErrorLogFile(hm,['Something went wrong with extracting data from ' Model.Name]);
        %     hm.Models(m).Status='failed';
        %     return;
    end
    hm.Models(m).ExtractDuration=toc;
end

if Model.ArchiveInput
    try
        disp('Archiving input ...');
        MakeDir(hm.ArchiveDir,Model.Continent,Model.Name,'archive',hm.CycStr,'input');
        fname=[hm.ArchiveDir Model.Continent filesep Model.Name filesep 'archive' filesep hm.CycStr filesep 'input' filesep Model.Name '.zip'];
        zip(fname,[Model.Dir 'lastrun' filesep 'input' filesep '*']);
    catch
        WriteErrorLogFile(hm,['Something went wrong with archiving input from ' Model.Name]);
    end
end

if Model.DetermineHazards
    try
        disp('Determining hazards ...');
        tic
        set(hm.TextModelLoopStatus,'String',['Status : determining hazards - ' mdl ' ...']);drawnow;
        switch lower(Model.Type)
            case{'delft3dflow','delft3dflowwave'}
%                 MakeDir(hm.ArchiveDir,Model.Continent,Model.Name,'archive',hm.CycStr,'hazards');
%                 determineHazardsDelft3D(hm,m);
            case{'xbeach'}
%                 MakeDir(hm.ArchiveDir,Model.Continent,Model.Name,'archive',hm.CycStr,'hazards');
%                 determineHazardsXBeach(hm,m);
            case{'ww3'}
%                 MakeDir(hm.ArchiveDir,Model.Continent,Model.Name,'archive',hm.CycStr,'hazards');
%                 determineHazardsWW3(hm,m);
            case{'xbeachcluster'}
                MakeDir(hm.ArchiveDir,Model.Continent,Model.Name,'archive',hm.CycStr,'hazards');
                determineHazardsXBeachCluster(hm,m);
        end
    catch
        WriteErrorLogFile(hm,['Something went wrong with determining hazards from ' Model.Name]);
        %     hm.Models(m).Status='failed';
        %     return;
    end
    hm.Models(m).HazardDuration=toc;
end

if Model.RunPost
    disp('Making figures ...');
    set(hm.TextModelLoopStatus,'String',['Status : making figures - ' mdl ' ...']);drawnow;
    try
        tic
        cosmos_makeModelFigures(hm,m);
    catch
        WriteErrorLogFile(hm,['Something went wrong with making figures for ' Model.Name]);
%         hm.Models(m).Status='failed';
%         return;
    end
    hm.Models(m).PlotDuration=toc;
end

if Model.MakeWebsite
    disp('Copying figures to local website ...');
    set(hm.TextModelLoopStatus,'String',['Status : copying to local website - ' mdl ' ...']);drawnow;
    try
        CopyFiguresToLocalWebsite(hm,m);
    catch
        WriteErrorLogFile(hm,['Something went wrong while copying figures to local website of ' Model.Name]);
%         hm.Models(m).Status='failed';
%         return;
    end
    %%
    disp('Updating models.xml on local website ...');
    try
        UpdateModelsXML(hm,m);
        updateScenariosXML(hm,m);
    catch
        WriteErrorLogFile(hm,['Something went wrong while updating models.xml on local website for ' hm.Models(m).Name]);
%         hm.Models(m).Status='failed';
%         return;
    end
end

if Model.UploadFTP
    set(hm.TextModelLoopStatus,'String',['Status : uploading to SCP server - ' mdl ' ...']);drawnow;
    disp('Uploading local website to SCP server ...');
    try
        tic
        %        PostFTP(hm,m);
        PostSCP(hm,m);
    catch
        WriteErrorLogFile(hm,['Something went wrong while upload to SCP server for ' Model.Name]);
        %         hm.Models(m).Status='failed';
        %         return;
    end
    hm.Models(m).UploadDuration=toc;
    %%
    if ~strcmpi(hm.Models(m).Status,'failed') && ~isempty(timerfind('Tag', 'ModelLoop'))
        disp('Uploading models.xml to website ...');
        try
            PostXML(hm,m);
        catch
            WriteErrorLogFile(hm,['Something went wrong while uploading models.xml to website for ' hm.Models(m).Name]);
            %         hm.Models(m).Status='failed';
            %         return;
        end
    end
end

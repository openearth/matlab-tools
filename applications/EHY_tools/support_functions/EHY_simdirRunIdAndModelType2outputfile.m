function outputfile = EHY_simdirRunIdAndModelType2outputfile(sim_dir,runid,modelType)
% get outputfile from the sim_dir,runid and modelType
switch modelType

    case {'d3dfm','dflow','dflowfm','mdu'}
        %% Delft3D-Flexible Mesh
        mdu=dflowfm_io_mdu('read',[sim_dir filesep runid '.mdu']);
        if isempty(mdu.output.OutputDir)
            outputDir = [ sim_dir filesep 'DFM_OUTPUT_' runid];
        else
            outputDir=strrep(mdu.output.OutputDir,'/','\');
            while strcmp(outputDir(1),filesep) || strcmp(outputDir(1),'.')
                outputDir=outputDir(2:end);
            end
            outputDir = [ sim_dir filesep outputDir];
        end
        hisncfiles         = dir([outputDir filesep '*his*.nc']);
        outputfile          = [outputDir filesep hisncfiles(1).name];
        
    case {'d3d','d3d4','delft3d4','mdf'}
        %% Delft3D 4
        outputfile=[sim_dir filesep 'trih-' runid '.dat'];

    case {'waqua','simona','siminp'}
        %% SIMONA (WAQUA/TRIWAQ)
        outputfile=[sim_dir filesep 'SDS-' runid];
        
    case {'sobek3'}
        %% SOBEK3
        sobekFile=dir([ sim_dir filesep runid '.dsproj_data\Water level (op)*.nc*']);
        outputfile=[sim_dir filesep runid '.dsproj_data' filesep sobekFile.name];
        
    case {'sobek3_new'}
        %% SOBEK3 new
        outputfile=[ sim_dir filesep runid '.dsproj_data\Integrated_Model_output\dflow1d\output\observations.nc'];
        
    case {'implic'}
        %% IMPLIC
        if exist([sim_dir filesep 'implic.mat'],'file')
            load([sim_dir filesep 'implic.mat']);
        else
            D         = dir2(sim_dir,'file_incl','\.dat$');
            files     = find(~[D.isdir]);
            filenames = {D(files).name};
            for i_stat = 1: length(filenames)
                [~,name,~] = fileparts(filenames{i_stat});
                stationNames{i_stat} = name;
            end
        end
end
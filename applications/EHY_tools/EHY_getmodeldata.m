function Data = EHY_getmodeldata(sim_dir,runid,stat_name,modelType,varargin)

% Extracts time series (of water levels), from SDS file, Sobek3 file, implic output etc.
% Input Arguments:
% sim_dir   : Directory with simulation results
% runid     : runid of thew simulation
% stat_name : station names can be either:
%             []       all stations
%             'name'   single string with station name
%             {'name'} cell array of strings
%  modelType : 'implic', 'sobek3', 'waqua' etc
%
%  Data.stationNames   : list of ALL stations available on history file
%  Data.times          : (matlab) times belonging with the series
%  Data.val (:,no_stat): water level values for the requested stations

OPT.varName = 'wl';
OPT.t0 = '';
OPT.tend = '';
OPT.layer = 0; % all

OPT         = setproperty(OPT,varargin);
if ~isempty(OPT.t0); OPT.t0=datenum(OPT.t0); end
if ~isempty(OPT.tend); OPT.tend=datenum(OPT.tend); end

%% no stat_name specified, all stations, otherwise, stat_name is a string or a cell array of strings
if ~isempty(stat_name)
    if ~iscell(stat_name)
        stat_name = {stat_name};
    end
end

%% Get station names
%% Sobek3
if strcmpi(modelType,'sobek3')
    
    sobekFile=dir([ sim_dir filesep runid '.dsproj_data\Water level (op)*.nc*']);
    D=read_sobeknc([sim_dir filesep runid '.dsproj_data' filesep sobekFile.name]);
    
    Data.stationNames=strtrim(D.feature_name_points.Val);
elseif strcmpi(modelType,'sobek3_new')
        sobekFile=[ sim_dir filesep runid '.dsproj_data\Integrated_Model_output\dflow1d\output\observations.nc'];
        D=read_sobeknc(sobekFile);
        
         Data.stationNames=strtrim(D.observation_Id.Val);

%% Dflow-FM
elseif strncmpi(modelType,'dflow',4)
    mdu=dflowfm_io_mdu('read',[sim_dir filesep runid '.mdu']);
    if isempty(mdu.output.OutputDir)
      files              = dir([ sim_dir filesep 'DFM_OUTPUT_' runid filesep '*his.nc*']);
    else
      outputDir=strrep(mdu.output.OutputDir,'/','\');
        while strcmp(outputDir(1),filesep) || strcmp(outputDir(1),'.')
          outputDir=outputDir(2:end);
        end
      files              = dir([ sim_dir filesep outputDir filesep runid '*his.nc*']);
    end
    dfm                = qpfopen([files.folder filesep files.name]);
    Data.stationNames  = strtrim(qpread(dfm,1,'water level (points)','stations'));
    
%% Waqua
elseif strcmpi(modelType,'waqua')
    sds= qpfopen([sim_dir filesep 'SDS-' runid]);

    Data.stationNames  = strtrim(qpread(sds,1,'water level (station)','stations'));

%% Implic
elseif strcmpi(modelType,'implic')
    if exist([sim_dir filesep 'implic.mat'],'file')
        load([sim_dir filesep 'implic.mat']);
    else
        D         = dir2(sim_dir,'file_incl','\.dat$');
        files     = find(~[D.isdir]);
        filenames = {D(files).name};
        for i_stat = 1: length(filenames)
            [~,name,~] = fileparts(filenames{i_stat});
            Data.stationNames{i_stat} = name;
        end
    end
end

%% No station name specified, all stations
if isempty(stat_name)
    stat_name = Data.stationNames;
end
Data.requestedStatNames=stat_name';

%% Get the computational data
for i_stat = 1: length(stat_name)
    switch OPT.varName
        case 'wl'

            %% Waterlevels, times and values for station nr nr_stat
            nr_stat  = find(strcmp(Data.stationNames,stat_name{i_stat}) ~= 0,1);
            if ~isempty(nr_stat)
                Data.exist_stat(i_stat) = true;
                %% Read Sobek3 data
                if strcmpi(modelType,'sobek3')
                    Data.times                 =D.water_level_points.Time;
                    Data.val(:,i_stat)         =D.water_level_points.Val(:,nr_stat);
                elseif strcmpi(modelType,'sobek3_new')
                    Data.times                 =D.Observedwaterlevel.Time;
                    Data.val(:,i_stat)         =D.Observedwaterlevel.Val(:,nr_stat);
                    %% Read Dflow-FM data
                elseif strncmpi(modelType,'dflow',4)
                    tmp                = qpread(dfm,1,'water level (points)','data',0,nr_stat);
                    Data.times         = tmp.Time;
                    Data.val(:,i_stat) = tmp.Val;
                    %% Read Waqua data
                elseif strcmpi(modelType,'waqua')
                    Data.times         = qpread(sds,1,'water level (station)','times');
                    Data.val(:,i_stat) = waquaio(sds,[],'wlstat',0,nr_stat);
                    %% Read Implic data (write to mat file for future fast pssing
                elseif strcmpi(modelType,'implic')
                    if ~exist([sim_dir filesep 'implic.mat'],'file')
                        months = {'jan' 'feb' 'mrt' 'apr' 'mei' 'jun' 'jul' 'aug' 'sep' 'okt' 'nov' 'dec'};
                        for ii_stat = 1: length(filenames)
                            fid   = fopen([sim_dir filesep filenames{i_stat}],'r');
                            line  = fgetl(fid);
                            line  = fgetl(fid);
                            line  = fgetl(fid);
                            i_time = 0;
                            while ~feof(fid)
                                i_time  = i_time + 1;
                                line    = fgetl(fid);
                                i_day   = str2num(line(1:2));
                                i_month = find(~cellfun(@isempty,strfind(months,line(4:6))));
                                i_year  = str2num(line( 8:11));
                                i_hour  = str2num(line(13:14));
                                i_min   = str2num(line(16:17));
                                r_val   = str2num(line(18:end))/100.;
                                Data.times(i_time) = datenum(i_year,i_month,i_day,i_hour,i_min,0);
                                Data.val_tmp(i_time,ii_stat)  = r_val;
                            end
                            fclose(fid);
                        end
                        save([sim_dir filesep 'implic.mat'],'Data');
                    end
                    Data.val(:,i_stat) = Data.val_tmp(:,nr_stat);
                end
            else
                Data.exist_stat(i_stat) = false;
                display (['Station : ' stat_name{i_stat} ' does not exist']); 
            end
                        
        case 'uv'
            %% Velocities, times and values for station nr nr_stat
            nr_stat  = find(strcmp(Data.stationNames,stat_name{i_stat}) ~= 0,1);
            if ~isempty(nr_stat)
                %% Read Waqua data
                if strcmpi(modelType,'waqua')
                    Data.times         = qpread(sds,1,'water level (station)','times');
                    [Data,time_index]=EHY_getmodeldata_time_index(Data,OPT);
                    Data.u(i_stat,:,:) = waquaio(sds,[],'u-stat',time_index,nr_stat,OPT.layer);
                    Data.v(i_stat,:,:) = waquaio(sds,[],'v-stat',time_index,nr_stat,OPT.layer);
                    Data.uv_dim='station,time,layer';
                end
            end
        case 'sal'
            %% Salinity, times and values for station nr nr_stat
            nr_stat  = find(strcmp(Data.stationNames,stat_name{i_stat}) ~= 0,1);
            if ~isempty(nr_stat)
                %% Read Waqua data
                if strcmpi(modelType,'waqua')
                    Data.times         = qpread(sds,1,'water level (station)','times');
                    [Data,time_index]=EHY_getmodeldata_time_index(Data,OPT);
                    Data.val(i_stat,:,:) = waquaio(sds,[],'stsubst:            salinity',time_index,nr_stat,OPT.layer);
                    Data.val_dim='station,time,layer';
                end
            end
    end
end
end

function [Data, time_index]=EHY_getmodeldata_time_index(Data,OPT)
if ~isempty('OPT.t0') && ~isempty('OPT.tend')
    time_index=find((Data.times>=OPT.t0) & (Data.times<=OPT.tend));
    if ~isempty(time_index)
        Data.times=Data.times(time_index);
    else
        time_index=0;
    end
else
    time_index=0;
end

end

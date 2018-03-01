function varargout = EHY_getmodeldata(sim_dir,runid,stat_name,modelType,varargin)
% Extracts time series (of water levels/velocities/salinity/temperature) from output of different models
%
% Running 'EHY_getmodeldata' without any arguments opens a interactive version, that also gives 
% feedback on how to use the EHY_getmodeldata-function with input arguments.
%
% Input Arguments:
% sim_dir   : Directory with simulation results
% runid     : runid of the simulation
% stat_name : station names can be either:
%             []       all stations
%             'name'   single string with station name
%             {'name'} cell array of strings
% modelType : 'dflowfm','delft3d4,'waqua','sobek3','implic'
%
% Optional input arguments:
% varName   : Name of variable, choose from: 'wl','uv','sal',tem'
% t0        : Start time of dataset (e.g. '01-Jan-2018' or 737061 (Matlab date) )
% tend      : End time of dataset (e.g. '01-Feb-2018' or 737092 (Matlab date) )
% layer     : Model layer, e.g. 0 (all layers), [2] or [4:8]
%
% Output:
% Data.stationNames       : list of ALL stations available on history file
% Data.requestedStatNames : list of requested stations
% Data.exist_stat         : logical if requested station exist in file
% Data.times              : (matlab) times belonging with the series
% Data.val/vel_*          : requested data, velocity in (u,v- and )x,y-direction
% Data.dimensions         : Dimensions of requested data (time,stats,lyrs)
% Data.OPT                : Structure with optional user settings used

if ~prod([exist('sim_dir','var') exist('runid','var') exist('stat_name','var') exist('modelType','var')])
    EHY_getmodeldata_interactive
    return
end

OPT.varName = 'wl';
OPT.t0 = '';
OPT.tend = '';
OPT.layer = 0; % all

OPT         = setproperty(OPT,varargin);

%% modify input
if ~isempty(OPT.t0); OPT.t0=datenum(OPT.t0); end
if ~isempty(OPT.tend); OPT.tend=datenum(OPT.tend); end
if ~isnumeric(OPT.layer); OPT.layer=str2num(OPT.layer); end
% no stat_name specified, all stations, otherwise, stat_name is a string or a cell array of strings
if ~isempty(stat_name)
    if ~iscell(stat_name)
        stat_name = {stat_name};
    end
end

%% Get station names
Data.stationNames = EHY_getStationNames(sim_dir,runid,modelType);

% No station name specified, get data from all stations
if isempty(stat_name)
    stat_name = Data.stationNames;
end
if size(stat_name,1)<size(stat_name,2); stat_name=stat_name'; end
Data.requestedStatNames=stat_name;

%% Get the computational data
for i_stat = 1: length(stat_name)
    disp(['EHY_getmodeldata progress - working on station: ' num2str(i_stat) '/' num2str(length(stat_name))])
    nr_stat  = find(strcmp(Data.stationNames,stat_name{i_stat}) ~= 0,1);
    if isempty(nr_stat)
        Data.exist_stat(i_stat,1) = false;
        disp(['Station : ' stat_name{i_stat} ' does not exist']);
    else
        Data.exist_stat(i_stat,1) = true;
        switch modelType
            
            case {'d3dfm','dflow','dflowfm','mdu'}
                %% Delft3D-Flexible Mesh
                % open data file
                if ~exist('mdu','var')
                    mdu=dflowfm_io_mdu('read',[sim_dir filesep runid '.mdu']);
                    if isempty(mdu.output.OutputDir)
                        outputDir = [ sim_dir filesep 'DFM_OUTPUT_' runid];
                    else
                        outputDir=strrep(mdu.output.OutputDir,'/','\');
                        while strcmp(outputDir(1),filesep) || strcmp(outputDir(1),'.')
                            outputDir=outputDir(2:end);
                        end
                        outputDir = [sim_dir filesep outputDir];
                    end
                    hisncfiles         = dir([outputDir filesep '*his*.nc']);
                    hisncfile          = [outputDir filesep hisncfiles(1).name];
                    infonc             = ncinfo(hisncfile);
                    indNC              = strmatch('laydim',{infonc.Dimensions.Name},'exact');
                    if ~isempty(indNC)
                        no_layers          = infonc.Dimensions(indNC).Length;
                        if prod(OPT.layer==0) %layer not specified
                            layerNCstart=0;
                            layerNClength=no_layers;
                        else
                            layerNCstart=OPT.layer(1)-1;
                            layerNClength=length(OPT.layer);
                        end
                    end
                    Data.times = nc_varget(hisncfile,'time')*timeFactor('S','D');
                    refdate = datenum(num2str(mdu.time.RefDate),'yyyymmdd');
                    Data.times = Data.times+refdate;
                    [Data,time_index]=EHY_getmodeldata_time_index(Data,OPT);
                    if prod(time_index==0) %times not specified
                        timeNCstart=0;
                        timeNClength=length(Data.times);
                    else
                        timeNCstart=time_index(1)-1;
                        timeNClength=length(time_index);
                    end
                end
                % get data
                switch OPT.varName
                    case 'wl'
                        Data.val(:,i_stat) = nc_varget(hisncfile,'waterlevel',[timeNCstart nr_stat-1],[timeNClength 1]);
                    case 'uv'
                        if ~exist('no_layers','var') % 2DH model
                            Data.vel_x(:,i_stat) = nc_varget(hisncfile,'x_velocity',[timeNCstart nr_stat-1],[timeNClength 1]);
                            Data.vel_y(:,i_stat) = nc_varget(hisncfile,'y_velocity',[timeNCstart nr_stat-1],[timeNClength 1]);
                        else % all layers or specified layer(s)
                            Data.vel_x(:,i_stat,:) = nc_varget(hisncfile,'x_velocity',[timeNCstart nr_stat-1 layerNCstart],[timeNClength 1 layerNClength]);
                            Data.vel_y(:,i_stat,:) = nc_varget(hisncfile,'y_velocity',[timeNCstart nr_stat-1 layerNCstart],[timeNClength 1 layerNClength]);
                        end
                    case 'sal'
                        if ~exist('no_layers','var') % 2DH model
                            Data.val(:,i_stat) = nc_varget(hisncfile,'salinity',[timeNCstart nr_stat-1],[timeNClength 1]);
                        else % all layers or specified layer(s)
                            Data.val(:,i_stat) = nc_varget(hisncfile,'salinity',[timeNCstart nr_stat-1 layerNCstart],[timeNClength 1 layerNClength]);
                        end
                    case 'tem'
                        if ~exist('no_layers','var') % 2DH model
                            Data.val(:,i_stat) = nc_varget(hisncfile,'temperature',[timeNCstart nr_stat-1],[timeNClength 1]);
                        else % all layers or specified layer(s)
                            Data.val(:,i_stat) = nc_varget(hisncfile,'temperature',[timeNCstart nr_stat-1 layerNCstart],[timeNClength 1 layerNClength]);
                        end
                end
                
            case {'d3d','d3d4','delft3d4','mdf'}
                %% Delft3D 4
                % open data file
                if ~exist('trih','var')
                    trihFile=[sim_dir filesep 'trih-' runid '.dat'];
                    trih=vs_use(trihFile,'quiet');
                    Data.times=qpread(trih,'water level','times');
                    [Data,time_index]=EHY_getmodeldata_time_index(Data,OPT);
                    no_layers=vs_get(trih,'his-const',{1},'KMAX','quiet');
                    constituents=squeeze(vs_get(trih,'his-const','NAMCON','quiet'));
                    if size(constituents,1)>size(constituents,2); constituents=constituents'; end
                    constituents=cellstr(constituents);
                end
                % get data
                switch OPT.varName
                    case 'wl'
                        Data.val(:,i_stat)=cell2mat(vs_get(trih,'his-series',{time_index},'ZWL',{nr_stat},'quiet'));
                    case 'uv'
                        if no_layers==1
                            data=qpread(trih,1,'depth averaged velocity','griddata',time_index,nr_stat);
                            Data.vel_x(:,i_stat) = data.XComp;
                            Data.vel_y(:,i_stat) = data.YComp;
                            Data.vel_u(:,i_stat) = vs_get(trih,'his-series',{time_index},'ZCURU',{nr_stat,1},'quiet');
                            Data.vel_v(:,i_stat) = vs_get(trih,'his-series',{time_index},'ZCURV',{nr_stat,1},'quiet');
                        else
                            data=qpread(trih,1,'horizontal velocity','griddata',time_index,nr_stat,OPT.layer);
                            Data.vel_x(:,i_stat,:) = squeeze(data.XComp);
                            Data.vel_y(:,i_stat,:) = squeeze(data.YComp);
                            Data.vel_u(:,i_stat,:) = vs_get(trih,'his-series',{time_index},'ZCURU',{nr_stat,OPT.layer},'quiet');
                            Data.vel_v(:,i_stat,:) = vs_get(trih,'his-series',{time_index},'ZCURV',{nr_stat,OPT.layer},'quiet');
                        end
                    case 'sal'
                        nr_cons=find(strcmpi(constituents,'salinity') ~= 0,1);
                        Data.val(:,i_stat,:) = vs_get(trih,'his-series',{time_index},'GRO',{nr_stat,OPT.layer,nr_cons},'quiet');
                    case 'tem'
                        nr_cons=find(strcmpi(constituents,'temperature') ~= 0,1);
                        Data.val(:,i_stat,:) = vs_get(trih,'his-series',{time_index},'GRO',{nr_stat,OPT.layer,nr_cons},'quiet');
                end
                
            case {'waqua','simona','siminp'}
                %% SIMONA (WAQUA/TRIWAQ)
                % open data file
                if ~exist('sds','var')
                    sds=qpfopen([sim_dir filesep 'SDS-' runid]);
                    Data.times = qpread(sds,1,'water level (station)','times');
                    [Data,time_index]=EHY_getmodeldata_time_index(Data,OPT);
                end
                % get data
                switch OPT.varName
                    case 'wl'
                        Data.val(:,i_stat) = waquaio(sds,[],'wlstat',time_index,nr_stat);
                    case 'uv'
                        try
                            Data.vel_x(:,i_stat,:) = waquaio(sds,[],'u-stat',time_index,nr_stat,OPT.layer);
                            Data.vel_y(:,i_stat,:) = waquaio(sds,[],'v-stat',time_index,nr_stat,OPT.layer);
                        catch
                            Data.vel_x(:,i_stat) = waquaio(sds,[],'u-stat',time_index,nr_stat);
                            Data.vel_y(:,i_stat) = waquaio(sds,[],'v-stat',time_index,nr_stat);
                        end
                    case 'sal'
                        try
                            Data.val(:,i_stat,:) = waquaio(sds,[],'stsubst:            salinity',time_index,nr_stat,OPT.layer);
                        catch
                            Data.val(:,i_stat) = waquaio(sds,[],'stsubst:            salinity',time_index,nr_stat);
                        end
                end
                
            case {'sobek3'}
                %% SOBEK3
                % open data file
                if ~exist('D','var')
                    sobekFile=dir([ sim_dir filesep runid '.dsproj_data\Water level (op)*.nc*']);
                    D=read_sobeknc([sim_dir filesep runid '.dsproj_data' filesep sobekFile.name]);
                    Data.times                 =D.water_level_points.Time;
                end
                % get data
                switch OPT.varName
                    case 'wl'
                        Data.val(:,i_stat)         =D.water_level_points.Val(:,nr_stat);
                end
                
            case {'sobek3_new'}
                %% SOBEK3 new
                % open data file
                if ~exist('D','var')
                    sobekFile=[ sim_dir filesep runid '.dsproj_data\Integrated_Model_output\dflow1d\output\observations.nc'];
                    D=read_sobeknc(sobekFile);
                    Data.times                 =D.Observedwaterlevel.Time;
                end
                % get data
                switch OPT.varName
                    case 'wl'
                        Data.val(:,i_stat)         =D.Observedwaterlevel.Val(:,nr_stat);
                end
                
            case {'implic'}
                %% IMPLIC
                % get data
                switch OPT.varName
                    case 'wl'
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
        end
    end
end

% dimension information
fn=fieldnames(Data);
if length(size(Data.(fn{end})))==2
    Data.dimensions='[times,stations]';
elseif length(size(Data.(fn{end})))==3
    Data.dimensions='[times,stations,layers]';
end

Data.OPT=OPT;

if nargout==1
    varargout{1}=Data;
end
EHYs(mfilename);
end

function [Data, time_index]=EHY_getmodeldata_time_index(Data,OPT)
if ~isempty(OPT.t0) && ~isempty(OPT.tend)
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

function varargout = EHY_getmodeldata(outputfile,stat_name,modelType,varargin)
% Extracts time series (of water levels/velocities/salinity/temperature) from output of different models
%
% Running 'EHY_getmodeldata' without any arguments opens a interactive version, that also gives
% feedback on how to use the EHY_getmodeldata-function with input arguments.
%
% Input Arguments:
% outputfile: Output file with simulation results
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
% layer     : Model layer, e.g. '0' (all layers), [2] or [4:8]
%
% Output:
% Data.stationNames       : list of ALL stations available on history file
% Data.requestedStatNames : list of requested stations
% Data.exist_stat         : logical if requested station exist in file
% Data.times              : (matlab) times belonging with the series
% Data.val/vel_*          : requested data, velocity in (u,v- and )x,y-direction
% Data.dimensions         : Dimensions of requested data (time,stats,lyrs)
% Data.location           : Locations of requested stations (x,y or lon,lat)
% Data.OPT                : Structure with optional user settings used

if ~prod([exist('outputfile','var') exist('stat_name','var') exist('modelType','var')])
    EHY_getmodeldata_interactive
    return
end

OPT.varName = 'wl';
OPT.t0 = '';
OPT.tend = '';
OPT.layer = 0; % all

% backward compatible - EHY_getmodeldata(sim_dir,runid,stat_name,modelType,varargin)
if isdir(outputfile)
    outputfile=EHY_simdirRunIdAndModelType2outputfile(outputfile,stat_name,varargin{1});
    varargout={EHY_getmodeldata(outputfile,modelType,varargin{1},varargin{2:end})};
    return
end

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
Data.stationNames = EHY_getStationNames(outputfile,modelType);

% No station name specified, get data from all stations
if isempty(stat_name)
    stat_name = Data.stationNames;
end
if size(stat_name,1)<size(stat_name,2); stat_name=stat_name'; end
Data.requestedStatNames=stat_name;

stationNr=[];
for i_stat = 1:length(stat_name)
    nr_stat  = find(strcmp(Data.stationNames,stat_name{i_stat}) ~= 0,1);
    if isempty(nr_stat)
        Data.exist_stat(i_stat,1) = false;
        disp(['Station : ' stat_name{i_stat} ' does not exist']);
    else
        stationNr(end+1)=nr_stat;
        Data.exist_stat(i_stat,1) = true;
    end
end

%% Get the computational data
switch modelType
    
    case {'d3dfm','dflow','dflowfm','mdu','dfm'}
        %% Delft3D-Flexible Mesh
        % open data file
        if ~exist('infonc','var')
            infonc             = ncinfo(outputfile);
            
            % layer info
            ncVarInd              = strmatch('laydim',{infonc.Dimensions.Name},'exact');
            if ~isempty(ncVarInd)
                no_layers          = infonc.Dimensions(ncVarInd).Length;
                if all(OPT.layer==0)
                    OPT.layer=1:no_layers;
                end
            end
            
            % time info
            % - to enhance speed, reconstruct time array from start time, numel and interval
            ncVarInd     = strmatch('time',{infonc.Variables.Name},'exact');
            nr_times     = infonc.Variables(ncVarInd).Size;
            seconds_int = ncread(outputfile, 'time', 1, 2);
            interval    = seconds_int(2) - seconds_int(1);
            seconds     = seconds_int(1) + interval * [0:nr_times-1]';
            days        = seconds / (24*60*60);
            attri       = infonc.Variables(ncVarInd).Attributes(1).Value;
            itdate      = attri(15:end);
            Data.times  = datenum(itdate, 'yyyy-mm-dd HH:MM:SS')+days;
            [Data,time_index,select]=EHY_getmodeldata_time_index(Data,OPT);
            nr_times_clip = length(Data.times);
            
            % station info
            stationX = ncread(outputfile,'station_x_coordinate',[1 1],[Inf 1]);
            stationY = ncread(outputfile,'station_y_coordinate',[1 1],[Inf 1]);
            
            Data.location(Data.exist_stat,:)=[stationX(find(Data.exist_stat)) stationY(find(Data.exist_stat))];
            Data.location(~Data.exist_stat,1:2)=NaN;
        end
        
        % get data
        % - To enhance speed, read in blocks if numel is too big
        % - It is faster to read all stations and only keep the data of the
        %   wanted stations than looping over the wanted stations.
        
        filesize    = dir(outputfile);
        filesize    = filesize.bytes /(1024^3); %converted to Gb
        maxblocksize= 0.5; %Gb
        nr_blocks   = ceil((nr_times_clip / nr_times) * (filesize / maxblocksize));
        bl_length   = ceil(nr_times_clip / nr_blocks);
        offset      = find(select, 1) - 1;
        
        % allocate variable 'value'
        if ismember(OPT.varName,{'wl'})
            value = zeros(nr_times_clip,length(Data.stationNames));
        elseif ismember(OPT.varName,'uv')
            if ~exist('no_layers','var')
                value_x = zeros(nr_times_clip,length(Data.stationNames));
                value_y = zeros(nr_times_clip,length(Data.stationNames));
            else
                value_x = zeros(nr_times_clip,length(Data.stationNames),no_layers);
                value_y = zeros(nr_times_clip,length(Data.stationNames),no_layers);
            end
        elseif ismember(OPT.varName,{'sal','tem'})
            if ~exist('no_layers','var')
                value = zeros(nr_times_clip,length(Data.stationNames));
            else
                value = zeros(nr_times_clip,length(Data.stationNames),no_layers);
            end
        end
        
        for i = 1:nr_blocks % time blocks
            bl_start    = 1 + (i-1) * bl_length;
            bl_stop     = min(i * bl_length, nr_times_clip);
            bl_int      = bl_stop-bl_start+1;
            switch OPT.varName
                case 'wl'
                    value(bl_start:bl_stop,:) 	= ncread(outputfile,'waterlevel',[1 bl_start+offset],[Inf bl_int])';
                case 'uv'
                    if ~exist('no_layers','var') % 2DH model
                        value_x(bl_start:bl_stop,:) 	= permute(ncread(outputfile,'x_velocity',[1 bl_start+offset],[Inf bl_int]),[2 1]);
                        value_y(bl_start:bl_stop,:) 	= permute(ncread(outputfile,'y_velocity',[1 bl_start+offset],[Inf bl_int]),[2 1]);
                    else
                        value_x(bl_start:bl_stop,:,:) 	= permute(ncread(outputfile,'x_velocity',[1 1 bl_start+offset],[Inf Inf bl_int]),[3 2 1]);
                        value_y(bl_start:bl_stop,:,:) 	= permute(ncread(outputfile,'y_velocity',[1 1 bl_start+offset],[Inf Inf bl_int]),[3 2 1]);
                    end
                case 'sal'
                    if ~exist('no_layers','var') % 2DH model
                        value(bl_start:bl_stop,:) 	= permute(ncread(outputfile,'salinity',[1 bl_start+offset],[Inf bl_int]),[2 1]);
                    else
                        value(bl_start:bl_stop,:,:) 	= permute(ncread(outputfile,'salinity',[1 1 bl_start+offset],[Inf Inf bl_int]),[3 2 1]);
                    end
                case 'tem'
                    if ~exist('no_layers','var') % 2DH model
                        value(bl_start:bl_stop,:) 	= permute(ncread(outputfile,'temperature',[1 bl_start+offset],[Inf bl_int]),[2 1]);
                    else
                        value(bl_start:bl_stop,:,:) 	= permute(ncread(outputfile,'temperature',[1 1 bl_start+offset],[Inf Inf bl_int]),[3 2 1]);
                    end
            end
        end
        
        % put value(_x/_y) in output structure 'Data'
        if exist('value','var')
            if ndims(value)==2
                Data.val(:,find(Data.exist_stat))=value(:,stationNr);
            elseif dim(value)==3
                Data.val(:,find(Data.exist_stat),1:length(OPT.layer))=value(:,stationNr,OPT.layer);
            end
        elseif exist('value_x','var')
            if ndims(value_x)==2
                Data.vel_x(:,find(Data.exist_stat))=value_x(:,stationNr);
                Data.vel_y(:,find(Data.exist_stat))=value_y(:,stationNr);
            elseif ndims(value_x)==3
                Data.vel_x(:,find(Data.exist_stat),1:length(OPT.layer))=value_x(:,stationNr,OPT.layer);
                Data.vel_y(:,find(Data.exist_stat),1:length(OPT.layer))=value_y(:,stationNr,OPT.layer);
            end
        end
        
    case {'d3d','d3d4','delft3d4','mdf'}
        %% Delft3D 4
        for i_stat = 1: length(stat_name)
            if Data.exist_stat(i_stat)
                nr_stat  = find(strcmp(Data.stationNames,stat_name{i_stat}) ~= 0,1);
                
                % open data file
                if ~exist('trih','var')
                    trih=vs_use(outputfile,'quiet');
                    Data.times=qpread(trih,'water level','times');
                    [Data,time_index]=EHY_getmodeldata_time_index(Data,OPT);
                    % layer info
                    no_layers=vs_get(trih,'his-const',{1},'KMAX','quiet');
                    if all(OPT.layer==0)
                        OPT.layer=1:no_layers;
                    elseif no_layers==1 && length(OPT.layer)>1
                        disp('User selected multiple layers, but there is only 1 layer available. Setting OPT.layer=1; ')
                        OPT.layer=1;
                    end
                    % constituents
                    constituents=squeeze(vs_get(trih,'his-const','NAMCON','quiet'));
                    if size(constituents,1)>size(constituents,2); constituents=constituents'; end
                    constituents=cellstr(constituents);
                    % station info
                    stationMN = vs_get(trih,'his-const',{1},'MNSTAT','quiet');
                    stationXY = vs_get(trih,'his-const',{1},'XYSTAT','quiet');
                end
                Data.locationMN(i_stat,:)=[stationMN(:,nr_stat)'];
                Data.location(i_stat,:)=[stationXY(:,nr_stat)'];

                % get data
                switch OPT.varName
                    case 'wl'
                        Data.val(:,i_stat)=cell2mat(vs_get(trih,'his-series',{time_index},'ZWL',{nr_stat},'quiet'));
                    case 'uv'
                        if no_layers==1
                            data=qpread(trih,1,'depth averaged velocity','griddata',time_index,nr_stat);
                            Data.vel_x(:,i_stat) = data.XComp;
                            Data.vel_y(:,i_stat) = data.YComp;
                            Data.vel_u(:,i_stat) = cell2mat(vs_get(trih,'his-series',{time_index},'ZCURU',{nr_stat,1},'quiet'));
                            Data.vel_v(:,i_stat) = cell2mat(vs_get(trih,'his-series',{time_index},'ZCURV',{nr_stat,1},'quiet'));
                        else
                            data=qpread(trih,1,'horizontal velocity','griddata',time_index,nr_stat,0);
                            Data.vel_x(:,i_stat,:) = squeeze(data.XComp(:,1,OPT.layer));
                            Data.vel_y(:,i_stat,:) = squeeze(data.YComp(:,1,OPT.layer));
                            Data.vel_u(:,i_stat,:) = cell2mat(vs_get(trih,'his-series',{time_index},'ZCURU',{nr_stat,OPT.layer},'quiet'));
                            Data.vel_v(:,i_stat,:) = cell2mat(vs_get(trih,'his-series',{time_index},'ZCURV',{nr_stat,OPT.layer},'quiet'));
                        end
                    case 'sal'
                        nr_cons=find(strcmpi(constituents,'salinity') ~= 0,1);
                        Data.val(:,i_stat,:) = cell2mat(vs_get(trih,'his-series',{time_index},'GRO',{nr_stat,OPT.layer,nr_cons},'quiet'));
                    case 'tem'
                        nr_cons=find(strcmpi(constituents,'temperature') ~= 0,1);
                        Data.val(:,i_stat,:) = cell2mat(vs_get(trih,'his-series',{time_index},'GRO',{nr_stat,OPT.layer,nr_cons},'quiet'));
                end
            end
        end
    case {'waqua','simona','siminp'}
        %% SIMONA (WAQUA/TRIWAQ)
        for i_stat = 1: length(stat_name)
            if Data.exist_stat(i_stat)
                nr_stat  = find(strcmp(Data.stationNames,stat_name{i_stat}) ~= 0,1);
                % open data file
                if ~exist('sds','var')
                    sds=qpfopen(outputfile);
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
            end
        end
        
    case {'sobek3'}
        %% SOBEK3
        for i_stat = 1: length(stat_name)
            if Data.exist_stat(i_stat)
                nr_stat  = find(strcmp(Data.stationNames,stat_name{i_stat}) ~= 0,1);
                % open data file
                if ~exist('D','var')
                    D=read_sobeknc(outputfile);
                    Data.times=D.water_level_points.Time;
                end
                % get data
                switch OPT.varName
                    case 'wl'
                        Data.val(:,i_stat)         =D.water_level_points.Val(:,nr_stat);
                end
            end
        end
        
    case {'sobek3_new'}
        %% SOBEK3 new
        for i_stat = 1: length(stat_name)
            if Data.exist_stat(i_stat)
                nr_stat  = find(strcmp(Data.stationNames,stat_name{i_stat}) ~= 0,1);
                % open data file
                if ~exist('D','var')
                    D=read_sobeknc(outputfile);
                    Data.times                 =D.Observedwaterlevel.Time;
                end
                % get data
                switch OPT.varName
                    case 'wl'
                        Data.val(:,i_stat)         =D.Observedwaterlevel.Val(:,nr_stat);
                end
            end
        end
        
    case {'implic'}
        %% IMPLIC
        for i_stat = 1: length(stat_name)
            if Data.exist_stat(i_stat)
                nr_stat  = find(strcmp(Data.stationNames,stat_name{i_stat}) ~= 0,1);
                % get data
                switch OPT.varName
                    case 'wl'
                        if ~exist([fileparts(outputfile) filesep 'implic.mat'],'file')
                            months = {'jan' 'feb' 'mrt' 'apr' 'mei' 'jun' 'jul' 'aug' 'sep' 'okt' 'nov' 'dec'};
                            for ii_stat = 1: length(filenames)
                                fid   = fopen([fileparts(outputfile) filesep filenames{i_stat}],'r');
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
                            save([fileparts(outputfile) filesep 'implic.mat'],'Data');
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

function [Data,time_index,select]=EHY_getmodeldata_time_index(Data,OPT)
if ~isempty(OPT.t0) && ~isempty(OPT.tend)
    select=(Data.times>=OPT.t0) & (Data.times<=OPT.tend);
    time_index=find(select);
    if ~isempty(time_index)
        Data.times=Data.times(time_index);
    else
        select=true(length(Data.times),1);
        time_index=0;
    end
else
    select=true(length(Data.times),1);
    time_index=0;
end

end

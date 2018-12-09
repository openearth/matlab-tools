function varargout = EHY_getmodeldata(inputFile,stat_name,modelType,varargin)
% Extracts time series (of water levels/velocities/salinity/temperature) from output of different models
%
% Running 'EHY_getmodeldata' without any arguments opens a interactive version, that also gives
% feedback on how to use the EHY_getmodeldata-function with input arguments.
%
% Input Arguments:
% inputFile : file with simulation results
% stat_name : station names can be either:
%             []       all stations
%             'name'   single string with station name
%             {'name'} cell array of strings
% modelType : 'dflowfm','delft3d4,'waqua','sobek3','implic'
%
% Optional input arguments:
% varName   : Name of variable, choose from: 'wl','wd','uv','sal',tem'
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
% Data.location(XY)       : (time-varying) locations of requested stations (x,y or lon,lat)
% Data.OPT                : Structure with optional user settings used
%
% Example1: EHY_getmodeldata % interactive
% Example2: Data = EHY_getmodeldata('D:\trih-r01.dat',[],'d3d') % load water level (default), all stations, all times
% Example3: Data = EHY_getmodeldata('D:\trih-r01.dat',[],'d3d','varName','uv') % load velocities, all stations, all times
% Example4: Data = EHY_getmodeldata('D:\trih-r01.dat',[],'d3d','varName','uv','layer',5) % load velocities, all stations, all times, layer 5
% Example5: Data = EHY_getmodeldata('D:\r01_his.nc',{'station1','station2'},'dfm','t0','01-Jan-2000','tend','01-Feb-2000') % load two stations, one month
%
% Added 08122018 (TK)
% Extraction of profile data from a history file resulting from a DFlowFM or a Delft3D-Flow simulation
% Required additional input argument (as <keyword,value> pair:
% typData : default is 'series' for time-series, use 'profile' to extract profile data
%
% By default the profile data for time t0 results. However if tint, in minutes, is specified (as <keyword,value> pair)
%                                                  profile data for times = [t0:tint:tend] is returned.
% If a requested time is not found on the history file, the nearest time is taken.
%
% Output:
% Data.OPT                : Structure with optional user settings used,
% Data.time_file          : times as found on file (might differ from requested_time if not found on file),
% Data.val                : 4-Dimensional array with dimensions (no_times,no_stat,kmax,2),
%                           Data.val(:,:,:,1) are the z_values,
%                           Data.val(:,:,:,2) are the varName values (salinity, temperature etc).
%
% Example6: Data = EHY_getmodeldata(files{i_file}, stations, 'dfm' ,'varName' ,'salinity'            , ...
%                                   't0'    ,'17-Jul-2018 01:40:00','tend'    ,'17-Jul-2018 02:00:00', ...
%                                   'tint'  ,10.0                  ,'typeData','profiles'            );
%
% For questions/suggestions, please contact Julien.Groenenboom@deltares.nl

if ~prod([exist('inputFile','var') exist('stat_name','var') exist('modelType','var')])
    EHY_getmodeldata_interactive
    return
end

OPT.varName  = 'wl';
OPT.t0       = '';
OPT.tend     = '';
OPT.tint     = '';
OPT.layer    = 0; % all
OPT.typeData = 'series';

% backward compatible - EHY_getmodeldata(sim_dir,runid,stat_name,modelType,varargin)
if isdir(inputFile) && ~any(strcmp(modelType,'implic')) && ~any(strcmp(varargin{1},'implic'))
    inputFile=EHY_simdirRunIdAndModelType2outputfile(inputFile,stat_name,varargin{1});
    varargout={EHY_getmodeldata(inputFile,modelType,varargin{1},varargin{2:end})};
    return
end

OPT         = setproperty(OPT,varargin);

%% modify input
if ~isempty(OPT.t0)     ; OPT.t0=datenum(OPT.t0); end
if ~isempty(OPT.tend)   ; OPT.tend=datenum(OPT.tend); end
if ~isnumeric(OPT.layer); OPT.layer=str2num(OPT.layer); end

%% Get list of numbers of the requested stations
Data           = EHY_getRequestedStations(inputFile,stat_name,modelType,'varName',OPT.varName);
stationNrNoNan = Data.stationNrNoNan;

%% Get the computational data
if strcmpi(OPT.typeData,'series')

    %  First the series (default)
    switch modelType
        
        case {'d3dfm','dflow','dflowfm','mdu','dfm'}
            %% Delft3D-Flexible Mesh
            % open data file
            if ~exist('infonc','var')
                infonc             = ncinfo(inputFile);
                
                % layer info
                gridInfo=EHY_getGridInfo(inputFile,'no_layers');
                no_layers=gridInfo.no_layers;
                OPT=EHY_getmodeldata_layer_index(OPT,no_layers);
                
                % time info
                ncVarInd                = strmatch('time',{infonc.Variables.Name},'exact');
                nr_times                = infonc.Variables(ncVarInd).Size;
                Data.times              =EHY_getmodeldata_getDatenumsFromOutputfile(inputFile);
                [Data,time_index,select]=EHY_getmodeldata_time_index (Data,OPT);
                nr_times_clip           = length(Data.times);
                
                % station info
                ncVarInd    = strmatch('station_x_coordinate',{infonc.Variables.Name},'exact');
                stationSize = infonc.Variables(ncVarInd).Size;
                if size(stationSize,2)>1
                    movingStations=1;
                    % info will be obtained using blocks, see few lines down
                else
                    stationX = ncread(inputFile,'station_x_coordinate');
                    stationY = ncread(inputFile,'station_y_coordinate');
                    Data.location(Data.exist_stat,1:2)=[stationX(stationNrNoNan,1) stationY(stationNrNoNan,1)];
                    Data.location(~Data.exist_stat,1:2)=NaN;
                end
                
            end
            
            % get data
            % - To enhance speed, read in blocks if numel is too big
            % - It is faster to read all stations and only keep the data of the
            %   wanted stations than looping over the wanted stations.
            
            filesize    = dir(inputFile);
            filesize    = filesize.bytes /(1024^3); %converted to Gb
            maxblocksize= 0.5; %Gb
            nr_blocks   = ceil((nr_times_clip / nr_times) * (filesize / maxblocksize));
            bl_length   = ceil(nr_times_clip / nr_blocks);
            offset      = find(select, 1) - 1;
            
            % allocate variable 'value'
            if ismember(OPT.varName,{'wl'})
                value = nan(nr_times_clip,length(Data.stationNames));
            elseif ismember(OPT.varName,'uv')
                if no_layers==1 % 2Dh
                    value_x = nan(nr_times_clip,length(Data.stationNames));
                    value_y = nan(nr_times_clip,length(Data.stationNames));
                else
                    value_x = nan(nr_times_clip,length(Data.stationNames),no_layers);
                    value_y = nan(nr_times_clip,length(Data.stationNames),no_layers);
                end
            elseif ismember(OPT.varName,{'sal','tem',infonc.Variables(:).Name})
                if no_layers==1 % 2Dh
                    value = nan(nr_times_clip,length(Data.stationNames));
                else
                    value = nan(nr_times_clip,length(Data.stationNames),no_layers);
                end
            end
            
            for i = 1:nr_blocks % time blocks
                bl_start    = 1 + (i-1) * bl_length;
                bl_stop     = min(i * bl_length, nr_times_clip);
                bl_int      = bl_stop-bl_start+1;
                
                % if needed, get time-varying station location info
                if exist('movingStations','var')
                    if i==1 % allocate
                        Data.locationX(1:length(Data.times),1:length(Data.stationNames))=NaN;
                        Data.locationY(1:length(Data.times),1:length(Data.stationNames))=NaN;
                        Data.locationXY_dimensions='[times,stations]';
                    end
                    Data.locationX(bl_start:bl_stop,:)=ncread(inputFile,'station_x_coordinate',[1 bl_start+offset],[Inf bl_int])';
                    Data.locationY(bl_start:bl_stop,:)=ncread(inputFile,'station_y_coordinate',[1 bl_start+offset],[Inf bl_int])';
                    if i==nr_blocks % only keep requested stations
                        Data.locationX(:,~ismember(1:length(Data.stationNames),stationNrNoNan))=[];
                        Data.locationY(:,~ismember(1:length(Data.stationNames),stationNrNoNan))=[];
                    end
                end
                
                switch OPT.varName
                    case 'wl'
                        value(bl_start:bl_stop,:) 	= ncread(inputFile,'waterlevel',[1 bl_start+offset],[Inf bl_int])';
                    case {'wd','water depth'}
                        value(bl_start:bl_stop,:) 	= ncread(inputFile,'waterdepth',[1 bl_start+offset],[Inf bl_int])';
                    case 'uv'
                        if no_layers==1 % 2Dh
                            value_x(bl_start:bl_stop,:) 	= permute(ncread(inputFile,'x_velocity',[1 bl_start+offset],[Inf bl_int]),[2 1]);
                            value_y(bl_start:bl_stop,:) 	= permute(ncread(inputFile,'y_velocity',[1 bl_start+offset],[Inf bl_int]),[2 1]);
                        else
                            value_x(bl_start:bl_stop,:,:) 	= permute(ncread(inputFile,'x_velocity',[1 1 bl_start+offset],[Inf Inf bl_int]),[3 2 1]);
                            value_y(bl_start:bl_stop,:,:) 	= permute(ncread(inputFile,'y_velocity',[1 1 bl_start+offset],[Inf Inf bl_int]),[3 2 1]);
                        end
                    case 'sal'
                        if no_layers==1 % 2Dh
                            value(bl_start:bl_stop,:) 	= permute(ncread(inputFile,'salinity',[1 bl_start+offset],[Inf bl_int]),[2 1]);
                        else
                            value(bl_start:bl_stop,:,:) 	= permute(ncread(inputFile,'salinity',[1 1 bl_start+offset],[Inf Inf bl_int]),[3 2 1]);
                        end
                    case 'tem'
                        if no_layers==1 % 2Dh
                            value(bl_start:bl_stop,:) 	= permute(ncread(inputFile,'temperature',[1 bl_start+offset],[Inf bl_int]),[2 1]);
                        else
                            value(bl_start:bl_stop,:,:) 	= permute(ncread(inputFile,'temperature',[1 1 bl_start+offset],[Inf Inf bl_int]),[3 2 1]);
                        end
                    case 'zcoord'
                        if no_layers==1 % 2Dh
                            value(bl_start:bl_stop,:) 	= permute(ncread(inputFile,'zcoordinate_c',[1 bl_start+offset],[Inf bl_int]),[2 1]);
                        else
                            value(bl_start:bl_stop,:,:) = permute(ncread(inputFile,'zcoordinate_c',[1 1 bl_start+offset],[Inf Inf bl_int]),[3 2 1]);
                        end
                    case {infonc.Variables(:).Name} % like constituents (e.g. totalN, totalP)
                        if no_layers==1 % 2Dh
                            value(bl_start:bl_stop,:) 	= permute(ncread(inputFile,OPT.varName,[1 bl_start+offset],[Inf bl_int]),[2 1]);
                        else
                            value(bl_start:bl_stop,:,:) 	= permute(ncread(inputFile,OPT.varName,[1 1 bl_start+offset],[Inf Inf bl_int]),[3 2 1]);
                        end
                end
            end
            
            % put value(_x/_y) in output structure 'Data'
            if exist('value','var')
                if ndims(value)==2
                    Data.val(:,Data.exist_stat)=value(:,stationNrNoNan);
                    Data.val(:,~Data.exist_stat)=NaN;
                elseif ndims(value)==3
                    Data.val(:,Data.exist_stat,1:length(OPT.layer))=value(:,stationNrNoNan,OPT.layer);
                    Data.val(:,~Data.exist_stat,1:length(OPT.layer))=NaN;
                end
            elseif exist('value_x','var')
                if ndims(value_x)==2
                    Data.vel_x(:,Data.exist_stat)=value_x(:,stationNrNoNan);
                    Data.vel_y(:,Data.exist_stat)=value_y(:,stationNrNoNan);
                    Data.vel_x(:,~Data.exist_stat)=NaN;
                    Data.vel_y(:,~Data.exist_stat)=NaN;
                elseif ndims(value_x)==3
                    Data.vel_x(:,Data.exist_stat,1:length(OPT.layer))=value_x(:,stationNrNoNan,OPT.layer);
                    Data.vel_y(:,Data.exist_stat,1:length(OPT.layer))=value_y(:,stationNrNoNan,OPT.layer);
                    Data.vel_x(:,~Data.exist_stat,1:length(OPT.layer))=NaN;
                    Data.vel_y(:,~Data.exist_stat,1:length(OPT.layer))=NaN;
                end
            end
            
        case {'d3d','d3d4','delft3d4','mdf'}
            %% Delft3D 4
            for i_stat = 1: length(stat_name)
                if Data.exist_stat(i_stat)
                    nr_stat  = find(strcmp(Data.stationNames,stat_name{i_stat}) ~= 0,1);
                    
                    % open data file
                    if ~exist('trih','var')
                        trih=vs_use(inputFile,'quiet');
                        Data.times=qpread(trih,'water level','times');
                        [Data,time_index]=EHY_getmodeldata_time_index(Data,OPT);
                        % layer info
                        no_layers=vs_get(trih,'his-const',{1},'KMAX','quiet');
                        OPT=EHY_getmodeldata_layer_index(OPT,no_layers);
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
                        case {'wd','water depth'}
                            wl=cell2mat(vs_get(trih,'his-series',{time_index},'ZWL',{nr_stat},'quiet')); % ref to wl
                            depth=vs_get(trih,'his-const',{1},'DPS',{nr_stat},'quiet'); % bed to ref
                            Data.val(:,i_stat)=wl+depth;
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
                        case {'sal' 'salinity'}
                            nr_cons=find(strcmpi(constituents,'salinity') ~= 0,1);
                            Data.val(:,i_stat,:) = cell2mat(vs_get(trih,'his-series',{time_index},'GRO',{nr_stat,OPT.layer,nr_cons},'quiet'));
                        case {'tem' 'temperature'}
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
                        sds=qpfopen(inputFile);
                        Data.times = qpread(sds,1,'water level (station)','times');
                        [Data,time_index]=EHY_getmodeldata_time_index(Data,OPT);
                        % layer info
                        dimen=waqua('readsds',sds,[],'MESH_IDIMEN');
                        no_layers   =dimen(18);
                        OPT=EHY_getmodeldata_layer_index(OPT,no_layers);
                    end
                    % get data
                    switch OPT.varName
                        case 'wl'
                            Data.val(:,i_stat) = waquaio(sds,[],'wlstat',time_index,nr_stat);
                        case 'uv'
                            if no_layers==1
                                [uu,vv] = waquaio(sds,[],'uv-stat',time_index,nr_stat);
                                Data.vel_x(:,i_stat) = uu;
                                Data.vel_y(:,i_stat) = vv;
                            else
                                [uu,vv] = waquaio(sds,[],'uv-stat',time_index,nr_stat,OPT.layer);
                                Data.vel_x(:,i_stat,:) = waquaio(sds,[],'u-stat',time_index,nr_stat,OPT.layer);
                                Data.vel_y(:,i_stat,:) = waquaio(sds,[],'v-stat',time_index,nr_stat,OPT.layer);
                            end
                        case 'sal'
                            if no_layers==1
                                Data.val(:,i_stat) = waquaio(sds,[],'stsubst:            salinity',time_index,nr_stat);
                            else
                                Data.val(:,i_stat,:) = waquaio(sds,[],'stsubst:            salinity',time_index,nr_stat,OPT.layer);
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
                        D=read_sobeknc(inputFile);
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
                        D          = read_sobeknc(inputFile);
                        refdate    = ncreadatt(inputFile, 'time','units');
                        Data.times = D.time/1440./60. + datenum(refdate(15:end),'yyyy-mm-dd  HH:MM:SS'); ;
                    end
                    % get data
                    switch OPT.varName
                        case 'wl'
                            Data.val(:,i_stat)         =D.water_level(nr_stat,:);
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
                            if exist([fileparts(inputFile) filesep 'implic.mat'],'file')
                                load([fileparts(inputFile) filesep 'implic.mat'])
                            else
                                months = {'jan' 'feb' 'mrt' 'apr' 'mei' 'jun' 'jul' 'aug' 'sep' 'okt' 'nov' 'dec'};
                                for ii_stat = 1: length(filenames)
                                    fid   = fopen([fileparts(inputFile) filesep filenames{i_stat}],'r');
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
                                save([fileparts(inputFile) filesep 'implic.mat'],'Data');
                            end
                            Data.val(:,i_stat) = Data.val_tmp(:,nr_stat);
                    end
                end
            end
    end
    
    % fill data of non-existing stations with NaN's
    if isfield(Data,'locationMN')
        Data.locationMN(~Data.exist_stat,:)=NaN;
    end
    if isfield(Data,'location')
        Data.location(~Data.exist_stat,:)=NaN;
    end
    if isfield(Data,'val')
        Data.val(:,~Data.exist_stat,:)=NaN;
    elseif isfield(Data,'vel_x')
        Data.vel_x(:,~Data.exist_stat,:)=NaN;
        Data.vel_y(:,~Data.exist_stat,:)=NaN;
        Data.vel_u(:,~Data.exist_stat,:)=NaN;
        Data.vel_v(:,~Data.exist_stat,:)=NaN;
    end
    
    % dimension information
    fn=fieldnames(Data);
    if length(size(Data.(fn{end})))==2
        Data.dimensions='[times,stations]';
    elseif length(size(Data.(fn{end})))==3
        Data.dimensions='[times,stations,layers]';
    end
    
    %% Profile data
elseif strcmpi(OPT.typeData(1:7),'profile')
    t0     = OPT.t0;
    tend   = OPT.tend;
    tint   = OPT.tint/1440.; % from minutes to days
    
    if isempty(t0) error(' You need to specify 1 time (t0) to extract profile data'); end
    
    % Reguested times for profile data
    times_requested = t0;
    if ~isempty(tend) && ~isempty(tint)
        times_requested = [t0:tint:tend];
    end
    
    varName  = OPT.varName;
    
    %% Retieve profile data
    [Data] = EHY_getProfileData(inputFile,stat_name,times_requested,varName);
end

%% Fill output struct
Data.requestedStatNames=stat_name;
Data.OPT               =OPT;
Data.OPT.inputFile    =inputFile;

if nargout==1
    varargout{1}=Data;
end

EHYs(mfilename);

end

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
% varName   : Name of variable, choose from:
%               'wl'    water level
%               'wd'    water depth
%               'uv'    velocities (in (u,v,)x,y-direction)
%               'sal'   salinity
%               'tem'   temperature
%               'Zcen'  z-coordinates (positive up) of cell centers
%               'Zint'  z-coordinates (positive up) of cell interfaces
% t0        : Start time of dataset (e.g. '01-Jan-2018' or 737061 (Matlab date) )
% tend      : End time of dataset (e.g. '01-Feb-2018' or 737092 (Matlab date) )
% layer     : Model layer, e.g. '0' (all layers), [2] or [4:8]
%
% Output:
% Data.stationNames       : list of ALL stations available on history file
% Data.requestedStations  : list of requested stations
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
% Output:
% Data.OPT                : Structure with optional user settings used,
% Data.val                : 4-Dimensional array with dimensions (no_times,no_stat,kmax,2),
%                           Data.val(:,:,:,1) are the z_values,
%                           Data.val(:,:,:,2) are the varName values (salinity, temperature etc).
%
% For questions/suggestions, please contact Julien.Groenenboom@deltares.nl

if ~all(ismember({'inputFile','stat_name','modelType'},who))
    EHY_getmodeldata_interactive
    return
end

%% Settings
OPT.varName  = 'wl';
OPT.t0       = '';
OPT.tend     = '';
OPT.tint     = ''; % in minutes
OPT.layer    = 0; % all
OPT          = setproperty(OPT,varargin);

%% modify input
if ~isempty  (OPT.t0           ) OPT.t0   =datenum(OPT.t0)    ; end
if ~isempty  (OPT.tend         ) OPT.tend =datenum(OPT.tend)  ; end
if ~isempty  (OPT.tint         ) OPT.tint = OPT.tint/1440.    ; end % From minutes to days
if ~isnumeric(OPT.layer        ) OPT.layer=str2num(OPT.layer) ; end

%% Get name of the parameter as known on output file
OPT.nameOnFile = nameOnFile(inputFile,OPT.varName);

%% Get time information from simulation and determine index of required times
Data.times                               = EHY_getmodeldata_getDatenumsFromOutputfile(inputFile);
[tmp,time_index,select,index_requested]  = EHY_getmodeldata_time_index(Data,OPT);
nr_times_clip                            = length(tmp.times);

%% Get layer information and type of vertical schematisation
gridInfo    = EHY_getGridInfo(inputFile,{'no_layers' 'layer_model'});
no_layers   = gridInfo.no_layers;
layer_model = gridInfo.layer_model;
OPT         = EHY_getmodeldata_layer_index(OPT,no_layers);

%% Get list with the numbers of the requested stations
[Data,stationNrNoNan] = EHY_getRequestedStations(inputFile,stat_name,modelType,'varName',OPT.varName);
if exist('tmp','var'); Data.times     = tmp.times(index_requested); end

%% Get the computational data
switch modelType
    %  Delft3D-Flexible Mesh
    case {'d3dfm','dflow','dflowfm','mdu','dfm'}
        
        % open inputfile
        infonc          = ncinfo(inputFile);
        variablesOnFile = {infonc.Variables.Name};
        nr_var     = get_nr({infonc.Variables.Name},OPT.nameOnFile);
        dimNames   = {infonc.Variables(nr_var).Dimensions.Name};
        dimensions = fliplr(infonc.Variables(nr_var).Size);
        
        % station info
        if ismember('stations',dimNames)
            stationX = ncread(inputFile,'station_x_coordinate');
            stationY = ncread(inputFile,'station_y_coordinate');
            Data.location( Data.exist_stat,1:2)=[stationX(stationNrNoNan,1) stationY(stationNrNoNan,1)];
            Data.location(~Data.exist_stat,1:2)=NaN;
        else % delete station-information from 'Data'
            Data=rmfield(Data,{'stationNames','requestedStations','exist_stat'});
        end
        
        % Specify dimensions and initialise series data
        if strcmp(dimNames(end),'time')
            dimensions(1) = nr_times_clip;
        end
        
        % get series data
        nrTimeStart           =  find(select, 1);
        if length(dimensions) == 1 start = [    nrTimeStart]; count        = [        nr_times_clip]; end
        if length(dimensions) == 2 start = [1   nrTimeStart]; count        = [Inf     nr_times_clip]; end
        if length(dimensions) == 3 start = [1 1 nrTimeStart]; count        = [Inf Inf nr_times_clip]; end
        order                 =  length(dimensions):-1:1;
        
        if ~ismember(OPT.varName,{'uv'})
            if length(order)==1
                value     =  ncread_blocks(inputFile,OPT.nameOnFile,start,count);
            else
                value     =  permute(ncread_blocks(inputFile,OPT.nameOnFile,start,count),order);
            end
        else
            value_x   =  permute(ncread_blocks(inputFile,'x_velocity',start,count),order);
            value_y   =  permute(ncread_blocks(inputFile,'y_velocity',start,count),order);
        end
        
        % put value(_x/_y) in output structure 'Data'
        if exist('value','var')
            if size(value,2)==1
                Data.val(:,1)=value(index_requested,:);
            elseif ndims(value)==2
                Data.val(:,Data.exist_stat)=value(index_requested,stationNrNoNan);
                Data.val(:,~Data.exist_stat)=NaN;
            elseif ndims(value)==3
                Data.val(:,Data.exist_stat,1:length(OPT.layer))=value(index_requested,stationNrNoNan,OPT.layer);
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
        
        % Delft3D 4
    case {'d3d','d3d4','delft3d4','mdf'}
        % open inputfile
        trih = vs_use(inputFile,'quiet');
        % loop over stations
        ii_stat = 0;
        for i_stat = 1: length(Data.requestedStations)
            if Data.exist_stat(i_stat)
                ii_stat = ii_stat + 1;
                nr_stat  = stationNrNoNan(ii_stat);
                % constituents
                constituents=squeeze(vs_get(trih,'his-const','NAMCON','quiet'));
                if size(constituents,1)>size(constituents,2); constituents=constituents'; end
                constituents=cellstr(constituents);
                % station info
                stationMN = vs_get(trih,'his-const',{1},'MNSTAT','quiet');
                stationXY = vs_get(trih,'his-const',{1},'XYSTAT','quiet');
                Data.locationMN(i_stat,:)=[stationMN(:,nr_stat)'];
                Data.location(i_stat,:)=[stationXY(:,nr_stat)'];
                
                % Get constants for profile data
                if strcmpi(OPT.varName,'Zcen') || strcmpi(OPT.varName,'Zint')
                    if strcmp(layer_model,'sigma-model')
                        thick    = vs_let(trih,'his-const'              ,'THICK'          ,'quiet');
                        dps      = vs_let(trih,'his-const'              ,'DPS'            ,'quiet');
                    elseif strcmp(layer_model,'z-model')
                        dps      = vs_let(trih,'his-const'              ,'DPS'            ,'quiet');
                        zk       = vs_get(trih,'his-const'              ,'ZK'             ,'quiet');
                    end
                end
                
                % get data
                switch OPT.varName
                    case 'wl'
                        Data.val(:,i_stat)=cell2mat(vs_get(trih,'his-series',{time_index},'ZWL',{nr_stat},'quiet'));
                    case {'waterdepth'}
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
                    case {'Zcen' 'Zint'}
                        zwl      = vs_let(trih,'his-series',{time_index(index_requested)},'ZWL'  ,{nr_stat},'quiet');
                        for i_time = 1: length(index_requested)
                            if strcmpi(layer_model,'sigma-model')
                                depth = dps(stationNrNoNan(i_stat)) + zwl(i_time);
                                Zint(i_time,1     )        = zwl(i_time);
                                Zint(i_time,no_layers + 1) = -dps(nr_stat);
                                Zcen(i_time,1     )        = zwl(i_time) - 0.5*thick(1)*depth;
                                for k = 2: no_layers
                                    Zint(i_time,k)  = Zint(i_time,k-1) - thick(k-1)*depth;
                                    Zcen(i_time,k)  = Zcen(i_time,k-1) - 0.5*(thick(k-1) + thick(k))*depth;
                                end
                            elseif strcmpi(layer_model,'z-model')
                                zk_int(1:no_layers + 1) = NaN;
                                
                                %restrict to active computational layers
                                i_start = find(zk> -dps(nr_stat),1,'first') - 1;
                                i_stop =  find(zk>  zwl(i_time),1,'first');
                                if isempty(i_stop) i_stop = no_layers + 1; end
                                zk_int(i_start) = -dps(nr_stat);
                                zk_int(i_stop)  =  zwl(i_time);
                                
                                zk_int(i_start+1:i_stop-1) = zk(i_start+1:i_stop-1);
                                Zint(i_time,:) = zk_int;
                                for k = 1: no_layers
                                    Zcen(i_time,k) = 0.5*(Zint(i_time,k  ) + Zint(i_time,k+1) );
                                end
                            end
                        end
                        
                        if strcmpi(OPT.varName    ,'Zcen')
                            Data.val(:,i_stat,:) = Zcen;
                        elseif strcmpi(OPT.varName,'Zint')
                            Data.val(:,i_stat,:) = Zint;
                        end
                        
                    case {'salinity' 'temperature'}
                        nr_cons            = get_nr(lower(constituents),OPT.varName);
                        value (:,i_stat,:) = cell2mat   (vs_get(trih,'his-series',{time_index(index_requested)},'GRO',{nr_stat,OPT.layer,nr_cons},'quiet'));
                        % series
                        Data.val(:, i_stat,:)= value(:,i_stat,:);
                end
            end
        end
        
    case {'waqua','simona','siminp'}
        %% SIMONA (WAQUA/TRIWAQ)
        % open data file
        sds=qpfopen(inputFile);
        
        ii_stat    = 0;
        for i_stat = 1: length(stat_name)
            if Data.exist_stat(i_stat)
                ii_stat  = ii_stat + 1;
                nr_stat  = stationNrNoNan(ii_stat);
                switch OPT.varName
                    case 'wl'
                        Data.val(:,i_stat) = waquaio(sds,[],'wlstat',time_index,nr_stat);
                    case 'dps'
                        [~,~,z_int]        = waquaio(sds,[],'z-stat',1,nr_stat);
                        Data.val(i_stat)   = -1.*z_int(end);
                    case 'uv'
                        if no_layers==1
                            [uu,vv] = waquaio(sds,[],'uv-stat',time_index,nr_stat);
                            Data.vel_x(:,i_stat) = uu;
                            Data.vel_y(:,i_stat) = vv;
                        else
                            Data.vel_x(:,i_stat,:) = waquaio(sds,[],'u-stat',time_index,nr_stat,OPT.layer);
                            Data.vel_y(:,i_stat,:) = waquaio(sds,[],'v-stat',time_index,nr_stat,OPT.layer);
                        end
                    case 'salinity'
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
                nr_stat  = stationNrNoNan(i_stat);
                % open data file
                D          = read_sobeknc(inputFile);
                % get data
                switch OPT.varName
                    case 'wl'
                        Data.val(:,i_stat)         =D.value(nr_stat,:);
                end
            end
        end
        
    case {'sobek3_new'}
        %% SOBEK3 new
        for i_stat = 1: length(stat_name)
            if Data.exist_stat(i_stat)
                nr_stat  = stationNrNoNan(i_stat);
                % open data file
                D          = read_sobeknc(inputFile);
                refdate    = ncreadatt(inputFile, 'time','units');
                Data.times = D.time/1440./60. + datenum(refdate(15:end),'yyyy-mm-dd  HH:MM:SS'); ;
                % get data
                switch OPT.varName
                    case 'wl'
                        Data.val(:,i_stat)         =D.water_level(nr_stat,:);
                end
            end
        end
        
    case {'implic'}
        %% IMPLIC
        %  get simulation data either by reading mat file or direct reading
        %  of IMPLIC output files
        if exist([inputFile filesep 'implic.mat'],'file')
            load([inputFile filesep 'implic.mat']);
        else
            months = {'jan' 'feb' 'mrt' 'apr' 'mei' 'jun' 'jul' 'aug' 'sep' 'okt' 'nov' 'dec'};
            for i_stat = 1: length(Data.stationNames)
                fileName = [inputFile filesep Data.stationNames{i_stat} '.dat'];
                fid      = fopen(fileName,'r');
                line     = fgetl(fid);
                line     = fgetl(fid);
                line     = fgetl(fid);
                i_time   = 0;
                while ~feof(fid)
                    i_time  = i_time + 1;
                    line    = fgetl(fid);
                    r_val   = str2num(line(18:end))/100.;
                    tmp.val_tmp (i_time,i_stat)  = r_val;
                end
                fclose(fid);
            end
            tmp.times = Data.times;
            save([inputFile filesep 'implic.mat'],'tmp');
        end
        
        for i_stat = 1: length(stat_name)
            if Data.exist_stat(i_stat)
                nr_stat  = stationNrNoNan(i_stat);
                % get data
                switch OPT.varName
                    case 'wl'
                        Data.val(:,i_stat) = tmp.val_tmp(:,nr_stat);
                end
            end
        end
        
        clear tmp
end

if ~isfield(Data,'exist_stat')
    % non-station info from .nc-file
else
    % fill data of non-existing stations with NaN's
    if isfield(Data,'locationMN')
        Data.locationMN(~Data.exist_stat,:)=NaN;
    end
    if isfield(Data,'location')
        Data.location(~Data.exist_stat,:)=NaN;
    end
    if isfield(Data,'val') && isfield(Data,'exist_stat')
        Data.val(:,~Data.exist_stat,:)=NaN;
    elseif isfield(Data,'vel_x')
        Data.vel_x(:,~Data.exist_stat,:)=NaN;
        Data.vel_y(:,~Data.exist_stat,:)=NaN;
        Data.vel_u(:,~Data.exist_stat,:)=NaN;
        Data.vel_v(:,~Data.exist_stat,:)=NaN;
    end
end

% dimension information
fn=fieldnames(Data);
if length(size(Data.(fn{end})))==2 && size(Data.(fn{end}),2)==1
    Data.dimensions='[times,-]';
elseif length(size(Data.(fn{end})))==2
    Data.dimensions='[times,stations]';
elseif length(size(Data.(fn{end})))==3
    Data.dimensions='[times,stations,layers]';
end

%% Fill output struct
Data.OPT               = OPT;
Data.OPT.inputFile     = inputFile;

if nargout==1
    varargout{1}=Data;
end

end

function newName = nameOnFile(inputFile,varName)

%% Get the name of varName as specified on the history file of a simulation
newName   = varName;

if strcmpi(varName,'sal'         ) newName = 'salinity'   ; end
if strcmpi(varName,'tem'         ) newName = 'temperature'; end

modelType = EHY_getModelType(inputFile);

switch modelType
    case 'dfm'
        if strcmpi(varName,'wl'         ) newName = 'waterlevel'   ; end
        if strcmpi(varName,'wd'         ) newName = 'waterdepth'   ; end
        if strcmpi(varName,'water depth') newName = 'waterdepth'   ; end
        if strcmpi(varName,'uv'         ) newName = 'x_velocity'   ; end
        if strcmpi(varName,'Zcen'       ) newName = 'zcoordinate_c'; end
        if strcmpi(varName,'Zint'       ) newName = 'zcoordinate_w'; end
        
    case 'd3d'
        
    case 'simona'
end

end

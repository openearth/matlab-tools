function EHY_nc2tek(filename,varargin)

%% EHY_nc2tek: Extract data from DFLOW-FM netcdf history file and write to tekal time series file
%  Example:
%
% stationlist = {'SARB';'CTD Fujairah';'Umm Lulu'};
% crslist     = {'crs19'};
% 
% EHY_nc2tek('c05r_his.nc','stationlist',stationlist, ...
%                          'crslist'    ,crslist    , ...
%                          'layers'     ,[1 10]     , ...  
%                          'waterlevel' ,true       , ... % Hydrodynamics, station information
%                          'salinity'   ,true       , ...
%                          'temperature',true       , ...
%                          'density'    ,true       , ...
%                          'discharge'  ,true       , ... % Hydrodynamics, cross section information
%                          'cummdis'    ,true       , ...
%                          'crs_area'   ,true       , ...
%                          'crs_vel'    ,true       , ...
%                          'crs_salt'   ,true       , ...
%                          'crs_temp'   ,true       , ...
%                          'wind'       ,true       , ... % Meteorology/temperature, station information
%                          'patm'       ,true       , ... 
%                          'Tair'       ,true       , ...
%                          'rhum'       ,true       , ...
%                          'clou'       ,true       , ...
%                          'Qsun'       ,true       , ...
%                          'Qeva'       ,true       , ...
%                          'Qcon'       ,true       , ...
%                          'Qlong'      ,true       , ...
%                          'Qfreva'     ,true       , ...
%                          'Qfrcon'     ,true       , ...
%                          'Qtot'       ,true       ) ;
%
%  Initialise
OPT.stationlist = {};
OPT.crslist     = {};
OPT.layers      = [];
OPT.waterlevel  = false;
OPT.salinity    = false;
OPT.temperature = false;
OPT.density     = false;
OPT.discharge   = false;
OPT.cummdis     = false;
OPT.crs_area    = false;
OPT.crs_vel     = false;
OPT.crs_salt    = false;
OPT.crs_temp    = false;
OPT.wind        = false;
OPT.patm        = false;
OPT.Tair        = false;
OPT.rhum        = false;
OPT.clou        = false;
OPT.Qsun        = false;
OPT.Qeva        = false;
OPT.Qcon        = false;
OPT.Qlong       = false;
OPT.Qfreva      = false;
OPT.Qfrcon      = false;
OPT.Qtot        = false;
OPT             = setproperty(OPT,varargin);
tmp             = strfind(filename,'_');
sim             = filename(1:tmp(1) - 1);

%  General: Dimensions
Info        = ncinfo(filename);
nr_field    = find(~cellfun(@isempty,strfind({Info.Dimensions.Name},'laydim'))==1,1);
laydim      = Info.Dimensions(nr_field).Length;
nr_field    = find(~cellfun(@isempty,strfind({Info.Dimensions.Name},'stations'))==1,1);
no_stations = Info.Dimensions(nr_field).Length;
nr_field    = find(~cellfun(@isempty,strfind({Info.Dimensions.Name},'cross_section'))==1,1);
no_crs      = Info.Dimensions(nr_field).Length;

%  General: times
times     = ncread    (filename,'time');
att_times = ncreadatt (filename,'time','units');
itdate    = datenum   (att_times(15:24),'yyyy-mm-dd');
times     = itdate + times/(1440.*60.);

%  General: station names
tmp           = ncread    (filename,'station_name');
station_names = deblank(char2cell(tmp'));

%  General: cross section names
tmp                 = ncread    (filename,'cross_section_name');
cross_section_names = deblank(char2cell(tmp'));

%% Get nr of the stations and/or cross sections to extract
if isempty(OPT.stationlist)
    station_nr = 1:1:no_stations;
else
    station_nr = [];
    for i_stat = 1: length(OPT.stationlist)
        nr_stat    = find(strcmpi(station_names,OPT.stationlist{i_stat}) ~= 0,1);
        station_nr = [station_nr nr_stat]; 
    end
end

if isempty(OPT.crslist)
    crs_nr = 1:1:no_crs;
else
    crs_nr = [];
    for i_stat = 1: length(OPT.crslist)
        nr_stat    = find(strcmpi(cross_section_names,OPT.crslist{i_stat}) ~= 0,1);
        crs_nr     = [crs_nr nr_stat]; 
    end
end

%% Get layers to extract
if isempty (OPT.layers)
    layers = 1:1:laydim;
else
    layers = OPT.layers;
end

%% Create list of parameters to extract
param_list    = {};
threeD        = [];
% Hydrodynamics station information
if OPT.waterlevel  param_list{end + 1} = 'waterlevel'                        ; threeD(end + 1) = false; end
if OPT.salinity    param_list{end + 1} = 'salinity'                          ; threeD(end + 1) = true ; end
if OPT.temperature param_list{end + 1} = 'temperature'                       ; threeD(end + 1) = true ; end
if OPT.density     param_list{end + 1} = 'density'                           ; threeD(end + 1) = true ; end
% Hydrodynamics cross section information
if OPT.discharge   param_list{end + 1} = 'cross_section_discharge'           ; threeD(end + 1) = false; end
if OPT.cummdis     param_list{end + 1} = 'cross_section_cumulative_discharge'; threeD(end + 1) = false; end
if OPT.crs_area    param_list{end + 1} = 'cross_section_area'                ; threeD(end + 1) = false; end
if OPT.crs_vel     param_list{end + 1} = 'cross_section_velocity'            ; threeD(end + 1) = false; end
if OPT.crs_salt    param_list{end + 1} = 'cross_section_salt'                ; threeD(end + 1) = false; end
if OPT.crs_temp    param_list{end + 1} = 'cross_section_temperature'         ; threeD(end + 1) = false; end
% Meteorology/temperature at stations
if OPT.wind        param_list{end + 1} = 'wind'                              ; threeD(end + 1) = false; end
if OPT.patm        param_list{end + 1} = 'patm'                              ; threeD(end + 1) = false; end
if OPT.Tair        param_list{end + 1} = 'Tair'                              ; threeD(end + 1) = false; end
if OPT.rhum        param_list{end + 1} = 'rhum'                              ; threeD(end + 1) = false; end
if OPT.clou        param_list{end + 1} = 'clou'                              ; threeD(end + 1) = false; end
if OPT.Qsun        param_list{end + 1} = 'Qsun'                              ; threeD(end + 1) = false; end
if OPT.Qeva        param_list{end + 1} = 'Qeva'                              ; threeD(end + 1) = false; end
if OPT.Qcon        param_list{end + 1} = 'Qcon'                              ; threeD(end + 1) = false; end
if OPT.Qlong       param_list{end + 1} = 'Qlong'                             ; threeD(end + 1) = false; end
if OPT.Qfreva      param_list{end + 1} = 'Qfreva'                            ; threeD(end + 1) = false; end
if OPT.Qfrcon      param_list{end + 1} = 'Qfrcon'                            ; threeD(end + 1) = false; end
if OPT.Qtot        param_list{end + 1} = 'Qtot'                              ; threeD(end + 1) = false; end


%% Get data and write
for i_param = 1: length(param_list)

    % stations or cross sections
    if ~strncmp(param_list{i_param},'cross_section',13)
        list = station_names;
        nr   = station_nr;
    else
        list = cross_section_names;
        nr   = crs_nr;
    end

    % get the data
    tmp      = ncread    (filename,param_list{i_param});

    % cycle over all station/cross sections
    for i_stat = 1: length(nr);
        tmpname = [param_list{i_param} '_' sim '_' list{nr(i_stat)}];
        if ~threeD(i_param)
            filename_out = tmpname;
            values       = tmp(nr(i_stat),:);
            write_tekaltime    (filename_out, times, values);
        else
            for i_lay = 1: length(layers)
                filename_out = [tmpname '_layer' num2str(layers(i_lay),'%2.2i')];
                values       = tmp(layers(i_lay),nr(i_stat),:);
                write_tekaltime    (filename_out, times, values);
            end
        end
    end
end

function write_tekaltime(filename,times,values)

%% Open file
fid = fopen([filename '.tek'],'w+');

%% Comments
fprintf (fid,'* Column  1: Date \n');
fprintf (fid,'* Column  2: Time \n');
fprintf (fid,'* Column  3: Values \n');

%% Data
fprintf(fid,'%s \n',filename);
fprintf(fid,'%5i %5i \n',length(times),3);
for i_time = 1: length(times)
    fprintf(fid,'%16s %12.6f \n',datestr(times(i_time),'yyyymmdd  HHMMSS'), values(i_time));
end

%% Close file
fclose (fid);










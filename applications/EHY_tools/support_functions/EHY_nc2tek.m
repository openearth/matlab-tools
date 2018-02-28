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
%                          'waterlevel' ,true       , ...
%                          'salinity'   ,true       , ...
%                          'temperature',true       , ...
%                          'density'    ,true       , ...
%                          'discharge'  ,true       , ...
%                          'cummdis'    ,true       );
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
OPT             = setproperty(OPT,varargin);
tmp             = strfind(filename,'_');
sim             = filename(1:tmp(1) - 1);

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

%  General: number of layers (not sure if this parameter exist in 2D simulation
try
    laydim = length(ncread    (filename,'zcoordinate_c',[1 1 1],[inf 1 1],[1 1 1]));
catch
    laydim = 1;
end

%% Get nr of the stations and/or cross sections to extract
if isempty(OPT.stationlist)
    station_nr = 1:1:length(station_names);
else
    station_nr = [];
    for i_stat = 1: length(OPT.stationlist)
        nr_stat    = find(strcmpi(station_names,OPT.stationlist{i_stat}) ~= 0,1);
        station_nr = [station_nr nr_stat]; 
    end
end

if isempty(OPT.crslist)
    crs_nr = 1:1:length(cross_section_names);
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
if OPT.waterlevel  param_list{end + 1} = 'waterlevel'                        ; threeD(end + 1) = false; end
if OPT.salinity    param_list{end + 1} = 'salinity'                          ; threeD(end + 1) = true ; end
if OPT.temperature param_list{end + 1} = 'temperature'                       ; threeD(end + 1) = true ; end
if OPT.density     param_list{end + 1} = 'density'                           ; threeD(end + 1) = true ; end
if OPT.discharge   param_list{end + 1} = 'cross_section_discharge'           ; threeD(end + 1) = false; end
if OPT.cummdis     param_list{end + 1} = 'cross_section_cumulative_discharge'; threeD(end + 1) = false; end

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










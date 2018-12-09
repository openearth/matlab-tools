function Data = EHY_getProfileData(fileInp,stations_requested,times_requested,varName)

% Get profile data out of a history file (DFlowFM or Delft3D-Flow)
% Called by EHY_getmodeldata
% 
% Input:
% file_inp           = history output file of hydrodynamic simulation,
%                      can be a DFlowFM file or a Delft3D file
%                      (TRIWAQ not supported yet),
% stations_requested = cell array containing names of the stations for
%                      which profile data is requested,
% times_requested    = numeric array containg matlab times for which
%                      profile data is requested 
%                      (if a time is not found the nearest time is taken),
% varName            = is the variable name (only 'salinity' tested)
%
%
% Output:
% Data               = structure containing
%                      time_file: times as found on file 
%                                 (might differ from requested_time if not found on file)
%                      val: 4-Dimensional array with dimensions (no_times,no_stat,kmax,2)
%                      val(:,:,:,1) are the z_values),
%                      val(:,:,:,2) are the varName values (salinity, temperature etc).
%
%% Initialisation
no_stat  = length(stations_requested);
no_times = length(times_requested);

%% Read history file
modelType = EHY_getModelType(fileInp);

% Salinity/temperature profile data
Data_series   = EHY_getmodeldata(fileInp,stations_requested,modelType,'varName',varName);
% z-coordinate
Data_z        = EHY_getGridInfo (fileInp,'Z','stations',stations_requested,'varName',varName);

%% Extract data
times_file       = Data_series.times;
stations_file    = Data_series.stationNames;

for i_time = 1: no_times
    [~,nr_time] = min(abs(times_file - times_requested(i_time))); % Find nearest value
    tmp.time_file(i_time) = times_file(nr_time);
    
    for i_stat = 1: no_stat
        tmp.val(i_time,i_stat,:,1) = Data_z.Zcen    (nr_time, i_stat,:);
        tmp.val(i_time,i_stat,:,2) = Data_series.val(nr_time, i_stat,:);
    end
end

%% Restrict to unique values (if interval is chosen small multiple identical times might occur)
[~,index_unique] = unique(tmp.time_file);
Data.time_file   = tmp.time_file(index_unique);
Data.val         = tmp.val      (index_unique,:,:,:); 

function [Data] = EHY_getRequestedStations(fileInp,requestedStations,modelType,varargin)

% Gets the subset of requested stations out of the list of available stations
OPT.varName = 'wl';
OPT         = setproperty(OPT,varargin);
varName     = OPT.varName;

%% no requestedStations specified, all stations, otherwise, stat_name is a string or a cell array of strings
if ~isempty(requestedStations)
    if ~iscell(requestedStations)
        stat_name = {requestedStations};
    end
end

%% Get station names
Data.stationNames = EHY_getStationNames(fileInp,modelType,'varName',varName);

%% No station name specified, get data from all stations
if isempty(requestedStations)
    requestedStations = Data.stationNames;
end
if size(requestedStations,1)<size(requestedStations,2); requestedStations=requestedStations'; end
Data.requestedStatNames=requestedStations;

%% Determine station numbers of the requested stations
stationNr(1:length(requestedStations),1)=NaN;
for i_stat = 1:length(requestedStations)
    nr_stat  = get_nr(Data.stationNames,requestedStations{i_stat});
    if isempty(nr_stat)
        Data.exist_stat(i_stat,1) = false;
        disp(['Station : ' requestedStations{i_stat} ' does not exist']);
    else
        stationNr      (i_stat,1) = nr_stat;
        Data.exist_stat(i_stat,1) = true;
    end
end
Data.stationNrNoNan=stationNr(~isnan(stationNr));
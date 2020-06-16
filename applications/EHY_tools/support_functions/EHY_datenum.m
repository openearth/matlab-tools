function daten = EHY_datenum(date,format)
% Similar function as MATLABs datenum. However, when 'format' is not provided
% this function will make an educated guess.
%
% daten       datenum [double]
% date        datestr [char]
% format      format of input, e.g. 'yyyymmdd' [char]
%
% Example1:   daten = EHY_datenum('20200101')
% Example2:   daten = EHY_datenum('20200101','yyyymmdd')
% Example3:   daten = EHY_datenum('202001011500')
%
% support function of the EHY_tools - E: Julien.Groenenboom@Deltares.nl
%%

%% check format
if iscell(date) && numel(date) == 1
    date = char(date);
end
if ~ischar(date)
    error('This functions expects "date" to be a cell or char array')
end

addTime = 0;
if length(date) == 8
    format = 'yyyymmdd';
elseif length(date) == 10
    format = 'yyyymmddHH';
elseif length(date) == 12 && all(~(isspace(date)))
    format = 'yyyymmddHHMM';
elseif length(date) == 13
    format = 'yyyymmdd HHMM';
elseif length(date) == 14 && all(~(isspace(date)))
    format = 'yyyymmddHHMMSS';
elseif length(date) == 15 && isspace(date(9))
    format = 'yyyymmdd HHMMSS';
elseif length(date) == 19 && all(ismember(date([5 8]),'-')) && all(ismember(date([14 17]),':'))
    format = 'yyyy-mm-dd HH:MM:SS';
elseif length(date) == 20 && all(ismember(date([5 8]),'-')) && all(ismember(date([14 17]),':')) ...
        && strcmp(date(19),'.') % mistake in creation of ERA5-meteo-files
    date = date(1:16);
    format = 'yyyy-mm-dd HH:MM';
elseif length(date) == 26 && all(ismember(date([5 8]),'-')) && all(ismember(date([14 17 24]),':')) ...
        && ismember(date(21),'+-')
    addTime = str2double(date(22:23))/24 + str2double(date(25:26))/60/24; % e.g. '+01:00'
    if strcmp(date(21),'-'); addTime = -1*addTime; end
    date = date(1:19);
    format = 'yyyy-mm-dd HH:MM:SS';
end

%% Determine daten
if exist('format','var') && ~isempty(format)
    daten = datenum(date,format) + addTime;
else
    error(['Could not convert ' date ' to MATLABs datenum format'])
end
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

if length(date) == 8
    format = 'yyyymmdd';
elseif length(date) == 10
    format = 'yyyymmddHH');
elseif length(date) == 12 && all(~(isspace(date)))
    format = 'yyyymmddHHMM');
elseif length(date) == 13
    format = 'yyyymmdd HHMM');
elseif length(date) == 14 && all(~(isspace(date)))
    format = 'yyyymmddHHMMSS');
elseif length(date) == 15 && isspace(date(9))
    format = 'yyyymmdd HHMMSS');
end

%% Determine daten
if exist('format','var') && ~isempty(format)
    daten = datenum(datestr,format)
else
    error(['Could not convert ' date ' to MATLABs datenum format'])
end
function voltReadLog
%voltReadLog Read a VODAS log file.
%   voltReadLog performs the following actions:
%      * Open the ASCII vodas log file;
%      * Read the header;
%      * Count the number of signals;
%      * Read the signals;
%      * Convert the date to numeric format;
%      * Convert the time to numeric format;
%      * Save volt to a binary mat file.

global volt

% Add backslash if necessary
if ~strcmpi(volt.path, '\')
    volt.path(end+1) = '\';
end % if ~strcmpi(volt.path(end), '\')

% Open file
fid = fopen([volt.path volt.file]);
if fid == -1
    error(sprintf('Failed to open %s', volt.file))
end % if fid == -1

fprintf(1, 'Reading "%s"\n', volt.file)

% Read header
volt.header = textscan(fid, '%s', 8, 'delimiter', '\n', 'bufSize', 8190);
volt.header = volt.header{:};

% Count signals and read the log data
volt.numberOfSignals = length(findstr(volt.header{3}, ';')) + 1;
volt.signalTags = textscan(volt.header{5},'%s','delimiter', ';');
volt.signalTags = volt.signalTags{:};

formatString = '%s %s';
for ii = 3: volt.numberOfSignals
    formatString = [formatString ' %f'];
end % for ii = 3: volt.numberOfSignals
volt.data = textscan(fid, formatString, 'delimiter', ';');

% Close file
fclose(fid);

% Check the date format
switch volt.data{1,1}{1}(3)
    case '-'
       DateFormat = 'dd-mm-yyyy';
       TimeFormat = 'dd-mm-yyyyHH:MM:SS.FFF';
    case '/'
       DateFormat = 'dd/mm/yyyy';
       TimeFormat = 'dd/mm/yyyyHH:MM:SS.FFF';
    otherwise
        error('Cannot recognise date format.')
end

% Proces data
dateNumbers = datenum(vertcat(volt.data{1,1}{:}), DateFormat);
volt.data{1,2} = ...
    datenum([ ...
    vertcat(volt.data{1,1}{:}) ...
    vertcat(volt.data{1,2}{:})], ...
    TimeFormat);
volt.data{1,1} = dateNumbers;
volt.data = ...
    cat(2, volt.data{1, [1: volt.numberOfSignals]});

save([volt.path volt.file(1:end-4)], 'volt')
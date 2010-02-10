function voltLoadMatFile
%voltLoadMatFile load the volt mat file
%   voltReadLog saves a mat file with the volt data structure. The reading
%   of the binary mat file is faster compared to reading the ASCII log
%   file

global volt

% Add backslash if necessary
if ~strcmpi(volt.path, '\')
    volt.path(end+1) = '\';
end % if ~strcmpi(volt.path(end), '\')

% Load the file
load([volt.path volt.file(1:end-4)]);
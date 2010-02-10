function signal = voltGetSignal(tag)
%voltGetSignal get a signal
%   To acces a signal one can use: volt.data(:, i). This will give
%   signal number i.
%   But if the log files have different selections, the number of the 
%   signal can change. This can be remedied by getting a signal by its
%   signal tag.
%   voltGetSignal only accepts one signal tag.

global volt

signal = [];
found = 0;
ii = 0;

while ~found && ii < volt.numberOfSignals
    ii = ii + 1;
    if strcmpi(tag, volt.signalTags{ii})
        found = 1;
        signal = volt.data(volt.selection, ii);
    end % if strcmpi(tag, volt.signalTags{ii})
end % while ~found && ii < volt.numberOfSignals

if ~found
    error(sprintf('signal "%s" not found.', tag))
end % if ~found
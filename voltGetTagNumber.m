function ii = voltGetTagNumber(tag)
%voltGetTagNumber get the number of a signal.
%   The signal numbers are equal to the column numbers of the data in the
%   vodas log file. Check this with vodasListTags.

global volt

ii = 1;
while ii <= volt.numberOfSignals
    if strcmpi(tag, volt.signalTags{ii})
        break
    else
        ii = ii + 1;
    end
end % for ii = 1: volt.numberOfSignals

if ii > volt.numberOfSignals
    error('Tag not recognised')
end
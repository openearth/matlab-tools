function voltListTags
%voltListTags show the list of signal tags.
%   The header file of a vodas log file contains the name tag of each 
%   signal. These tags are listed in the Matlab command window. The user 
%   can look at the list of the available signals.

global volt

for ii = 1: volt.numberOfSignals
    fprintf(1, '%3d: %s\n', ii, volt.signalTags{ii}) 
end % for ii = 1: volt.numberOfSignals
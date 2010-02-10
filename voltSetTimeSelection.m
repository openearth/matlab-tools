function voltSetTimeSelection
%voltSetTimeSelection set a time selection.
%   There are two ways of setting the time selection
%
%   No time selection:
%      volt.t1 = [];
%      volt.t2 = [];
%
%   A start and an end time:
%      volt.t1 = datenum(2009, 11, 25, 17, 20,  0);
%      volt.t2 = datenum(2009, 11, 25, 17, 50,  0);


global volt

if ~isempty(volt.t1) && ~isempty(volt.t2)
    volt.selection = find( ...
        (volt.data(:,2) >= datenum(volt.t1)) & ...
        (volt.data(:,2) <= datenum(volt.t2)));
else
    volt.selection = ...
        [1:size(volt.data,1)]';
end
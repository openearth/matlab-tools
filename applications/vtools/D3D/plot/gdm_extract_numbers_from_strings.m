%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Extract first numeric token from each input string.
% If any element cannot be parsed, fallback to 1:n.
% Output label is 'rkm' when parsing succeeds and 'station' on fallback.
%
% Examples:
%   [v,lab]=gdm_extract_numbers_from_strings({'MA_15.00_QK','MA_16.00_QK'}) -> v=[15 16], lab='rkm'
%   [v,lab]=gdm_extract_numbers_from_strings({'A','B','C'}) -> v=[1 2 3], lab='station'
%
function [values,label] = gdm_extract_numbers_from_strings(str_in)

% Normalize input into a cell array of character vectors.
if ischar(str_in)
    items = {str_in};
elseif isstring(str_in)
    items = cellstr(str_in(:));
elseif iscell(str_in)
    items = str_in(:);
else
    error('Input must be char, string, or cell array of strings.')
end

n = numel(items);
values = NaN(1,n);
label = 'rkm';

for k = 1:n
    item = items{k};

    if isstring(item)
        item = char(item);
    elseif ~ischar(item)
        values = 1:n;
        label = 'station';
        return
    end

    % First numeric token, including optional sign and decimals.
    token = regexp(item,'[-+]?\d*\.?\d+','match','once');
    if isempty(token)
        values = 1:n;
        label = 'station';
        return
    end

    values(k) = str2double(token);
    if isnan(values(k))
        values = 1:n;
        label = 'station';
        return
    end
end

% Keep whole numbers clean in output (e.g., 15.00 -> 15).
is_whole = abs(values - round(values)) < 1e-12;
values(is_whole) = round(values(is_whole));

end %function

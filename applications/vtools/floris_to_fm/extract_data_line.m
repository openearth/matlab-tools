%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 20320 $
%$Date: 2025-09-15 08:29:13 +0200 (Mon, 15 Sep 2025) $
%$Author: chavarri $
%$Id: floris_to_fm_read_funin.m 20320 2025-09-15 06:29:13Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/floris_to_fm/floris_to_fm_read_funin.m $
%
% Parse line into numbers and quoted strings in correct order.
% Commas define slots; empty slots -> NaN / ''
% Quoted items -> strs, nums=NaN
% Unquoted numbers -> nums, strs=''
% Everything after a backslash '\' is ignored

function [nums, strs] = extract_data_line(line)

    if nargin==0 || isempty(line)
        nums = [];
        strs = {};
        return
    end

    % Remove everything after first backslash
    idx = strfind(line, '/');
    if ~isempty(idx)
        line = line(1:idx(1)-1);
    end

    % % Remove trailing slash at the end (if any)
    % line = regexprep(line, '/\s*$', '');

    % Split on commas
    parts = regexp(line, '\s*,\s*', 'split');

    nums = [];
    strs = {};

    for i = 1:numel(parts)
        part = strtrim(parts{i});

        if isempty(part)
            nums(end+1) = NaN;
            strs{end+1} = '';
            continue
        end

        % Scan left-to-right for quoted strings or numbers
        tokenPat = '''[^'']*''|[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?';
        tokens = regexp(part, tokenPat, 'match');

        for t = tokens
            tok = t{1};
            if startsWith(tok, '''') && endsWith(tok, '''')
                % quoted string
                strs{end+1} = tok(2:end-1); % remove quotes
                nums(end+1) = NaN;
            else
                % numeric
                nums(end+1) = str2double(tok);
                strs{end+1} = '';
            end
        end
    end

    % Ensure row vectors
    nums = reshape(nums,1,[]);
    strs = reshape(strs,1,[]);
end

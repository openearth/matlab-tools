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
%COMPARE_TEXT_FILES Compare two text files while ignoring certain timestamp lines.
%   Replaces timestamp/creation lines with "" (keeps line positions) and
%   then compares the files line-by-line.
%
% Output:
%   is_equal   : true if files are identical, false otherwise
%   diff_lines : Nx2 string array containing differing lines:
%                column 1 = line from file1
%                column 2 = line from file2

function [is_equal, diff_lines] = compare_text_files(file1, file2)

% Read files as string arrays and trim whitespace
lines1 = strtrim(string(readlines(file1)));
lines2 = strtrim(string(readlines(file2)));

% Replace matched (ignored) lines by empty string (keeps indexing)
lines1 = replace_ignored_lines(lines1);
lines2 = replace_ignored_lines(lines2);

% Make lengths equal by padding shorter file with ""
n1 = numel(lines1);
n2 = numel(lines2);
n_max = max(n1, n2);
if n1 < n_max
    lines1(n1+1:n_max) = "";
end
if n2 < n_max
    lines2(n2+1:n_max) = "";
end

% Final trim (in case replacing introduced spaces)
lines1 = strtrim(lines1);
lines2 = strtrim(lines2);

% Find differing lines
diff_idx = find(lines1 ~= lines2);

% Build output
is_equal = isempty(diff_idx);
if is_equal
    diff_lines = strings(0,2);
else
    diff_lines = [lines1(diff_idx), lines2(diff_idx)];
end

end %function

%%
%% FUNCTIONS
%%

% Replace (blank out) lines that we want to ignore (timestamps / creationDate)
function lines_out = replace_ignored_lines(lines_in)

lines_out = lines_in;                 % preserve index positions
for kl = 1:numel(lines_in)
    % convert to char and trim to normalize whitespace
    this_line = char(strtrim(lines_in(kl)));
    if isempty(this_line)
        continue
    end

    % normalize to lowercase for case-insensitive checks
    this_line_l = lower(this_line);

    % 1) ignore "# Generated: ..." style (allow optional leading '#', spaces)
    %    example: "# Generated: 22-Sep-2025 14:15:22"
    if startsWith(this_line_l, '# generated:')
        lines_out(kl) = "";
        continue
    end

    % 2) ignore <creationDate ...>...</creationDate> lines
    %    allow attributes in opening tag and allow it to appear with or
    %    without leading/trailing spaces (we've trimmed already).
    %    We simply check that the line starts with "<creationdate" and
    %    contains the closing tag "</creationdate>"
    if startsWith(this_line_l, '<creationdate') && contains(this_line_l, '</creationdate>')
        lines_out(kl) = "";
        continue
    end

    % (add more simple pattern checks here if needed)
end %i

end %function
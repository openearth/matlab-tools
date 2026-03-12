%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%%D3D_BUILD_FIND_ERROR Find lines containing "<integer> error(s)" pattern
%
%   [lineNumbers, lines] = D3D_build_find_error(filename)
%
%   lineNumbers : indices of lines where the pattern occurs
%   lines       : corresponding line contents

function [lineNumbers, lines] = D3D_build_find_error(filename)

fid = fopen(filename,'r');
if fid == -1
    error('Cannot open file: %s', filename);
end

lineNumbers = [];
lines = {};
errorCounts = [];

pattern = '(\d+)\s+error\(s\)';   % capture integer before "error(s)"

i = 0;
while ~feof(fid)
    tline = fgetl(fid);
    i = i + 1;

    tok = regexp(tline, pattern, 'tokens', 'once');
    if ~isempty(tok)
        nerr = str2double(tok{1});
        if nerr > 0
            lineNumbers(end+1) = i; %#ok<AGROW>
            lines{end+1} = tline; %#ok<AGROW>
            errorCounts(end+1) = nerr; %#ok<AGROW>
        end
    end
end

fclose(fid);
end
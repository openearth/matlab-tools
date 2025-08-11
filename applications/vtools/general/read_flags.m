%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 20235 $
%$Date: 2025-07-07 14:32:25 +0200 (Mon, 07 Jul 2025) $
%$Author: chavarri $
%$Id: D3D_io_input.m 20235 2025-07-07 12:32:25Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_io_input.m $
%
%Reads key-value flags from a config file into a struct
%Ignores lines that start with / or // (comments).
%Returns a struct with fields corresponding to the flags.
%
%E.G.:

function flags = read_flags(filename)

flags = struct();

fid = fopen(filename, 'r');
if fid == -1
    error('Could not open file: %s', filename);
end

% Read line by line
while ~feof(fid)
    line = strtrim(fgetl(fid));
    
    % Skip empty lines and comments
    if isempty(line) || startsWith(line, '/') || startsWith(line, '//')
        continue;
    end
    
    % Look for key = value
    tokens = regexp(line, '^(\S+)\s*=\s*(.*)$', 'tokens');
    if ~isempty(tokens)
        key = tokens{1}{1};
        value = strtrim(tokens{1}{2});
        % optionally, strip quotes if present
        value = strip(value, '"');
        % Save
        flags.(key) = value;
    end
end

fclose(fid);

end %function
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
%Efficiently search for a string in D3D diagnostic file and return line numbers

function [kl,fline_got] = D3D_search_dia(filepath, search_str, kl_start)
    % Efficiently find line numbers where search_str appears (memory-efficient for large files)
    % 
    % Inputs:
    %   filepath   - Full path to the diagnostic file
    %   search_str - String to search for
    %   kl_start   - Start searching after this line number (optional)
    %
    % Output:
    %   kl - Array of line numbers where string is found, or NaN if not found
    %   fline_got - Cell array with matched lines

    if nargin < 3 || isempty(kl_start)
        kl_start = 0;
    end
    
    kl = [];
    fline_got = {};
    
    try
        fid = fopen(filepath, 'r');
        if fid == -1
            kl = NaN;
            fline_got = {};
            return;
        end
        
        % Buffered reading: process chunks of lines for better performance
        buffer_size = 50000; % Read 50k lines at a time (keeps memory low for large files)
        line_num = 0;
        
        while ~feof(fid)
            % Read a chunk of lines
            chunk = textscan(fid, '%s', buffer_size, 'Delimiter', '\n', 'Whitespace', '');
            lines = chunk{1};
            
            if isempty(lines)
                break;
            end
            
            % Search for string in this chunk using vectorized operation
            matches = contains(lines, search_str);
            match_indices = find(matches);
            
            if ~isempty(match_indices)
                % Add matching line numbers (adjust for current position in file)
                match_lines = line_num + match_indices;
                valid_idx = match_lines > kl_start;
                if any(valid_idx)
                    kl = [kl; match_lines(valid_idx)]; %#ok<AGROW>
                    fline_got = cat(1,fline_got,lines(match_indices(valid_idx)));
                end
            end
            
            line_num = line_num + numel(lines);
        end
        
        fclose(fid);
        
        if isempty(kl)
            kl = NaN;
            fline_got = {};
        end
        
    catch
        if exist('fid', 'var') && fid ~= -1
            fclose(fid);
        end
        kl = NaN;
        fline_got = {};
    end
end

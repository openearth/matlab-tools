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
%

function winPath = winify(linuxPath)

    if isempty(linuxPath)
        winPath = linuxPath;
        return
    end

    % Case 1 — Absolute POSIX path (/x/...)
    if startsWith(linuxPath, '/')

        parts = strsplit(linuxPath, '/');
        parts = parts(~cellfun(@isempty, parts));

        if isempty(parts)
            error('Invalid path.');
        end

        driveLetter = parts{1};

        if length(driveLetter) ~= 1
            error('Absolute POSIX path must be of form /<drive>/...');
        end

        remaining = parts(2:end);

        if isempty(remaining)
            winPath = sprintf('%s:\\', driveLetter);
        else
            winPath = sprintf('%s:\\%s', driveLetter, strjoin(remaining, '\'));
        end

    else
        % Case 2 — Relative path or filename only
        winPath = strrep(linuxPath, '/', '\');
    end
end %function
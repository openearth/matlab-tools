function string = simona2mdu_replacechar(string,char_org,char_replace)

% Replaces single character in a string or cell array of strings
%

if iscell(string)
    %
    % Cell array of strings
    %
    for icel = 1: length(string)
        index = strfind(string{icel},char_org);
        if ~isempty(index)
            for ichar = 1: length(index)
                string{icel}(index(ichar):index(ichar)) = char_replace;
            end
            string{icel} = strtrim(string{icel});
        end
    end
else
    %
    % Single string
    %
    index = strfind(string,char_org);
    if ~isempty(index)
        for ichar = 1: length(index)
            string(index(ichar):index(ichar)) = char_replace;
        end
        string = strtrim(string);
    end
end



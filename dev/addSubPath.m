function addSubPath(thePath)
% adds a path with all subpaths
%
% addSubPath(thePath)
% INPUT: thePath
allPath = dir(thePath);
    for i = 3:length(allPath)
        newPath = fullfile(thePath,allPath(i).name);
        if isdir(newPath)
            addpath(newPath);
            addSubPath(newPath)
        end
    end    
end
function path=EHY_path(path)
% path=EHY_path(path)
% Correct path for usage in either Linux or Windows
% path can be either a string or cell array of strings
%
% Example1: EHY_path('D:\folder\\script.m')
% returns on Windows:  'D:\folder\script.m'
% returns on Linux:    '/d/folder/script.m'
%
% created by Julien Groenenboom, September 2017
% Julien.Groenenboom@Deltares.nl

if ischar(path)
    path=EHY_path_WinLin(path);
elseif iscell(path)
    for iP=1:length(path)
        path{iP}=EHY_path_WinLin(path{iP});
    end
end

end

function path=EHY_path_WinLin(path)

if ispc % Windows

    % from /p/ to p:\
    if strcmp(path([1 3]),'//')
        path=[path(2) ':' path(3:end)];
    end
    % change '/' into '\'
    path=strrep(path,'/','\');
    
elseif isunix % Linux
    
    % from p:\ to /p/
    if strcmp(path(2),':')
        path=['/' lower(path(1)) path(3:end)];
    end
    % change '\' into '/'
    path=strrep(path,'\','/');
    
end

% remove double fileseps
deleteIndex=strfind(path,[filesep filesep]);
path(deleteIndex)='';
end

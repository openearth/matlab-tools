function fullWinPath=EHY_getFullWinPath(name_and_ext,pathstr)
%% fullWinPath=EHY_getFullWinPath(name_and_ext,pathstr)
%
% This function returns the full/aboslute windows path based 
% on the name+extension of a file and a path.
%
% Example1: 	fullWinPath=EHY_getFullWinPath('model.mdu','/p/123-name/runs/')
%               fullWinPath='p:\123-name\runs\model.mdu'
% Example2: 	fullWinPath=EHY_getFullWinPath('/p/123-name/runs/model.mdu')
%               fullWinPath='p:\123-name\runs\model.mdu'
% Example3: 	fullWinPath=EHY_getFullWinPath('/p/123-name/runs/model.mdu','/p/123-name/runs/')
%               fullWinPath='p:\123-name\runs\model.mdu'
%
% support function of the EHY_tools
% Julien Groenenboom - E: Julien.Groenenboom@deltares.nl

% from /p/ to p:/
if strcmp(name_and_ext([1 3]),'//')
    name_and_ext=[name_and_ext(2) ':' name_and_ext(3:end)];
end
if exist('pathstr','var') && strcmp(pathstr([1 3]),'//')
    pathstr=[pathstr(2) ':' pathstr(3:end)];
end

% pathstr+name > fullWinPath
if isempty(strfind(name_and_ext,':')) % if paths are given as in Example1
   fullWinPath=[pathstr filesep name_and_ext];
else % if paths are given as in Example2 or Example3
    fullWinPath=name_and_ext;
end





fullWinPath=strrep(fullWinPath,'/','\');
fullWinPath=strrep(fullWinPath,'\\','\');


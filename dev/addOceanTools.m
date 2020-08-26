function addOceanTools(defaultPath)
% add the ocsan Toolbox to your path
%
% addOceanTools(defaultPath)
%
% INPUT: defaultPath (optional).  Default  'S:\Commercial\Matlab_Software\oceanographic matlab tools\oceanNew';
%
if nargin  < 1
    defaultPath= 'S:\Commercial\Matlab_Software\oceanographic matlab tools\oceanNew';
end
if ~exist('adiabatt','file')
    thePath = pwd;
    cd(defaultPath) ;
    addpath(defaultPath);
    dirList  = Util.getSubDir(defaultPath);
    for i=1:length(dirList)
        addpath(dirList{i});
    end
    cd(thePath)
else
    disp('Ocean toolbox is already in the path');
end




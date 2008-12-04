function addpathfast(basepath)
%ADDPATHFAST   adds paths to yout matlab path really fast
%
% addpathfast(basepath)
%
% where basepath is the root of which all subdirectories will be added to your path.
%
% Is much faster than addpath(genpath(basepath)), because genpath uses too much java.
%
% See also: ADDPATH

if ispc
    [a b] = system(['dir /b /ad /s ' '"' basepath '"']); % "'s added to enable spaces in directory and filenames
else
    [a b] = system(['find ' basepath ' -type d']);
end
b = [basepath char(10) b];

%% Exclude the .svn directories from the path
s = strread(b, '%s', 'delimiter', char(10)); % read path as cell
% clear cells which contain [filesep '.svn']
s = s(cellfun('isempty', regexp(s, [filesep '.svn'])))'; % keep only paths not containing [filesep '.svn']
% create string with remaining paths
s = [s; repmat({pathsep}, size(s))];
newpath = [s{:}];
% add newpath to path
path(path, newpath);

%% EOF
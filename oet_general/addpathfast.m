function addpathfast(basepath)
%ADDPATHFAST   adds paths to yout matlab path really fast
%
% addpathfast(basepath)
%
% where basepath is the root of whcoh al, subdirectories will be added to your path.
%
% Is much faster than addpath(genpath(basepath)), because genpath uses too much java.
%
% See also: ADDPATH

  if ispc
      [a,b]=system(['dir /b /ad /s ' '"' basepath '"']); % "'s added to enable spaces in directory and filenames
   else
      [a,b]=system(['find ' basepath ' -type d']);
   end
   s = strrep(b, char(10), pathsep);
   path(path, s);

%% EOF
function addpathfast(basepath,varargin)
%ADDPATHFAST   adds paths to your matlab path fast
%
%   addpathfast(basepath,<keyword,value>)
%
% where basepath is the root of which all subdirectories will be 
% added to your path. In contrast to addpath(genpath(basepath)) 
% all <a href="subversion.tigris.org">Subversion</a> directories are excluded (.svn ).
%
% Is much faster than addpath(genpath(basepath)), because genpath 
% uses too much java.
%
% Thew following <keyword,value> pairs have been implemented;
% * patterns:  cell array with regular expression patterns to be excluded
%              default {[filesep,'.svn']}. (i.e. <a href="subversion.tigris.org">Subversion</a> directories)
%
% Example: to exclude all mexnc and (s)nctools related stuff too:
%
%   addpathfast(pwd,'patterns',{'.mexnc','.nctools',[filesep,'.svn']});
%
% See also: ADDPATH, REGEXP, OETSETTINGS

   OPT.patterns = {[filesep,'.svn']}; % case sensitive
   
   OPT = setProperty(OPT,varargin{:});

%% Find all subdirs in basepath
%  -------------------------------------------

   if ispc
       [a b] = system(['dir /b /ad /s ' '"' basepath '"']); % "'s added to enable spaces in directory and filenames
   else
       [a b] = system(['find ' basepath ' -type d']);
   end
   b = [basepath char(10) b];

%% Exclude the .svn directories from the path
%  -------------------------------------------

   s = strread(b, '%s', 'delimiter', char(10));  % read path as cell
   
   % clear cells which contain [filesep '.svn']

   for imask = 1:length(OPT.patterns)
   
   OPT.pattern = OPT.patterns{imask};

   s = s(cellfun('isempty', regexp(s, [OPT.pattern]))); % keep only paths not containing [filesep '.svn']

   end
   
   s = reshape(s,[1 length(s)]);

%% create string with remaining paths
%  -------------------------------------------
   s = [s; repmat({pathsep}, size(s))] ;
   newpath = [s{:}];
   % add newpath to path
   path(path, newpath);

%% EOF
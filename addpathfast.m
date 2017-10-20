function addpathfast(basepath,varargin)
%ADDPATHFAST   adds Matlab paths while allowing to exlude some patterns (notably .svn)
%
%   addpathfast(basepath,<keyword,value>)
%
% where basepath is the root of which all subdirectories will be 
% added to your path. In contrast to addpath(genpath(basepath)) 
% all <a href="subversion.tigris.org">Subversion</a> directories are excluded (.svn).
%
% Is much faster than addpath(genpath(basepath)), because genpath 
% uses too much java.
%
% The following <keyword,value> pairs have been implemented;
% * patterns:  cell array with regular expression patterns to be excluded
%              default {[filesep,'.svn']}. (i.e. <a href="subversion.tigris.org">Subversion</a> directories)
% * append:    add new path before (0) or after existing path (1, default)
%
% Example: to exclude all mexnc and (s)nctools related stuff too:
%
%   addpathfast(pwd,'patterns',{'.mexnc','.nctools',[filesep,'.svn']});
%
% See also: ADDPATH, REGEXP, OETSETTINGS

   OPT.patterns = {[filesep,'.svn']}; % case sensitive
   OPT.method   = 3; % 1 = via OS system call, 2 = Matlab (used to be slower but not any more), 3 = dir2
   OPT.append   = true; % add new path before or after existing path
   
   OPT = setproperty(OPT,varargin{:});
   
   if ~exist(basepath,'dir'); return; end;

%% Find all subdirs in basepath

   if OPT.method==1||OPT.method==2

      if OPT.method==1
      % via OS system call, was faster in older Matlab releases
         if ispc
             [a b] = system(['dir /b /ad /s ' '"' basepath '"']); % "'s added to enable spaces in directory and filenames
         else
             [a b] = system(['find ' basepath ' -type d']);
         end
         b = [basepath char(10) b];
         s = strread(b, '%s', 'delimiter', char(10));  % read path as cell
      elseif OPT.method==2
      % via matlab, faster in later releases
         b = genpath(basepath);
         s = strread(b, '%s',...
                     'delimiter', pathsep);  % read path as cell
      end
      
      if isempty(s)
          return
      end
   
%% Exclude the .svn directories from the path

      % clear cells which contain [filesep '.svn']

      for imask = 1:length(OPT.patterns)
      
      OPT.pattern = OPT.patterns{imask};

      s = s(cellfun('isempty', regexp(s, [OPT.pattern]))); % keep only paths not containing [filesep '.svn']

      end
      
      s = reshape(s,[1 length(s)]);

%% create string with remaining paths

      s = [s; repmat({pathsep}, size(s))] ;
      newpath = [s{:}];

   elseif OPT.method==3
   
% via dir2, faster

      % do a dir commando that excludes all .svn and private directories, and does not include any files
%     dirs    = dir2(basepath,'dir_excl','^\+|^@|^private$|^\.svn$|^\.','file_incl','');
      % Added deprecated folder to the excluse list
      dirs    = dir2(basepath,'dir_excl','^\+|^@|^private$|^\.svn$|^\.|^deprecated$','file_incl','');
      
      if ~isempty(dirs)
          % concatenate the path and the directory names
          dirs    = strcat({dirs.pathname}, {dirs.name}, filesep, ';')';
          newpath = strcat(dirs{:});
      else
          newpath = [];
      end
   end

%% add newpath to path

   if   OPT.append
       path(path, newpath);
   else
       path(newpath, path);
   end

%% EOF
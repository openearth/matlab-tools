function varargout = findAllFiles2(varargin)
%FINDALLFILES   get list of all files in a directory tree.
%
%    files          = findAllFiles(basepath,<keyword,value>)
%   [files,folders] = findAllFiles(basepath,<keyword,value>)
%
% returns cellstr with a list of all files in a directory tree,
% and optionally also of all unique folder names.
% The following <keyword,value> pairs have been implemented.
%
% * pattern_excl (default '.svn')
% * pattern_incl (default '*')
% * basepath     (default '')
% * recursive    (default 1):
%   return relative filenames inside basepath only if 0,
%   returns absulote filenames if 1
%
% Notice that the pattern_excl paths are filtered with regexp. The syntax
% is slightly different. Example: '*.svn' versus '.\.svn' see help regexp
% for more
%
% For the <keyword,value> pairs and their defaults call
%
%    OPT = findAllFiles()
%
%See also: DIR, OPENDAP_CATALOG, ADDPATHFAST, REGEXP, DIRLISTING

%% settings
%  defaults

OPT.pattern_excl = {'.svn'}; % pattern to exclude
OPT.pattern_incl = '*';       % pattern to include
OPT.basepath     = '';        % indicate basedpath to start looking
OPT.recursive    = 1;         % indicate whether or not the request is recursive

if odd(nargin)
    OPT.basepath = varargin{1};
    nextarg = 2;
else
    nextarg = 1;
end

% overrule default settings by property pairs, given in varargin

OPT = setproperty(OPT, varargin{nextarg:end});

if nargin==0;varargout = {OPT};return;end

if ~exist(OPT.basepath,'dir')
    error(['directory ''',OPT.basepath,''' does not exist'])
end


% crop last fileseparator from the basepath
if strcmp(OPT.basepath(end),filesep)
    OPT.basepath(end) = [];
end

% find filenames
filenames = files_in_dir(OPT.basepath,'',[OPT.pattern_excl {'..','.'}]);

% prepend basepath
filenames = cellstr([repmat([OPT.basepath filesep] ,length(filenames),1),char(filenames)]);

% check for pattern_incl 
filenames = filenames(~cellfun('isempty', regexp(filenames, [OPT.pattern_incl],'once')));
%% return cell with resulting files (including pathnames)

if nargout==1
    varargout = {filenames};
else
    
    foldernames = filenames; % preallocate
    
    for i=1:length(foldernames)
        if ~isdir(foldernames{i})
            foldernames{i} = fileparts(foldernames{i});
        end
    end
    foldernames = unique(foldernames);
    
    varargout = {filenames,foldernames};
end


function filenames = files_in_dir(basepath,subdirpath,pattern_excl)
basepath = [basepath filesep subdirpath];
fns = dir(basepath);
ignore = false(size(fns));
for ii = 1:length(fns)
    if any(strcmp(fns(ii).name,pattern_excl))
        ignore(ii) = true;
    end
end
fns(ignore) = [];
dirs = cell2mat({fns.isdir});
filenames = {fns(~dirs).name}';
for ii = find(dirs)
    filenames = [filenames; files_in_dir(basepath(1:end-1),[fns(ii).name filesep],pattern_excl)];
end
filenames = cellstr([repmat(subdirpath,length(filenames),1),char(filenames)]);

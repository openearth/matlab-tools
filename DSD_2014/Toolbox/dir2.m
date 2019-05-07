function D = dir2(varargin)
%dir2  A more powerfull version of DIR
%
% dir2 returns a structure containing all files and folders in a
% directory tree. Users can define filters to in or exclude certain cases.
% The function is similar to findAllFiles and dir, and tries to combine
% best of both. The main advantages are:
%
% Compared to dir()
%   * Operates recursively on subfolders to specified depth
%   * Returns folder sizes
%   * Allows advanced filtering with regular expressions
%   * Filters out directories named '.' and '..'
%
% Compared to findAllFiles()
%   * Much faster
%   * Returns filename, pathname, filesize etc
%    
% The one drawback is that the use of regular expressions is not allways
% that easy, for some tips see below.
%
%   Syntax:
%     There are three ways to call this function: 
%
%     D = dir2 
%     D = dir2(<keyword,value>)
%     D = dir2(basepath,<keyword,value>)
%
%   Input:
%     The following <keyword,value> pairs have been implemented.
% 
%     * basepath     directory to operate on
%                    defaults to pwd, current working directory
% 
%     * dir_excl     string containing regular expression. Any folder
%                    (including that folders children) that matches the 
%                    espression is excluded from the results. 
%                    defaults to '.svn$', exclude svn directories
% 
%     * file_incl    string containing regular expression. Only filenames
%                    that match the expression are included in the
%                    results. 
%                    defaults to '.*', include all files
%
%     * file_excl    string containing regular expression. All filenames
%                    that match the expression are excluded from the
%                    results. 
%                    defaults to '', exclode no files
% 
%     * depth        maximum directory depth to search on. Set to 0 for a non 
%                    recursive query, and to infinitie to search all subfolders
%                    in subfolders etc.
%                    defaults to inf
%
%     * no_dirs      only list files, no directories, default is false
%
%
%   Output:
%   D        = a struct array with the following fields: 
%       name     -- Filename
%       date     -- Modification date
%       bytes    -- Number of bytes allocated to the file
%       isdir    -- 1 if name is a directory and 0 if not
%       datenum  -- Modification date as a MATLAB serial date number.
%                   This value is locale-dependent.
%       pathname -- path to the file, including trailing fileseperator, so
%                   that [D.pathname D.name] is always the full file path
%
%   Examples
%
%     % concatenating pathname and filename to fullfilenames
%     D               = dir2;
%     files           = find(~[D.isdir]);
%     fullfilenames   = strcat({D(files).pathname}, {D(files).name})';
%     disp(fullfilenames);
% 
%     % find the largest m file in OpenEarthTools
%     D               = dir2(oetroot,'file_incl','\.m$');
%     files           = find(~[D.isdir]);
%     [value,index]   = max([D(files).bytes]);
%     fprintf(1,'largest file:  %s\nsize in bytes: %d\n',...
%         fullfile(D(files(index)).pathname,...
%         D(files(index)).name),...
%         D(files(index)).bytes);
% 
%     % find the newest file in OpenEarthTools
%     D               = dir2(oetroot);
%     files           = find(~[D.isdir]);
%     [value,index]   = max([D(files).datenum]);
%     fprintf(1,'newest file:    %s\nage in seconds: %0.0f\n',...
%         fullfile(D(files(index)).pathname,...
%         D(files(index)).name),...
%         (now - D(files(index)).datenum)*24*3600);
%     
%     % find m files in OpenEarthTools that appear to have something to do with
%     % netcdf
%     D               = dir2(oetroot,'file_incl','(nc[^a-zA-Z]|[^a-zA-Z]nc|netcdf).*\.m$');
%     files           = find(~[D.isdir]);
%     fullfilenames   = strcat({D(files).pathname}, {D(files).name})';
%     disp(fullfilenames);
%    
% Some notes on regexp
%    * '^' and '$' function as anchors to the left of the first charachter and to
%      the right of the last charachter repectively. 
%    * multiple conditions can be specified with '|'
%    * some characters, such as '.' are modifiers. To match that charachter,
%     add a '\'.
% 
%   Example values for file_incl: 
%   '\.m$'         finds files that end with '.m'
%   '\.(png|jpg)$' finds files that end with '.jpg' or '.png'
%   '\.[^\.]{5}$'  finds files with 5 charachter extensions
%   'time.*\.m$'   finds .m files time in the name
% 
%   These expressions can be very powerfull and complicated, like:
%   '(nc[^a-zA-Z]|[^a-zA-Z]nc|netcdf).*\.m$'
%   This finds .m files that have something to do with netcdf
%   For more information, see 'help regexp'.     
%
%   See also: DIR, FINDALLFILES, DIR, DIRLISTING


%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Van Oord Dredging and Marine Contractors BV
%       Thijs Damsma
%
%       tda@vanoord.com
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 28 Jan 2011
% Created with Matlab version: 7.12.0.62 (R2011a)

% $Id: dir2.m 4147 2014-10-31 10:12:42Z bieman $
% $Date: 2014-10-31 11:12:42 +0100 (ven, 31 ott 2014) $
% $Author: bieman $
% $Revision: 4147 $
% $HeadURL: https://svn.oss.deltares.nl/repos/xbeach/Courses/DSD_2014/Toolbox/dir2.m $
% $Keywords: $

%% settings
%  defaults

OPT.basepath         = pwd;      % indicate basedpath to start looking
OPT.dir_incl         = '.*';     % regex style pattern to include
OPT.dir_excl         = '.svn$';  % regex style pattern to exclude
OPT.file_incl        = '.*';     % regex style pattern to include
OPT.file_excl        = '';       % regex style pattern to excldue
OPT.case_sensitive   = true;     % _incl and _excl functions can be set to case insensitive
OPT.depth            = inf;      % indicate recursion depth (0 is only this folder)
OPT.no_dirs          = false;    % only list files, not directories

if mod(nargin,2)==1
    OPT.basepath = varargin{1};
    nextarg = 2;
else
    nextarg = 1;
end

OPT.basepath = relativeToabsolutePath(OPT.basepath);

%% overrule default settings by property pairs, given in varargin
OPT = setproperty(OPT, varargin(nextarg:end));

%% set regexpFcn
if OPT.case_sensitive
    regexpFcn = @(varargin) regexp (varargin{:});
else
    regexpFcn = @(varargin) regexpi(varargin{:});
end

%% crop last fileseparator from the basepath
if strcmp(OPT.basepath(end),filesep)
    OPT.basepath(end) = [];
end

if exist(OPT.basepath,'dir') == 7
    method = 'folder';
else
    if exist(OPT.basepath,'file')
        method = 'file';
    else
        error(['directory ''',OPT.basepath,''' does not exist'])
    end
end

%% find filenames
%  pattern_excl is appended with two criteria that exclude '..' and '.' from
%  the dir inquiry. See 'help regexp' for explanation.
newD = dir_in_subdir(OPT.basepath,...
    OPT.dir_incl,...
    [OPT.dir_excl '|^\.{1,2}$'],...
    OPT.file_incl,...
    OPT.file_excl,...
    OPT.depth,regexpFcn);
if isempty(newD)
    % add the field pathname to the empty struct
    newD(1).pathname = '';
    newD(1) = [];
end

%% add basepath
% split basepath in path and folder name
[a,b,c] = fileparts(OPT.basepath);
if ~strcmp(a(end),filesep)
    a = [a filesep];
end

switch method
    case 'folder'
        % query the folder
        D     = dir(a);
        
        % find the folder from the basepath
        D     = D([D.isdir]);
        D     = D(strcmpi({D.name},[b c]));
    case 'file'
        D     = dir(OPT.basepath);
end

% add field datenum for old matlab versions
if ~isfield(D,'datenum')
    D.datenum = deal(nan);
end

D(1).pathname = a;
switch method
    case 'folder'
        D(1).isdir    = true;
        D(1).bytes    = sum([newD(~[newD.isdir]).bytes]);
        % concatenate D
        D = [D; newD];
    case 'file'
        D(1).isdir    = false;
end

% remove directories from output
if OPT.no_dirs
    D([D.isdir]) = [];
end
%EOF

function D = dir_in_subdir(basepath,dir_incl,dir_excl,file_incl,file_excl,depth,regexpFcn)

%% do a regular dir query
D = dir([basepath filesep]);

% add field datenum for old matlab versions
if ~isfield(D,'datenum')
    [D.datenum] = deal(nan);
end

%% fill empty fields of D with NaN, space or false
[D(cellfun('isempty',{D.name    })).name    ] = deal(' ');
[D(cellfun('isempty',{D.date    })).date    ] = deal(nan);
[D(cellfun('isempty',{D.bytes   })).bytes   ] = deal(nan);
[D(cellfun('isempty',{D.isdir   })).isdir   ] = deal(false(1));
[D(cellfun('isempty',{D.datenum })).datenum ] = deal(nan);

%% exclude directories that match 'dir_excl' or do not match 'dir_incl' from D
dirs            = find([D.isdir]);

dirs_to_include = false(size(dirs));
dirs_to_exclude = false(size(dirs));

dirs_to_include(~cellfun('isempty',regexpFcn({D(dirs).name},dir_incl,'once'))) = true;
dirs_to_exclude(~cellfun('isempty',regexpFcn({D(dirs).name},dir_excl,'once'))) = true;

D(dirs(~dirs_to_include | dirs_to_exclude)) = [];

%% exclude files that match 'file_excl' or do not match 'file_incl' from D
files            = find(~[D.isdir]);

files_to_include = false(size(files));
files_to_exclude = false(size(files));

files_to_include(~cellfun('isempty',regexpFcn({D(files).name},file_incl,'once'))) = true;
files_to_exclude(~cellfun('isempty',regexpFcn({D(files).name},file_excl,'once'))) = true;

D(files(~files_to_include | files_to_exclude)) = [];

%% return if D is empty
if isempty(D)
    return
end

%% add field pathname
dirs         = [D.isdir];
[D.pathname] = deal([basepath filesep]);

if depth>0
    % loop all directories, and add their contents
    for ii = find(dirs)
        newD = dir_in_subdir(...
            [basepath filesep D(ii).name], ...   % basepath:  construct from basepath and directory name
            dir_incl,...                         % dir_incl:  keep as is
            dir_excl,...                         % dir_excl:  keep as is
            file_incl,...                        % file_incl: keep as is
            file_excl,...                        % file_excl: keep as is
            depth-1,...                          % depth:     subtract 1
            regexpFcn);                          % regexpFcn: keep as is
        if ~isempty(newD)
            D(ii).bytes = sum([newD(~[newD.isdir]).bytes]);
            D = [D; newD]; %#ok<AGROW>
        else
            D(ii).bytes = 0;
        end
    end
end

function s = relativeToabsolutePath(s)
% this subfunction converts relative file paths to absolute file paths. The
% function is designed to make dir2 mimic the output of dir as much as
% possible

s = fullfile(s,'');

if isempty(s)
    s = pwd;
elseif s(1) == filesep
    % then basepath is relative unless second entry of s is also a filesep
    % indicating a network path
    if length(s)>1
        if s(2) == filesep
            % it is already an absolute networkpath
        else
            tmp = pwd;
            % Only on windows assume that the first two letters of tmp are
            % the drive letter
            if ispc
                s  = [tmp(1:2) s];
            end
        end
    else
        tmp = pwd;
        
        if ispc
        s   = [tmp(1:2) s];
        end
    end
elseif strcmp(s,'.')
    s   = pwd;
elseif strcmp(s,'..')
    s   = [pwd filesep s];
else
    if length(s) >= 2
        if strcmp(s(2),':')
            % it is already an absolute path
        else
            s   = [pwd filesep s];
        end
    else
        s   = [pwd filesep s];
    end
end

% append filesep
if ~strcmp(s(end),filesep)
    s = [s filesep];
end

% remove 'up one folder' statements ('../')
while 1
    a = strfind(s,filesep);
    b = strfind(s,[filesep '..' filesep]);
    
    if isempty(b)
        return
    end
    c = find(ismember(a,b));
    if c(1)==1;
        s = s([1:a(c(1)) a(c(1)+1)+1 : end]);
    else
        s = s([1:a(c(1)-1) a(c(1)+1)+1 : end]);
    end
end


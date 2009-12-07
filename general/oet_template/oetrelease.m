function [zipfilename files targetdir] = oetrelease(varargin)
%OETRELEASE  create release in new folder and zipfile
%
%   Function to create a release of specific folders (including subfolders)
%   and files. If the files in the selection are dependent on other files
%   in OpenEarthTools, these are also included in the release. The release
%   is created as separate folder and as zipfile.
%
%   Syntax:
%   [zipfilename files targetdir] = oetrelease(varargin)
%
%   Input:
%   varargin    =
%
%   Output:
%   zipfilename =
%   files       =
%   targetdir   =
%
%   Example
%   oetrelease
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
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
% Created: 04 Dec 2009
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
OPT = struct(...
    'targetdir', fullfile(cd, ['release_' datestr(now, 'ddmmmyyyy')]),...
    'zipfilename', tempname,...
    'folders', cd,...
    'files', 'oetsettings',...
    'omitextensions', {{'.asv' '.m~'}});

OPT = setProperty(OPT, varargin{:});

%% gather all files of the selected folders
if ischar(OPT.folders)
    OPT.folders = {OPT.folders};
end

files = {};
for i = 1:length(OPT.folders)
    [dirs dircont tempfiles] = dirlisting(OPT.folders{i}, 'svn');
    files(end+1:end+length(tempfiles)) = tempfiles;
end

%% gather all other selected files
if ischar(OPT.files)
    OPT.files = {OPT.files};
end

for i = 1:length(OPT.files)
    if ~ismember(which(OPT.files{i}), files)
        files{end+1} = which(OPT.files{i});
    end
end

%% gather all related files
i = 0;
while i < length(files)
    i = i + 1;
    [pathstr filename fileext] = fileparts(files{i});
    if strcmp(fileext, '.m')
        tempfiles = getCalls(files{i}, openearthtoolsroot, 'quiet');
        tempid = ~ismember(tempfiles, files);
        files(end+1:end+sum(tempid)) = tempfiles(tempid);
    end
end

%% filter for omit-extensions
if ischar(OPT.omitextensions)
    OPT.omitextensions = {OPT.omitextensions};
end
for i = 1:length(OPT.omitextensions)
    omitid = ~cellfun(@isempty, strfind(files, OPT.omitextensions{i}));
    files(omitid) = [];
end

%% copy all selected files to separate folder
for i = 1:length(files)
    mkpath(fileparts(files{i}))
    destinationfile = strrep(files{i}, openearthtoolsroot, [OPT.targetdir filesep]);
    mkpath(fileparts(destinationfile))
    if ~exist(destinationfile, 'file')
        copyfile(files{i}, destinationfile)
    end
end

%% create zipfile of newly created folder
zip(OPT.zipfilename, OPT.targetdir, openearthtoolsroot)

%% prepare output
[zipfilename targetdir] = deal(OPT.zipfilename, OPT.targetdir);
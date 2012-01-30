function ddb_copyAllFilesToDataFolder(inipath, ddbdir, additionalToolboxDir)
%DDB_COPYALLFILESTODATAFOLDER  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_copyAllFilesToDataFolder(inipath, ddbdir, additionalToolboxDir)
%
%   Input:
%   inipath              =
%   ddbdir               =
%   additionalToolboxDir =
%
%
%
%
%   Example
%   ddb_copyAllFilesToDataFolder
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
% Create new folder
disp('Copying data file from repository ...');
mkdir(ddbdir);
mkdir([ddbdir 'bathymetry']);
copyfiles([inipath 'data' filesep 'bathymetry'],[ddbdir 'bathymetry']);
mkdir([ddbdir 'imagery']);
mkdir([ddbdir 'shorelines']);
copyfiles([inipath 'data' filesep 'shorelines'],[ddbdir 'shorelines']);
mkdir([ddbdir 'tidemodels']);
copyfiles([inipath 'data' filesep 'tidemodels'],[ddbdir 'tidemodels']);

%  Do the same for the tropical cyclone directory structure, but don't
%  perform a copyfiles() call, as there should be no files to copy.
mkdir([ddbdir 'tropicalcyclone']);
mkdir([ddbdir 'tropicalcyclone' filesep 'JTWC']);  % JTWC warning files subdir.
mkdir([ddbdir 'tropicalcyclone' filesep 'NHC']);   % NHC warning files subdir.

mkdir([ddbdir 'toolboxes']);
mkdir([ddbdir 'supertrans']);
epf=which('EPSG.mat');
if ~isempty(epf)
    copyfile(epf,[ddbdir 'supertrans']);
end
epf=which('EPSG_ud.mat');
if ~isempty(epf)
    copyfile(epf,[ddbdir 'supertrans']);
end

% Find toolboxes and copy all files in data folders
flist=dir([inipath 'toolboxes']);
for i=1:length(flist)
    if isdir([inipath 'toolboxes' filesep flist(i).name])
        switch lower(flist(i).name)
            case{'.','..','.svn'}
            otherwise
                if isdir([inipath 'toolboxes' filesep flist(i).name filesep 'data'])
                    mkdir([ddbdir 'toolboxes' filesep flist(i).name]);
                    copyfiles([inipath 'toolboxes' filesep flist(i).name filesep 'data'],[ddbdir 'toolboxes' filesep flist(i).name]);
                end
        end
    end
end

% Find ADDITIONAL toolboxes and copy all files in data folders
if ~isempty(additionalToolboxDir)
    flist=dir(additionalToolboxDir);
    for i=1:length(flist)
        if isdir([additionalToolboxDir filesep flist(i).name])
            switch lower(flist(i).name)
                case{'.','..','.svn'}
                otherwise
                    if isdir([additionalToolboxDir filesep flist(i).name filesep 'data'])
                        mkdir([ddbdir 'toolboxes' filesep flist(i).name]);
                        copyfiles([additionalToolboxDir filesep flist(i).name filesep 'data'],[ddbdir 'toolboxes' filesep flist(i).name]);
                    end
            end
        end
    end
end


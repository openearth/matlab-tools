function [handles ok] = ddb_getDirectories(handles)
%DDB_GETDIRECTORIES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [handles ok] = ddb_getDirectories(handles)
%
%   Input:
%   handles =
%
%   Output:
%   handles =
%   ok      =
%
%   Example
%   ddb_getDirectories
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

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%% Find DDB directories

ok=1;

handles.workingDirectory=pwd;

if isdeployed
    
    handles.settingsDir=[ctfroot filesep 'ddbsettings' filesep];
    
    [status, result] = system('path');
    exeDir = char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'));
    ddbdir=[fileparts(exeDir) filesep 'data' filesep];
    additionalToolboxDir=[];
    
else
    
    inipath=[fileparts(fileparts(fileparts(which('DelftDashBoard')))) filesep];
    
    % check existence of ini file DelftDashBoard.ini
    inifile=[inipath 'DelftDashBoard.ini'];
    
    if ~exist(inifile,'file')
        
        txt='Select folder (preferably named "delftdashboard") for data storage (e.g. d:\delftdashboard). You may need to create a new folder. Folder must be outside OET repository!';
        dirname = uigetdir(inipath,txt);
        
        if isnumeric(dirname)
            dirname='';
        end
        
        if isempty(dirname)
            error('Local data directory not found, check reference in ini-file!');
        end
        
        datadir=[dirname filesep 'data'];
        
        disp('Making delftdashboard.ini file ...');
        
        fid=fopen([inipath 'delftdashboard.ini'],'wt');
        fprintf(fid,'%s\n','% Data directories');
        fprintf(fid,'%s\n',['DataDir=' datadir filesep]);
        fclose(fid);
        
    end
    
    handles.settingsDir=[inipath 'settings' filesep];
    ddbdir=getINIValue(inifile,'DataDir');
    if exist(ddbdir)==7 % absolute path
        ddbdir = [cd(cd(ddbdir)) filesep];
    elseif exist([fileparts(inifile) filesep ddbdir])==7 % relative path
        ddbdir = [cd(cd([fileparts(inifile) filesep ddbdir])) filesep];
    else
        %         error(['Local data directory ''' ddbdir ''' not found, check reference in ini-file!']);
    end
    
    try
        additionalToolboxDir=getINIValue(inifile,'AdditionalToolboxDir');
    catch
        additionalToolboxDir=[];
    end
    
    if ~isdir(ddbdir)
        
        % Usually done the first time ddb is run. Files are copied from
        % repository to DDB data folder
        
        ddb_copyAllFilesToDataFolder(inipath,ddbdir,additionalToolboxDir);
        
    end
    
end

handles.bathyDir=[ddbdir 'bathymetry' filesep];
handles.tideDir=[ddbdir 'tidemodels' filesep];
handles.toolBoxDir=[ddbdir 'toolboxes' filesep];
handles.additionalToolboxDir=additionalToolboxDir;
handles.shorelineDir=[ddbdir 'shorelines' filesep];
handles.satelliteDir=[ddbdir 'imagery' filesep];

%if isdeployed
    handles.superTransDir=[ddbdir 'supertrans' filesep];
%else
%    dr=fileparts(which('EPSG.mat'));
%    handles.superTransDir=[dr filesep];
%end



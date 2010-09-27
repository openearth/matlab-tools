function DelftDashBoard
%DELFTDASHBOARD.
%
%   Compile with ddcompile
%
%   See also MUPPET, DETRAN

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <COMPANY>
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
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
% Created: 14 Sep 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%

% curdir = pwd;
% cd(fileparts(which('ddsettings.m')));

% get revision number
Revision = '$Revision$';
eval([strrep(Revision(Revision~='$'),':','=') ';']);

handles.DelftDashBoardVersion=['1.00.' num2str(Revision)];
handles.MatlabVersion=version;

% if isdeployed
%     jardir=[ctfroot filesep 'checkout' filesep 'OpenEarthTools' filesep 'trunk' filesep 'matlab' filesep 'io' filesep 'netcdf' filesep];
%     disp([jardir 'netcdfAll-4.1.jar'])
%     java2add         = path2os([jardir 'netcdfAll-4.1.jar']); % 'netcdfAll-4.1.jar'; % same functionality
% %     dynjavaclasspath = path2os(javaclasspath);
% %     indices          = strfind(javaclasspath,java2add);
% %    javaaddpath (java2add)
%     javaaddpath (jardir);
%     setpref ('SNCTOOLS','USE_JAVA'   , 1); % This requires SNCTOOLS 2.4.8 or better
%     % keep snctools default
%     setpref ('SNCTOOLS','PRESERVE_FVD',0); % 0: backwards compatibility and consistent with ncBrowse
%     % 1: We do not want to transpose matrices because:
%     %    (i)  we have some LARGE datasets and need a performance boost
%     %    (ii) some use the netCDF API directly which does not do this.
%     %    May break previous work though ...
% end

% Add java paths for snc tools
if isdeployed
    pth=[ctfroot filesep 'checkout' filesep 'OpenEarthTools' filesep 'trunk' filesep 'matlab' filesep 'io' filesep 'netcdf' filesep 'toolsUI-4.1.jar'];
    disp(['SNC jar file is : ' pth]);
    javaaddpath(pth);
    setpref ('SNCTOOLS','USE_JAVA'   , 1); % This requires SNCTOOLS 2.4.8 or better
    setpref ('SNCTOOLS','PRESERVE_FVD',0); % 0: backwards compatibility and consistent with ncBrowse
end

disp(['Delft DashBoard v' handles.DelftDashBoardVersion]);
disp(['Matlab v' version]);

disp('Finding directories ...');
[handles,ok]=ddb_getDirectories(handles);
if ~ok
    return
end

warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

% Open Splash Screen
frame=splash([handles.SettingsDir 'icons' filesep 'DelftDashBoard.jpg'],30);

handles=ddb_initialize(handles,'startup');
setHandles(handles);

% Maximize Figure
maximize(handles.GUIHandles.MainWindow);

% set(gcf,'Renderer','Painters');

% Make Figure Visible
set(handles.GUIHandles.MainWindow,'Visible','on');

% Close Splash Screen
frame.hide;

% cd(curdir);

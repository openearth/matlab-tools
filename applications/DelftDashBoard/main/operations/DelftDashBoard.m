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
%       maarten.vanormondt@deltares.nl
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

% get revision number
Revision = '$Revision$';
eval([strrep(Revision(Revision~='$'),':','=') ';']);

handles.DelftDashBoardVersion=['1.00.' num2str(Revision)];
handles.MatlabVersion=version;

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

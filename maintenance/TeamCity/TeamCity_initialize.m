function TeamCity_initialize(varargin)
%TEAMCITY_INITIALIZE  Initializes oetsettings and wlsettings.
%
%   More detailed description goes here.
%
%
%   See also TeamCity_runtests TeamCity_makedocumentation

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
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
% Created: 03 Dec 2010
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Locate oetroot and add maintenance toolbox
oetdir = strrep(fileparts(mfilename('fullpath')),'maintenance\TeamCity','');
addpath(oetdir);
addpath(genpath(fullfile(oetdir,'maintenance')));
TeamCity.running(true);

%% Run Oetsettings
TeamCity.postmessage('progressStart','Run Oetsettings');
oetsettings;
TeamCity.postmessage('progressMessage','Oetsettings enabled');
TeamCity.postmessage('progressFinish','Run Oetsettings');

%% Try to run wlsettings
TeamCity.postmessage('progressStart','Run wlsettings');
try
    wlsettings;
    TeamCity.postmessage('progressMessage','wlsettings enabled');
catch
    % No problem, try continuing without wlsettings
    TeamCity.postmessage('progressMessage','Could not load wlsettings');
end
TeamCity.postmessage('progressFinish','Run wlsettings');
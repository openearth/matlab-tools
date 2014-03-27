function XBeachProbabilisticRun(ModelOutputDir, varargin)
%XBEACHPROBABILISTICRUN  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = XBeachProbabilisticRun(varargin)
%
%   Input: For <keyword,value> pairs call XBeachProbabilisticRun() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   XBeachProbabilisticRun
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Joost den Bieman
%
%       joost.denbieman@deltares.nl
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
% Created: 16 Oct 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Settings
OPT = struct(...
    'Ph',               [],         ...
    'PHm0',             [],         ...
    'PTp',              [],         ...
    'D50',              225e-6,     ...
    'JarkusID',         [],         ...
    'Station1',         [],         ...
    'Station2',         [],         ...
    'MaxErosionPoint',  [],         ...
    'ModelSetupDir',    '',         ...
    'ModelRunDir',      '',         ...
    'ExecutablePath',   '',         ...
    'tstop',            5*3600,     ...
    'RunRemote',        false,      ...
    'NrNodes',          1,          ...
    'QueueType',        'normal',   ...
    'sshUser',          [],         ...
    'sshPassword',      [],         ...
    'LSFChecker',       []);

OPT = setproperty(OPT, varargin{:});

%% Load initial model setup

xbModel = xb_read_input(fullfile(OPT.ModelSetupDir, 'params.txt'));

%% Calculate unspecified variables

[Lambda, ~] = getLambda_2Stations(OPT.Station1, OPT.Station2, 'JarkusId', OPT.JarkusID);

[h, h1, h2, Station1, Station2, Lambda] = getWl_2Stations(norm_cdf(OPT.Ph, 0, 1), Lambda, OPT.Station1, OPT.Station2);
[Hs, Hs1, Hs2, Station1, Station2]      = getHs_2Stations(OPT.PHm0, Lambda, h1, h2, Station1, Station2);
[Tp, Tp1, Tp2, Station1, Station2]      = getTp_2Stations(OPT.PTp, Lambda, Hs1, Hs2, Station1, Station2);

%% Change stochastic variables in XBeach model

xbModel = xs_set(xbModel, 'zs0file.tide', [h -20; h -20]);
xbModel = xs_set(xbModel, 'bcfile.Hm0', Hs);
xbModel = xs_set(xbModel, 'bcfile.Tp', Tp);
xbModel = xs_set(xbModel, 'bcfile.fp', 1/Tp);
xbModel = xs_set(xbModel, 'D50', OPT.D50);
xbModel = xs_set(xbModel, 'tstop', OPT.tstop);

%% Run model

ModelOutputDirLinux = path2os(ModelOutputDir);
ModelOutputDirLinux = ['/' strrep(ModelOutputDirLinux,':','')];

mkdir(ModelOutputDir)
if OPT.RunRemote
    [~, FolderName, ~]  = fileparts(ModelOutputDir);
    xb_run_remote(xbModel, 'nodes', OPT.NrNodes, 'queuetype', OPT.QueueType, ...
        'netcdf', true, 'ssh_user', OPT.sshUser, 'ssh_pass', OPT.sshPassword, ...
        'path_local', ModelOutputDir, 'path_remote', ModelOutputDirLinux, ...
        'mpitype', 'OPENMPI', 'name', FolderName)
else
    xb_run(xbModel, 'binary', OPT.ExecutablePath, 'netcdf', true, ...
        'path', ModelOutputDir, 'name', '', 'copy', false);
end
function z = XBeachLimitStateFunction(varargin)
%XBeachLimitStateFunction  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   z = XBeachLimitStateFunction(varargin)
%
%   Input: For <keyword,value> pairs call XBeachLimitStateFunction() without arguments.
%   varargin  =
%
%   Output:
%   z =
%
%   Example
%   Untitled
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
    'h', [],...
    'Hm0', [], ...
    'Tp', [],...
    'D50', 225e-6,...
    'tstop', 1800, ...
    'ModelSetupDir', 'd:\bieman\Documents\ADIS_XB_testing\ModelSetup\test1',...
    'ModelRunDir', 'd:\bieman\Documents\ADIS_XB_testing\TestRuns',...
    'sshUser', [], ...
    'sshPassword', [], ...
    'LSFChecker', []);

OPT = setproperty(OPT, varargin{:});

%% Check whether run already exists

FolderName          = ['h' num2str(OPT.h) '_Hm0' num2str(OPT.Hm0)];
ModelOutputDir      = fullfile(OPT.ModelRunDir, FolderName);

% only for debugging! Remove when done
if isdir(ModelOutputDir)
    rmdir(ModelOutputDir,'s')
end

if ~isdir(ModelOutputDir)
    %% Setup & run model
    XBeachProbabilisticRun(varargin);
    OPT.LSFChecker.CheckProgress(ModelOutputDir);
end

%% Dummy Limit State Function

MaxWetPoint = 1380; 
wetz        = nc_varget(fullfile(ModelOutputDir,'xboutput.nc'), 'wetz');
xGrid       = load(fullfile(ModelOutputDir,'x.grd'));
WetPoint    = xGrid(find(squeeze(wetz(end,:,:)) == 1,1,'last'));
z           = MaxWetPoint - WetPoint;
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
    'Ph', [],...
    'PHm0', [], ...
    'PTp', [],...
    'D50', 225e-6,...
    'tstop', 5*3600, ...
    'MaxErosionPoint', 75, ...
    'ModelSetupDir', 'd:\ADIS_XB_testing\ModelSetup\ReferenceProfile',...
    'ModelRunDir', 'd:\ADIS_XB_testing\TestRuns',...
    'sshUser', [], ...
    'sshPassword', [], ...
    'LSFChecker', []);

OPT = setproperty(OPT, varargin{:});

%% Check whether run already exists

FolderName          = ['h' num2str(OPT.Ph) '_H' num2str(OPT.PHm0) '_Tp' num2str(OPT.PTp)];
ModelOutputDir      = fullfile(OPT.ModelRunDir, FolderName);

if ~isdir(ModelOutputDir)
    %% Setup & run model
    XBeachProbabilisticRun(varargin);
    OPT.LSFChecker.CheckProgress(ModelOutputDir);
else
    OPT.LSFChecker.CheckProgress(ModelOutputDir);
end

%% Dummy Limit State Function

MaxErosionPoint = OPT.MaxErosionPoint;

zsize       = nc_varsize(fullfile(ModelOutputDir,'xboutput.nc'),'zb');
xi          = nc_varget(fullfile(ModelOutputDir,'xboutput.nc'), 'globalx');
zi          = nc_varget(fullfile(ModelOutputDir,'xboutput.nc'), 'zb',[0 0 0], [1 -1 -1]);
xe          = xi;
ze          = nc_varget(fullfile(ModelOutputDir,'xboutput.nc'), 'zb',[zsize(1)-1 0 0], [1 -1 -1]);
tide        = load(fullfile(ModelOutputDir,'tide.txt'));

if tide(1,2) > max(zi)
    ErosionPoint    = max(xi);
else
    [TargetVolume, ~, ~] = getVolume('x',xi,'z',zi,'x2',xe,'z2',ze,'LowerBoundary',tide(1,2));
    ErosionResult = getAdditionalErosion(xi, zi, ...
        'TargetVolume', TargetVolume, ...
        'x0min', min(xi), ...
        'x0max', max(findCrossings(xi,zi,[min(xi),max(xi)],ones(1,2)*tide(1,2))), ...
        'zmin',tide(1,2));
    
    if ~isempty(ErosionResult.VTVinfo.Xr)
        ErosionPoint    = ErosionResult.VTVinfo.Xr;
    else
        ErosionPoint    = min(findCrossings(xi,zi,[min(xi),max(xi)],ones(1,2)*tide(1,2)));
    end
end

z           = MaxErosionPoint - ErosionPoint;
display(['The current exact Z-value is ' num2str(z) '(h = ' num2str(OPT.Ph), ...
    ', Hm0 = ' num2str(OPT.PHm0) ', Tp = ' num2str(OPT.PTp) ')']) %DEBUG
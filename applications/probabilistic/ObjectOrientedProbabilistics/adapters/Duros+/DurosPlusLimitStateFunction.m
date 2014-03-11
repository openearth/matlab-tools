function z = DurosPlusLimitStateFunction(varargin)
%DUROSPLUSLIMITSTATEFUNCTION  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = DurosPlusLimitStateFunction(varargin)
%
%   Input: For <keyword,value> pairs call DurosPlusLimitStateFunction() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   DurosPlusLimitStateFunction
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
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
% Created: 24 Feb 2014
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
    'MaxErosionPoint', -351, ...
    'ModelSetupDir', 'd:\ADIS_XB_testing\ModelSetup\Terschelling_4000760');

OPT = setproperty(OPT, varargin{:});

%% Read input

xInitial    = load(fullfile(OPT.ModelSetupDir, 'xDuros+.grd'));
zInitial    = load(fullfile(OPT.ModelSetupDir, 'bedDuros+.dep'));

xInitial    = fliplr(xInitial);
zInitial    = fliplr(zInitial);

xInitial    = -xInitial;

JarkusID    = 4000760;                  % Change this according to location!
Station1    = 'Steunpunt Waddenzee';    % Change this according to location!
Station2    = 'Eierlandse Gat';         % Change this according to location!

[Lambda, ~] = getLambda_2Stations(Station1, Station2, 'JarkusId', JarkusID);     

[h, h1, h2, Station1, Station2]     = getWl_2Stations(norm_cdf(OPT.Ph, 0, 1), Lambda, Station1, Station2);
[Hs, Hs1, Hs2, Station1, Station2]  = getHs_2Stations(norm_cdf(OPT.PHm0, 0, 0.6), Lambda, h1, h2, Station1, Station2);
[Tp, Tp1, Tp2, Station1, Station2]  = getTp_2Stations(norm_cdf(OPT.PTp, 0, 1), Lambda, Hs1, Hs2, Station1, Station2);

%% Duros+ settings

DuneErosionSettings('set', 'AdditionalErosion', false);

%% run Duros+
[~, ~, ErosionResult]   = x2z_DUROS(        ...
    'Resistance',   OPT.MaxErosionPoint,    ...
    'xInitial',     xInitial,               ...
    'zInitial',     zInitial,               ...
    'WL_t',         h,                  ...
    'Hsig_t',       Hs,                    ...
    'Tp_t',         Tp,                     ...
    'D50',          OPT.D50,                ...
    'Duration',     0,                      ...
    'Accuracy',     0,                      ...
    'zRef',         min(zInitial)           ...
    );

%% Limit State Function

MaxErosionPoint = OPT.MaxErosionPoint;
ErosionPoint    = -ErosionResult(1).VTVinfo.Xr;
z               = MaxErosionPoint - ErosionPoint;

display(['The current exact Z-value is ' num2str(z) '(h = ' num2str(OPT.Ph), ...
    ', Hm0 = ' num2str(OPT.PHm0) ', Tp = ' num2str(OPT.PTp) ')']) %DEBUG
function xRPoint = mpa_durosplusfast(xInitial, zInitial, D50, waterLevel, significantWaveHeight, peakPeriod, coastalBend)
%MPA_DUROSPLUSFAST  One line description goes here.
%
%   Assumes the MorphAn library is loaded correctly. Only outputs the
%   retreat distance
%
%   Syntax:
%   varargout = mpa_durosplusfast(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   mpa_durosplusfast
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
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
% Created: 09 Mar 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Run MorphAn
morphAnInput = DeltaShell.Plugins.MorphAn.TRDA.Calculators.TRDAInputParameters;

morphAnInput.D50 = D50;
morphAnInput.SignificantWaveHeight = significantWaveHeight;
morphAnInput.PeakPeriod = peakPeriod;
morphAnInput.MaximumStormSurgeLevel = waterLevel;
morphAnInput.CoastalBend = coastalBend;
morphAnInput.InputProfile = DeltaShell.Plugins.MorphAn.Domain.Transect;
morphAnInput.InputProfile.CrossShoreGeometry.Clear;
for i=1:length(xInitial)
    morphAnInput.InputProfile.CrossShoreGeometry.Add(DeltaShell.Plugins.MorphAn.Domain.TransectCoordinate(xInitial(i),zInitial(i)));
end

morphAnResult = DeltaShell.Plugins.MorphAn.TRDA.CoastalSafetyAssessment.AssessDuneProfileAccordingTo2006Rules(morphAnInput);

xRPoint = morphAnResult.OutputPointR.X;

function [Tp, Tp1, Tp2] = getTp_2Stations(lambda, waveHeight1, waveHeight2, a1, a2, b1, b2)
%GETTP_2SUPPORTPOINTS  Calculates peak period given sign. wave height in 2
%stations
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = getTp_2SupportPoints(varargin)
%
%   Input: For <keyword,value> pairs call getTp_2SupportPoints() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   getTp_2SupportPoints
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
% Created: 04 Mar 2014
% Created with Matlab version: 8.2.0.701 (R2013b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Settings

%% Calculate Tp for both stations

Tp1 = getTp_t(waveHeight1, a1, b1);
Tp2 = getTp_t(waveHeight2, a2, b2);

%% Interpolate

Tp  = lambda*Tp1 + (1-lambda)*Tp2;
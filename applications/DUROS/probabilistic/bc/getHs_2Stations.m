function [Hs, Hs1, Hs2] = getHs_2Stations(lambda, waterLevel1, waterLevel2, a1, a2, b1, b2, c1, c2, d1, d2, e1, e2)
%GETHS_2STATOIONS  Calculate sign. wave height given water level in two
%support stations
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = getHs_2Stations(varargin)
%
%   Input: For <keyword,value> pairs call getHs_2Stations() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   getHs_2Stations
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

%% Calculate Hs for both stations

Hs1 = getHsig_t(waterLevel1, a1, b1, c1, d1, e1);
Hs2 = getHsig_t(waterLevel2, a2, b2, c2, d2, e2);

%% Interpolate

Hs  = lambda*Hs1 + (1-lambda)*Hs2;
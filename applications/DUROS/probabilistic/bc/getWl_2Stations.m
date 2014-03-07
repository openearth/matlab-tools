function [Wl, Wl1, Wl2] = getWl_2Stations(lambda, P, Omega1, Omega2, rho1, rho2, alpha1, alpha2, sigma1, sigma2)
%GETWL_2SUPPORTPOINTS  Calculates waterlevels in 2 stations and point
%in between, given a probability and the parameters in both stations
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = getWl_2SupportPoints(varargin)
%
%   Input: For <keyword,value> pairs call getWl_2SupportPoints() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   getWl_2SupportPoints
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

Wl1 = conditionalWeibull(P, Omega1, rho1, alpha1, sigma1);
Wl2 = conditionalWeibull(P, Omega2, rho2, alpha2, sigma2);

%% Interpolate

Wl  = lambda*Wl1 + (1-lambda)*Wl2;
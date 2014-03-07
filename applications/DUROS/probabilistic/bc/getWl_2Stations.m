function [Wl, Wl1, Wl2] = getWl_2Stations(lambda, P, Station1, Station2)
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

%% Parameters per station

% Station information obtained from "Dune erosion - Product 3:
% Probabilistic dune erosion prediction method" WL|Delft
% Hydraulics/DUT/Alkyon 2007
%                           Omega   Rho     Alpha   Sigma
StationInfo = {
    'Hoek van Holland',     1.95,   7.237,  0.57,   0.0158;
    'IJmuiden',             1.85,   5.341,  0.63,   0.0358;
    'Den Helder',           1.6,    3.254,  1.6,    0.9001; 
    'Eierlandse Gat',       2.25,   0.5,    1.86,   1.0995;
    'Steunpunt Waddenzee',  [],     [],     [],     [];
    'Borkum',               1.85,   5.781,  1.27,   0.535
    };

Station1Valid   = false;
Station2Valid   = false;

for iStation = 1:size(StationInfo,1)
    if strcmpi(StationInfo{iStation,1}, Station1)
        Omega1          = StationInfo{iStation,2}; 
        rho1            = StationInfo{iStation,3};
        alpha1          = StationInfo{iStation,4};
        sigma1          = StationInfo{iStation,5};
        Station1Valid   = true;
    elseif strcmpi(StationInfo{iStation,1}, Station2)
        Omega2          = StationInfo{iStation,2}; 
        rho2            = StationInfo{iStation,3};
        alpha2          = StationInfo{iStation,4};
        sigma2          = StationInfo{iStation,5};
        Station2Valid   = true;
    end
end

if ~Station1Valid || ~Station2Valid
    error('Please specify valid station names!')
end

%% Calculate Wl for both stations

% Steunpunt Waddenzee doesn't have it's own set of parameters, and is
% itself an interpolation between Eierlandse Gat (Lambda = 0.57) and Borkum
% (Lambda = 0.43)
if strcmpi(Station1, 'Steunpunt Waddenzee')
    [Wl1, ~, ~] = getWl_2Stations(0.57, P, 'Eierlandse Gat', 'Borkum');
%     Wl2         = getWaterlevelWeibull(Omega2, rho2, alpha2, sigma2, P);
    Wl2         = conditionalWeibull_inv(P, Omega2, rho2, alpha2, sigma2);
elseif strcmpi(Station2, 'Steunpunt Waddenzee')
%     Wl1         = getWaterlevelWeibull(Omega1, rho1, alpha1, sigma1, P);
    Wl1         = conditionalWeibull_inv(P, Omega1, rho1, alpha1, sigma1);
    [Wl2, ~, ~] = getWl_2Stations(0.57, P, 'Eierlandse Gat', 'Borkum');
else
%     Wl1         = getWaterlevelWeibull(Omega1, rho1, alpha1, sigma1, P);
%     Wl2         = getWaterlevelWeibull(Omega2, rho2, alpha2, sigma2, P);
    Wl1         = conditionalWeibull_inv(P, Omega1, rho1, alpha1, sigma1);
    Wl2         = conditionalWeibull_inv(P, Omega2, rho2, alpha2, sigma2);
end

%% Interpolate

Wl  = lambda*Wl1 + (1-lambda)*Wl2;
function [curvatures radii relativeAngle distances] = jarkus_deriveCurvature_test(varargin)
%JARKUS_DERIVECURVATURE_TEST  Test function for jarkus_deriveCurvature function
%
%   Creates a spiral shaped coastline using a linear dune profile and
%   writes it to a jarkus formatted file. Subsequently it calls the
%   jarkus_deriveCurvature function to backtrace the coastal curvatures.
%
%   Syntax:
%   [curvatures radii relativeAngle distances] = jarkus_deriveCurvature_test(varargin)
%
%   Input:
%   varargin    = key/value pairs of optional parameters
%                 jarkusFile        = filename of file containing
%                                     generated JARKUS information
%                                     (default: spiral.mat)
%                 xMin              = minimum cross-shore location
%                                     (default: 0)
%                 xMax              = maximum cross-shore location
%                                     (default: 2500)
%                 zMin              = minimum bed level (default: -20)
%                 zMax              = maximum bed level (default: 15)
%                 Rmin              = minimum radius to be included in
%                                     calculation method 2 (default: 1000)
%                 Rmax              = maximum radius to be included in
%                                     calculation method 2 (default: 20000)
%                 dR                = step size in which the radius should
%                                     be varied in calculation method 2
%                                     (default: 100)
%
%   Output:
%   curvatures      = array of curvatures in degrees per kilometer
%   radii           = array of curvatures in curvature radii in meter
%   relativeAngle   = array with angles between transects
%   distances       = array with distances between transects at shoreline
%
%   Example
%   jarkus_deriveCurvature_test
%
%   See also jarkus_deriveCurvature

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Bas Hoonhout
%
%       bas@hoonhout.com
%
%       Stevinweg 1
%       2628CN Delft
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

% This tool is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 23 Nov 2009
% Created with Matlab version: 7.5.0.338 (R2007b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

MTestCategory.Integration;
if TeamCity.running
    TeamCity.ignore('WIP: jarkus_deriveCurvature is deprecated, use jarkus_curvature and jarkus_transects');
    return;
end

%% settings

OPT = struct( ...
    'jarkusFile', 'spiral.mat', ...
    'xMin', 0, ...
    'xMax', 2500, ...
    'zMin', -20, ...
    'zMax', 15, ...
    'Rmin', 1000, ...
    'Rmax', 20000, ...
    'dR', 500 ...
);

OPT = setproperty(OPT, varargin{:});

%% create spiral shaped coastline

profileX = [OPT.xMin OPT.xMax];
profileZ = [OPT.zMin OPT.zMax];

coastlineLocation = interp1(profileZ, profileX, 0);

R = OPT.Rmin:OPT.dR:OPT.Rmax;
da = 2*pi/length(R);
a = 0:da:2*pi;

x = [];
y = [];
z = [];
xx = [];
yy = [];
zz = [];

i = 1;
for Ri = R
    x(i) = Ri * sin(a(i));
    y(i) = Ri * cos(a(i));
    
    for j = 1:length(profileX);
        xx(i,j) = (Ri + coastlineLocation - profileX(j)) * sin(a(i));
        yy(i,j) = (Ri + coastlineLocation - profileX(j)) * cos(a(i));
        zz(i,j) = profileZ(j);
    end
    
    i = i + 1;
end

jarkusAltitude = zz;
jarkusXGrid = xx;
jarkusYGrid = yy;
jarkusCrossshoreGrid = profileX;
jarkusAreaCode = ones(size(R));
jarkusTransectIDs = R;

save(OPT.jarkusFile, 'jarkusAreaCode', 'jarkusTransectIDs', ...
            'jarkusXGrid', 'jarkusYGrid', 'jarkusCrossshoreGrid', ...
            'jarkusAltitude');

%% derive curvature

[curvatures radii relativeAngle distances] = jarkus_deriveCurvature( ...
    'jarkusFile', OPT.jarkusFile, 'Rmin', OPT.Rmin, 'Rmax', OPT.Rmax, ...
    'dR', OPT.dR, 'angleThreshold', 1e6, 'distanceThreshold', 1e6, ...
    'order', false, 'christmas', true);
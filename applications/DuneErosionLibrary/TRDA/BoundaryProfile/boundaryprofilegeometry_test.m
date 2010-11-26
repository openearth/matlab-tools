function boundaryprofilegeometry_test()
% BOUNDARYPROFILEGEOMETRY_TEST  Unit test of boundaryprofilegrometry
%  
% This unit test examines the working of boundaryprofilegeometry.
%
%
%   See also boundaryprofilegeometry

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 18 Nov 2009
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

MTestCategory.Integration;

significantWaveHeight = 9;
peakPeriod = 8+1/3;
waterLevel = 5;

%% Testcase 1
% With x0 input parameter
% This testcase tests the basic functionality with input parameter x0 = 0.

x0Point = -5;
xExpected = [-12 -6 -3 0]'+x0Point;
zExpected = [waterLevel waterLevel+3 waterLevel+3 waterLevel]'; 

Result1 = boundaryprofilegeometry(waterLevel, significantWaveHeight, peakPeriod, x0Point);
assert(all(xExpected==Result1.xActive) & all(zExpected==Result1.z2Active),'X and Z values were not as expected');

%% Testcase 2
% Without x0 input parameter
% This testcase tests the basic functionality without input parameter x0. The function should not
% crash and get the default value of x0 = 0.
xExpected = [-12 -6 -3 0]';
zExpected = [waterLevel waterLevel+3 waterLevel+3 waterLevel]'; 

Result2 = boundaryprofilegeometry(waterLevel, significantWaveHeight, peakPeriod);
assert(all(xExpected==Result2.xActive) & all(zExpected==Result2.z2Active),'X and Z values are not as expected');
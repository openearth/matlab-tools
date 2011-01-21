function testresult = additional_erosionpoint_test()
% ADDITIONAL_EROSIONPOINT_TEST  One line description goes here
%  
% More detailed description of the test goes here.
%
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
%       The Netherlands
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
% Created: 20 Jan 2011
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

MTestCategory.WorkInProgress;

%%
% tr = jarkus_transects(...
%     'id', 7003600);
% x = tr.cross_shore(:);
% z = squeeze(tr.altitude(end,1,:));
% nnid = ~isnan(z);
% [x z] = deal(x(nnid), z(nnid));

[x z] = SimpleProfile;

targetVolume = 200;
lowerboundary = 10.7;
slope = 1;

[epsw pr] = additional_erosionpoint(x, z, targetVolume,...
    'positive_landward', false,...
    'slope', slope,...
    'lowerboundary', lowerboundary);

zep = interp1(x, z, epsw);

[vol res] = jarkus_getVolume(x, z,...
    'LowerBoundary', lowerboundary,...
    'x2', [max(x) epsw + [(zep - lowerboundary) * slope 0]],...
    'z2', [lowerboundary  lowerboundary zep]);

testresult = diff([res.Volumes.Erosion targetVolume]) < 1e-7;
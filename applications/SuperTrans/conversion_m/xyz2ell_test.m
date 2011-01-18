function OK = xyz2ell_test
% XYZ2ELL_TEST  Test routine for xyz2ell
%  
% More detailed description of the test goes here.
%
%
%   See also XYZ2ELL

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arjan Mol
%
%       arjan.mol@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
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
% Created: 29 Oct 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

MTestCategory.Unit;

OK = 0;

a  = 6378137;
e2 = 0.006694381;
x0 = 5000000;
y0 = 3000000;
z0 = 2000000;

x  = x0;
y  = y0;
z  = z0;
numIters = 1000;
d = nan(1,numIters);

% convert back and forth several times
for ii = 1:numIters
    [lat,lon,h] = xyz2ell(x,y,z,    a,e2);
    [x,y,z]     = ell2xyz(lat,lon,h,a,e2);
    d(ii)       = (x-x0).^2+(y-y0).^2+(z-z0).^2;
end

% plot d to see error developement trhoughout iterations
% plot(d)

OK = d(numIters)<1e-5;
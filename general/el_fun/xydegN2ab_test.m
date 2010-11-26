function testresult = xydegN2ab_test()
% XYDEGN2AB_TEST  One line description goes here
%  
% More detailed description of the test goes here.
%
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Kees den Heijer
%
%       Kees.denHeijer@Deltares.nl	
%
%       Deltares
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
% Created: 26 Oct 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

Category(TestCategory.Unit);

[x y] = deal(0); % arbitrary (x,y) point
degNs = 0:45:360; % 9 angles all around the circle

[a b] = deal(NaN(size(degNs))); % pre-allocate a and b

% calculate all a's and b's
for idegN = 1:length(degNs)
    degN = degNs(idegN);
    [a(idegN) b(idegN)] = xydegN2ab(x, y, degN);
end

result = false(size(degNs)); % pre-allocate result
for idegN = 1:4
    % define id for opposite angles
    id = idegN:4:length(degNs);
    % check whether a and b are equal for all opposite angles
    resulta(id) = isscalar(nanunique(a(idegN:4:end)));
    resultb(id) = isscalar(nanunique(b(idegN:4:end)));
end

testresult = all([resulta resultb]);
function testresult = roundoff_test()
% ROUNDOFF_TEST  test defintion routine
%  
% More detailed description of the test goes here.
%
%
%   See also roundoff 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       C.(Kees) den Heijer
%
%       Kees.denHeijer@deltares.nl
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
% Created: 11 Sep 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% $Description (Name = roundoff unit test)
% Publishable code that describes the test.

%% $RunCode

tr(1) = roundoffnormaltest;
tr(2) = roundofffloortest;
tr(3) = roundoffceiltest;

testresult = all(tr);

%% $PublishResult
% Publishable code that describes the test.

end

function testresult = roundoffnormaltest()
%% $Description (Name = normal)
%round pi (mode = normal)

%% $RunCode
X = pi();
n = -1:5;

res = nan(size(n));
for i=1:length(res)
    res(i) = roundoff(X,n(i));
end
Xround = [0 3 3.1 3.14 3.142 3.1416 3.14159];

testresult = all(res==Xround);

%% $PublishResult

end

function testresult = roundofffloortest()
%% $Description (Name = floor)
%round pi (mode = floor)

%% $RunCode
X = pi();
n = -1:5;

res = nan(size(n));
for i=1:length(res)
    res(i) = roundoff(X,n(i),'floor');
end
Xround = [0 3 3.1 3.14 3.141 3.1415 3.14159];

testresult = all(res==Xround);

%% $PublishResult

end

function testresult = roundoffceiltest()
%% $Description (Name = ceil)
%round pi (mode = ceil)

%% $RunCode
X = pi();
n = -1:5;

res = nan(size(n));
for i=1:length(res)
    res(i) = roundoff(X,n(i),'ceil');
end
Xround = [10 4 3.2 3.15 3.142 3.1416 3.14160];

testresult = all(res==Xround);

%% $PublishResult

end
function testresult = roundoff_test()
% ROUNDOFF_TEST  Unit test definition for roundoff
%  
% This function defines a unittest for the roundoff function.
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
% The roundoff unittest tests three ways to use roundoff:
%
% * normal
% * ceil
% * floor
%
% Each testcase contains several calls to roundoff trying to roundoff pi().

%% $RunCode

tr(1) = roundoffnormaltest;
tr(2) = roundofffloortest;
tr(3) = roundoffceiltest;

testresult = all(tr);
end

function testresult = roundoffnormaltest()
%% $Description (Name = normal & IncludeCode = true & EvaluateCode = false)
% round pi (mode = normal). We round pi at -1 to 5 digits. The result should look like this:

Xround = [0 3 3.1 3.14 3.142 3.1416 3.14159];

%% $RunCode
X = pi();
n = -1:5;

res = nan(size(n));
for i=1:length(res)
    res(i) = roundoff(X,n(i));
end

testresult = all(res==Xround);
end

function testresult = roundofffloortest()
%% $Description (Name = floor)
% round pi (mode = floor). We round pi at -1 to 5 digits in floor mode. The result should look like
% this:

Xround = [0 3 3.1 3.14 3.141 3.1415 3.14159];

%% $RunCode
X = pi();
n = -1:5;

res = nan(size(n));
for i=1:length(res)
    res(i) = roundoff(X,n(i),'floor');
end

testresult = all(res==Xround);
end

function testresult = roundoffceiltest()
%% $Description (Name = ceil)
% round pi (mode = ceil). We round pi at -1 to 5 digits in ceil mode. The result should look like
% this:

Xround = [10 4 3.2 3.15 3.142 3.1416 3.14160];

%% $RunCode
X = pi();
n = -1:5;

res = nan(size(n));
for i=1:length(res)
    res(i) = roundoff(X,n(i),'ceil');
end

testresult = all(res==Xround);
end
function testresult = getFallVelocity_test()
% GETFALLVELOCITY_TEST  One line description goes here
%  
% More detailed description of the test goes here.
%
%
%   See also 

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
% Created: 11 Sep 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% $Description (Name = getFallVelocity_test)
% Publishable code that describes the test.

%% $RunCode
tr(1) = fallvelocitydefault;
tr(2) = fallvelocitycoefficients;
testresult = all(tr);

%% $PublishResult
% Publishable code that describes the test.
end

function testresult = fallvelocitydefault()
%% $Description (Name = default settings check)

%% $RunCode
D50 = (150:25:300)*1e-6;

expectedw = [...
    0.0141227,...
    0.0176015,...
    0.0211321,...
    0.0246782,...
    0.0282143,...
    0.0317219,...
    0.035188];

try
    w = getFallVelocity('D50',D50);
    testresult = all(roundoff(w,7)==expectedw);
catch me
    testresult = false;
end

%% $PublishResult
% Nothing to publish
end

function testresult = fallvelocitycoefficients()
%% $Description (Name = manually set coeffs)

%% $RunCode
D50 = 0.000225;
a = 0.5236;
b = 2.398;
c = 3.5486;

expectedw = 0.017043;

try
    w = getFallVelocity(...
        'a',a,...
        'b',b,...
        'c',c,...
        'D50',D50);
    testresult = roundoff(w,7)==expectedw;
catch me
    testresult = false;
end

%% $PublishResult
% TODO

end

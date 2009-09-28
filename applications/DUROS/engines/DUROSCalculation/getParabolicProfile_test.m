function testresult = getParabolicProfile_test()
% GETPARABOLICPROFILE_TEST  test defintion routine
%  
% More detailed description of the test goes here.
%
%
%   See also getParabolicProfile 

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
% Created: 28 Sep 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% $Description (Name = Name of the test goes here)
% Publishable code that describes the test.

%% $RunCode
WL_t = 0;
Hsig_t = 9;
Tp_t = 12;
w = 0.0246782;
x0 = 0;
x = [0 16.254 32.5079 48.7619 65.0158 81.2698 97.5237 113.778 130.032 146.286 162.54 178.793 195.047 211.301 227.555 243.809 260.063 276.317 292.571 308.825 325.079]';

tr(1) = parabprofilecase1([],Hsig_t,Tp_t,w,x0,WL_t);
tr(2) = parabprofilecase2(x,Hsig_t,Tp_t,w,x0,WL_t);

testresult = all(tr);

%% $PublishResult
% Publishable code that describes the test.

end

function testresult = parabprofilecase1(x,Hsig_t,Tp_t,w,x0,WL_t)
%% $Description (Name = xmax)

%% $RunCode
[xmax, z, Tp_t] = getParabolicProfile(WL_t, Hsig_t, Tp_t, w, x0, x);

testresult = xmax == 325.079;

%% $PublishResult

end

function testresult = parabprofilecase2(x,Hsig_t,Tp_t,w,x0,WL_t)
%% $Description (Name = profile)

%% $RunCode
[xmax, z, Tp_t] = getParabolicProfile(WL_t, Hsig_t, Tp_t, w, x0, x);
testresult = xmax == 325.079;
%% $PublishResult

end
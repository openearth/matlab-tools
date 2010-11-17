function getFallVelocity_test()
% GETFALLVELOCITY_TEST  Unit test for getFallVelocity
%  
% This test definition function describes a unit test for getFallVelocity.
%
%
%   See also getFallVelocity

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

%% $Description (Name = getFallVelocity unit test)
% The function getFallVelocity calculates the fall velocity of sediment in water according to (v. Rijn
% et. al., 1993):
%
% $$^{10} \log \left( {{1 \over w}} \right) = a\left( {^{10} \log D_{50} } \right)^2  + b\left(^{10} \log D_{50} \right)  + c$$
%
% The default values for a, b and c correspond with the formulation for sediment in fresh water with
% a temperature of 5 degrees:
%
% * a = 0.476
% * b = 2.18
% * c = 3.226
%
% This test checks the fallvelocity for various grain size diameters and with various coeeficients.
% The unit test is successfull if the function returns a fall velocity of 0.0211 m/s (rounded at the 
% fourth digit) with an input grain size diameter D50 = 200e-6 and coefficients a = 0.476, b = 2.18,
% c = 3.226.

D50range = (50e-6:10e-6:450e-6)';

% calculate unit test:
w = getFallVelocity('D50',200e-6,'a',0.476,'b',2.18,'c',3.226);
assert(roundoff(w,4)==0.0211);

% First calculate with default settings
wdef = getFallVelocity(D50range);
w1 = getFallVelocity('D50',D50range,'a',0.476,'b',2.18,'c',3.19);

%% $PublishResult (EvalueateCode = true & IncludeCode = false)
% The testresult consists of two parts:
%
% # Outcome of the unit test with default values
% # Results of getFallVelocity with various values for the D50, a, b and c
%

%% Rersult unit test
% The result of the unit test was:

disp(num2str(w,'%0.4f'));

%% Regression test
% The following figure shows the outcome of getFallVelocity with various input parameters:

figure('Color','w');
hold on
grid on
plot(D50range*1e6,wdef,'Color','k','DisplayName','c = 3.226, 5 degrees fresh water');
plot(D50range*1e6,w1,'Color','b','DisplayName','c = 3.19, 10 degrees fresh water');
legend('show','Location','NorthWest')
xlabel('D_5_0 [um]');
ylabel('w (fall velocity) [um/s]');

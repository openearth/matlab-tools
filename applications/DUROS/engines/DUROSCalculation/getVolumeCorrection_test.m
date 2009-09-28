function testresult = getVolumeCorrection_test()
% GETVOLUMECORRECTION_TEST  test defintion routine
%  
% More detailed description of the test goes here.
%
%
%   See also getVolumeCorrection 

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
tr(1) = volcorrcase1;
tr(2) = volcorrcase2;
tr(3) = volcorrcase3;

testresult = all(tr);

%% $PublishResult
% Publishable code that describes the test.

end

function testresult = volcorrcase1()
%% $Description (IncludeCode = false & EvaluateCode = true & Name = )
x = [0 0.314159 0.628319 0.942478 1.25664 1.5708 1.88496 2.19911 2.51327 2.82743 3.14159 3.41812]';
z = [0 -0.025 -0.05 -0.075 -0.1 -0.125 -0.15 -0.175 -0.2 -0.225 -0.25 -0.272006]';
z2 = [0 0.309017 0.587785 0.809017 0.951057 1 0.951057 0.809017 0.587785 0.309017 1.22465e-016 -0.272006]';
WL = 1;

figure('Color','w');
hold on
plot(x,z,'DisplayName','Initial profile');
plot(x,z2,'Color','r','DisplayName','Second profile');
plot(xlim,ones(1,2)*WL,'Color','b','DisplayName','water level');
legend show

%% $RunCode

Volume = 2.41079;
Volumechange = 0;
CorrectionApplied = false;
DuneCorrected = false;

[Volume, Volumechange, CorrectionApplied, DuneCorrected, x, z, z2] = getVolumeCorrection(x, z, z2, WL);

testresult = nan;
%% $PublishResult

end

function testresult = volcorrcase2()
%% $Description

%% $RunCode
x = [0 0.314159 0.628319 0.942478 1.25664 1.5708 1.88496 2.19911 2.51327 2.82743 3.14159 3.41812 3.45575 3.76991 4.08407 4.39823 4.71239 5.02655 5.34071 5.65487 5.79737]';
z = [0 -0.025 -0.05 -0.075 -0.1 -0.125 -0.15 -0.175 -0.2 -0.225 -0.25 -0.272006 -0.275 -0.3 -0.325 -0.35 -0.375 -0.4 -0.425 -0.45 -0.46134]';
z2 = [0 0.309017 0.587785 0.809017 0.951057 1 0.951057 0.809017 0.587785 0.309017 1.22465e-016 -0.272006 -0.309017 -0.587785 -0.809017 -0.951057 -1 -0.951057 -0.809017 -0.587785 -0.46134]';
WL = 1;
Volume = 1.45193;
Volumechange = 0;
CorrectionApplied = false;
DuneCorrected = false;

testresult = nan;
%% $PublishResult

end

function testresult = volcorrcase3()
%% $Description

%% $RunCode
x = [3.41812 3.45575 3.76991 4.08407 4.39823 4.71239 5.02655 5.34071 5.65487 5.79737]';
z = [-0.272006 -0.275 -0.3 -0.325 -0.35 -0.375 -0.4 -0.425 -0.45 -0.46134]';
z2 = [-0.272006 -0.309017 -0.587785 -0.809017 -0.951057 -1 -0.951057 -0.809017 -0.587785 -0.46134]';
WL = -0.272006;

Volume = -0.958854;
Volumechange = 0;
CorrectionApplied = false;
DuneCorrected = false;

testresult = nan;

%% $PublishResult


end

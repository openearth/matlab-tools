function testresult = getVolumeCorrection_test()
% GETVOLUMECORRECTION_TEST  testdefinition for getVolumeCorrection
%  
% This function describes the testdefinition for a test that examines getVolumeCorrection.
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

%% $Description (Name = getVolumeCorrection)
% The DUROS parabolic profile must be located in the initial profile in such a way that the amount
% of eroded sediment and accreted sediment is equal. This should only be achieved with seaward
% directed sediment transport. In other words, landwar directed sediment transport should be ignored
% in the sediment balance. getVolumeCorrection calculates the amount of landward transport that
% apparently took place to achive the suggested solution and returns the sediment balance excluding
% landward transport of sediment.
%
% This test consideres three testcases:
%
% # A testcase with an eroding and an accreting part
% # A testcase that only contains an erosive part
% # A testcase that only contains an accretive part

%% $RunCode
tr(1) = volcorrcase1;
tr(2) = volcorrcase2;
tr(3) = volcorrcase3;

testresult = all(tr);

%% $PublishResult (IncludeCode = false & EvaluateCode = true)
% The overall result of the test was:

if testresult
    disp('positive');
else
    disp('negative');
end

end

function testresult = volcorrcase1()
%% $Description (IncludeCode = false & EvaluateCode = true & Name = Normal calculation)
% To test the basic functionality of getVolumeCorrection we use the following "profiles":
x = [0 0.314159 0.628319 0.942478 1.25664 1.5708 1.88496 2.19911 2.51327 2.82743 3.14159 3.41812 3.45575 3.76991 4.08407 4.39823 4.71239 5.02655 5.34071 5.65487 5.79737]';
z = [0 -0.025 -0.05 -0.075 -0.1 -0.125 -0.15 -0.175 -0.2 -0.225 -0.25 -0.272006 -0.275 -0.3 -0.325 -0.35 -0.375 -0.4 -0.425 -0.45 -0.46134]';
z2 = [0 0.309017 0.587785 0.809017 0.951057 1 0.951057 0.809017 0.587785 0.309017 1.22465e-016 -0.272006 -0.309017 -0.587785 -0.809017 -0.951057 -1 -0.951057 -0.809017 -0.587785 -0.46134]';
WL = 1;

figure('Color','w');
hold on
plot(x,z,'DisplayName','Initial profile');
plot(x,z2,'Color','r','DisplayName','Second profile');
plot(xlim,ones(1,2)*WL,'Color','b','DisplayName','water level');
legend show

%% $RunCode

[Volume, Volumechange, CorrectionApplied, DuneCorrected, x, z, z2] = getVolumeCorrection(x, z, z2, WL);

Volume = -0.958854;
Volumechange = 0;
CorrectionApplied = false;
DuneCorrected = false;

testresult = nan;

%% $PublishResult




end

function testresult = volcorrcase2()
%% $Description

%% $RunCode
x = [3.41812 3.45575 3.76991 4.08407 4.39823 4.71239 5.02655 5.34071 5.65487 5.79737]';
z = [-0.272006 -0.275 -0.3 -0.325 -0.35 -0.375 -0.4 -0.425 -0.45 -0.46134]';
z2 = [-0.272006 -0.309017 -0.587785 -0.809017 -0.951057 -1 -0.951057 -0.809017 -0.587785 -0.46134]';
WL = -0.272006;
Volume = 1.45193;
Volumechange = 0;
CorrectionApplied = false;
DuneCorrected = false;

testresult = nan;
%% $PublishResult

end

function testresult = volcorrcase3()
%% $Description
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

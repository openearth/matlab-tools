function testResult = TeamCity_test()
% TEAMCITY_TEST  Tests the TeamCity object
%
% This test tests the basic functionality of a TeamCity object.
%
%
%   See also TeamCity

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
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
% Created: 18 May 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $
testResult = true;

teamcity_constructor_test;
teamcity_postmessage_test;
teamcity_ignore_test;
teamcity_category_test;

end

function teamcity_constructor_test()
if isappdata(0,'MTestTeamCityObject')
    rmappdata(0,'MTestTeamCityObject');
end
tc = TeamCity;

assert(isappdata(0,'MTestTeamCityObject'),'TeamCity object was not written to application data.');
tc.CurrentTest = 2;

tc2 = getappdata(0,'MTestTeamCityObject');
assert(tc2.CurrentTest==2,'Current Test was not stored');

clear tc tc2
tc2 = TeamCity;
assert(tc2.CurrentTest==2,'TeamCity object was not restored');

end

function teamcity_postmessage_test()
tc = TeamCity;
tc.WorkDirectory = tempdir;
tc.TeamCityRunning = false;
txt = evalc('TeamCity.postmessage(''testTeamCityMessage'',''opt1'',''arg1'')');
assert(isempty(txt),'There should be no message to the command window');

tc.TeamCityRunning = true;
txt = evalc('TeamCity.postmessage(''testTeamCityMessage'',''opt1'',''arg1'')');
assert(isempty(txt),'TeamCity should not post message to command window when running');
assert(exist(fullfile(tc.WorkDirectory,'teamcitymessage.matlab'),'file')==2,'Teamcity message file was not created');
delete(fullfile(tc.WorkDirectory,'teamcitymessage.matlab'));

% TODO: check message in text file?
end

function teamcity_ignore_test()
mt = MTest;
mt.Name = 'test';
tc = TeamCity;
tc.CurrentTest = mt;
tc.TeamCityRunning = false;
clear tc

txt = evalc('TeamCity.ignore(''test ignore'');');

assert(~isempty(txt),'TeamCity should post an ignore message to command window');
assert(mt.Ignore,'Test should be ignored by teamcity');

tc = TeamCity;
tc.TeamCityRunning = true;
txt = evalc('TeamCity.ignore(''test ignore'');');
assert(~isempty(txt),'TeamCity should post ignore message to command window when running');
assert(exist(fullfile(tc.WorkDirectory,'teamcitymessage.matlab'),'file')==2,'Teamcity message file was not created');
delete(fullfile(tc.WorkDirectory,'teamcitymessage.matlab'));
end

function teamcity_category_test()
% if TeamCity.ignore('wip'), return; end
end

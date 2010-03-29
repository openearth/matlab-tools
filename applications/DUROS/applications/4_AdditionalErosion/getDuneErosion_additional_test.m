function testresult = getDuneErosion_additional_test()
% GETDUNEEROSION_ADDITIONAL_TEST  tests for getduneerosion_additional
%  
% More detailed description of the test goes here.
%
%
%   See also getDuneErosion_additional

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
% Created: 29 Mar 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% $Description (Name = Name of the test goes here)
% Publishable code that describes the test.

%% $RunCode

testresult = true;

getDuneErosion_additional_testdir = fileparts(which('getDuneErosion_additional_testcase1.mat'));
disp('Precision / TargetVolume:');

%% case 1: normal dune erosion calculation with reference profile
writemessage init
load(fullfile(getDuneErosion_additional_testdir,'getDuneErosion_additional_testcase1.mat'));
TargetVolume = -100.8099;
resultout = getDuneErosion_additional(xInitial,zInitial,DUROSresult,WL_t,TargetVolume,AVolume,maxRetreat,x0except);
resultout.info.messages = writemessage('get');
plotDuneErosion(cat(2,DUROSresult,resultout),figure);
disp(['case 1: ' num2str(resultout.info.precision,'%0.4f') ' , TargetVolume = ' num2str(TargetVolume,'%0.2f')]);

%% case 2: valley in the dune profile
writemessage init
load(fullfile(getDuneErosion_additional_testdir,'getDuneErosion_additional_testcase2.mat'));
maxRetreat = [];
TargetVolume = -100.8099;
resultout = getDuneErosion_additional(xInitial,zInitial,DUROSresult,WL_t,TargetVolume,AVolume,maxRetreat,x0except);
resultout.info.messages = writemessage('get');
plotDuneErosion(cat(2,DUROSresult,resultout),figure);
disp(['case 2: ' num2str(resultout.info.precision,'%0.4f') ' , TargetVolume = ' num2str(TargetVolume,'%0.2f')]);

%% case 3: restricted in the valley
writemessage init
load(fullfile(getDuneErosion_additional_testdir,'getDuneErosion_additional_testcase2.mat'));
TargetVolume = -100.8099;
resultout = getDuneErosion_additional(xInitial,zInitial,DUROSresult,WL_t,TargetVolume,AVolume,maxRetreat,x0except);
resultout.info.messages = writemessage('get');
plotDuneErosion(cat(2,DUROSresult,resultout),figure);
disp(['case 3: ' num2str(resultout.info.precision,'%0.4f') ' , TargetVolume = ' num2str(TargetVolume,'%0.2f')]);

%% case 4: DUROS calculation in the valley (not restricted)
writemessage init
load(fullfile(getDuneErosion_additional_testdir,'getDuneErosion_additional_testcase4.mat'));
maxRetreat = [];
TargetVolume = -100.8099;
resultout = getDuneErosion_additional(xInitial,zInitial,DUROSresult,WL_t,TargetVolume,AVolume,maxRetreat,x0except);
resultout.info.messages = writemessage('get');
plotDuneErosion(cat(2,DUROSresult,resultout),figure);
disp(['case 4: ' num2str(resultout.info.precision,'%0.4f') ' , TargetVolume = ' num2str(TargetVolume,'%0.2f')]);

%% case 5: DUROS calculation in the valley (restricted)
writemessage init
load(fullfile(getDuneErosion_additional_testdir,'getDuneErosion_additional_testcase4.mat'));
TargetVolume = -100.8099;
resultout = getDuneErosion_additional(xInitial,zInitial,DUROSresult,WL_t,TargetVolume,AVolume,maxRetreat,x0except);
resultout.info.messages = writemessage('get');
plotDuneErosion(cat(2,DUROSresult,resultout),figure);
disp(['case 5: ' num2str(resultout.info.precision,'%0.4f') ' , TargetVolume = ' num2str(TargetVolume,'%0.2f')]);

%% case 6: Positive TargetVolume
writemessage init
load(fullfile(getDuneErosion_additional_testdir,'getDuneErosion_additional_testcase1.mat'));
TargetVolume = 200;
resultout = getDuneErosion_additional(xInitial,zInitial,DUROSresult,WL_t,TargetVolume,AVolume,maxRetreat,x0except);
resultout.info.messages = writemessage('get');
plotDuneErosion(cat(2,DUROSresult,resultout),figure);
disp(['case 6: ' num2str(resultout.info.precision,'%0.4f') ' , TargetVolume = ' num2str(TargetVolume,'%0.2f')]);

%% case 7: Positive TargetVolume large
writemessage init
load(fullfile(getDuneErosion_additional_testdir,'getDuneErosion_additional_testcase1.mat'));
TargetVolume = 380;
resultout = getDuneErosion_additional(xInitial,zInitial,DUROSresult,WL_t,TargetVolume,AVolume,maxRetreat,x0except);
resultout.info.messages = writemessage('get');
plotDuneErosion(cat(2,DUROSresult,resultout),figure);
disp(['case 7: ' num2str(resultout.info.precision,'%0.4f') ' , TargetVolume = ' num2str(TargetVolume,'%0.2f')]);

%% case 8: Positive TargetVolume too large
writemessage init
load(fullfile(getDuneErosion_additional_testdir,'getDuneErosion_additional_testcase1.mat'));
TargetVolume = 600;
resultout = getDuneErosion_additional(xInitial,zInitial,DUROSresult,WL_t,TargetVolume,AVolume,maxRetreat,x0except);
resultout.info.messages = writemessage('get');
plotDuneErosion(cat(2,DUROSresult,resultout),figure);
disp(['case 8: ' num2str(resultout.info.precision,'%0.4f') ' , TargetVolume = ' num2str(TargetVolume,'%0.2f')]);

%% $PublishResult
% Publishable code that describes the test.

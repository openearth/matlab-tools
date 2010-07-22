function MTestPublisher_test()
% MTESTPUBLISHER_TEST  One line description goes here
%  
% More detailed description of the test goes here.
%
%
%   See also 

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
% Created: 21 Jul 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Set Category and TeamCity preferences
MTest.category('DataAccess');
if TeamCity.running
    TeamCity.ignore('Because');
    return;
end

%% Initialize general variables
teamCity = TeamCity;
tmpdir = teamCity.PublishDirectory;
teamCity.PublishDirectory = [];

mtp = MTestPublisher(...
    'TargetDir',fullfile(tempdir,'mtestpublish'),...
    'CopyMode','svnkeep',...
    'Verbose',true);

%% Test Publication of coverage
t = MTest(which('MTestUtils_test.m'));
t.run
mtp.publishcoverage(t.ProfilerInfo);
assert(exist(fullfile(mtp.TargetDir,'index.html'),'file')==2,'index should be created');
assert(isdir(mtp.TargetDir),'TargetDir should be created');
rmdir(mtp.TargetDir,'s');

%% publish test description and result
t = MTest(which('mte_testpublish_test'));
t.MTestPublisher = mtp;
t.MTestPublisher.Publish = true;
TeamCity.publish(true);
t.run;

assert(~isempty(t.PublishedDescriptionFile),...
    'Description should be published');
assert(strncmp(fileparts(t.PublishedDescriptionFile),mtp.TargetDir,length(mtp.TargetDir)),...
    'File should be published in the correct location');
assert(~isempty(t.PublishedResultFile),...
    'Result should be published');
assert(strncmp(fileparts(t.PublishedResultFile),mtp.TargetDir,length(mtp.TargetDir)),...
    'File should be published in the correct location');

rmdir(mtp.TargetDir,'s');

%% Publish test overview
mtr = MTestRunner(...
    'MainDir',fileparts(which('mte_concepttest_test.m')),...
    'Verbose',true,...
    'MTestPublisher',mtp);
mtr.gathertests;
mtr.run
mtp.Verbose = false; % To prevent the result from automatically being pooped up....
mtp.publishtestsoverview(mtr);

assert(exist(fullfile(mtp.TargetDir,'index.html'),'file')==2,'index should be created');
assert(isdir(mtp.TargetDir),'TargetDir should be created');
rmdir(mtp.TargetDir,'s');

%% TeamCity
teamCity.PublishDirectory = tmpdir;
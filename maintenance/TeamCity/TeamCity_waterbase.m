function TeamCity_runtests(varargin)
%TEAMCITYRUNOETTESTS  Function that runs all tests available in the OpenEarthTools repository.
%
%   This function gathers and runs all tests in the OpenEarthTools repository.
%
%   Syntax:
%   teamcityrunoettests;
%
%   See also mtestengine mtest oetruntests

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
% Created: 15 Sep 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

try %#ok<TRYNC>
    mlock;

    %% First load oetsettings
    try
        if exist('OetTestResult.zip','file')
            delete('OetTestResult.zip');
        end
        if exist('OetTestResult.mat','file')
            delete('OetTestResult.mat');
        end

        TeamCity_initialize;

    catch me
        TeamCity.postmessage('message', 'text', 'Matlab was unable to run oetsettings.',...
            'errorDetails',me.getReport,...
            'status','ERROR');
        TeamCity.postmessage('progressFinish','Run Oetsettings');
        TeamCity.postmessage('buildStatus',...
                'status','FAILURE',...
                'text', 'FAILURE: Matlab was unable to run oetsettings.');
%            rethrow(me);
         exit;
    end

    OPT = struct(...
        'TestsMainDir',[],...
        'Category','all',...
        'PublishCoverage',false,...
        'RunDir',cd,...
        'RevisionNumber',NaN);

    if nargin > 0
        try
            OPT = setproperty(OPT,varargin);
            if ~isempty(OPT.TestsMainDir)
                TeamCity.postmessage('message', 'text', ['Add tests directory:',char(10),OPT.TestsMainDir]);
                tempcd = cd;
                cd(OPT.TestsMainDir);
                oettestsettings;
                cd(tempcd);
                TeamCity.postmessage('message', 'text', 'Finished adding tests');
            end
        catch me
            TeamCity.postmessage('message', 'text', 'Matlab was unable to set options or add the main dir of the test data.',...
                'errorDetails',me.getReport,...
                'status','ERROR');
            TeamCity.postmessage('buildStatus',...
                'status','FAILURE',...
                'text', 'FAILURE: Matlab was unable to set options or add the main dir of the test data.');
        end
    end
    try
        TeamCity.postmessage('progressStart','Prepare MTestRunner');
        %% initiate variables:
        maindir = oettestroot;
        targetdir = fullfile(oetroot,'teamcitytesthtml');
        if isdir(targetdir)
            rmdir(targetdir,'s');
        end

        %% Create testengine
        mtr = MTestRunner(...
            'MainDir'       ,maindir,...
            'Recursive'     ,true,...
            'Verbose'       ,true,...
            'IncludeCoverage',OPT.PublishCoverage);

        TeamCity.postmessage('progressFinish','Prepare MTestRunner');

        %% Collect tests that need to be run
        TeamCity.postmessage('progressStart','Collect Tests');
        mtr.gathertests;
        collectedTestCategories = [mtr.Tests.Category]';

        % Check which tests we have to run
        if strcmp(OPT.Category,'all')
            id = true(size(collectedTestCategories)) & ...
            collectedTestCategories ~= MTestCategory.UserInput &...
            collectedTestCategories ~= MTestCategory.WorkInProgress;
        else
            id = collectedTestCategories  == str2category(OPT.Category);
        end

        mtr.Tests(~id)=[];
        if isempty(mtr.Tests)
            % exit because we do not have any test in this category
            TeamCity.postmessage('progressMessage', 'No tests were found under this category.');
            TeamCity.postmessage('progressFinish','Collect Tests');
            exit
        end

        TeamCity.postmessage('progressMessage', ['Identified ' num2str(length(mtr.Tests)) ' tests within the specified category ("' OPT.Category '")']);
        TeamCity.postmessage('progressFinish','Collect Tests');

        %% Run tests
        TeamCity.postmessage('progressStart','Run Tests');
        mtr.run;
        TeamCity.postmessage('progressFinish','Run Tests');

        %% Remove template files
        if exist(fullfile(targetdir,'mxdom2defaulthtml.xsl'),'file')
            delete(fullfile(targetdir,'mxdom2defaulthtml.xsl'));
        end

        if any(~[mtr.Tests.Ignore]) && OPT.PublishCoverage
            TeamCity.postmessage('progressStart','Publish coverage');

            TeamCity.postmessage('progressMessage', 'Remove coverage target dir.');
            targetDir = fullfile(OPT.RunDir,'OetTestCoverage');
            if isdir(targetDir)
                rmdir(targetDir,'s');
            end

            TeamCity.postmessage('progressMessage', 'Calculate and publish coverage.');
            mtp = MTestPublisher(...
                'Publish',true,...
                'Verbose',true,...
                'TargetDir',targetDir,...
                'OutputDir',targetDir);
            mtp.publishcoverage(mtr.ProfileInfo);

            TeamCity.postmessage('progressFinish','Publish coverage');
        end

        %% save test info
        TeamCity.postmessage('progressMessage', 'Save result.');
        OetTestResult = struct(...
            'Revisionnumber',OPT.RevisionNumber,...
            'Date',datestr(now),...
            'TestRunner',mtr,...
            'TeamCity',TeamCity,...
            'OPT',OPT);
        save('OetTestResult.mat','OetTestResult');

    catch me
        try %#ok<TRYNC>
            TeamCity.postmessage('message',...
                'text','error detailes:',...
                'errorDetails',me.getReport,...
                'status','ERROR');
            TeamCity.postmessage('buildStatus',...
                'status','FAILURE',...
                'text', 'FAILURE: Something went wrong while running the tests.');
        end
%            rethrow(me);
         exit;
    end
end
exit;
end

function cat = str2category(str)
switch str
    case 'Integration'
        cat = MTestCategory.Integration;
    case 'DataAccess'
        cat = MTestCategory.DataAccess;
    case 'Performance'
        cat = MTestCategory.Performance;
    case 'Unit'
        cat = MTestCategory.Unit;
    case 'UserInput'
        cat = MTestCategory.UserInput;
    case 'WorkInProgress'
        cat = MTestCategory.WorkInProgress;
end
end

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
        oetdir = strrep(fileparts(mfilename('fullpath')),'maintenance\TeamCity','');
        addpath(oetdir);
        addpath(genpath(fullfile(oetdir,'maintenance')));
        TeamCity.running(true);
        TeamCity.postmessage('progressStart','Running oetsettings.');
        oetsettings;
        TeamCity.postmessage('progressFinish','Oetsettings enabled.');
    catch me
        TeamCity.postmessage('buildStatus',...
                'status','FAILED',...
                'text', 'FAILED Matlab was unable to run oetsettings.');
        TeamCity.postmessage('message', 'text', 'Matlab was unable to run oetsettings.',...
            'errorDetails',me.getReport,...
            'status','ERROR');
%            rethrow(me);
         exit;
    end
    
    OPT = struct(...
        'TestDataMainDir',[],...
        'Category','all',...
        'Publish',true,...
        'RevisionNumber',NaN);

    if nargin > 0
        try
            OPT = setproperty(OPT,varargin);
            if ~isempty(OPT.TestDataMainDir)
                TeamCity.postmessage('message', 'text', ['Add test data directory:',char(10),OPT.TestDataMainDir]);
                addpath(genpath(OPT.TestDataMainDir));
                TeamCity.postmessage('message', 'text', 'Finished adding test data');
            end
        catch me
            TeamCity.postmessage('buildStatus',...
                'status','FAILED',...
                'text', 'FAILED Matlab was unable to set options or add the main dir of the test data.');
            TeamCity.postmessage('message', 'text', 'Matlab was unable to set options or add the main dir of the test data.',...
                'errorDetails',me.getReport,...
                'status','ERROR');
        end
    end
    try
        TeamCity.postmessage('progressStart','Prepare for running tests.');
        %% initiate variables:
        maindir = oetroot;
        targetdir = fullfile(oetroot,'teamcitytesthtml');
        if isdir(targetdir)
            rmdir(targetdir,'s');
        end

        exclusions = {...
            '.svn',...
            '_tutorial',...
            '_exclude',...
            'KML_testdir',...
            'maintenance'...
            ...
            ... DelftDashboard stuff
            'xml_toolbox',...
            'GeoImage',...
            ...
            ... io stuff (one of the tests gives a java heap space error)
            'h4tools',...
            'netcdf',...
            'sqltools'...
            };

        %% Create testengine
        mtr = MTestRunner(...
            'MainDir'       ,maindir,...
            'Recursive'     ,true,...
            'TargetDir'     ,targetdir,...
            'Exclusions'    ,exclusions,...
            'Verbose'       ,true,...
            'CopyMode'      ,'svnkeep',...
            'IncludeCoverage',false,...
            'Publish'       ,OPT.Publish,...
            'Template'      ,'oet');

        %% Collect tests that need to be run
        mtr.cataloguetests;
        collectedTestCategories = {mtr.Tests.Category}';
       
        % Check which tests we have to run
        if strcmp(OPT.Category,'all')
            id = true(size(collectedTestCategories));
        elseif strcmpi(OPT.Category,'Unit')
            % Category is Unit (all tests that are not assigned to another category)
            predefinedTestCategories = {'Performance','Integration','Regression','DataAccess','all','Unit'};
            id = ~ismember(collectedTestCategories,predefinedTestCategories) | strcmpi(collectedTestCategories,'Unit') | strcmpi(collectedTestCategories,'all');
        else
            id = strcmpi(collectedTestCategories,OPT.Category);
        end
        
        mtr.Tests(~id)=[];
        if isempty(mtr.Tests)
            % exit because we do not have any test in this category
            TeamCity.postmessage('message', 'text', 'No tests were found under this category.');
            TeamCity.postmessage('progressFinish','Tests finished.');
            exit
        end
        
        TeamCity.postmessage('progressFinish', ['Identified ' num2str(length(mtr.Tests)) ' tests within the specified category ("' OPT.Category '")']);
        
        %% Run tests
        TeamCity.postmessage('progressStart','Running tests.');
        mtr.run;
        TeamCity.postmessage('progressFinish','Tests finished.');

        %% Remove template files
        delete(fullfile(targetdir,'mxdom2defaulthtml.xsl'));

        %% zip result and remove target dir
        if OPT.Publish
            delete('OetTestResult.zip');
            zip('OetTestResult',{fullfile(targetdir,'*.*')});
            rmdir(targetdir,'s');
        end

        %% save test info
        OetTestResult = struct(...
            'Revisionnumber',OPT.RevisionNumber,...
            'Date',datestr(now),...
            'TestRunner',mtr,...
            'TeamCity',TeamCity,...
            'OPT',OPT);
        save('OetTestResult.mat','OetTestResult');
        
    catch me
        try %#ok<TRYNC>
            TeamCity.postmessage('buildStatus',...
                'status','FAILED',...
                'text', 'FAILED Something went wrong while running the tests.');
            TeamCity.postmessage('message',...
                'text','error detailes:',...
                'errorDetails',me.getReport,...
                'status','ERROR');
        end
%            rethrow(me);
         exit;
    end
end
exit;

classdef MTestRunner < handle
    % MTESTRUNNER - Object to autmatically run tests in a toolbox
    %
    % The mtest object is designed to run and publish a large amount of tests. Based on a main
    % directory it can assamble all tests in the dir (and/or subdir if specified) and convert the
    % test definition files to mtest objects. With its methods run and runAndPublish the tests can
    % be run as well.
    %
    % Publishing the results is done based on a template (which is the default deltares template if
    % not specified and created).
    %
    % See also MTestRunner.MTestRunner MTestRunner.gathertests MTestRunner.run MTest TeamCity
    
    %% Copyright notice
    %     Copyright (c) 2008  DELTARES.
    %
    %       Pieter van Geer
    %
    %       Pieter.vanGeer@deltares.nl
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
    
    %% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
    % Created: $date(dd mmm yyyy)
    % Created with Matlab version: $version
    
    % $Id$
    % $Date$
    % $Author$
    % $Revision$
    % $HeadURL$
    % $Keywords: $
    
    %% Properties
    properties
        MainDir = cd;                   % Main directory of the tests
        Recursive = true;               % Recursive determines whether the engine searches for tests in the maindir only or in subdirs as well
        Verbose = false;                % Determines display messages to be posted while running (Not implemented yet).
        IncludeCoverage = true;         % Starts the profile function when a test runs

        TestID = '_test';               % ID of the test files. all files that include this string in the filename are selected as tests
        Exclusions = {'.svn','_tutorial','_exclude'};% A cell array of strings determining the test definitions that must be skipped
    end
    properties (SetObservable = true)
        Tests = MTest;                  % Stores all tests found in the maindir (and subdirs if recursive = true)
        WrongTestDefs = {};             % Files identified as testdefinitions, but unreadable.
    end
    properties
        TestsCatalogued = false;
        ProfileInfo = [];
    end
    
    %% Methods
    methods
        function obj = MTestRunner(varargin)
            %MTESTRUNNER  creates an MTestRunner object.
            %
            %   With the mtestengine object a toolbox can be examined for testdefinition files. The
            %   catalogueTests method (or function) converts all testdefinition files to mtest
            %   objects. The mtestengine object can than be used to run all tests and publish the
            %   results in html according to a nice format. This format can be manually set with the
            %   template property.
            %
            %   Syntax:
            %   obj = mtestengine('property','value')
            %
            %   Input:
            %   All input must be given in property value pairs. The properties and there
            %   requirements are listed below.
            %       targetdir   -   (dir string) The target directory where all published results
            %                       (html) will be located (default is the current directory).
            %       maindir     -   (dir string) The main directory of the toolbox (default is the
            %                       current directory).
            %       recursive   -   (boolean) Determines whether just the maindir (false) is
            %                       examined for testdefinition files or also all recursive
            %                       (true, default) dirs.
            %       verbose     -   (boolean) Determines whether the user gets feedback while
            %                       running the tests (default = false). NOT IMPLEMENTED YET.
            %       testid      -   (string) A string that identifies all testdefinition files.
            %                       While catalogueing all files that contain this string in their
            %                       filenames are identified as test definitions (default = '_test').
            %       exclusion   -   (cell of strings) Files or folders with one of these strings in
            %                       their names are not considered (default = {'.svn'}).
            %       template    -   (string) name of the template (dir).
            %
            %   Output:
            %   obj     -   mtestengine object.
            %
            %   See also mtestengine mtestengine.run mtestengine.runAndPublish mtest mtestcase
            
            %% Use the setproperty function to set all properties.
            MTestUtils.setproperty(obj,varargin);
        end
        function varargout = gathertests(obj,varargin)
            %CATALOGUETESTS  Lists all tests in the maindir of the mtestobject and converts them to mtest objects.
            %
            %   This function lists all files in the maindir (and subdirs if recursive = true) of an
            %   mtestobject. Test or directory names that contain one of the exclusion strings are
            %   not taken into account. For each test an mtest object is created and stored in the
            %   mtestengine object.
            %
            %   Syntax:
            %   outobj = obj.catalogueTests;
            %   outobj = catalogueTests(obj);
            %
            %   Input:
            %   obj     -   an mtestengine object.
            %
            %   Output:
            %   outobj  -   The same mtestengine object, but with mtest objects for all tests in the
            %               maindir. It is not necessary to have an output, since the mtestengine is
            %               of type handle. This automatically adjusts all copies of the object that
            %               are in the matlab memory. The one that is in the base workspace is
            %               therefore automatically updated and does not need to be output of the
            %               function.
            %
            %   See also mtestengine mtestengine.mtestengine mtestengine.run mtestengine.runAndPublish mtest mtestcase
            
            %% initiate output
            varargout = {};
            
            if obj.Verbose
                TeamCity.postmessage('progressMessage', 'Collecting tests');
                disp('Collecting tests');
            end
                
            %% list all the tests in the toolbox
            % get directories
            if obj.Recursive
                dirs = strread(genpath(obj.MainDir), '%s', 'delimiter', pathsep);
            else
                dirs = obj.MainDir;
            end
            
            % remove all exclusion dirs
            for iexc = 1: length(obj.Exclusions)
                % find dirs containing exc in their name
                id = ~cellfun(@isempty, strfind(dirs, obj.Exclusions{iexc}));
                % remove dirs containing exc in their name
                dirs(id) = [];
            end
            
            % list the files in the dirs
            files = {};
            for i = 1:length(dirs)
                cnt = dir(dirs{i});
                cnt = cnt(~[cnt.isdir]);
                for j = 1:length(cnt)
                    [files{end+1,1} files{end+1,2} files{end+1,3}] = fileparts(fullfile(dirs{i}, cnt(j).name)); %#ok<AGROW>
                end
            end
            if isempty(files)
                obj.Tests = [];
                return
            end
            
            % isolate all test definitions
            id = ~cellfun(@isempty,strfind(files(:,2),obj.TestID)) &...
                strcmp(files(:,3),'.m');
            files(~id,:) = [];
            if isempty(files)
                return
            end
            
            % remove the exclusions
            id = false(size(files,1),1);
            for iexcl = 1:length(obj.Exclusions)
                id = id | ~cellfun(@isempty,strfind(files(:,2),obj.Exclusions{iexcl}));
            end
            files(id,:)=[];
            
            %% add read testdefinitions and store in engine
            wrongfiles = false(size(files,1),1);
            errors = cell(size(files,1),1);
            fnames = cell(size(files,1),1);
            for ifiles = 1:size(files,1)
                fnames{ifiles} = fullfile(files{ifiles,1},[files{ifiles,2} files{ifiles,3}]);
                try
                    obj.Tests(ifiles) = MTest(fnames{ifiles});
                catch me %#ok<*NASGU>
                    errors{ifiles} = me;
                    wrongfiles(ifiles) = true;
                end
            end
            obj.Tests = obj.Tests(~wrongfiles(1:length(obj.Tests)));
            obj.WrongTestDefs = cat(2,fnames(wrongfiles),errors(wrongfiles));
            
            %% store hidden prop
            obj.TestsCatalogued = true;
            
            %% assign output
            if nargout==1
                varargout{1} = obj;
            end

            if obj.Verbose
                TeamCity.postmessage('progressMessage', ['Collected ' num2str(length(obj.Tests)) ' tests']);
            end
        end
        function varargout = run(obj,varargin)
            %RUN  Runs all tests (that are in the "Test" property)
            %
            %   This function executes the run function of all mtest objects in the Tests property.
            %
            %   TODO:
            %       - include input argument to specify test numbers (instead of just all tests).
            %
            %   Syntax:
            %   outobj = obj.run;
            %   outobj = run(obj);
            %
            %   Input:
            %   obj     -   an MTestRunner object.
            %
            %   Output:
            %   outobj  -   The same MTestRunner object as the input argument obj. It is not 
            %               necessary to have an output, since the MTestRunner is of type handle. 
            %               This automatically adjusts all copies of the object that are in the 
            %               matlab memory. The one that is in the base workspace is therefore 
            %               automatically updated and does not need to be output of the function.
            %
            %   See also MTestRunner MTestRunner.MTestRunner MTestRunner.run MTest MTestFactory TeamCity
            
            %% get current dir
            startdir = cd;
            
            %% assign output
            varargout = {};
            
            %% Check if we even have tests
            if isempty(obj.Tests)
                warning('MtestEngine:NoTest','There were no tests in the maindir or one of the subdirs');
                return
            end
            
            %% Check profiler
            if obj.IncludeCoverage
                profstate = profile('status');
                BeginProfile = ~strcmp(profstate.ProfilerStatus,'on');
                if ~BeginProfile
                    if obj.Verbose
                        warning('MTestRunner:ProfilerRunning','Profiler is already running. the obtained coverage information maybe incorrect');
                    end
                end
                profile off
                profile clear
            end
            
            %% Make sure the current dir is in the searchpath
            mtestpath = path;
            addpath(cd);
            
            %% Run and Publish individual tests tests
            TeamCity.postmessage('progressMessage', 'Started running tests');
            if obj.Verbose
                disp('## start running tests ##');
            end
            
            %% First post all testdefinitions that could not be read
            if size(obj.WrongTestDefs,1)>0
                TeamCity.postmessage('testSuitStarted','name','wrong test definitions');
                for iwrongtest = 1:size(obj.WrongTestDefs,1)
                    [pt name] = fileparts(obj.WrongTestDefs{iwrongtest,1});
                    me = obj.WrongTestDefs{iwrongtest,2};
                    TeamCity.postmessage('testStarted',...
                        'name',name,...
                        'captureStandardOutput','true');
                    TeamCity.postmessage('testFailed',...
                        'name',name,...
                        'message','Error while reading test definition',...
                        'details',me.getReport);
                    TeamCity.postmessage('testFinished',...
                        'name',name,...
                        'duration',num2str(0));
                    if obj.Verbose
                        disp(['     ', name, ' Could not be interpreted as a valid testdefinition.']);
                    end
                end
                TeamCity.postmessage('testSuitFinished','name','wrong test definitions');
            end
            
            %% Loop tests and run.
            wrongtests = false(length(obj.Tests),1); % Remove? rename to failing tests?
            existingfigs = findobj('Type','figure');
            for itest = 1:length(obj.Tests)
                %% Display progress
                if isempty(obj.Tests(itest).Name)
                    obj.Tests(itest).Name = obj.Tests(itest).FileName;
                end
                if obj.Verbose
                    disp([' ' num2str(itest) '. ' obj.Tests(itest).Name ' (' obj.Tests(itest).FileName ')']);
                end
                %% Run test
                try
                    obj.Tests(itest).IncludeCoverage = obj.IncludeCoverage;
                    obj.Tests(itest).run;
                catch me
                    cd(startdir);
                    TeamCity.postmessage('testFinished',...
                        'name',obj.Tests(itest).Name);
            
                    wrongtests(itest)=true;
                    obj.WrongTestDefs{end+1} = fullfile(obj.Tests(itest).FilePath,[obj.Tests(itest).FileName '.m']);
                end
                newfigs = findobj('Type','figure');
                close(newfigs(~ismember(newfigs,existingfigs)));
            end
            obj.Tests(wrongtests) = [];
            
            %% Get profiler information
            if obj.IncludeCoverage
                if min(size(obj.Tests))>0 && ~all([obj.Tests.Ignore])
                    obj.ProfileInfo = MTestUtils.mergeprofileinfo(obj.Tests(~[obj.Tests.Ignore]).ProfilerInfo);
                else
                    profile('clear');
                    obj.ProfileInfo = profile('info');
                end
            end
            
            %% return to the previous searchpath settings
            path(mtestpath);
            
            %% assign output
            if nargout==1
                varargout{1} = obj;
            end
            
            %% Return to initial dir
            cd(startdir);
        end
    end
    methods
        function delete(this)
            this.Tests = [];
            TeamCity.destroy;
        end
    end
end
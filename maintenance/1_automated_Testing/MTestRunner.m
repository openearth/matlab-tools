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
    % See also MTestRunner.MTestRunner MTestRunner.cataloguetests MTestRunner.run MTest TeamCity
    
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
        Publish = false;                % Determines whether the publishable parts of a test get published
        Verbose = false;                % Determines display messages to be posted while running (Not implemented yet).
        IncludeCoverage = true;         % Includes a dir with html files expressing the coverage of the tests for each function

        TargetDir = cd;                 % Directory that is used to place the final html files
        TestID = '_test';               % ID of the test files. all files that include this string in the filename are selected as tests
        Exclusions = {'.svn','_tutorial','_exclude'};% A cell array of strings determining the test definitions that must be skipped
        Template = 'default';           % Overview template of the testengine results (that maybe links to the descriptiontemplate and resulttemplate).

        Tests = MTest;                  % Stores all tests found in the maindir (and subdirs if recursive = true)
        WrongTestDefs = {};             % Files identified as testdefinitions, but unreadable.
        FunctionsRun = {};              % Table that contains information about functions that were called during the tests (Cell N x 3, with columns functionname, html reference and coverage percentage).
    end
    properties (Hidden=true)
        CopyMode = [];
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
            setproperty(obj,varargin);
        end
        function varargout = cataloguetests(obj,varargin)
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
            
            %% Prepare publication
            tc = TeamCity;
            tc.Publish = obj.Publish;
            if obj.Publish
                %% subtract props
                maxwidth = [];
                id = find(strcmp(varargin,'maxwidth'));
                if ~isempty(id)
                    maxwidth = varargin{id+1};
                end
                maxheight = [];
                id = find(strcmp(varargin,'maxheight'));
                if ~isempty(id)
                    maxheight = varargin{id+1};
                end
                
                %% clear and prepare target dir
                TeamCity.postmessage('progressMessage', 'Preparing output files');
                if obj.Verbose
                    disp('Preparing output files');
                end
                if ~isdir(obj.TargetDir)
                    mkdir(obj.TargetDir);
                else
                    % list all files not being svn related or dirs.
                    fls = MTestRunner.listfiles(obj.TargetDir,'*',true);
                    fls(~cellfun(@isempty,strfind(fls(:,1),'.svn')) | strcmp(fls(:,2),'.') | strcmp(fls(:,2),'..'),:)=[];
                    if ~isempty(fls)
                        if ~isempty(obj.CopyMode)
                            button = obj.CopyMode;
                        else
                            button = questdlg({['The target directory is set to: ' obj.TargetDir];'There are already files in this directory. What do you want to do with them?'},'Target dir not empty','Remove all files and dirs','Only remove files and keep svn information','Leave all my files there','Leave all my files there');
                            if isempty(button)
                                return
                            end
                        end
                        switch button
                            case {'Leave all my files there','keep'}
                                % Do nothing
                            case {'Only remove files and keep svn information','svnkeep'}
                                % delete all files that are not svn.
                                % Do not delete dirs. (could have svn content..).
                                for ifls = 1:size(fls,1)
                                    if exist(fullfile(fls{ifls,1},fls{ifls,2}),'file') && ~isdir(fullfile(fls{ifls,1},fls{ifls,2}))
                                        delete(fullfile(fls{ifls,1},fls{ifls,2}));
                                    end
                                end
                            case {'Remove all files and dirs','remove'}
                                rmdir(obj.TargetDir,'s');
                                mkdir(obj.TargetDir);
                            otherwise
                                % also do nothing
                        end
                    end
                end
                tc = TeamCity;
                tc.PublishDirectory = fullfile(obj.TargetDir,'html');
                
                %% copy template files and dirs
                templatedir = fullfile(fileparts(mfilename('fullpath')),'templates');
                if ~isdir(templatedir)
                    error('MtestEngine:MissingTemplates','There are no templates.');
                end
                if ~isdir(fullfile(templatedir,'default'))
                    error('MtestEngine:MissingTemplates','The default template was not found.');
                end
                dirs = dir(templatedir);
                templatenames = {dirs([false false dirs(3:end).isdir]).name}';
                if ~strcmp(templatenames,obj.Template)
                    warning('MtestEngine:TemplateNotFound',['Template with the name: "' obj.Template '" was not found. Default is used instead']);
                    obj.Template = 'default';
                end
                templdir = fullfile(templatedir,obj.Template);
                
                % check the existance of template files (*.tpl)
                tplfiles = MTestRunner.listfiles(templdir,'tpl',obj.Recursive);
                tplfiles(:,1) = cellfun(@fullfile,...
                    repmat({obj.TargetDir},size(tplfiles,1),1),...
                    strrep(tplfiles(:,1),templdir,''),...
                    'UniformOutput',false);
                
                if isempty(tplfiles)
                    error('MtestEngine:WrongTemplate','There is no template file (*.tpl) in the template directory');
                end
                
                temptemplatedir = tempname;
                mkdir(temptemplatedir);
                copyfile(fullfile(templdir,'*.*'),temptemplatedir,'f');
                
                % remove all svn dirs from the template
                DirsInTemplateDir = strread(genpath(temptemplatedir),'%s',-1,'delimiter',';');
                SvnDirsInTemplateDir = DirsInTemplateDir(~cellfun(@isempty,strfind(DirsInTemplateDir,'.svn')));
                
                % remove all svn dirs from the template
                for i=1:length(SvnDirsInTemplateDir)
                    if isdir(SvnDirsInTemplateDir{i})
                        rmdir(SvnDirsInTemplateDir{i},'s');
                    end
                end
                
                % copy template to target dir
                copyfile(fullfile(temptemplatedir,'*.*'),obj.TargetDir,'f');
                rmdir(temptemplatedir,'s');
                
                publishstylesheet = dir(fullfile(templdir,'*.xsl'));
                if ~isempty(publishstylesheet)
                    publishstylesheet = fullfile(templdir,publishstylesheet.name);
                else
                    publishstylesheet = '';
                end
                
                if ~isdir(fullfile(obj.TargetDir,'html'))
                    mkdir(fullfile(obj.TargetDir,'html'));
                end
                
                %% Check profiler
                profstate = profile('status');
                BeginProfile = ~strcmp(profstate.ProfilerStatus,'on');
                if ~BeginProfile
                    if obj.Verbose
                        warning('mtestEngine:ProfilerRunning','Profiler is already running. the obtained coverage information maybe incorrect');
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
            
            %% Run each individual test.
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
                if obj.Publish
                    %% set options
                    if ~isempty(maxwidth)
                        obj.Tests(itest).MaxWidth = maxwidth;
                    end
                    if ~isempty(maxheight)
                        obj.Tests(itest).MaxHeight = maxheight;
                    end
                    if ~isempty(publishstylesheet)
                        obj.Tests(itest).StyleSheet = publishstylesheet;
                    end
                end
                %% publish description of test
                try
                    %% Disable publication and run
                    obj.Tests(itest).run(...
                        'Publish',obj.Publish,...
                        'OutputDir',fullfile(obj.TargetDir,'html'));
                catch me
                    cd(startdir);
                    if isdir(obj.Tests(itest).RunDir)
                        fclose('all');
                        rmdir(obj.Tests(itest).RunDir,'s');
                    end
                    wrongtests(itest)=true;
                    obj.WrongTestDefs{end+1} = fullfile(obj.Tests(itest).FilePath,[obj.Tests(itest).FileName '.m']);
                end
                newfigs = findobj('Type','figure');
                close(newfigs(~ismember(newfigs,existingfigs)));
            end
            obj.Tests(wrongtests) = [];
            
            if obj.Publish
                %% Get profiler information
                if min(size(obj.Tests))>0
                    obj.ProfileInfo = mergeprofileinfo(obj.Tests(~[obj.Tests.Ignore]).ProfilerInfo);
                end
                
                %% print coverage html pages
                if obj.IncludeCoverage
                    TeamCity.postmessage('progressMessage', 'Calculating test coverage');
                    if obj.Verbose
                        disp('Calculating test coverage');
                    end
                    %% create coverage dir
                    if ~isdir(fullfile(obj.TargetDir,'html','fcncoverage'))
                        mkdir(fullfile(obj.TargetDir,'html','fcncoverage'));
                    end
                    %% copy template te coverage dir
                    covtempldir = fullfile(fileparts(mfilename('fullpath')),'coverage_template');
                    
                    temptemplatedir = tempname;
                    mkdir(temptemplatedir);
                    copyfile(fullfile(covtempldir,'*.*'),temptemplatedir,'f');
                    
                    % remove all svn dirs from the template
                    DirsInTemplateDir = strread(genpath(temptemplatedir),'%s',-1,'delimiter',';');
                    SvnDirsInTemplateDir = DirsInTemplateDir(~cellfun(@isempty,strfind(DirsInTemplateDir,'.svn')));
                    
                    % remove all svn dirs from the template
                    for i=1:length(SvnDirsInTemplateDir)
                        if isdir(SvnDirsInTemplateDir{i})
                            rmdir(SvnDirsInTemplateDir{i},'s');
                        end
                    end
                    
                    % copy template to target dir
                    copyfile(fullfile(temptemplatedir,'*.*'),fullfile(obj.targetdir,'html','fcncoverage'),'f');
                    rmdir(temptemplatedir,'s');
                    
                    %% publish coverage files
                    mainfnames = {};
                    if ~isempty(obj.ProfileInfo)
                        fnames = {obj.ProfileInfo.FunctionTable.FileName}';
                        mainfnames = fnames(strncmpi(fnames,obj.maindir,length(obj.maindir)));
                        
                        obj.FunctionsRun = mtestfunction;
                        for ifunc = 1:length(obj.ProfileInfo.FunctionTable)
                            if ismember(obj.ProfileInfo.FunctionTable(ifunc).FileName,mainfnames) &&...
                                    ismember(obj.ProfileInfo.FunctionTable(ifunc).Type,{'M-subfunction','M-function'})
                                %% Create mtestfunction object
                                obj.FunctionsRun(ifunc) = mtestfunction(obj.ProfileInfo,ifunc);
                                %% construct name of outputfile
                                [dummy fn] = fileparts(obj.FunctionsRun(ifunc).functionname);
                                obj.FunctionsRun(ifunc).htmlfilename = fullfile(obj.targetdir,'html','fcncoverage',mtestfunction.constructfilename([fn '_coverage.html']));
                                %% publish coverage files.
                                obj.FunctionsRun(ifunc).publishCoverage;
                            end
                        end
                    end
                    
                    %% Loop tests and publish overview
%                         if ~isempty(obj.MainDir) && strcmp(obj.MainDir(end),filesep)
%                             obj.MainDir(end)=[];
%                         end
%                     for itest = 1:length(obj.Tests)
%                         if obj.Tests(itest).Ignore
%                             continue;
%                         end
% %                         obj.Tests(itest).publishCoverage('include',{obj.maindir},...
% %                             'resdir',fullfile(obj.targetdir,'html'),...
% %                             'coveragedir',fullfile('html','fcncoverage'));
%                     end
                end
                %% loop all tpl files and fill keywords
                TeamCity.postmessage('progressMessage', 'Printing test result and documentation to html');
                if obj.Verbose
                    disp('Printing test result and documentation to html');
                end
                for itpl = 1:size(tplfiles,1)
                    tplfilename = fullfile(tplfiles{itpl,1},tplfiles{itpl,2});
                    
                    obj.filltemplate(tplfilename);
                    
                end
                %% run any code that is in the targetdir
                mfiles = MTestRunner.listfiles(templdir,'m',obj.Recursive);
                if ~isempty(mfiles)
                    mfiles(:,1) = cellfun(@fullfile,...
                        repmat({obj.TargetDir},size(mfiles,1),1),...
                        strrep(mfiles(:,1),templdir,''),...
                        'UniformOutput',false);
                    for ifiles = 1:size(mfiles,1)
                        run(fullfile(mfiles{ifiles,1},mfiles{ifiles,2}));
                    end
                end
                
                %% try opening index.html or home.html
                tc = TeamCity;
                if ~tc.TeamCityRunning
                    if exist(fullfile(obj.TargetDir,'index.html'),'file')
                        winopen(fullfile(obj.TargetDir,'index.html'));
                    elseif exist(fullfile(obj.TargetDir,'home.html'),'file')
                        winopen(fullfile(obj.TargetDir,'home.html'));
                    end
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
    methods (Hidden=true)
        function obj = filltemplate(obj,tplfilename)
            %fillTemplate  Replaces keywords in a template file with information from an mtestengine obj.
            %
            %   This function reads the string from a template file and replaces keywords with
            %   values from the mtestengine object. Allowed keywords:
            %
            %       keywords defining a loop:
            %       <!-- ##BEGINTESTS -->/<!-- ##ENDTESTS -->
            %                               All code between these two keywords is copied and
            %                               filled (keywords are replaced by the correct
            %                               information) for each individual test. The resulting
            %                               strings are pasted successive.
            %       <!-- ##BEGINTESTCASE -->/<!-- ##ENDTESTCASE -->
            %                               In between the ##BEGINTESTS/##ENDTESTS keywords these
            %                               keywords can be placed. The ##BEGINTESTCASE and
            %                               ##ENDTESTCASE keywords are treated in the same manner as
            %                               the loop definition of the tests, but now with
            %                               the correct information of the testcases within a test.
            %       <!-- ##BEGINSUCCESSFULLTESTS -->/<!-- ##ENDSUCCESSFULLTESTS -->
            %                               TODO - write help
            %       <!-- ##BEGINUNSUCCESSFULLTESTS -->/<!-- ##ENDUNSUCCESSFULLTESTS -->
            %                               TODO - write help
            %       <!-- ##BEGINNEUTRALTESTS -->/<!-- ##ENDNEUTRALTTESTS -->
            %                               TODO - write help
            %       <!-- ##BEGINFUNCTIONCALLS -->/<!-- ##ENDFUNCTIONCALLS -->
            %                               TODO - write help
            %
            %       Including test results and results of testcases, part of a template file can
            %       look like this:
            %
            %       <!-- ##BEGINTESTS -->
            %           "Some html code that must be repeated for each test (including test keywords)
            %           <p>The name of this test is: #TESTNAME</p>
            %           <!-- ##BEGINTESTCASE -->
            %               "Some html code that must be repeated for each testcase (including testcase keywords)
            %               <p>The name of this testcase is: #TESTCASENAME</p>
            %           <!-- ##ENDTESTCASE -->
            %       <!-- ##ENDTESTS -->
            %
            %       General keywords:
            %       #POSITIVEICON           -   Is replaced by a reference to the positive icon.
            %       #NEGATVIEICON           -   Is replaced by a reference to the negative icon.
            %       #NEUTRALICON            -   Is replaced by a reference to the neutral icon.
            %       #NRTESTSTOTAL           -   Is replaced by the total number of tests in the
            %                                   mtestengine object.
            %       #NRTESTCASESTOTAL       -   Is replaced by the total number of testcases in the
            %                                   tests that are part of the mtestengine object.
            %       #NRSUCCESSFULLTESTS     -   Is replaced by the number of successfull tests
            %                                   (testresult = true).
            %       #NRUNSUCCESSFULLTESTS   -   Is replaced by the number of unsuccessfull tests
            %                                   (testresult = false).
            %       #NRNEUTRALTESTS         -   Is replaced by the number of tests that had no test
            %                                   results (testresult = NaN).
            %
            %       test keywords:
            %       #TESTDATE           -   TODO
            %       #TESTAUTHOR         -   TODO
            %       #TESTNUMBER         -   Is replaced by the location (number) of the test within
            %                               the mtestengine object. This keyword can be used to
            %                               reference a certain object or location in the file.
            %       #DESCRIPTIONHTML    -   This keyword is replaced by the location of the html
            %                               file of the test description that was created with the
            %                               publish function. The location is relative to the
            %                               targetdir.
            %       #RESULTHTML         -   This keyword is replaced by the location of the html
            %                               file of the published results that was created with the
            %                               publish function. The location is relative to the
            %                               targetdir.
            %       #TESTNAME           -   This keyword is replaced by the name of the test.
            %
            %       testcase keywords:
            %       #TESTCASENAME       -   This keyword is replaced by the name of the testcase.
            %       #TESTCASENUMBER     -   This keyword is replaced by the number of the testcase.
            %       #DESCRIPTIONHTML    -   This keyword is replaced by the location of the
            %                               published html file of the testcase description. The
            %                               location is relative to the target dir.
            %       #RESULTHTML         -   This keyword is replaced by the location of the
            %                               published html file of the test results. The
            %                               location is relative to the target dir.
            %
            %       function call keywords:
            %       #FUNCTIONFULLNAME   -   Is replaced by the name of the function
            %       #FUNCTIONHTML       -   Is replaced by the html reference to the published
            %                               coverage report.
            %       #FUNCTIONCOVERAGE   -   Is replaced by the percentage of lines that was run
            %
            %       specifying variable icons:
            %       #ICON               -   This keyword is replaced with the reference to an icon
            %                               specifying whether the current test or testcase was
            %                               successfull, unsuccessfull or did not produce a
            %                               testresult.
            %       The relative paths to these three icons can be specified in the template with
            %       the following phrase (usually placed at the end of a tpl file):
            %
            %       <!-- ##ICONS -->
            %       <!-- #POSITIVE='relative path to the icon indicating a positive result' -->
            %       <!-- #NEUTRAL='relative path to the icon indicating no testresult' -->
            %       <!-- #NEGATIVE='relative path to the icon indicating a negative result' -->
            %       <!-- ##ENDICONS -->
            %
            %   Syntax:
            %   outobj = obj.fillTemplate(tplfilename);
            %   fillTemplate(obj,tplfilename)
            %
            %   Input:
            %   obj         -   an mtestengine object.
            %   tplfilename -   Full path to the tpl file in the target dir.
            %
            %   Output:
            %   outobj  -   The same mtestengine object that entered the function.
            %
            %   See also mtestengine mtestengine.mtestengine mtestengine.run mtestengine.runAndPublish mtest mtestcase
            
            %% Check if the file was there
            if ~exist(tplfilename,'file')
                return
            end
            
            %% Acquire template string
            fid = fopen(tplfilename);
            str = fread(fid,'*char')';
            fclose(fid);
            
            ends = strfind(str,'-->');
            
            %% Get icons (positive and negative result)
            idbeg = strfind(str,'#ICONS');
            idend = strfind(str,'#ENDICONS');
            idPos = strfind(str,'#POSITIVE');
            idPos(idPos>idend | idPos<idbeg) = [];
            
            positiveIm = '';
            if ~isempty(idPos)
                positiveIm = strtrim(str(idPos+10:min(ends(ends>idPos))-1));
            else
                % copy and reference default icon?
            end
            
            idNeg = strfind(str,'#NEGATIVE');
            idNeg(idNeg>idend | idNeg<idbeg) = [];
            negativeIm = '';
            if ~isempty(idNeg)
                negativeIm = strtrim(str(idNeg+10:min(ends(ends>idNeg))-1));
            else
                % copy and reference default icon?
            end
            
            idNeutral = strfind(str,'#NEUTRAL');
            idNeutral(idNeutral>idend | idNeutral<idbeg) = [];
            neutralIm = '';
            if ~isempty(idNeutral)
                neutralIm = strtrim(str(idNeutral+9:min(ends(ends>idNeutral))-1));
            else
                % copy and reference default icon?
            end
            
            %% replace general keywords
            % #POSITIVEICON
            % #NEGATVIEICON
            % #NEUTRALICON
            % #NRSUCCESSFULLTESTS
            % #NRUNSUCCESSFULLTESTS
            % #NRNEUTRALTESTS
            % #NRTESTSTOTAL
            % #NRTESTCASESTOTAL
            
            str = strrep(str,'#POSITIVEICON',positiveIm);
            str = strrep(str,'#NEGATIVEICON',negativeIm);
            str = strrep(str,'#NEUTRALICON',neutralIm);
            tr = cat(1,obj.Tests(:).TestResult);
            str = strrep(str,'#NRSUCCESSFULLTESTS',num2str(sum(tr(~isnan(tr)))));
            str = strrep(str,'#NRUNSUCCESSFULLTESTS',num2str(sum(tr(~isnan(tr))==0)));
            str = strrep(str,'#NRNEUTRALTESTS',num2str(sum(isnan(tr))));
            str = strrep(str,'#NRTESTSTOTAL',num2str(length(obj.Tests)));
            
            %% Loop all tests
            str = obj.loopandfilltests(str,...
                '##BEGINTESTS',...
                '##ENDTESTS',...
                true(size(obj.Tests)),...
                positiveIm,...
                negativeIm,...
                neutralIm);
            
            %% Loop successfulltests
            str = obj.loopandfilltests(str,...
                '##BEGINSUCCESSFULLTESTS',...
                '##ENDSUCCESSFULLTESTS',...
                ~(isnan([obj.Tests.TestResult]) | [obj.Tests(:).TestResult]==false),...
                positiveIm,...
                negativeIm,...
                neutralIm);
            
            %% Loop unsuccessfulltests
            str = obj.loopandfilltests(str,...
                '##BEGINUNSUCCESSFULLTESTS',...
                '##ENDUNSUCCESSFULLTESTS',...
                ~(isnan([obj.Tests.TestResult]) | [obj.Tests(:).TestResult]==true),...
                positiveIm,...
                negativeIm,...
                neutralIm);
            
            %% Loop neutral test
            str = obj.loopandfilltests(str,...
                '##BEGINNEUTRALTESTS',...
                '##ENDNEUTRALTESTS',...
                isnan([obj.Tests(:).TestResult]),...
                positiveIm,...
                negativeIm,...
                neutralIm);
            
            %% Loop called functions
            str = obj.loopandfillfunctions(str);
            
            %% Write output file (replace .tpl with .html)
            [pt fname] = fileparts(tplfilename);
            [emptydummy fname ext] = fileparts(fname); %#ok<*ASGLU>
            if ~isempty(ext)
                fullfname = fullfile(pt,[fname ext]);
            else
                fullfname = fullfile(pt,[fname '.html']);
            end
            fid = fopen(fullfname,'w');
            fprintf(fid,'%s',str);
            fclose(fid);
            
            %% Remove tpl file from target dir
            delete(tplfilename);
        end
        function str = loopandfillfunctions(obj,str)
            ends = strfind(str,'-->');
            if ~isempty(strfind(str,'##BEGINFUNCTIONCALLS'))
                begstrids = strfind(str,'##BEGINFUNCTIONCALLS');
                idteststrends = strfind(str,'##ENDFUNCTIONCALLS')-6;
                for istr = length(begstrids):-1:1
                    idteststrbegin = min(ends(ends>begstrids(istr)))+4;
                    idteststrend = idteststrends(istr)-6;
                    funcstr = str(idteststrbegin:idteststrend);
                    str = strrep(str,funcstr,'#@#FUNCTIONSTRING');
                    %% Loop tests
                    finalstr = '';
                    for icall = 1:length(obj.FunctionsRun)
                        %% create functionstring and replace keywords
                        % #FUNCTIONFULLNAME
                        % #FUNCTIONHTML
                        % #FUNCTIONCOVERAGE
                        
                        if isempty(strfind(lower(obj.FunctionsRun(icall).filename),lower(obj.MainDir)))
                            continue
                        end
                        tempstr = funcstr;
                        
                        % #FUNCTIONFULLNAME
                        tempstr = strrep(tempstr,'#FUNCTIONFULLNAME',code2html(obj.FunctionsRun(icall).functionname));
                        
                        % #FUNCTIONHTML
                        htmlref = strrep(obj.FunctionsRun(icall).htmlfilename,fullfile(obj.TargetDir),'');
                        if strcmp(htmlref(1),filesep)
                            htmlref = htmlref(2:end);
                        end
                        tempstr = strrep(tempstr,'#FUNCTIONHTML',strrep(htmlref,filesep,'/'));
                        
                        % #FUNCTIONCOVERAGE
                        tempstr = strrep(tempstr,'#FUNCTIONCOVERAGE',num2str(obj.FunctionsRun(icall).coverage,'%0.1f'));
                        
                        %% concatenate teststrings
                        finalstr = cat(2,finalstr,tempstr);
                    end
                    
                    %% replace the test loop with the teststring.
                    str = strrep(str,'#@#FUNCTIONSTRING',finalstr);
                    
                end
            end
        end
        function str = loopandfilltests(obj,str,beginstring,endstring,testid,positiveIm,negativeIm,neutralIm)
            %% Find string that must be looped (replace with '#@#TESTSTRTING')
            ends = strfind(str,'-->');
            
            if ~isempty(strfind(str,beginstring))
                begstrids = strfind(str,beginstring);
                idteststrends = strfind(str,endstring)-6;
                for istr = length(begstrids):-1:1
                    idteststrbegin = min(ends(ends>begstrids(istr)))+4;
                    idteststrend = idteststrends(istr)-6;
                    teststr = str(idteststrbegin:idteststrend);
                    str = strrep(str,teststr,'#@#TESTSTRING');
                    
                    %% Loop tests
                    finalstr = '';
                    testid = find(testid);
                    for itest = 1:length(testid)
                        %% create teststring and replace keywords
                        % #TESTNUMBER
                        % #ICON
                        % #TESTNAME
                        % #DESCRIPTIONHTML
                        % #COVERAGEHTML
                        % #RESULTHTML
                        % #TESTDATE
                        % #TESTAUTHOR
                        % #TESTTIME
                        
                        id = testid(itest);
                        
                        tempstr = teststr;
                        % #TESTNUMBER
                        tempstr = strrep(tempstr,'#TESTNUMBER',num2str(id));
                        
                        % #ICON
                        if obj.Tests(id).Ignore
                            tempstr = strrep(tempstr,'#ICON',neutralIm);
                        elseif obj.Tests(id).TestResult
                            tempstr = strrep(tempstr,'#ICON',positiveIm);
                        else
                            tempstr = strrep(tempstr,'#ICON',negativeIm);
                        end
                        
                        % #TESTNAME
                        if ~isempty(obj.Tests(id).Name)
                            tempstr = strrep(tempstr,'#TESTNAME',obj.Tests(id).Name);
                        else
                            tempstr = strrep(tempstr,'#TESTNAME',obj.Tests(id).FileName);
                        end
                        
                        
                        % #TESTHTML (backwards compatibility)
                        % #DESCRIPTIONHTML
                        tc = TeamCity;
                        fNameDescription = fullfile(tc.PublishDirectory,[obj.Tests(id).FileName,'_description.html']);
                        if exist(fNameDescription,'file')
                            [dum fn ext] = fileparts(fNameDescription);
                            tempstr = strrep(tempstr,'#TESTHTML',strrep(fullfile('html',[fn ext]),filesep,'/'));
                            tempstr = strrep(tempstr,'#DESCRIPTIONHTML',strrep(fullfile('html',[fn ext]),filesep,'/'));
                        else
                            tempstr = strrep(tempstr,'#TESTHTML','');
                            tempstr = strrep(tempstr,'#DESCRIPTIONHTML','');
                        end
                        
%                         % #COVERAGEHTML
%                         if ~isempty(obj.tests(id).coverageoutputfile)
%                             [dum fn ext] = fileparts(obj.tests(id).coverageoutputfile);
%                             tempstr = strrep(tempstr,'#COVERAGEHTML',strrep(fullfile('html',[fn ext]),filesep,'/'));
%                         else
%                             tempstr = strrep(tempstr,'#COVERAGEHTML','');
%                         end
                        
                        % #RESULTHTML
                        fNamePublish = fullfile(tc.PublishDirectory,[obj.Tests(id).FileName,'_publish.html']);
                        if exist(fNamePublish,'file')
                            [dum fn ext] = fileparts(fNamePublish);
                            tempstr = strrep(tempstr,'#RESULTHTML',strrep(fullfile('html',[fn ext]),filesep,'/'));
                        else
                            tempstr = strrep(tempstr,'#RESULTHTML','');
                        end

                        
                        % #TESTDATE
                        if isempty(obj.Tests(id).Date)
                            obj.Tests(id).Date = NaN;
                        end
                        if isnan(obj.Tests(id).Date)
                            tempstr = strrep(tempstr,'#TESTDATE','Never');
                        else
                            tempstr = strrep(tempstr,'#TESTDATE',datestr(obj.Tests(id).Date,'yyyy-mm-dd (HH:MM:ss)'));
                        end
                        
                        % #TESTAUTHOR
                        if isempty(obj.Tests(id).Author)
                            tempstr = strrep(tempstr,'#TESTAUTHOR','Unknown');
                        else
                            tempstr = strrep(tempstr,'#TESTAUTHOR',obj.Tests(id).Author);
                        end
                        
                        % #TESTTIME
                        tempstr = strrep(tempstr,'#TESTTIME',num2str(obj.Tests(id).Time,'%0.1f (s)'));
                        
                        %% concatenate teststrings
                        finalstr = cat(2,finalstr,tempstr);
                    end
                    
                    %% replace the test loop with the teststring.
                    str = strrep(str,'#@#TESTSTRING',finalstr);
                end
            else
                return
            end
        end
    end
    methods (Hidden=true, Static=true)
        function filescell = listfiles(basedir,extension,recursive)
            filescell = [];
            if recursive
                drs = strread(genpath(basedir),'%s',-1,'delimiter',';');
                drs(~cellfun(@isempty,strfind(drs,'.svn')))=[];
                for idirs = 1:length(drs)
                    tempstruct = dir(fullfile(drs{idirs},['*.' extension]));
                    if ~isempty(tempstruct)
                        dr = fullfile(basedir,strrep(drs{idirs},basedir,''));
                        newfiles = cell(length(tempstruct),2);
                        newfiles(:,1) = {dr};
                        newfiles(:,2) = {tempstruct.name}';
                        filescell = cat(1,filescell,newfiles);
                    end
                end
            else
                tplflsstruct = dir(fullfile(basedir,'*.tpl'));
                filescell = cell(length(tplflsstruct),2);
                filescell(:,2) = {tplflsstruct.name}';
                filescell(:,1) = {obj.targetdir};
            end
        end
    end
end
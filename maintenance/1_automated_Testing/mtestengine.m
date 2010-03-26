classdef mtestengine < handle
    % MTESTENGINE - Object to autmatically run tests in a toolbox
    %
    % The mtest object is designed to run and publish a large amount of tests. Based on a main
    % directory it can assamble all tests in the dir (and/or subdir if specified) and convert the
    % test definition files to mtest objects. With its methods run and runAndPublish the tests can
    % be run as well.
    %
    % Publishing the results is done based on a template (which is the default deltares template if
    % not specified and created).
    %
    % See also mtestengine.mtestengine mtestengine.catalogueTests mtestengine.run mtestengine.runAndPublish mtest mtestcase
    
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
        targetdir = cd;                 % Directory that is used to place the final html files
        
        maindir = cd;                   % Main directory of the tests
        recursive = true;               % Recursive determines whether the engine searches for tests in the maindir only or in subdirs as well
        verbose = false;                % Determines display messages to be posted while running (Not implemented yet).
        includecoverage = true;         % Includes a dir with html files expressing the coverage of the tests for each function
        
        testid = '_test';               % ID of the test files. all files that include this string in the filename are selected as tests
        exclusion = {'.svn','_tutorial'};% A cell array of strings determining the test definitions that must be skipped
        
        template = 'default';           % Overview template of the testengine results (that maybe links to the descriptiontemplate and resulttemplate).
        
        tests = mtest;                  % Stores all tests found in the maindir (and subdirs if recursive = true)
        
        wrongtestdefs = {};             % Files identified as testdefinitions, but unreadable.
        
        functionsrun = {};              % Table that contains information about functions that were called during the tests (Cell N x 3, with columns functionname, html reference and coverage percentage).
    end
    properties (Hidden=true)
        copymode = [];
        testscatalogued = false;
        profInfo = [];
        postteamcity = false;           % prints a teamcity log file.
    end
    
    %% Methods
    methods
        function obj = mtestengine(varargin)
            %MTESTENGINE  creates an mtestengine object.
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
            
            %% Use the setProperty function to set all properties.
            setProperty(obj,varargin);
        end
        function varargout = catalogueTests(obj,varargin)
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
            
            %% list all the tests in the toolbox
            % get directories
            if obj.recursive
                dirs = strread(genpath(obj.maindir), '%s', 'delimiter', pathsep);
            else
                dirs = obj.maindir;
            end
            
            % remove all exclusion dirs
            for iexc = 1: length(obj.exclusion)
                % find dirs containing exc in their name
                id = ~cellfun(@isempty, strfind(dirs, obj.exclusion{iexc}));
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
                return
            end
            
            % isolate all test definitions
            id = ~cellfun(@isempty,strfind(files(:,2),obj.testid)) &...
                strcmp(files(:,3),'.m');
            files(~id,:) = [];
            if isempty(files)
                return
            end
            
            % remove the exclusions
            id = false(size(files,1),1);
            for iexcl = 1:length(obj.exclusion)
                id = id | ~cellfun(@isempty,strfind(files(:,2),obj.exclusion{iexcl}));
            end
            files(id,:)=[];
            
            %% add read testdefinitions and store in engine
            wrongfiles = false(size(files,1),1);
            fnames = cell(size(files,1),1);
            for ifiles = 1:size(files,1)
                fnames{ifiles} = fullfile(files{ifiles,1},[files{ifiles,2} files{ifiles,3}]);
                try
                    obj.tests(ifiles) = mtest('filename',fnames{ifiles});
                catch me %#ok<*NASGU>
                    wrongfiles(ifiles) = true;
                end
            end
            obj.tests = obj.tests(~wrongfiles(1:length(obj.tests)));
            obj.wrongtestdefs = fnames(wrongfiles);
            
            %% store hidden prop
            obj.testscatalogued = true;
            
            %% assign output
            if nargout==1
                varargout{1} = obj;
            end
        end
        function varargout = run(obj,varargin)
            %RUN  Runs all mtest objects
            %
            %   This function executes the run function of all mtest objects in the mtestengine.
            %   After running the mtestengine does not call cleanUp. Large test results can
            %   therefore become a problem when using this run function.
            %
            %   TODO:
            %       - include input argument 'cleanUp' to cleanUp each tests after running leaving only
            %         the testresult (without a possibility to publish the results).
            %       - include input argument to specify test numbers (instead of just all tests).
            %
            %   Syntax:
            %   outobj = obj.run;
            %   outobj = run(obj);
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
            
            %% assign output
            varargout = {};
            
            %% catalogue tests if not done already
            if ~obj.testscatalogued
                obj.catalogueTests;
            end
            
            %% Make shure the current dir is in the searchpath
            pt = path;
            addpath(cd);
            
            %% Run each individual test and store results.
            wrongtests = false(length(obj.tests),1);
            for itest = 1:length(obj.tests)
                %% publish description of test
                try
                    obj.tests(itest).run;
                catch me
                    wrongtests(itest)=true;
                    obj.wrongtestdefs{end+1} = fullfile(obj.tests(itest).filepath,[obj.tests(itest).filename '.m']);
                end
            end
            obj.tests(wrongtests) = [];
            
            %% return to the previous searchpath settings
            path(pt);
            
            %% assign output
            if nargout==1
                varargout{1} = obj;
            end
        end
        function varargout = runAndPublish(obj,varargin)
            %runAndPublish  runs the mtestengine and publishes all results.
            %
            %   This function runs the mtestengine and publishes all results. First the function
            %   executest the runAndPublish function of each specified test. Second, the function
            %   publishes all results in html according to the specified template.
            %
            %   Syntax:
            %   runAndPublish(obj);
            %   obj.runAndPublish;
            %   outobj = obj.runAndPublish
            %   runAndPublish(obj,...,'property','value');
            %
            %   Input:
            %   obj     -   an mtestengine object.
            %
            %   property value pairs:
            %   maxwidth    - Maximum widht of the published figures (default = 600 px)
            %   maxheight   - Maximum height of the published figures (default = 600 px)
            %
            %   Output:
            %   outobj  -   The same mtestengine object, but with mtest objects for all tests in the
            %               maindir. It is not necessary to have an output, since the mtestengine is
            %               of type handle. This automatically adjusts all copies of the object that
            %               are in the matlab memory. The one that is in the base workspace is
            %               therefore automatically updated and does not need to be output of the
            %               function.
            %
            %               %   See also mtestengine mtestengine.mtestengine mtestengine.run mtestengine.runAndPublish mtest mtestcase
            
            %% Teamcity message
            
            
            %% get current dir
            startdir = cd;
            
            %% initiate output
            varargout = {};
            
            %% cataloguq tests if not done already
            if ~obj.testscatalogued
                if obj.verbose
                    postmessage('progressMessage',obj.postteamcity, 'Collecting tests');
                end
                obj.catalogueTests;
                if obj.verbose
                    postmessage('progressMessage',obj.postteamcity, ['Collected ' length(obj.tests) ' tests']);
                end
            end
            
            %% Check if we even have tests
            if isempty(obj.tests)
                warning('MtestEngine:NoTest','There were no tests in the maindir or one of the subdirs');
                postmessage('progressMessage',obj.postteamcity, ['Collected ' length(obj.tests) ' tests']);
                return
            end
                        
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
            if obj.verbose
                postmessage('progressMessage',obj.postteamcity, 'Preparing output files');
            end
            if ~isdir(obj.targetdir)
                mkdir(obj.targetdir);
            else
                % list all files not being svn related or dirs.
                fls = mtestengine.listfiles(obj.targetdir,'*',true);
                fls(~cellfun(@isempty,strfind(fls(:,1),'.svn')) | strcmp(fls(:,2),'.') | strcmp(fls(:,2),'..'),:)=[];
                if ~isempty(fls)
                    if ~isempty(obj.copymode)
                        button = obj.copymode;
                    else
                        button = questdlg({['The target directory is set to: ' obj.targetdir];'There are already files in this directory. What do you want to do with them?'},'Target dir not empty','Remove all files and dirs','Only remove files and keep svn information','Leave all my files there','Leave all my files there');
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
                            rmdir(obj.targetdir,'s');
                            mkdir(obj.targetdir);
                        otherwise
                            % also do nothing
                    end
                end
            end
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
            if ~strcmp(templatenames,obj.template)
                warning('MtestEngine:TemplateNotFound',['Template with the name: "' obj.template '" was not found. Default is used instead']);
                obj.template = 'default';
            end
            templdir = fullfile(templatedir,obj.template);
            
            % check the existance of template files (*.tpl)
            tplfiles = mtestengine.listfiles(templdir,'tpl',obj.recursive);
            tplfiles(:,1) = cellfun(@fullfile,...
                repmat({obj.targetdir},size(tplfiles,1),1),...
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
            copyfile(fullfile(temptemplatedir,'*.*'),obj.targetdir,'f');
            rmdir(temptemplatedir,'s');
            
            publishstylesheet = dir(fullfile(templdir,'*.xsl'));
            if ~isempty(publishstylesheet)
                publishstylesheet = fullfile(templdir,publishstylesheet.name);
            else
                publishstylesheet = '';
            end
            %% Make shure the current dir is added to the search path
            pt = path;
            addpath(cd);
            %% Run and Publish individual tests tests
            if ~isdir(fullfile(obj.targetdir,'html'))
                mkdir(fullfile(obj.targetdir,'html'));
            end
            
            if obj.verbose
                postmessage('progressMessage',obj.postteamcity, ['Started running tests']);
                disp('## start running tests ##');
            end
            %% Check profiler
            profstate = profile('status');
            BeginProfile = ~strcmp(profstate.ProfilerStatus,'on');
            if ~BeginProfile
                if obj.verbose
                    warning('mtestEngine:ProfilerRunning','Profiler is already running. the obtained coverage information maybe incorrect');
                end
            end
            profile off
            profile clear
            
            wrongtests = false(length(obj.tests),1);
            
            existingfigs = findobj('Type','figure');
            for itests = 1:length(obj.tests)
                %% Display progress
                if isempty(obj.tests(itests).testname)
                    obj.tests(itests).testname = obj.tests(itests).filename;
                end
                testname = obj.tests(itests).testname;
                filename = [obj.tests(itests).filename, '.m'];
                if obj.verbose
                    postmessage('testSuiteStarted',obj.postteamcity, 'name',filename);
                    postmessage('testStarted',obj.postteamcity,...
                        'name',testname,...
                        'captureStandardOutput','true');
                    disp([' ' num2str(itests) '. ' obj.tests(itests).testname]);
                end
                %% set options
                if ~isempty(maxwidth)
                    obj.tests(itests).maxwidth = maxwidth;
                end
                if ~isempty(maxheight)
                    obj.tests(itests).maxheight = maxheight;
                end
                if ~isempty(publishstylesheet)
                    obj.tests(itests).stylesheet = publishstylesheet;
                end
                %% Run and publish
                try
                    if isempty(publishstylesheet)
                        obj.tests(itests).runAndPublish(...
                            'resdir',fullfile(obj.targetdir,'html'));
                    else
                        obj.tests(itests).runAndPublish(...
                            'resdir',fullfile(obj.targetdir,'html'),...
                            'stylesheet',publishstylesheet);
                    end
                    if ~isnan(obj.tests(itests).testresult) && ~obj.tests(itests).testresult
                        % test failed
                        if obj.verbose
                            postmessage('testFailed',obj.postteamcity,...
                                'name',testname,...
                                'message','Test result was negative');
                        end
                    end
                catch me %#ok<NASGU>
                    cd(startdir);
                    if isdir(obj.tests(itests).rundir)
                        fclose('all');
                        rmdir(obj.tests(itests).rundir,'s');
                    end
                    % test failed, wrong test definition
                    if obj.verbose
                        postmessage('testFailed',obj.postteamcity,...
                            'name',testname,...
                            'message','Error while reading or executing the test. There could be an error in either the test definition or the actual test code');
                    end
                    wrongtests(itests)=true;
                    obj.wrongtestdefs{end+1} = fullfile(obj.tests(itests).filepath,[obj.tests(itests).filename '.m']);
                end
                if obj.verbose
                    postmessage('testFinished',obj.postteamcity,...
                        'name',testname,...
                        'duration',num2str(round(obj.tests(itests).time*1000)));
                    postmessage('testSuiteFinished',obj.postteamcity, 'name',filename);
                end
                newfigs = findobj('Type','figure');
                close(newfigs(~ismember(newfigs,existingfigs)));
            end
            
            obj.tests(wrongtests) = [];            
            %% Get profiler information
            if min(size(obj.tests))>0
                obj.profInfo = mergeprofileinfo(obj.tests.profinfo);
            end
            %% print coverage html pages
            if obj.includecoverage
                if obj.verbose
                    postmessage('progressMessage',obj.postteamcity, 'Printing test coverage');
                end
                %% create coverage dir
                if ~isdir(fullfile(obj.targetdir,'html','fcncoverage'))
                    mkdir(fullfile(obj.targetdir,'html','fcncoverage'));
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
                fnames = {obj.profInfo.FunctionTable.FileName}';
                mainfnames = fnames(strncmpi(fnames,obj.maindir,length(obj.maindir)));
                
                obj.functionsrun = mtestfunction;
                for ifunc = 1:length(obj.profInfo.FunctionTable)
                    if ismember(obj.profInfo.FunctionTable(ifunc).FileName,mainfnames) &&...
                            ismember(obj.profInfo.FunctionTable(ifunc).Type,{'M-subfunction','M-function'})
                        %% Create mtestfunction object
                        obj.functionsrun(ifunc) = mtestfunction(obj.profInfo,ifunc);                       
                        %% construct name of outputfile
                        [dummy fn] = fileparts(obj.functionsrun(ifunc).functionname);
                        obj.functionsrun(ifunc).htmlfilename = fullfile(obj.targetdir,'html','fcncoverage',mtestfunction.constructfilename([fn '_coverage.html']));
                        %% publish coverage files.
                        obj.functionsrun(ifunc).publishCoverage;
                    end
                end
                
                %% Loop tests and publish overview
                for itest = 1:length(obj.tests)
                    if ~isempty(obj.maindir) && strcmp(obj.maindir(end),filesep)
                        obj.maindir(end)=[];
                    end
                    obj.tests(itest).publishCoverage('include',{obj.maindir},...
                        'resdir',fullfile(obj.targetdir,'html'),...
                        'coveragedir',fullfile('html','fcncoverage'));
                    for icase = 1:length(obj.tests(itest).testcases)
                        obj.tests(itest).testcases(icase).coverageoutputfile = ...
                            fullfile(obj.targetdir,'html',[obj.tests(itest).filename,'_coverage_case_' num2str(icase) '.html']);
                        obj.tests(itest).testcases(icase).publishCoverage(...
                            'include',{obj.maindir},...
                            'resdir',fullfile(obj.targetdir,'html'),...
                            'coveragedir',fullfile('html','fcncoverage'));
                    end
                end
            end
            %% return the previous searchpath
            path(pt);
            %% loop all tpl files and fill keywords
            if obj.verbose
                postmessage('progressMessage',obj.postteamcity, 'Printing test result and documentation to html');
            end
            for itpl = 1:size(tplfiles,1)
                tplfilename = fullfile(tplfiles{itpl,1},tplfiles{itpl,2});
                
                obj.fillTemplate(tplfilename);
                
            end
            %% run any code that is in the targetdir
            mfiles = mtestengine.listfiles(templdir,'m',obj.recursive);
            if ~isempty(mfiles)
                mfiles(:,1) = cellfun(@fullfile,...
                    repmat({obj.targetdir},size(mfiles,1),1),...
                    strrep(mfiles(:,1),templdir,''),...
                    'UniformOutput',false);
                for ifiles = 1:size(mfiles,1)
                    run(fullfile(mfiles{ifiles,1},mfiles{ifiles,2}));
                end
            end
            
            %% try opening index.html or home.html
            if ~obj.postteamcity
                if exist(fullfile(obj.targetdir,'index.html'),'file')
                    winopen(fullfile(obj.targetdir,'index.html'));
                elseif exist(fullfile(obj.targetdir,'home.html'),'file')
                    winopen(fullfile(obj.targetdir,'home.html'));
                end
            end
            
            %% Set output
            if nargout == 1
                varargout = {obj};
            end
            %% Return to initial dir
            cd(startdir);
        end
    end
    methods (Hidden=true)
        function obj = fillTemplate(obj,tplfilename)
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
            tr = cat(1,obj.tests(:).testresult);
            str = strrep(str,'#NRSUCCESSFULLTESTS',num2str(sum(tr(~isnan(tr)))));
            str = strrep(str,'#NRUNSUCCESSFULLTESTS',num2str(sum(tr(~isnan(tr))==0)));
            str = strrep(str,'#NRNEUTRALTESTS',num2str(sum(isnan(tr))));
            str = strrep(str,'#NRTESTSTOTAL',num2str(length(obj.tests)));
            str = strrep(str,'#NRTESTCASESTOTAL',num2str(length([obj.tests(:).testcases])));
            
            %% Loop all tests
            str = obj.loopAndFillTests(str,...
                '##BEGINTESTS',...
                '##ENDTESTS',...
                true(size(obj.tests)),...
                positiveIm,...
                negativeIm,...
                neutralIm);
            
            %% Loop successfulltests
            str = obj.loopAndFillTests(str,...
                '##BEGINSUCCESSFULLTESTS',...
                '##ENDSUCCESSFULLTESTS',...
                ~(isnan([obj.tests.testresult]) | [obj.tests(:).testresult]==false),...
                positiveIm,...
                negativeIm,...
                neutralIm);
            
            %% Loop unsuccessfulltests
            str = obj.loopAndFillTests(str,...
                '##BEGINUNSUCCESSFULLTESTS',...
                '##ENDUNSUCCESSFULLTESTS',...
                ~(isnan([obj.tests.testresult]) | [obj.tests(:).testresult]==true),...
                positiveIm,...
                negativeIm,...
                neutralIm);
            
            %% Loop neutral test
            str = obj.loopAndFillTests(str,...
                '##BEGINNEUTRALTESTS',...
                '##ENDNEUTRALTESTS',...
                isnan([obj.tests(:).testresult]),...
                positiveIm,...
                negativeIm,...
                neutralIm);
            
            %% Loop called functions
            str = obj.loopAndFillFunctions(str);
            
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
        function str = loopAndFillFunctions(obj,str)
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
                    for icall = 1:length(obj.functionsrun)
                        %% create functionstring and replace keywords
                        % #FUNCTIONFULLNAME
                        % #FUNCTIONHTML
                        % #FUNCTIONCOVERAGE
                        
                        if isempty(strfind(lower(obj.functionsrun(icall).filename),lower(obj.maindir)))
                            continue
                        end
                        tempstr = funcstr;

                        % #FUNCTIONFULLNAME
                        tempstr = strrep(tempstr,'#FUNCTIONFULLNAME',code2html(obj.functionsrun(icall).functionname));
                        
                        % #FUNCTIONHTML
                        htmlref = strrep(obj.functionsrun(icall).htmlfilename,fullfile(obj.targetdir),'');
                        if strcmp(htmlref(1),filesep)
                            htmlref = htmlref(2:end);
                        end
                        tempstr = strrep(tempstr,'#FUNCTIONHTML',strrep(htmlref,filesep,'/'));
                        
                        % #FUNCTIONCOVERAGE
                        tempstr = strrep(tempstr,'#FUNCTIONCOVERAGE',num2str(obj.functionsrun(icall).coverage,'%0.1f'));
                        
                        %% concatenate teststrings
                        finalstr = cat(2,finalstr,tempstr);
                    end
                    
                    %% replace the test loop with the teststring.
                    str = strrep(str,'#@#FUNCTIONSTRING',finalstr);

                end
            end
        end
        function str = loopAndFillTests(obj,str,beginstring,endstring,testid,positiveIm,negativeIm,neutralIm)
            %% Find string that must be looped (replace with '#@#TESTSTRTING')
            ends = strfind(str,'-->');
            
            testCaseStringToBeFilled = false;
            if ~isempty(strfind(str,beginstring))
                begstrids = strfind(str,beginstring);
                idteststrends = strfind(str,endstring)-6;
                for istr = length(begstrids):-1:1
                    idteststrbegin = min(ends(ends>begstrids(istr)))+4;
                    idteststrend = idteststrends(istr)-6;
                    teststr = str(idteststrbegin:idteststrend);
                    str = strrep(str,teststr,'#@#TESTSTRING');
                    if ~isempty(strfind(teststr,'##BEGINTESTCASE'))
                        testCaseStringToBeFilled = true;
                        ends2 = strfind(teststr,'-->');
                        idtestcasestrbegin = min(ends2(ends2>strfind(teststr,'##BEGINTESTCASE')))+4;
                        idtestcasestrend = strfind(teststr,'##ENDTESTCASE')-6;
                        testcasestr = teststr(idtestcasestrbegin:idtestcasestrend);
                        teststr = strrep(teststr,testcasestr,'#@#TESTCASESTRING');
                    end
                    
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
                        if isnan(obj.tests(id).testresult)
                            tempstr = strrep(tempstr,'#ICON',neutralIm);
                        elseif obj.tests(id).testresult
                            tempstr = strrep(tempstr,'#ICON',positiveIm);
                        else
                            tempstr = strrep(tempstr,'#ICON',negativeIm);
                        end
                        
                        % #TESTNAME
                        if ~isempty(obj.tests(id).testname)
                            tempstr = strrep(tempstr,'#TESTNAME',obj.tests(id).testname);
                        else
                            tempstr = strrep(tempstr,'#TESTNAME',obj.tests(id).filename);
                        end
                        
                        % #TESTHTML (backwards compatibility)
                        % #DESCRIPTIONHTML
                        [dum fn ext] = fileparts(obj.tests(id).descriptionoutputfile);
                        tempstr = strrep(tempstr,'#TESTHTML',strrep(fullfile('html',[fn ext]),filesep,'/'));
                        tempstr = strrep(tempstr,'#DESCRIPTIONHTML',strrep(fullfile('html',[fn ext]),filesep,'/'));
                        
                        % #COVERAGEHTML
                        [dum fn ext] = fileparts(obj.tests(id).coverageoutputfile);
                        tempstr = strrep(tempstr,'#COVERAGEHTML',strrep(fullfile('html',[fn ext]),filesep,'/'));
                        
                        % #RESULTHTML
                        [dum fn ext] = fileparts(obj.tests(id).publishoutputfile);
                        tempstr = strrep(tempstr,'#RESULTHTML',strrep(fullfile('html',[fn ext]),filesep,'/'));
                        
                        % #TESTDATE
                        if isempty(obj.tests(id).date)
                            obj.tests(id).date = NaN;
                        end
                        if isnan(obj.tests(id).date)
                            tempstr = strrep(tempstr,'#TESTDATE','Never');
                        else
                            tempstr = strrep(tempstr,'#TESTDATE',datestr(obj.tests(id).date,'yyyy-mm-dd (HH:MM:ss)'));
                        end
                        
                        % #TESTAUTHOR
                        if isempty(obj.tests(id).author)
                            tempstr = strrep(tempstr,'#TESTAUTHOR','Unknown');
                        else
                            tempstr = strrep(tempstr,'#TESTAUTHOR',obj.tests(id).author);
                        end
                        
                        % #TESTTIME
                        tempstr = strrep(tempstr,'#TESTTIME',num2str(obj.tests(id).time,'%0.1f (s)'));
                        
                        if testCaseStringToBeFilled
                            %% loop testcases
                            finalcasesstr = '';
                            for icase = 1:length(obj.tests(id).testcases)
                                %% create testcasestring and replace keywords
                                % #TESTNUMBER
                                % #TESTCASENUMBER
                                % #ICON
                                % #TESTCASENAME
                                % #DESCRIPTIONHTML
                                % #RESULTHTML
                                tempstr2 = testcasestr;
                                
                                % #TESTNUMBER
                                tempstr2 = strrep(tempstr2,'#TESTNUMBER',num2str(id));
                                
                                % #TESTCASENUMBER
                                tempstr2 = strrep(tempstr2,'#TESTCASENUMBER',num2str(obj.tests(id).testcases(icase).casenumber));
                                
                                % #ICON
                                if isnan(obj.tests(id).testcases(icase).testresult)
                                    tempstr2 = strrep(tempstr2,'#ICON',neutralIm);
                                elseif obj.tests(id).testcases(icase).testresult
                                    tempstr2 = strrep(tempstr2,'#ICON',positiveIm);
                                else
                                    tempstr2 = strrep(tempstr2,'#ICON',negativeIm);
                                end
                                
                                % #TESTCASENAME
                                tcname = ['Case ' num2str(icase)];
                                if ~isempty(obj.tests(id).testcases(icase).casename)
                                    tcname = ['Case ' num2str(icase) ' (' obj.tests(id).testcases(icase).casename ')'];
                                end
                                tempstr2 = strrep(tempstr2,'#TESTCASENAME',tcname);
                                
                                % #DESCRIPTIONHTML
                                [dum fn ext] = fileparts(obj.tests(id).testcases(icase).descriptionoutputfile);
                                tempstr2 = strrep(tempstr2,'#DESCRIPTIONHTML',strrep(fullfile('html',[fn ext]),filesep,'/'));
                                
                                % #COVERAGEHTML
                                [dum fn ext] = fileparts(obj.tests(id).testcases(icase).coverageoutputfile);
                                tempstr2 = strrep(tempstr2,'#COVERAGEHTML',strrep(fullfile('html',[fn ext]),filesep,'/'));

                                % #RESULTHTML
                                [dum fn ext] = fileparts(obj.tests(id).testcases(icase).publishoutputfile);
                                tempstr2 = strrep(tempstr2,'#RESULTHTML',strrep(fullfile('html',[fn ext]),filesep,'/'));
                                
                                %% concatenate testcase strings
                                finalcasesstr = cat(2,finalcasesstr,tempstr2);
                            end
                            
                            %% replace testcase string keyword
                            tempstr = strrep(tempstr,'#@#TESTCASESTRING',finalcasesstr);
                        end
                        %% concatenate teststrings
                        finalstr = cat(2,finalstr,tempstr);
                    end
                    
                    %% replace the test loop with the teststring.
                    str = strrep(str,'#@#TESTSTRING',finalstr);
                end
            else
                return
            end
            
            %% Loop tests
            finalstr = '';
            testid = find(testid);
            for itest = 1:length(testid)
                %% create teststring and replace keywords
                % #TESTNUMBER
                % #ICON
                % #TESTNAME
                % #DESCRIPTIONHTML
                % #RESULTHTML
                % #TESTDATE
                % #TESTAUTHOR
                % #TESTTIME
                
                id = testid(itest);
                
                tempstr = teststr;
                % #TESTNUMBER
                tempstr = strrep(tempstr,'#TESTNUMBER',num2str(id));
                
                % #ICON
                if isnan(obj.tests(id).testresult)
                    tempstr = strrep(tempstr,'#ICON',neutralIm);
                elseif obj.tests(id).testresult
                    tempstr = strrep(tempstr,'#ICON',positiveIm);
                else
                    tempstr = strrep(tempstr,'#ICON',negativeIm);
                end
                
                % #TESTNAME
                if ~isempty(obj.tests(id).testname)
                    tempstr = strrep(tempstr,'#TESTNAME',obj.tests(id).testname);
                else
                    tempstr = strrep(tempstr,'#TESTNAME',obj.tests(id).filename);
                end
                
                % #TESTHTML (backwards compatibility)
                % #DESCRIPTIONHTML
                [dum fn ext] = fileparts(obj.tests(id).descriptionoutputfile);
                tempstr = strrep(tempstr,'#TESTHTML',strrep(fullfile('html',[fn ext]),filesep,'/'));
                tempstr = strrep(tempstr,'#DESCRIPTIONHTML',strrep(fullfile('html',[fn ext]),filesep,'/'));
                
                % #RESULTHTML
                [dum fn ext] = fileparts(obj.tests(id).publishoutputfile);
                tempstr = strrep(tempstr,'#RESULTHTML',strrep(fullfile('html',[fn ext]),filesep,'/'));
                
                % #TESTDATE
                if isempty(obj.tests(id).date)
                    obj.tests(id).date = NaN;
                end
                if isnan(obj.tests(id).date)
                    tempstr = strrep(tempstr,'#TESTDATE','Never');
                else
                    tempstr = strrep(tempstr,'#TESTDATE',datestr(obj.tests(id).date,'yyyy-mm-dd (HH:MM:ss)'));
                end
                
                % #TESTAUTHOR
                if isempty(obj.tests(id).author)
                    tempstr = strrep(tempstr,'#TESTAUTHOR','Unknown');
                else
                    tempstr = strrep(tempstr,'#TESTAUTHOR',obj.tests(id).author);
                end
                
                % #TESTTIME
                tempstr = strrep(tempstr,'#TESTTIME',num2str(obj.tests(id).time,'%0.1f (s)'));
                
                if testCaseStringToBeFilled
                    %% loop testcases
                    finalcasesstr = '';
                    for icase = 1:length(obj.tests(id).testcases)
                        %% create testcasestring and replace keywords
                        % #TESTNUMBER
                        % #TESTCASENUMBER
                        % #ICON
                        % #TESTCASENAME
                        % #DESCRIPTIONHTML
                        % #RESULTHTML
                        tempstr2 = testcasestr;
                        
                        % #TESTNUMBER
                        tempstr2 = strrep(tempstr2,'#TESTNUMBER',num2str(id));
                        
                        % #TESTCASENUMBER
                        tempstr2 = strrep(tempstr2,'#TESTCASENUMBER',num2str(obj.tests(id).testcases(icase).casenumber));
                        
                        % #ICON
                        if isnan(obj.tests(id).testcases(icase).testresult)
                            tempstr2 = strrep(tempstr2,'#ICON',neutralIm);
                        elseif obj.tests(id).testcases(icase).testresult
                            tempstr2 = strrep(tempstr2,'#ICON',positiveIm);
                        else
                            tempstr2 = strrep(tempstr2,'#ICON',negativeIm);
                        end
                        
                        % #TESTCASENAME
                        tcname = ['Case ' num2str(icase)];
                        if ~isempty(obj.tests(id).testcases(icase).casename)
                            tcname = ['Case ' num2str(icase) ' (' obj.tests(id).testcases(icase).casename ')'];
                        end
                        tempstr2 = strrep(tempstr2,'#TESTCASENAME',tcname);
                        
                        % #DESCRIPTIONHTML
                        [dum fn ext] = fileparts(obj.tests(id).testcases(icase).descriptionoutputfile);
                        tempstr2 = strrep(tempstr2,'#DESCRIPTIONHTML',strrep(fullfile('html',[fn ext]),filesep,'/'));
                        
                        % #RESULTHTML
                        [dum fn ext] = fileparts(obj.tests(id).testcases(icase).publishoutputfile);
                        tempstr2 = strrep(tempstr2,'#RESULTHTML',strrep(fullfile('html',[fn ext]),filesep,'/'));
                        
                        %% concatenate testcase strings
                        finalcasesstr = cat(2,finalcasesstr,tempstr2);
                    end
                    
                    %% replace testcase string keyword
                    tempstr = strrep(tempstr,'#@#TESTCASESTRING',finalcasesstr);
                end
                %% concatenate teststrings
                finalstr = cat(2,finalstr,tempstr);
            end
            
            %% replace the test loop with the teststring.
            str = strrep(str,'#@#TESTSTRING',finalstr);
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

function postmessage(message,postteamcity,varargin)
if postteamcity
    h = tic;
    while exist('teamcitymessage.matlab','file')
        pause(0.001);
        if toc(h) > 1
            delete(which('teamcitymessage.matlab'));
        end
    end
    
    teamcityString = ['##teamcity[', message, ' '];
    if nargin/2~=round(nargin/2)
        for ivararg = 1:length(varargin)
            teamcityString = cat(2,teamcityString,'''',varargin{ivararg},'''');
        end
    else
        for ivararg = 1:2:length(varargin)
            teamcityString = cat(2,teamcityString,varargin{ivararg},'=''', varargin{ivararg+1},'''',' ');
        end
    end
    teamcityString = cat(2,teamcityString,']');
    dlmwrite('teamcitymessage.matlabtemp',...
        teamcityString,...
        'delimiter','','-append');
    % To prevent echo that is too early
    movefile('teamcitymessage.matlabtemp','teamcitymessage.matlab');
else
    disp(message);
end
end
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

        testid = '_test';               % ID of the test files. all files that include this string in the filename are selected as tests
        exclusion = {'.svn','_tutorial'};% A cell array of strings determining the test definitions that must be skipped

        template = 'default';           % Overview template of the testengine results (that maybe links to the descriptiontemplate and resulttemplate).

        tests = mtest;                  % Stores all tests found in the maindir (and subdirs if recursive = true)
        
        wrongtestdefs = {};             % Files identified as testdefinitions, but unreadable.
        
        functionsrun = {};              % Table that contains information about functions that were called during the tests (Cell N x 3, with columns functionname, html reference and coverage percentage).
    end
    properties (Hidden=true)
        testscatalogued = false;
        profInfo = [];
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
                catch me
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

            %% initiate output
            varargout = {};
            %% cataloguq tests if not done already
            if ~obj.testscatalogued
                obj.catalogueTests;
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
            if ~isdir(obj.targetdir)
                mkdir(obj.targetdir);
            else
                % list all files not being svn related or dirs.
                fls = mtestengine.listfiles(obj.targetdir,'*',true);
                fls(~cellfun(@isempty,strfind(fls(:,1),'.svn')) | strcmp(fls(:,2),'.') | strcmp(fls(:,2),'..'),:)=[];
                if ~isempty(fls)
                    button = questdlg({['The target directory is set to: ' obj.targetdir];'There are already files in this directory. What do you want to do with them?'},'Target dir not empty','Remove all files and dirs','Only remove files and keep svn information','Leave all my files there','Leave all my files there');
                    switch button
                        case 'Leave all my files there'
                            % Do nothing
                        case 'Only remove files and keep svn information'
                            % delete all files that are not svn.
                            % Do not delete dirs. (could have svn content..).
                            for ifls = 1:size(fls,1)
                                if exist(fullfile(fls{ifls,1},fls{ifls,2}),'file') && ~isdir(fullfile(fls{ifls,1},fls{ifls,2}))
                                    delete(fullfile(fls{ifls,1},fls{ifls,2}));
                                end
                            end
                        case 'Remove all files and dirs'
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
                disp('## start running tests ##');
            end
            %% Initiate profiler
            profstate = profile('status');
            BeginProfile = ~strcmp(profstate.ProfilerStatus,'on');
            if ~BeginProfile
                if obj.verbose
                    warning('mtestEngine:ProfilerRunning','Profiler is already running. the obtained coverage information maybe incorrect');
                end
                profile resume
            else
                profile clear
                profile on
            end
            
            wrongtests = false(length(obj.tests),1);
            
            for itests = 1:length(obj.tests)
                %% Display progress
                if obj.verbose
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
                catch me
                    wrongtests(itests)=true;
                    obj.wrongtestdefs{end+1} = fullfile(obj.tests(itests).filepath,[obj.tests(itests).filename '.m']);
                end
            end
            obj.tests(wrongtests) = [];
            
            %% Get profiler information
            obj.profInfo = profile('info');
            
            if BeginProfile
                profile clear
            end
            oldprefs(1) = getpref('profiler','parentDisplayMode',1);
            oldprefs(2) = getpref('profiler','busylineDisplayMode',1);
            oldprefs(3) = getpref('profiler','childrenDisplayMode',1);
            oldprefs(4) = getpref('profiler','mlintDisplayMode',1);
            oldprefs(5) = getpref('profiler','coverageDisplayMode',1);
            oldprefs(6) = getpref('profiler','listingDisplayMode',1);
            
            setpref('profiler','parentDisplayMode',0);
            setpref('profiler','busylineDisplayMode',0);
            setpref('profiler','childrenDisplayMode',0);
            setpref('profiler','mlintDisplayMode',0);
            setpref('profiler','coverageDisplayMode',1);
            setpref('profiler','listingDisplayMode',1);
            
            if ~isdir(fullfile(obj.targetdir,'fcncoverage'))
                mkdir(fullfile(obj.targetdir,'fcncoverage'));
            end
            fnames = {obj.profInfo.FunctionTable.FileName}';
            oetfnames = fnames(strncmp(fnames,openearthtoolsroot,length(openearthtoolsroot)));
            
            obj.functionsrun = {};
            for ifunc = 1:length(obj.profInfo.FunctionTable)
                if ismember(obj.profInfo.FunctionTable(ifunc).FileName,oetfnames) &&...
                        ismember(obj.profInfo.FunctionTable(ifunc).Type,{'M-subfunction','M-function'})
                    %% Create coverage html
                    functioninfo = cell(1,3);
                    [ dum functioninfo{1}] = fileparts(obj.profInfo.FunctionTable(ifunc).FunctionName);
                    
                    fcnhtml = profview(obj.profInfo.FunctionTable(ifunc).FunctionName,obj.profInfo);
                    
                    %% replace header
%                     TODO('replace stylesheet link');

                    %% filter parts
                    % forms
                    formbegins = strfind(fcnhtml,'<form');
                    formends = strfind(fcnhtml,'</form>')+6;
                    for iii=length(formbegins):-1:1
                        fcnhtml(formbegins(iii):formends(iii))=[];
                    end
                    
                    % general part
                    begid = strfind(fcnhtml,'<body>')+6;
                    endid = min(strfind(fcnhtml,'<div class="grayline"/>'))-1;
                    fcnhtml(begid:endid)=[];
                    
                    % replace hrefs with text:
                    begid = strfind(fcnhtml,'<a');
                    endid = strfind(fcnhtml,'</a>')+3;
                    for iii=length(begid):-1:1
                        href = fcnhtml(begid(iii):endid(iii));
                        tempstr = href(min(strfind(href,'>'))+1:max(strfind(href,'<'))-1);
                        fcnhtml = cat(2,fcnhtml(1:begid(iii)-1),tempstr,fcnhtml(endid(iii)+1:end));
                    end
                    
                    % remove some text
                    fcnhtml = strrep(fcnhtml,'[ Show coverage for parent directory ]<br/>','');
                    
                    % remove redundant div
                    id = min(strfind(fcnhtml,'<div class="grayline"/>'));
                    fcnhtml(id:id+length('<div class="grayline"/>')-1)=[];

                    %% retrieve stats
                    id = strfind(fcnhtml,'Coverage (did run/can run)</td><td class="td-linebottomrt">');
                    percid = strfind(fcnhtml,'%');
                    percid = min(percid(percid>id));
                    functioninfo{3} = str2double(fcnhtml(id+length('Coverage (did run/can run)</td><td class="td-linebottomrt">'):percid-1));
                    
                    %% write html file
                    [dm name] = fileparts(obj.profInfo.FunctionTable(ifunc).FunctionName);
                    functioninfo{2} = strrep(fullfile(obj.targetdir,'fcncoverage',[name '.html']),'>','_');
                    fid = fopen(functioninfo{2},'w');
                    fprintf(fid,'%s',fcnhtml);
                    fclose(fid);
                    
                    %% save info to mtestengine object
                    obj.functionsrun(size(obj.functionsrun,1)+1,1:3) = functioninfo;
                end
            end
            
            %% reset profile prefs
            setpref('profiler','parentDisplayMode',oldprefs(1));
            setpref('profiler','busylineDisplayMode',oldprefs(2));
            setpref('profiler','childrenDisplayMode',oldprefs(3));
            setpref('profiler','mlintDisplayMode',oldprefs(4));
            setpref('profiler','coverageDisplayMode',oldprefs(5));
            setpref('profiler','listingDisplayMode',oldprefs(6))
            
            %% remove temp dirs
            for itest = 1:length(obj.tests)
                if isdir(obj.tests(itest).rundir)
                    rmdir(obj.tests(itest).rundir,'s');
                end
                obj.tests(itest).tmpobjname = [];
                for itc = 1:length(obj.tests(itest).testcases)
                    if isdir(obj.tests(itest).testcases(itc).resdir)
                        rmdir(obj.tests(itest).testcases(itc).resdir,'s');
                    end
                    obj.tests(itest).testcases(itc).tmpobjname = [];
                end
            end
            
            %% return the previous searchpath
            path(pt);
            %% loop all tpl files and fill keywords
            for itpl = 1:size(tplfiles,1)
                tplfilename = fullfile(tplfiles{itpl,1},tplfiles{itpl,2});

                obj.fillTemplate(tplfilename);

            end
            %% run any code that is in the targetdir
            mfiles = mtestengine.listfiles(templdir,'m',obj.recursive);
            mfiles(:,1) = cellfun(@fullfile,...
                repmat({obj.targetdir},size(mfiles,1),1),...
                strrep(mfiles(:,1),templdir,''),...
                'UniformOutput',false);
            if ~isempty(mfiles)
                for ifiles = 1:size(mfiles,1)
                    run(fullfile(mfiles{ifiles,1},mfiles{ifiles,2}));
                end
            end
            %% try opening index.html or home.html
            if exist(fullfile(obj.targetdir,'index.html'),'file')
                winopen(fullfile(obj.targetdir,'index.html'));
            elseif exist(fullfile(obj.targetdir,'home.html'),'file')
                winopen(fullfile(obj.targetdir,'home.html'));
            end
            %% Set output
            if nargout == 1
                varargout = {obj};
            end
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
            %                               TODO
            %       <!-- ##BEGINUNSUCCESSFULLTESTS -->/<!-- ##ENDUNSUCCESSFULLTESTS -->
            %                               TODO
            %       <!-- ##BEGINNEUTRALTESTS -->/<!-- ##ENDNEUTRALTTESTS -->
            %                               TODO
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
            
            %% Write output file (replace .tpl with .html)
            [pt fname] = fileparts(tplfilename);
            [emptydummy fname ext] = fileparts(fname);
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
        function str = loopAndFillTests(obj,str,beginstring,endstring,testid,positiveIm,negativeIm,neutralIm)
            %% Find string that must be looped (replace with '#@#TESTSTRTING')
            ends = strfind(str,'-->');
            
            testStringToBeFilled = false;
            testCaseStringToBeFilled = false;
            if ~isempty(strfind(str,beginstring))
                testStringToBeFilled = true;
                idteststrbegin = min(ends(ends>strfind(str,beginstring)))+4;
                idteststrend = strfind(str,endstring)-6;
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
            end

            if ~testStringToBeFilled
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
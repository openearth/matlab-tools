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
        exclusion = {'.svn'};           % A cell array of strings determining the test definitions that must be skipped
        
        template = 'default';           % Overview template of the testengine results (that maybe links to the descriptiontemplate and resulttemplate).
                
        tests = mtest;                  % Stores all tests found in the maindir (and subdirs if recursive = true)
    end
    properties (Hidden=true)
        testscatalogued = false;
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
        function catalogueTests(obj,varargin)
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
            for ifiles = 1:size(files,1)
                fname = fullfile(files{ifiles,1},[files{ifiles,2} files{ifiles,3}]);
                obj.tests(ifiles) = mtest('filename',fname);
            end
            
            %% store hidden prop
            obj.testscatalogued = true;
            
        end
        function run(obj,varargin)
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
            
            %% catalogue tests if not done already
            if ~obj.testscatalogued
                obj.catalogueTests;
            end

            %% Make shure the current dir is in the searchpath
            pt = path;
            addpath(cd);
            
            %% Run each individual test and store results.
            for itest = 1:length(obj.tests)
                %% publish description of test
                obj.tests(itest).runTest;
            end
            
            %% return to the previous searchpath settings
            path(pt);
        end        
        function runAndPublish(obj,varargin)
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
            %               %   See also mtestengine mtestengine.mtestengine mtestengine.run mtestengine.runAndPublish mtest mtestcase            
            
            %% cataloguq tests if not done already
            if ~obj.testscatalogued
                obj.catalogueTests;
            end
            
            %% clear and prepare target dir
            if ~isdir(obj.targetdir)
                mkdir(obj.targetdir);
            else
                fls = dir(obj.targetdir);
                if ~isempty(fls) % first delete .. and . dirs...
                    %??? Dir not empty. Just clean the place or ask user for confirmation?
                end
            end
            
            %% copy template files and dirs
            templdir = fullfile(fileparts(mfilename('fullpath')),'templates');
            if ~isdir(templdir)
                error('MtestEngine:MissingTemplates','There are no templates.');
            end
            if ~isdir(fullfile(templdir,'default'))
                error('MtestEngine:MissingTemplates','The default template was not found.');
            end
            dirs = dir(templdir);
            templatenames = {dirs([false false dirs(3:end).isdir]).name}';
            if ~strcmp(templatenames,obj.template)
                warning('MtestEngine:TemplateNotFound',['Template with the name: "' obj.template '" was not found. Default is used instead']);
                obj.template = 'default';
            end
            templdir = fullfile(templdir,obj.template);
                        
            % check the existance of testresult.tmp
            % TODO('change to searching for *.tmp. This gives even more flexibility.');
            if isempty(dir(fullfile(templdir,'testresults.tmp')))
                error('MtestEngine:WrongTemplate','The template dir must at least contain the file testresults.tmp');
            end
            
            % copy template files to tempdir
            if isdir(fullfile(tempdir,'mtestengine_template'))
                rmdir(fullfile(tempdir,'mtestengine_template'),'s');
            end
            copyfile(fullfile(templdir,'*.*'),fullfile(tempdir,'mtestengine_template'),'f');
            
            % remove all svn dirs from the template
            DirsInTemplateDir = strread(genpath(fullfile(tempdir,'mtestengine_template')),'%s',-1,'delimiter',';');
            SvnDirsInTemplateDir = DirsInTemplateDir(~cellfun(@isempty,strfind(DirsInTemplateDir,'.svn')));
            
            % remove all svn dirs from the template
            for i=1:length(SvnDirsInTemplateDir)
                if isdir(SvnDirsInTemplateDir{i})
                    rmdir(SvnDirsInTemplateDir{i},'s');
                end
            end
            
            % copy template to target dir
            copyfile(fullfile(tempdir,'mtestengine_template','*.*'),obj.targetdir,'f');
            
            publishstylesheet = dir(fullfile(templdir,'*.xsl'));
            if ~isempty(publishstylesheet)
                publishstylesheet = fullfile(templdir,publishstylesheet.name);
            else
                publishstylesheet = '';
            end
            
            %% Make shure the current dir is added to the search path
            pt = path;
            addpath(cd);
            
            %% Run and Publish individual tests testscases
            if ~isdir(fullfile(obj.targetdir,'html'))
                mkdir(fullfile(obj.targetdir,'html'));
            end
                       
            for itests = 1:length(obj.tests)
                obj.tests(itests).runAndPublish(...
                    'resdir',fullfile(obj.targetdir,'html'),...
                    'stylesheet',publishstylesheet);
                obj.tests(itests).publishTestDescription(...
                    'resdir',fullfile(obj.targetdir,'html'),...
                    'stylesheet',publishstylesheet);
            end
            
            %% return the previous searchpath
            path(pt);
            
            %% Acquire template string
            fid = fopen(fullfile(obj.targetdir,'testresults.tmp'));
            str = fread(fid,'*char')';
            fclose(fid);
            
            ends = strfind(str,'-->');
            
            %% Get icons (positive and negative result)
            idbeg = strfind(str,'#ICONS');
            idend = strfind(str,'#ENDICONS');
            idPos = strfind(str,'#POSITIVE');
            
            
            positiveIm = '';
            if idPos>idbeg && idPos<idend
                positiveIm = strtrim(str(idPos+10:min(ends(ends>idPos))-1));
            end
            
            idNeg = strfind(str,'#NEGATIVE');
            negativeIm = '';
            if idNeg>idbeg && idNeg<idend
                negativeIm = strtrim(str(idNeg+10:min(ends(ends>idNeg))-1));
            end

            idNeutral = strfind(str,'#NEUTRAL');
            neutralIm = '';
            if idNeutral>idbeg && idNeutral<idend
                neutralIm = strtrim(str(idNeutral+9:min(ends(ends>idNeutral))-1));
            end
            
            %% get tests string
            idteststrbegin = min(ends(ends>strfind(str,'##BEGINTESTS')))+4;
            idteststrend = strfind(str,'##ENDTESTS')-6;
            teststr = str(idteststrbegin:idteststrend);
            idtestcasestrbegin = strfind(str,'##BEGINTESTCASE');
            idtestcasestrend = strfind(str,'##ENDTESTCASE')-6;
            testcasestr = str(min(ends(ends>idtestcasestrbegin))+4:idtestcasestrend);
            
            teststr = strrep(teststr,testcasestr,'#@#TESTCASESTRING');
            %% fill and write template
            finalstr = '';
            for itest = 1:length(obj.tests)
                tempstr = teststr;
                tempstr = strrep(tempstr,'#TESTNUMBER',num2str(itest));
                if isnan(obj.tests(itest).testresult)
                    tempstr = strrep(tempstr,'#ICON',neutralIm);
                elseif obj.tests(itest).testresult
                    tempstr = strrep(tempstr,'#ICON',positiveIm);
                else
                    tempstr = strrep(tempstr,'#ICON',negativeIm);
                end
                if ~isempty(obj.tests(itest).testname)
                    tempstr = strrep(tempstr,'#TESTNAME',obj.tests(itest).testname);
                else
                    tempstr = strrep(tempstr,'#TESTNAME',obj.tests(itest).filename);
                end
                tempstr = strrep(tempstr,'#TESTHTML',strrep(fullfile('html',obj.tests(itest).descriptionoutputfile),filesep,'/'));
                
                finalcasesstr = '';
                for icase = 1:length(obj.tests(itest).testcases)
                    tempstr2 = testcasestr;
                    tempstr2 = strrep(tempstr2,'#TESTNUMBER',num2str(itest));
                    tempstr2 = strrep(tempstr2,'#TESTCASENUMBER',num2str(obj.tests(itest).testcases(icase).casenumber));
                    if isnan(obj.tests(itest).testcases(icase).testresult)
                        tempstr2 = strrep(tempstr2,'#ICON',neutralIm);
                    elseif obj.tests(itest).testcases(icase).testresult
                        tempstr2 = strrep(tempstr2,'#ICON',positiveIm);
                    else
                        tempstr2 = strrep(tempstr2,'#ICON',negativeIm);
                    end
                    tcname = ['Case ' num2str(icase)];
                    if ~isempty(obj.tests(itest).testcases(icase).casename)
                        tcname = ['Case ' num2str(icase) ' (' obj.tests(itest).testcases(icase).casename ')'];
                    end
                    tempstr2 = strrep(tempstr2,'#TESTCASENAME',tcname);
                    tempstr2 = strrep(tempstr2,'#DESCRIPTIONHTML',strrep(fullfile('html',obj.tests(itest).testcases(icase).descriptionoutputfile),filesep,'/'));
                    tempstr2 = strrep(tempstr2,'#RESULTHTML',strrep(fullfile('html',obj.tests(itest).testcases(icase).publishoutputfile),filesep,'/'));
                    
                    finalcasesstr = cat(2,finalcasesstr,tempstr2);
                end
                
                tempstr = strrep(tempstr,'#@#TESTCASESTRING',finalcasesstr);
                
                finalstr = cat(2,finalstr,tempstr);
            end
            
            str = cat(2,str(1:idteststrbegin),finalstr,str(idteststrend:end));
            
            fid = fopen(fullfile(obj.targetdir,'testresults.html'),'w');
            fprintf(fid,'%s',str);
            fclose(fid);
        end
    end
end
classdef MTest < handle
    properties
        Name = [];                          % Name of the test
        
        FileName = [];                      % Original name of the testfile
        FilePath = [];                      % Path of the "_test.m" file
        FunctionHeader = '';                % Header of the test(case) function (first line)
        FunctionName = '';                  % Name of the test(case) function
        
        H1Line   = [];                      % A one line description of the test (h1 line)
        Description = {};                   % Detailed description of the test that appears in the help block
        Author   = [];                      % Last author of the test (obtained from svn keywords)
        SeeAlso  = {};                      % see also references
        
        DescriptionCode = {};               % Code that was included in the testfile description cell
        DescriptionIncludecode = false;     % Attribute IncludeCode for publishing the description cell
        DescriptionEvaluatecode = true;     % Attribute EvaluateCode for publishing the description cell
        
        RunCode = {};                       % Code that was included in the testfile RunTest cell
        
        PublishCode = {};                   % Code that was included in the testfile TestResults cell
        PublishIncludecode = false;         % Attribute IncludeCode for publishing the TestResults cell
        PublishEvaluatecode = true;         % Attribute EvaluateCode for publishing the TestResults cell
        
        Publish = true;                     % Determines whether test results, coverage and description are published to html
        MaxWidth  = 600;                    % Maximum width of the published figures (in pixels). By default the maximum width is set to 600 pixels.
        MaxHeight = 600;                    % Maximum height of the published figures (in pixels). By default the maximum height is set to 600 pixels.
        StyleSheet = '';                    % Style sheet that is used for publishing (see publish documentation for more information).
        
        Ignore = false;                     % If ignore = true, this test is ignored
        IgnoreMessage = '';                 % Optional string to point out why this test(case) was ignored
        Category = 'Unit';                  % Category of the test(case)
        
        TestResult = false;                 % Boolean indicating whether the test was run successfully
        Time     = 0;                       % Time that was needed to perform the test
        Date     = NaN;                     % Date and time the test was performed
        
        ProfilerInfo = [];                  % Profile info structure
        FunctionCalls = [];                 % Called functions
        StackTrace    = [];                 % Stack trace (diary + error message)
    end
    properties (Hidden = true)
        FullString = [];                    % Full string of the contents of the test file
        IDTestFunction = [];                % boolean the size of FullStrin with true for the lines that are part of the main test
        IDTestCode = [];                    % boolean the size of FullStrin with true for the lines that are part of the runnable code of the main test
        IDDescriptionCode = [];             % boolean the size of FullStrin with true for the lines that are part of the (publishable) test description
        IDRunCode = [];                     % boolean the size of FullStrin with true for the lines that are part of the run code
        IDPublishCode = [];                 % boolean the size of FullStrin with true for the lines that are part of the publish code part
        IDOetHeaderString = [];             % boolean the size of FullStrin with true for the lines that are part of the oet function header
        
        SubFunctions = [];                  % Struct with output of getcallinfo for all subfunctions
        RunDir = [];
        OutputDir = [];
    end
    
    methods
        function obj = MTest(varargin)
            if nargin==0
                return;
            end
            %% Create shortcut to MtestFactory to create a test
            obj = MTestFactory.createtest(varargin{:});
        end
        function run(obj,varargin)
            % This method is still work in progress
            
            %runAndPublish  Runs the test and publishes the descriptions and results of all testcases.
            %
            %   This function runs the mtest object and publishes all case descriptions and results.
            %   The variables of the description and runcode of the test are stored in the hidden
            %   workspace, so that the publishResult function can directly be called after running
            %   the test.
            %
            %   Syntax:
            %   runAndPublish(obj,'property','value');
            %   obj.publisResults(...'property','value');
            %
            %   Input:
            %   obj  = An instance of an mtest object.
            %
            %   property value pairs:
            %           'resdir'     -  Specifies the output directory (current dir is default).
            %           'outputfile' -  Main part of the name of the output file. The description is
            %                           output file appends _description to this name. The results
            %                           output file appends _results to it.
            %           'testname'   -  Name of the main test.
            %           'maxwidth'  -   Maximum width of the published figures (in pixels). By
            %                           default the maximum width is set to 600 pixels.
            %           'maxheight' -   Maximum height of the published figures (in pixels). By
            %                           default the maximum height is set to 600 pixels.
            %           'stylesheet'-   Style sheet that is used for publishing (see publish
            %                           documentation for more information).
            %
            %   See also mtestcase mtestcase.mtestcase mtestcase.publishDescription mtest.publishResults mtestcase.runTest mtestengine mtest
            
            
            %% subtract outputfilename
            obj = setproperty(obj,varargin{:});
                       
            %% include testname
            if isempty(obj.Name)
                obj.Name = obj.FileName;
            end
            
            %% notify begin of test
            TeamCity.postmessage('testStarted',...
                'name',obj.Name,...
                'captureStandardOutput','true');
            
            %% return if obj has to be ignored
            if obj.Ignore
                TeamCity.postmessage('testIgnored',...
                    'name',obj.Name,...
                    'message',obj.IgnoreMessage);
                TeamCity.postmessage('testFinished',...
                    'name',obj.Name,...
                    'duration',num2str(0));
                return;
            end
            
            %% register at TeamCity
            teamCity = TeamCity;
            teamCity.CurrentTest = obj;
            
            %% Make sure the directory of the test is in the searchpath
            pt = path;
            addpath(obj.FilePath);
            
            %% construct temp rundir
            obj.RunDir = tempname;
            mkdir(obj.RunDir);
            
            
            %% Check whether the function has a proper header
            if isempty(obj.FunctionHeader)
                obj.testresult = false;
                TeamCity.postmessage('testFailed',...
                    'name',obj.Name,...
                    'message','Error in test definition',...
                    'details','This test does not work due to a missing function declaration.');
                TeamCity.postmessage('testFinished',...
                    'name',obj.Name,...
                    'duration','0');
                return;
            end
            
            %% go to rundir
            cdtemp = cd;
            cd(obj.RunDir);
            
            %% Print Run file
            testString = obj.FullString;
            testString(~obj.IDTestFunction | obj.IDPublishCode) = deal({' '});
            
            if obj.Publish
                testString(obj.IDDescriptionCode) = deal({' '});
                if any(obj.IDDescriptionCode)
                    testString{find(obj.IDDescriptionCode,1,'first')} = 'profile(''off''); TeamCity.storeworkspace; TeamCity.publishdescription; TeamCity.restoreworkspace; profile(''on'');';
                end
                if any(obj.IDPublishCode)
                    if find(obj.IDTestFunction & ~obj.IDPublishCode,1,'last') > find(obj.IDPublishCode,1,'first')
                        testString{find(obj.IDPublishCode,1,'first')} = 'profile(''off''); TeamCity.storeworkspace; TeamCity.publishresult; TeamCity.restoreworkspace; profile(''on'');';
                    else
                        testString{find(obj.IDPublishCode,1,'first')} = 'profile(''off''); TeamCity.storeworkspace; TeamCity.publishresult(false);';
                    end
                end
            end
            
            str = sprintf('%s\n',testString{:});
            
            fid = fopen(fullfile(obj.RunDir,[obj.FunctionName '.m']),'w');
            fprintf(fid,'%s\n',str);
            fclose(fid);
            
            %% Print subfunctions
            for isub = 1:length(obj.SubFunctions)
                fid = fopen(fullfile(obj.RunDir,[obj.SubFunctions(isub).name,'.m']),'w');
                fprintf(fid,'%s\n',sprintf('%s\n',obj.FullString{obj.SubFunctions(isub).linemask}));
                fclose(fid);
            end
            
            if ~exist(fullfile(obj.RunDir,[obj.FunctionName '.m']),'file')
                % Since Windows is slower in writing the file than the matlab fclose function..?
                % This is a workaround to let windows finish the file...
            end
   
            %% Check open figures
            openfigures = findobj('Type','figure');

            %% Evaluate test
            try
                runTime = 0;
                errorReport = '';
                errorMessage = '';
                commandWindowString = evalc(sprintf('%s\n',...
                    'try',...
                    '    tic;',...
                    '    profile clear',...
                    '    profile on',...
                    ['    obj.TestResult = ' obj.FunctionName ';'],...
                    '    profile off',...
                    '    runTime = toc;',...
                    '    if ~islogical(obj.TestResult)',...
                    '        obj.TestResult = true;',...
                    '    end',...
                    'catch me',...
                    '    if strcmp(me.identifier,''MATLAB:TooManyOutputs'')',...
                    '        % Function does not have an output argument',...
                    '        clear me',...
                    '        eval(sprintf(''%s\n'',...',...
                    '            ''try'',...',...
                    '            ''    tic;'',...',...
                    '            ''    profile clear'',...',...
                    '            ''    profile on'',...',...
                    ['            ''    ' obj.FunctionName ';'',...'],...
                    '            ''    profile off'',...',...
                    '            ''    runTime = toc;'',...',...
                    '            ''    obj.TestResult = true;'',...',...
                    '            ''catch me'',...',...
                    '            ''    obj.TestResult = false;'',...',...
                    '            ''    profile off'',...',...
                    '            ''    runTime = toc;'',...',...
                    '            ''    errorReport = me.getReport;'',...',...
                    '            ''    errorMessage = me.message;'',...',...
                    '            ''end''));',...
                    '    else',...
                    '        profile off',...
                    '        runTime = toc;',...
                    '        obj.TestResult = false;',...
                    '        errorReport = me.getReport;',...
                    '        errorMessage = me.message;',...
                    '    end',...
                    'end'));
                
                obj.StackTrace = strrep(sprintf('%s\n',commandWindowString,errorReport),obj.RunDir,obj.FilePath);
                obj.ProfilerInfo = profile('info');
                obj.Time = runTime;
                if ~obj.TestResult
                    % Something went wrong
                    obj.Time = 0;
                    TeamCity.postmessage('testFailed',...
                        'name',obj.Name,...
                        'message',errorMessage,...
                        'details',obj.StackTrace);
                end
            catch me
                % Something went wrong while executing test (Something with
                % the MTest code)
                obj.TestResult = false;
                obj.StackTrace = me.getReport;
                obj.Time = 0;
                TeamCity.postmessage('testFailed',...
                    'name',obj.Name,...
                    'message',me.message,...
                    'details',me.getReport);
            end
            
            %% Close all remaining open figures from the test
            newopenfigures = findobj('Type','figure');
            id = ~ismember(newopenfigures,openfigures);
            if any(id) && isempty(find(strcmpi(varargin,'keepfigures'), 1))
                close(newopenfigures(id));
            end
            
            %% cd back
            cd(cdtemp);
            
            %% remove tempdir
            rmdir(obj.RunDir,'s');
            
            %% set additional parameters
            obj.Date = now;
            
            %% Return the initial searchpath
            path(pt);
            
            %% Finish test
            TeamCity.postmessage('testFinished',...
                'name',obj.Name,...
                'duration',num2str(round(obj.Time*1000)));
        end
    end
    methods (Hidden = true)
        function publishdescription(obj,varargin)
            %publishDescripton  Creates an html file from the description code with publish
            %
            %   This function publishes the code included in the Description cell of the test file
            %   for this test(case) with the help of the publish function.
            %
            %   Syntax:
            %   publishDescripton(obj,'property','value')
            %   publishDescripton(...,'keepfigures');
            %   obj.publisDescription('property','value')
            %
            %   Input:
            %   obj             - An instance of an mtestpublishable object with the information of the
            %                     test description that has to be published.
            %   'keepfigures'   - The publishDescription function automatically closes any figures
            %                     that were created during publishing and were not already there.
            %                     The optional argument 'keepfigures' prevents these figures from
            %                     being closed (unless stated in the test code somewhere).
            %
            %   property value pairs:
            %           'resdir'     -  Specifies the output directory (default is the current
            %                           directory)
            %           'filename'   -  Name of the output file. If the filename include a path,
            %                           this pathname overrides the specified resdir.
            %           'testname'   -  Name of the (main) test.
            %           'includeCode'-  Boolean overriding the mtestcase-property
            %                           descriptionincludecode. This property determines whether the
            %                           code parts of the description are included in the published
            %                           html file (see publish documentation for more info).
            %           'evaluateCode'- Boolean overriding the mtestcase-property
            %                           descriptionevaluatecode. This property determines whether
            %                           the code parts of the description are executed before
            %                           publishing the code to html (see publish documentation for
            %                           more info).
            %           'maxwidth'  -   Maximum width of the published figures (in pixels). By
            %                           default the maximum width is set to 600 pixels.
            %           'maxheight' -   Maximum height of the published figures (in pixels). By
            %                           default the maximum height is set to 600 pixels.
            %           'stylesheet'-   Style sheet that is used for publishing (see publish
            %                           documentation for more information).
            %
            %   See also mtest mtestcase mtestengine mtest.publishResults
            
            %% Do not publish if there is no description or the test should be ignored
            if isempty(obj.DescriptionCode) || obj.Ignore
                return;
            end
            
            %% subtract result dir from input
            resdir = obj.OutputDir;
            id = find(strcmp(varargin,'outputdir'));
            if ~isempty(id)
                resdir = varargin{id+1};
                varargin(id:id+1) = [];
            end
            if isempty(resdir)
                resdir = cd;
            end
            
            saveWorkSpace = true;
            id = find(strcmp(varargin,'saveworkspace'));
            if ~isempty(id)
                saveWorkSpace = varargin{id+1};
                varargin(id:id+1) = [];
            end
            %% Get filename from input
            id = find(strcmp(varargin,'outputfile'));
            outputfile = fullfile(resdir,[obj.FileName, '_description.html']);
            if ~isempty(id)
                [pt nm] = fileparts(varargin{id+1});
                outputfile = [nm '.html'];
                if ~isempty(pt)
                    resdir = pt;
                end
                varargin(id:id+1) = [];
            end
            
            %% Process other input arguments
            % includeCode
            if any(strcmpi(varargin,'includecode'))
                id = find(strcmpi(varargin,'includecode'));
                obj.DescriptionIncludecode = varargin{id+1};
            end
            
            % evaluateCode
            if any(strcmpi(varargin,'evaluatecode'))
                id = find(strcmpi(varargin,'evaluatecode'));
                obj.DescriptionEvaluatecode = varargin{id+1};
            end
            
            % Maxwidth
            if any(strcmpi(varargin,'maxwidth'))
                id = find(strcmpi(varargin,'maxwidth'));
                obj.MaxWidth = varargin{id+1};
            end
            
            % maxheight
            if any(strcmpi(varargin,'maxheight'))
                id = find(strcmpi(varargin,'maxheight'));
                obj.MaxHeight = varargin{id+1};
            end
            
            % stylesheet
            if any(strcmpi(varargin,'stylesheet'))
                id = find(strcmpi(varargin,'stylesheet'));
                obj.StyleSheet = varargin{id+1};
            end
            
            %% createoutputname
            [pt fn] = fileparts(outputfile);
            if isempty(pt)
                pt = resdir;
            end
            outputname = fullfile(pt,[fn '.html']);
            
            %% set publish options
            opt = struct(...
                'format','html',...
                'stylesheet',obj.StyleSheet,...
                'outputDir',fileparts(outputname),...
                'maxHeight',obj.MaxHeight,...
                'maxWidth',obj.MaxWidth,...
                'showCode',obj.DescriptionIncludecode,...
                'useNewFigure',false,... % Maybe add this to the input of properties?
                'evalCode',obj.DescriptionEvaluatecode);
            
            %% Check open figures
            openfigures = findobj('Type','figure');
            
            %% publish results to resdir
            if ~isempty(obj.Name)
                descrstr = cat(1,{['%% Description ("' obj.Name '")']},obj.DescriptionCode);
            else
                descrstr = cat(1,{['%% Description ("' obj.FunctionName '")']},obj.DescriptionCode);
            end
            MTest.publishcodestring(outputname,...
                [],...
                descrstr,...
                opt,...
                saveWorkSpace);
            
            %% Close all remaining open figures from the test
            newopenfigures = findobj('Type','figure');
            id = ~ismember(newopenfigures,openfigures);
            if any(id) && isempty(find(strcmpi(varargin,'keepfigures'), 1))
                close(newopenfigures(id));
            end
            
        end
        function publishresult(obj,varargin)
            %publishResults  Creates an html file from the test result with publish
            %
            %   This function publishes the code included in the Publish(Result) cell of the test file
            %   with the help of the publish function. All variables created by running the test are
            %   still in the workspace and can therefore be used while publishing the results.
            %
            %   Syntax:
            %   publishResults(obj,'property','value')
            %   publishResults(...,'keepfigures');
            %   obj.publisResults(...)
            %
            %   Input:
            %   obj             - An instance of an mtestpublishable object with the information of the
            %                     test results that has to be published.
            %   'keepfigures'   - The publishResults function automatically closes any figures that
            %                     were created during publishing and were not already there.
            %                     The optional argument 'keepfigures' prevents these figures from
            %                     being closed (unless stated in the test code somewhere).
            %
            %   property value pairs:
            %           'resdir'     -  Specifies the output directory
            %           'filename'   -  Name of the output file. If the filename includes a path,
            %                           this pathname overrides the specified resdir.
            %           'name'       -  Name of the test.
            %           'includeCode'-  Boolean overriding the mtest-property publishincludecode.
            %                           This property determines whether the code parts of the
            %                           publication part are included in the published html file (see
            %                           publish documentation for more info).
            %           'evaluateCode'- Boolean overriding the mtest-property publishevaluatecode.
            %                           This property determines whether the code parts of the
            %                           publishresult are executed before publishing the code to html
            %                           (see publish documentation for more info).
            %           'maxwidth'  -   Maximum width of the published figures (in pixels). By
            %                           default the maximum width is set to 600 pixels.
            %           'maxheight' -   Maximum height of the published figures (in pixels). By
            %                           default the maximum height is set to 600 pixels.
            %           'stylesheet'-   Style sheet that is used for publishing (see publish
            %                           documentation for more information).
            %
            %   See also mtest mtestcase mtestengine mtestpublishable.publishDescription mtestpublishable.publishCoverage
            
            %% Don't publish if the test was ignored
            if obj.Ignore || isempty(obj.PublishCode)
                return;
            end
                        
            %% subtract result dir from input
            resdir = cd;
            id = find(strcmp(varargin,'outputdir'));
            if ~isempty(id)
                resdir = varargin{id+1};
                varargin(id:id+1) = [];
            end
            
            saveWorkSpace = true;
            id = find(strcmp(varargin,'saveworkspace'));
            if ~isempty(id)
                saveWorkSpace = varargin{id+1};
                varargin(id:id+1) = [];
            end
            
            %% Get filename from input
            id = find(strcmp(varargin,'outputfile'));
            outputfile = fullfile(resdir,[obj.FileName, '_publish.html']);
            if ~isempty(id)
                [pt nm] = fileparts(varargin{id+1});
                outputfile = [nm '.html'];
                if ~isempty(pt)
                    resdir = pt;
                end
                varargin(id:id+1) = [];
            end
            
            %% Process other input arguments
            % includeCode
            if any(strcmpi(varargin,'includecode'))
                id = find(strcmpi(varargin,'includecode'));
                obj.DescriptionIncludecode = varargin{id+1};
            end
            
            % evaluateCode
            if any(strcmpi(varargin,'evaluatecode'))
                id = find(strcmpi(varargin,'evaluatecode'));
                obj.DescriptionEvaluatecode = varargin{id+1};
            end
            
            % Maxwidth
            if any(strcmpi(varargin,'maxwidth'))
                id = find(strcmpi(varargin,'maxwidth'));
                obj.MaxWidth = varargin{id+1};
            end
            
            % maxheight
            if any(strcmpi(varargin,'maxheight'))
                id = find(strcmpi(varargin,'maxheight'));
                obj.MaxHeight = varargin{id+1};
            end
            
            % stylesheet
            if any(strcmpi(varargin,'stylesheet'))
                id = find(strcmpi(varargin,'stylesheet'));
                obj.StyleSheet = varargin{id+1};
            end
            
            %% createoutputname
            [pt fn] = fileparts(outputfile);
            if isempty(pt)
                pt = resdir;
            end
            outputname = fullfile(pt,[fn '.html']);
            
            %% set publish options
            opt = struct(...
                'format','html',...
                'stylesheet',obj.StyleSheet,...
                'outputDir',fileparts(outputname),...
                'maxHeight',obj.MaxHeight,...
                'maxWidth',obj.MaxWidth,...
                'showCode',obj.PublishIncludecode,...
                'useNewFigure',false,... % Maybe add this to the input of properties?
                'evalCode',obj.PublishEvaluatecode);
            
            %% Check open figures
            openfigures = findobj('Type','figure');
            
            %% publish results to resdir
            if ~isempty(obj.Name)
                publstr = cat(1,{['%% Results ("' obj.Name '")']},obj.PublishCode);
            else
                publstr = cat(1,{['%% Results ("' obj.FunctionName '")']},obj.PublishCode);
            end
            MTest.publishcodestring(outputname,...
                [],...
                publstr,...
                opt,...
                saveWorkSpace);
            
            %% Close all remaining open figures from the test
            newopenfigures = findobj('Type','figure');
            id = ~ismember(newopenfigures,openfigures);
            if any(id) && isempty(find(strcmpi(varargin,'keepfigures'), 1))
                close(newopenfigures(id));
            end
        end
    end
    methods (Hidden = true, Static = true)
        function publishcodestring(outputname,tempdir,string2publish,publishoptions,saveWorkSpace)
            %PUBLISHCODESTRING  publishes a string to a html page
            %
            %   This function publishes a string to a html page. it uses the UserData of the matlab
            %   root to store any variables that are used as input.
            %
            %   Syntax:
            %   publishCodeString(...
            %       outputname,...
            %       tempdir,...
            %       workspace,...
            %       string2publish,...
            %       publishoptions)
            %
            %   Input:
            %   outputname    -   Name of the html output file. If this is
            %   tempdir       -   Name of the temp dir where the file can be created. If this
            %                     variable is left empty the file is published in the output
            %                     directory (filepath of mtest_outputname).
            %   workspace     -   Variables that should be in the workspace to be able to
            %                     publish the code string. This variable should be an Nx2 cell
            %                     array. The first column should contain a string with the
            %                     name of the variable. The second column stores the content
            %                     of that variable.
            %   string2publish-   String that has to be published
            %   publishoptions-   A struct with publish options as described in the help
            %                     documentation of the matlab function "publish".
            %
            %   See also mtest publish mtest.mtest mtest.runTest
            
            %% create temp file with code that needs to be executed
            publishInOutputDir = false;
            if isempty(tempdir)
                tempdir = fileparts(outputname);
                publishInOutputDir = true;
            end
            
            tempfilename = MTest.makeTempFile(tempdir,string2publish,outputname);
            
            [ newdir newname ] = fileparts(outputname);
            fileNamesIdentical = strcmp(tempfilename,fullfile(newdir,[newname '.m']));
            
            if publishInOutputDir && ~fileNamesIdentical
                % move the tempfile to the correct name (to have sensible names for the figures) and
                % the correct directory
                
                movefile(tempfilename,fullfile(newdir,[newname '.m']));
                % renew filename
                tempfilename = fullfile(newdir,[newname '.m']);
            end
            % split output dir and filename
            [tempdir tempfileshortname] = fileparts(tempfilename);
            
            %% fill workspace
            % store mtest_workspace in UserData of the matlab root. The publish function is preceded
            % by code to retrieve the variables from the root UserData.
            % Build a string that restores the variables and executes the tempfile.
            string2evaluate = ['TeamCity.restoreworkspace;', tempfileshortname, ';'];
            if saveWorkSpace
                string2evaluate = cat(2,string2evaluate,' TeamCity.storeworkspace;');
            end
            
            % Now specify the code to evaluate. The string constructed above should be evaluated in
            % an empty workspace. Therefore in the base workspace we only call evalinemptyworkspace,
            % with the string we just constructed as input.
            publishoptions.codeToEvaluate = ['evalinemptyworkspace(' string2evaluate ');'];
            
            %% publish file
            tempcd = cd;
            cd(tempdir)
            if datenum(version('-date')) >= datenum(2009,08,12) && datenum(version('-date')) < datenum(2010,01,01)
                intwarning('off');
            end
            publish(tempfilename,publishoptions);
            cd(tempcd);
            
            %% delete the temp file
            delete(tempfilename);
            
            %% move output file
            [dr fname] = fileparts(tempfilename); %#ok<*ASGLU>
            if ~strcmp(fullfile(publishoptions.outputDir,[fname '.html']),outputname)
                movefile(fullfile(publishoptions.outputDir,[fname '.html']),outputname);
            end
        end
        function [testResult errorMessage errorReport runTime] = mtestrunner(functionName)
            %% Default output
            errorReport = '';
            errorMessage = '';
            testResult = false;
            runTime = 0;
            
            %% Evaluate the test to avoid information about the test engine in the exeption
            % First try the test with an output parameter. Then also try the test without...
            eval(sprintf('%s\n',...
                'try',...
                '    tic;',...
                '    profile clear',...
                '    profile on',...
                ['    testResult = eval(' functionName ');'],...
                '    profile off',...
                '    runTime = toc;',...
                '    if ~islogical(testResult)',...
                '        testResult = true;',...
                '    end',...
                'catch me',...
                '    if strcmp(me.identifier,''MATLAB:TooManyOutputs'')',...
                '        % Function does not have an output argument',...
                '        eval(sprintf(''%s\n'',...',...
                '            ''try'',...',...
                '            ''    tic;'',...',...
                '            ''    profile clear'',...',...
                '            ''    profile on'',...',...
                '            [''    '' functionName '';''],...',...
                '            ''    profile off'',...',...
                '            ''    runTime = toc;'',...',...
                '            ''    testResult = true;'',...',...
                '            ''catch me2'',...',...
                '            ''    testResult = false;'',...',...
                '            ''    profile off'',...',...
                '            ''    runTime = toc;'',...',...
                '            ''    errorReport = me2.getReport;'',...',...
                '            ''    errorMessage = me2.message;'',...',...
                '            ''end''));',...
                '    else',...
                '        profile off',...
                '        runTime = toc;',...
                '        testResult = false;',...
                '        errorReport = me.getReport;',...
                '        errorMessage = me.message;',...
                '    end',...
                'end'));
        end
        function fname = makeTempFile(tempdir,str,fn)
            if ~ischar(str)
                str = sprintf('%s\n',str{:});
            end
            
            if nargin==2
                fn = tempname;
            end
            [dum fn] = fileparts(fn);
            fname = fullfile(tempdir,[fn '.m']);
            fid = fopen(fname,'w');
            fprintf(fid,'%s\n',str);
            fclose(fid);
        end
    end
    methods
        function value = get.DescriptionCode(obj)
            value = {};
            
            if length(obj.FullString)==length(obj.IDDescriptionCode)
                value = obj.FullString(obj.IDDescriptionCode);
            end
        end
        function value = get.RunCode(obj)
            value = {};
            
            if length(obj.FullString)==length(obj.IDRunCode)
                value = obj.FullString(obj.IDRunCode);
            end
        end
        function value = get.PublishCode(obj)
            value = {};
            
            if length(obj.FullString)==length(obj.IDPublishCode)
                value = obj.FullString(obj.IDPublishCode);
            end
        end
    end
end
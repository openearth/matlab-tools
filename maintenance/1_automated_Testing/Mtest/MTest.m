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
        Ignore = false;                     % If ignore = true, this test is ignored
        IgnoreMessage = '';                 % Optional string to point out why this test(case) was ignored
        Category = 'unit';                  % Category of the test(case)
        
        TestResult = false;                 % Boolean indicating whether the test was run successfully
        Time     = 0;                       % Time that was needed to perform the test
        Date     = NaN;                     % Date and time the test was performed

        ProfilerInfo = [];                  % Profile info structure
        FunctionCalls = [];                 % Called functions
        StackTrace    = [];                 % Stack trace (diary + error message)
    end
    properties (Hidden = true)
        FullString = [];                    % Full string of the contents of the test file
        IDTestFunction = [];
        IDTestCode = [];
        IDDescriptionCode = [];
        IDRunCode = [];
        IDPublishCode = [];
        IDOetHeaderString = [];               % Comments that form the standart parts of the oet header

        SubFunctions = [];
        RunDir = [];
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
            idBeginDescription = find(obj.IDDescriptionCode,1,'first');
            idEndDescription = find(obj.IDDescriptionCode,1,'last');
            idBeginPublish = find(obj.IDPublishCode,1,'first');
            idEndPublish = find(obj.IDPublishCode,1,'last');
            
            % TODO find solution if one of the blocks is not defined.
            if ~any(obj.IDPublishCode)
                
            end
            if ~any(obj.IDDescriptionCode)
                
            end
            
            id = obj.IDTestFunction;
            id(idBeginDescription-1:end) = false;
            testBodyString = cat(1,...
                obj.FullString(id),...
                ' ');
            
            if obj.Publish
                testBodyString = cat(1,testBodyString,...
                    '%% Publish the description',...
                    'TeamCity.publishdescription;',...
                    ' ');
            end
            
            id = obj.IDTestFunction;
            id(1:idEndDescription) = false;
            id(idBeginPublish-1:end) = false;
            testBodyString = cat(1,testBodyString,...
                '%% Start profiler and timer',...
                'profile clear',...
                'TeamCity.starttimer',...
                'profile on',...
                ' ',...
                obj.FullString(id),...
                ' ',...
                '%% Turn of profiler and timer',...
                'profile off',...
                'TeamCity.collectprofilerinfo',...
                'TeamCity.stoptimer',...
                ' ');
            
            if obj.Publish
                testBodyString = cat(1,testBodyString,...
                '%% Publish the results',...
                'TeamCity.publishresult;',...
                ' ');
            end
            
            if any(obj.IDPublishCode)
                id = obj.IDTestFunction;
                id(1:idEndPublish) = false;
                testBodyString = cat(1,testBodyString,...
                    obj.FullString(id));
            end
            
            str = sprintf('%s\n',testBodyString{:});
            
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
            
            %% Evaluate test
            try
                [obj.StackTrace obj.TestResult] = evalc(obj.FunctionName);
                if isnan(obj.TestResult)
                    obj.TestResult = true;
                end
            catch me
                obj.TestResult = false;
                obj.StackTrace = me;
                obj.Time = 0;
                TeamCity.postmessage('testFailed',...
                    'name',obj.Name,...
                    'message',me.message,...
                    'details',me.getReport);
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
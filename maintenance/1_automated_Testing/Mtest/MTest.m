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
        IDTestString = [];                    % 
        IDTestCode = [];
        IDDescriptionCode = [];
        IDRunCode = [];
        IDPublishCode = [];
        IDSubfunctionsString = [];            % Any remaining subfunctions
        IDOetHeaderString = [];               % Comment that form the standart parts of the oet header
        EventListeners = [];                % Listeren to event runTest of testcases
        RunDir = [];
    end
    
    methods
        function run(obj,varargin)
           % optional parameters:
           % - publish
           % - 
        end
        function publishdescription(obj,varargin)
            
        end
        function publishcoverage(obj,varargin)
            
        end
        function publishresult(obj,varargin)
            
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
classdef MTest < handle
    % MTEST - Object to handle tests written in MTest format
    %
    % This objects stores the information written in an mtest format test definition file. The test
    % files consist of three parts divided by a cell break (%%). The three cells represent:
    %
    %   1.  Description of the testcase (%% $Description)
    %   2.  The actual test code (%% $Run)
    %   3.  Publishable code that describes the results (%% $Publish)
    %
    % 1. The Description is seen purely as documentation of the test (in other words: what do we test, 
    % how do we test it and what outcome do we expect).
    %
    % 2. The Run section contains code that must be executed in order to test the function (Any
    % code that was already used in the Description gets executed prior to running this section. 
    % Preferrably the test code should issue an error when the test fails. This gives the most
    % information on what went wrong. It is advised to use the assert function:
    %
    % assert(1==2, 'One should be equal to two');
    %
    % 3. The Publish section includes code that can be used to publish the results of the test. It
    % is published to html with the Matlab publish function. Any variables created in the first two
    % sections of a test (description and run) can be used in this section. For more information on 
    % producing publishable code, see the Matlab documentation on cell formatting:
    %
    % docsearch('Formatting M-File Code for Publishing');
    %
    % See also MTest.MTest MTestRunner MTestFactory
    
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
    % Created: 15 Jun 2010
    % Created with Matlab version: 7.10.0.499 (R2010a)
    
    % $Id$
    % $Date$
    % $Author$
    % $Revision$
    % $HeadURL$
    % $Keywords: testing test unittest$

    %% Properties
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
        
        Publish = true;                     % Determines whether test results, coverage and description are published to html
        MaxWidth  = 600;                    % Maximum width of the published figures (in pixels). By default the maximum width is set to 600 pixels.
        MaxHeight = 600;                    % Maximum height of the published figures (in pixels). By default the maximum height is set to 600 pixels.
        StyleSheet = '';                    % Style sheet that is used for publishing (see publish documentation for more information).
        
        Ignore = false;                     % If ignore = true, this test is ignored
        IgnoreMessage = '';                 % Optional string to point out why this test(case) was ignored
        Category = 'Unit';                  % Category of the test(case)
    end
    properties (SetObservable = true)
        TestResult = false;                 % Boolean indicating whether the test was run successfully
    end
    properties
        Time     = 0;                       % Time that was needed to perform the test
        Date     = NaN;                     % Date and time the test was performed
        
        ProfilerInfo = [];                  % Profile info structure
        FunctionCalls = [];                 % Called functions
        StackTrace    = [];                 % Stack trace (diary + error message)
        
        Verbose = true;                     % Determines whether messages are written to the command window whenever the run function gets executed
        
        AutoRefresh = false;                % If this property is set true, the object gets updated with the newest version of the definition before executing run
        TimeStamp = [];                     % Timestamp of the last time the definition was saved
    end
    properties (Hidden = true)
        FullString = [];                    % Full string of the contents of the test file
        IDTestFunction = [];                % boolean the size of FullStrin with true for the lines that are part of the main test
        IDOetHeaderString = [];             % boolean the size of FullStrin with true for the lines that are part of the oet function header
        
        SubFunctions = [];                  % Struct with output of getcallinfo for all subfunctions
        RunDir = [];                        % This dir is used to run the test (if it needs to be run in a different dir)
        OutputDir = [];                     % The output (published html) will be placed in this dir
    end
    
    methods
        function obj = MTest(varargin)
            %MTest  Creates an MTest object from a test definition file.
            %
            %   This function reads the contents of an MTest definition file and creates an
            %   MTest object that stores all the necessary test information and results. This object
            %   can later be used to publish the description (MTest.publishdescription), run the
            %   test (MTest.run) or publish the testresults (MTest.publishresults).
            %
            %   Syntax:
            %   obj = MTest(filename,...);
            %   obj = MTest(...,'filename',filename);
            %   obj = MTest(...,'property','value');
            %
            %   Input:
            %   filename  = name of a file that is in the matlab search path or a full filename to
            %               the test definition file that has to be converted to an mtest object.
            %               This parameter must be entered to load a test definition.
            %
            %   Property - value pairs:
            %       descriptionoutputfile   -   Name of the html output file created when publishing
            %                                   the description of the test.
            %       includecode             -   TODO
            %       evaluatecode            -   TODO
            %
            %   Output:
            %   obj - mtest object
            %
            %   See also MTest MTest.run MTestRunner MTestFactory

            %% Return in case of no input
            if nargin==0
                return;
            end
            
            %% Create shortcut to MtestFactory to create a test
            obj = MTestFactory.createtest(varargin{:});
        end
        function run(obj,varargin)
            %RUN  Runs the test and publishes the descriptions and results.
            %
            %   This function runs the MTest object and publishes the descriptions and results.
            %
            %   Syntax:
            %   run(obj,'property','value');
            %   obj.run(...'property','value');
            %
            %   Input:
            %   obj  = An instance of an MTest object.
            %
            %   property value pairs:
            %           'OutputDir' -  Specifies the output directory (current dir is default).
            %           'RunDir'    -  Specifies the directory that is used to run the test.
            %           'Name'      -  Name of the main test.
            %           'MaxWidth'  -  Maximum width of the published figures (in pixels). By
            %                          default the maximum width is set to 600 pixels.
            %           'MaxHeight' -  Maximum height of the published figures (in pixels). By
            %                          default the maximum height is set to 600 pixels.
            %           'StyleSheet'-  Style sheet that is used for publishing (see publish
            %                          documentation for more information).
            %           'Publish'   -  {true} | false specifies whether description and result
            %                          section should be published.
            %           'Category'  -  {string} overrides the category of the test.
            %
            %   See also MTest MTest.MTest MTestFactory MTestRunner
            
            %% Lock this workspace and function code
            mlock;
            teamcity = TeamCity;
            
            %% subtract outputfilename
            obj = MTestUtils.setproperty(obj,varargin{:});
                       
            %% include testname
            if isempty(obj.Name)
                obj.Name = obj.FileName;
            end
            
            %% AutoRefresh
            if obj.AutoRefresh
                [obj isUpToDate] = MTestFactory.verifytimestamp(obj);
                if ~isUpToDate
                    obj = MTestFactory.updatetest(obj);
                    if obj.Verbose
                        disp(['     Updated test definition: ' obj.Name]);
                    end
                end
            end
            
            %% notify begin of test
            if teamcity.running
                TeamCity.postmessage('testStarted',...
                    'name',obj.Name,...
                    'captureStandardOutput','true');
            end
            if obj.Verbose
                disp(['     Test started: ' obj.Name]);
            end
            
            %% return if obj has to be ignored
            if obj.Ignore
                if obj.Verbose
                    disp(['     Ignored: ' obj.IgnoreMessage]);
                    disp(['     Test finished: ' obj.Name]);
                end
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
            
            %% Remember current dir
            cdtemp = cd;
            
            %% Check whether the function has a proper header
            if isempty(obj.FunctionHeader)
                obj.testresult = false;
                if obj.Verbose
                    disp('    Error occurred: Error in test definition');
                    disp(['     Test finished: ' obj.Name]);
                end
                TeamCity.postmessage('testFailed',...
                    'name',obj.Name,...
                    'message','Error in test definition',...
                    'details','This test does not work due to a missing function declaration.');
                TeamCity.postmessage('testFinished',...
                    'name',obj.Name,...
                    'duration','0');
                return;
            end
            
            %% Check open figures
            openfigures = findobj('Type','figure');

            %% Evaluate test
            try
                errorReport = '';
                errorMessage = '';
                commandWindowString = '';
                try
                    % Try to perform test with output argument (testResult)
                    tic;
                    profile clear
                    profile on
                    [commandWindowString obj.TestResult] = evalc([obj.FunctionName ';']);
                    profile off
                    runTime = toc;
                    if ~islogical(obj.TestResult)
                        obj.TestResult = true;
                    end
                catch me
                    % Test did not run, figure out if it is because we expect output
                    path(pt);
                    if strcmp(me.identifier,'MATLAB:TooManyOutputs')
                        % Function does not have an output argument, run the test without output
                        clear me
                        try
                            tic;
                            profile clear
                            profile on
                            commandWindowString = evalc([obj.FunctionName ';']);
                            profile off
                            runTime = toc;
                            obj.TestResult = true;
                        catch me
                            % Test failed, report failure
                            path(pt);
                            obj.TestResult = false;
                            profile off
                            runTime = toc;
                            errorReport = me.getReport;
                            errorMessage = me.message;
                        end
                    else
                        % Another error occurred, Report failure of the test
                        profile off
                        runTime = toc;
                        obj.TestResult = false;
                        errorReport = me.getReport;
                        errorMessage = me.message;
                    end
                end
                
                %% Save stacktrace information
                if ~isempty(obj.RunDir) && ~isempty(obj.FilePath)
                    stacktrace = strrep(sprintf('%s\n',commandWindowString,errorReport),obj.RunDir,obj.FilePath);
                else
                    stacktrace = sprintf('%s\n',commandWindowString,errorReport);
                end
                obj.StackTrace = stacktrace;
                obj.ProfilerInfo = profile('info');
                obj.Time = runTime;
                
                if ~obj.TestResult
                    % Something went wrong, Post failure message
                    obj.Time = 0;
                    if obj.Verbose
                        disp(['     Error occurred: ' errorMessage]);
                    end
                    TeamCity.postmessage('testFailed',...
                        'name',obj.Name,...
                        'message',errorMessage,...
                        'details',obj.StackTrace);
                end
            catch me
                path(pt);
                % Something went wrong while executing test (Something with
                % the MTest code)
                obj.TestResult = false;
                obj.StackTrace = me.getReport;
                obj.Time = 0;
                TeamCity.postmessage('testFailed',...
                    'name',obj.Name,...
                    'message',me.message,...
                    'details',me.getReport);
                if obj.Verbose
                    disp(['     Error occurred: ' me.message]);
                end
            end
            
            %% return if obj has to be ignored
            if obj.Ignore && obj.Verbose
                disp(['     Ignored: ' obj.IgnoreMessage]);
            end
            
            %% Close all remaining open figures from the test
            newopenfigures = findobj('Type','figure');
            id = ~ismember(newopenfigures,openfigures);
            if any(id) && isempty(find(strcmpi(varargin,'keepfigures'), 1))
                close(newopenfigures(id));
            end
            
            %% cd back
            cd(cdtemp);
            
            %% set additional parameters
            obj.Date = now;
            
            %% Return the initial searchpath
            path(pt);
            
            %% Finish test
            TeamCity.postmessage('testFinished',...
                'name',obj.Name,...
                'duration',num2str(round(obj.Time*1000)));
            if obj.Verbose
                disp(['     Test finished: ' obj.Name]);
            end
            %% Unlock the workspace
            munlock;
        end
        function edit(obj,varargin)
            for iobj = 1:length(obj)
                filename = fullfile(obj(iobj).FilePath,[obj(iobj).FileName '.m']);
                if ~exist(filename,'file')
                    filename = which([obj(iobj).FileName '.m']);
                    if ~exist(filename,'file')
                        warning('MTest:NoSuchFile',['Could not find file: ' fullfile(obj(iobj).FilePath,[obj(iobj).FileName '.m'])]);
                        continue;
                    end
                end
                if nargin > 1
                    opentoline(filename,varargin{:});
                else
                    opentoline(filename,max([1 find(obj(iobj).IDTestFunction,1,'first')]),1);
                end
            end
        end
    end
    methods (Hidden = true)
        function publishdescription(obj,functionname,varargin)
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
            
            %% Do not publish if the object should be ignored
            if obj.Ignore
                return;
            end

            %% Determine whether the publish code is a subfunction, function or script
            functionType = 'subfunction';
            if isa(functionname,'function_handle')
                functionname = func2str(functionname);
            end
            idfunction = strcmp({obj.SubFunctions.name},functionname);

            if all(~idfunction)
                % function is not a subfunction
                if ~exist(which(functionname),'file')
                    % There is no external file with this name
                    error('TeamCity:Publish','TeamCity.publishdescription should have the name or handle of a function or script as first input argument');
                end
                % read the code of the external file to see if it is a function or a script
                fcncalls = getcallinfo(which(functionname));
                if datenum(version('-date')) > datenum(2010,1,1)
                    if fcncalls(1).type == internal.matlab.codetools.reports.matlabType.Function
                        functionType = 'function';
                    else
                        functionType = 'script';
                    end
                else
                    if strcmp(fcncalls(1).type,'function')
                        functionType = 'function';
                    else
                        functionType = 'script';
                    end
                end
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
            includeCode = false;
            if any(strcmpi(varargin,'includecode'))
                id = find(strcmpi(varargin,'includecode'));
                includeCode = varargin{id+1};
            end
            
            % evaluateCode
            evaluateCode = true;
            if any(strcmpi(varargin,'evaluatecode'))
                id = find(strcmpi(varargin,'evaluatecode'));
                evaluateCode = varargin{id+1};
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
                'showCode',includeCode,...
                'useNewFigure',false,... % Maybe add this to the input of properties?
                'evalCode',evaluateCode);
            
            %% Check open figures
            openfigures = findobj('Type','figure');
            
            %% publish results to resdir
            switch functionType
                case 'subfunction'
                    idPublishString = obj.SubFunctions(idfunction).linemask;
                    if strncmp(obj.FullString(obj.SubFunctions(idfunction).firstline),'function ',9)
                        idPublishString(obj.SubFunctions(idfunction).firstline) = false;
                    end
                    
                    % ==> This can lead to errors if someone somehow does not end the subfunction with end end
                    % also begins the last line with end....
                    if strncmp(obj.FullString(obj.SubFunctions(idfunction).lastline),'end',3)
                        idPublishString(obj.SubFunctions(idfunction).lastline) = false;
                    end
                    
                    descrstr = obj.FullString(idPublishString);
                otherwise
                    fid = fopen(which(functionname),'r');
                    str = textscan(fid,'%s','delimiter','\n','whitespace','','bufSize',10000);
                    functioncontent = str{1};
                    fclose(fid);
                    if strcmp(functionType,'script')
                        descrstr = sprintf('%s\n',functioncontent{:});
                    else
                        if length(fcncalls)>1
                            descrstr = sprintf('%s\n',functioncontent{:});
                        else
                            functioncontent(fcncalls.firstline) = [];
                            descrstr = sprintf('%s\n',functioncontent{:});
                        end
                    end
            end
            
            %% Publish
            MTest.publishcodestring(outputname,...
                [],...
                descrstr,...
                opt,...
                true);
            
            %% Close all remaining open figures from the test
            newopenfigures = findobj('Type','figure');
            id = ~ismember(newopenfigures,openfigures);
            if any(id) && isempty(find(strcmpi(varargin,'keepfigures'), 1))
                close(newopenfigures(id));
            end
        end
        function evaluatedescription(obj,functionname)
            %% Do not publish if the object should be ignored
            if obj.Ignore
                return;
            end

            %% Determine whether the publish code is a subfunction, function or script
            functionType = 'subfunction';
            if isa(functionname,'function_handle')
                functionname = func2str(functionname);
            end
            idfunction = strcmp({obj.SubFunctions.name},functionname);

            if all(~idfunction)
                % function is not a subfunction
                if ~exist(which(functionname),'file')
                    % There is no external file with this name
                    error('TeamCity:Publish','TeamCity.publishdescription should have the name or handle of a function or script as first input argument');
                end
                % read the code of the external file to see if it is a function or a script
                fcncalls = getcallinfo(which(functionname));
                % TODO: Known issue, if Matlab 2009b there is a bug in getcallinfo that prevents
                % generation of callinfo for scripts. THis bug was fixed in 2010a and did not exist
                % in 2009a whereas R14 up till 2008b use the same version of getcallinfo.
                if datenum(version('-date')) > datenum(2010,1,1)
                    if fcncalls(1).type == internal.matlab.codetools.reports.matlabType.Function
                        functionType = 'function';
                    else
                        functionType = 'script';
                    end
                else
                    if strcmp(fcncalls(1).type,'function')
                        functionType = 'function';
                    else
                        functionType = 'script';
                    end
                end
            end

            switch functionType
                case 'subfunction'
                    idPublishString = obj.SubFunctions(idfunction).linemask;
                    if strncmp(obj.FullString(obj.SubFunctions(idfunction).firstline),'function ',9)
                        idPublishString(obj.SubFunctions(idfunction).firstline) = false;
                    end
            
                    % ==> This can lead to errors if someone somehow does not end the subfunction with end end
                    % also begins the last line with end....
                    if strncmp(obj.FullString(obj.SubFunctions(idfunction).lastline),'end',3)
                        idPublishString(obj.SubFunctions(idfunction).lastline) = false;
                    end
                    
                    descrstr = sprintf('%s\n',...
                        'TeamCity.restoreworkspace;',...
                        'profile on',...
                        obj.FullString{idPublishString},...
                        'profile off',...
                        'TeamCity.storeworkspace;');
                    
                    MTestUtils.evalinemptyworkspace(descrstr);
                case 'function'
                    fid = fopen(which(functionname),'r');
                    str = textscan(fid,'%s','delimiter','\n','whitespace','','bufSize',10000);
                    functioncontent = str{1};
                    fclose(fid);
                    descrstr = sprintf('%s\n',...
                        'TeamCity.restoreworkspace;',...
                        'profile on',...
                        functioncontent{:},...
                        'profile off',...
                        'TeamCity.storeworkspace;');
                    MTestUtils.evalinemptyworkspace(descrstr);
                case 'script'
                    descrstr = sprintf('%s\n',...
                        'TeamCity.restoreworkspace;',...
                        'profile on',...
                        [functionname ';'],...
                        'profile off',...
                        'TeamCity.storeworkspace;');
                    MTestUtils.evalinemptyworkspace(descrstr);
            end

        end
        function publishresult(obj,functionname,varargin)
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
            
            %% Do not publish if the object should be ignored
            if obj.Ignore
                return;
            end

            %% Determine whether the publish code is a subfunction, function or script
            functionType = 'subfunction';
            if isa(functionname,'function_handle')
                functionname = func2str(functionname);
            end
            idfunction = strcmp({obj.SubFunctions.name},functionname);

            if all(~idfunction)
                % function is not a subfunction
                if ~exist(which(functionname),'file')
                    % There is no external file with this name
                    error('TeamCity:Publish','TeamCity.publishdescription should have the name or handle of a function or script as first input argument');
                end
                % read the code of the external file to see if it is a function or a script
                fcncalls = getcallinfo(which(functionname));
                if datenum(version('-date')) > datenum(2010,1,1)
                    if fcncalls(1).type == internal.matlab.codetools.reports.matlabType.Function
                        functionType = 'function';
                    else
                        functionType = 'script';
                    end
                else
                    if strcmp(fcncalls(1).type,'function')
                        functionType = 'function';
                    else
                        functionType = 'script';
                    end
                end
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
            
            %% Get filename from input
            id = find(strcmp(varargin,'outputfile'));
            outputfile = fullfile(resdir,[obj.FileName, 'publish.html']);
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
            includeCode = false;
            if any(strcmpi(varargin,'includecode'))
                id = find(strcmpi(varargin,'includecode'));
                includeCode = varargin{id+1};
            end
            
            % evaluateCode
            evaluateCode = true;
            if any(strcmpi(varargin,'evaluatecode'))
                id = find(strcmpi(varargin,'evaluatecode'));
                evaluateCode = varargin{id+1};
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
                'showCode',includeCode,...
                'useNewFigure',false,... % Maybe add this to the input of properties?
                'evalCode',evaluateCode);
            
            %% Check open figures
            openfigures = findobj('Type','figure');
            
            %% publish results to resdir
            % Todo: in future it should be possible to call a script outside the function
            switch functionType
                case 'subfunction'
                    idPublishString = obj.SubFunctions(idfunction).linemask;
                    if strncmp(obj.FullString(obj.SubFunctions(idfunction).firstline),'function ',9)
                        idPublishString(obj.SubFunctions(idfunction).firstline) = false;
                    end
                    
                    % ==> This can lead to errors if someone somehow does not end the subfunction with end end
                    % also begins the last line with end....
                    if strncmp(obj.FullString(obj.SubFunctions(idfunction).lastline),'end',3)
                        idPublishString(obj.SubFunctions(idfunction).lastline) = false;
                    end
                    
                    publishstr = obj.FullString(idPublishString);
                otherwise
                    fid = fopen(which(functionname),'r');
                    str = textscan(fid,'%s','delimiter','\n','whitespace','','bufSize',10000);
                    functioncontent = str{1};
                    fclose(fid);
                    if strcmp(functionType,'script')
                        publishstr = sprintf('%s\n',functioncontent{:});
                    else
                        if length(fcncalls)>1
                            publishstr = sprintf('%s\n',functioncontent{:});
                        else
                            functioncontent(fcncalls.firstline) = [];
                            publishstr = sprintf('%s\n',functioncontent{:});
                        end
                    end
            end
            
            MTest.publishcodestring(outputname,...
                [],...
                publishstr,...
                opt,...
                true);
            
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
            string2evaluate = ['TeamCity.restoreworkspace; profile on;', tempfileshortname, ';'];
            if saveWorkSpace
                string2evaluate = cat(2,string2evaluate,' profile off; TeamCity.storeworkspace;');
            end
            
            % Now specify the code to evaluate. The string constructed above should be evaluated in
            % an empty workspace. Therefore in the base workspace we only call evalinemptyworkspace,
            % with the string we just constructed as input.
            publishoptions.codeToEvaluate = ['MTestUtils.evalinemptyworkspace(''' string2evaluate ''');'];
            
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
    methods (Static = true)
        function name(proposedname)
            currentTest = TeamCity.currenttest;
            if ~isempty(currentTest)
                if TeamCity.running
                    %% Set test properties
                    if ~strcmp(currentTest.Name,proposedname)
                        return;
                        % TODO give warning
                    end
                else
                    currentTest.Name = proposedname;
                end
            end
        end
        function category(newcategory)
            %% Give Category name
            if TeamCity.running
                currentTest = TeamCity.currenttest;
                if ~isempty(currentTest)
                    currentTest.Category = newcategory;
                end
            end
        end
    end
end
classdef MTest < MFunctionFile & handle
    %MTEST  One line description goes here.
    %
    %   More detailed description goes here.
    %
    %   See also
    
    %% Copyright notice
    %   --------------------------------------------------------------------
    %   Copyright (C) 2010 Deltares
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
    
    % This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
    % OpenEarthTools is an online collaboration to share and manage data and
    % programming tools in an open source, version controlled environment.
    % Sign up to recieve regular updates of this function, and to contribute
    % your own tools.
    
    %% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
    % Created: 30 Nov 2010
    % Created with Matlab version: 7.11.0.584 (R2010b)
    
    % $Id$
    % $Date$
    % $Author$
    % $Revision$
    % $HeadURL$
    % $Keywords: $
    
    %% Properties
    properties
        Name = [];                          % Name of the test
        
        Ignore = false;                     % If ignore = true, this test is ignored
        IgnoreMessage = '';                 % Optional string to point out why this test(case) was ignored
        Category = MTestCategory.Unit;      % Category of the test(case)

        Verbose = true;                     % Determines whether messages are written to the command window whenever the run function gets executed
        AutoRefresh = false;                % If this property is set true, the object gets updated with the newest version of the definition before executing run
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
        IncludeCoverage = false;
    end
    
    %% Methods
    methods
        function this = MTest(varargin)
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
            %           TODO
            %
            %   Output:
            %   obj - MTest object
            %
            %   See also MTest MTest.run MTestRunner MTestFactory

            %% Return in case of no input
            if nargin==0
                return;
            end
            
            %% Create shortcut to MtestFactory to create a test
            this = MTestFactory.createtest(varargin{:});
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
                isUpToDate = obj.verifytimestamp;
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
                    if obj.IncludeCoverage
                        profile clear
                        profile on
                    end
                    [commandWindowString obj.TestResult] = evalc([obj.FunctionName ';']);
                    if obj.IncludeCoverage
                        profile off
                    end
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
                            if obj.IncludeCoverage
                                profile clear
                                profile on
                            end
                            commandWindowString = evalc([obj.FunctionName ';']);
                            if obj.IncludeCoverage
                                profile off
                            end
                            runTime = toc;
                            obj.TestResult = true;
                        catch me
                            % Test failed, report failure
                            path(pt);
                            obj.TestResult = false;
                            if obj.IncludeCoverage
                                profile off
                            end
                            runTime = toc;
                            errorReport = me.getReport;
                            errorMessage = me.message;
                        end
                    else
                        % Another error occurred, Report failure of the test
                        if obj.IncludeCoverage
                            profile off
                        end
                        runTime = toc;
                        obj.TestResult = false;
                        errorReport = me.getReport;
                        errorMessage = me.message;
                    end
                end
                
                %% Save stacktrace information
                obj.StackTrace = sprintf('%s\n',commandWindowString,errorReport);
                if obj.IncludeCoverage
                    obj.ProfilerInfo = profile('info');
                end
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
                if obj.IncludeCoverage
                    profile off
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
        function edit(this,varargin)
            %EDIT  opens the test definition file in the editor.
            %
            %   More detailed description goes here.
            %
            %   Syntax:
            %   edit(this)
            %
            %   Input:
            %   this  = Instance of an MTest object
            %
            %   See also MTest MTest.run edit opentoline 
            for iobj = 1:length(this)
                filename = fullfile(this(iobj).FilePath,[this(iobj).FileName '.m']);
                if ~exist(filename,'file')
                    filename = which([this(iobj).FileName '.m']);
                    if ~exist(filename,'file')
                        warning('MTest:NoSuchFile',['Could not find file: ' fullfile(this(iobj).FilePath,[this(iobj).FileName '.m'])]);
                        continue;
                    end
                end
                if nargin > 1
                    opentoline(filename,varargin{:});
                else
                    TODO('Search for first code line');
                    firstCodeLine = 1;
                    opentoline(filename,max([1 firstCodeLine]),1);
                end
            end
        end
    end
    
    %% Static methods
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
    end
end

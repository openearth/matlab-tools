classdef mtestcase < handle & mtestdefinitionblock & mtestpublishable
    % MTESTCASE - Object to handle testcases written in WaveLab format
    %
    % This objects stores the information written in a WaveLab format test file. The test files
    % consist of three parts divided by a cell break (%%). The three cells represent:
    %
    %   1.  Description of the testcase
    %   2.  Run code
    %   3.  Publish code
    %
    % Each section starts with "%% #CaseX YYYY" in wich X represents the number of the testcase and
    % YYYY is either "Description", "RunTest" or "TestResults", specifying the steps mentioned
    % above. An mtestcase object containes one of these tests.
    % 
    % Description is seen purely as documentation of the testcase (in other words: what do we test,
    % how do we test it and what outcome do we expect).
    %
    % The RunCode section contains code that must be executed in order to test the function (Any
    % code that was already used in the Description is executed as well. The only requirement is
    % that the code produces a variable testresult indicating whether the test was a success or
    % not).
    %
    % The TestResults section includes code that can be used to publish the results of the test. It
    % is published to html with the Matlab publish function. Any variables created in the first two
    % sections of a test (description and test run) can be used in this section. See the Matlab 
    % documentation on cell formatting:
    %
    % docsearch('Formatting M-File Code for Publishing');
    %
    % See also mtest mtestengine mtestcase.mtestcase mtestcase.publishDescription mtestcase.runTest mtestcase.publishResults 
    
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
        casenumber = [];                    % Number of the testcase
        
        testresult = false;                 % Boolean indicating whether the test was run successfully
        time = [];                          % time needed for the testcase
        profinfo = [];                      % Profile info structure
        functioncalls = [];

        resdir = '';                        % Location where files are published
        postteamcitymessage = true;
    end
    properties (Hidden = true)
        testperformed = false;              % Variable to indicate whether the test was executed.
        eventlisteners = [];
        % old props that should not be used
        inputneeded = false;                % Boolean determining if there is any code in the baseworkspace that must be included.
        outputfile = '';
    end
    
    %% events
    events
        CaseInitialized
        CaseFailed
        CaseRun
        TestPerformed
        PublishCase % not a good name
    end
    
    %% Methods
    methods
        function obj = mtestcase(varargin)
            %mtestcase  Creates an mtestcase object.
            %
            %   This function creates an mtestcase object that sores all the necessary test
            %   information and results. This object can later be used to publish the description 
            %   (mtestcase.publishDescription), run the test (mtestcase.runTest) or publish the 
            %   testresults (mtestcase.publishResults).
            %
            %   Syntax:
            %   obj = mtest(casenumber,...);
            %   obj = mtest(...,'property','value');
            %
            %   Input:
            %   casenumber  = Number of the testcase.
            %
            %   Property - value pairs:
            %       casename                -   TODO, Name of the testcase
            %       description             -   String with the content of the testcase description.
            %       runcode                 -   String with the content of the testcase runcode.
            %       publishcode             -   String with the content of the publishcode.
            %       descriptionoutputfile   -   Name of the html output file created when publishing
            %                                   the description of the test.
            %       descriptionincludecode  -   boolean setting the mtest property with the same
            %                                   name. This property is normally set with attributes
            %                                   in the test definition file, but can be changed
            %                                   before publishing.
            %       descriptionevaluatecode -   boolean setting the mtest property with the same
            %                                   name. This property is normally set with attributes
            %                                   in the test definition file, but can be changed
            %                                   before publishing.
            %       publishoutputfile       -   Name of the html output file created when publishing
            %                                   the test results.
            %       publishincludecode      -   boolean setting the mtest property with the same
            %                                   name. This property is normally set with attributes
            %                                   in the test definition file, but can be changed
            %                                   before publishing.
            %       publishevaluatecode     -   boolean setting the mtest property with the same
            %                                   name. This property is normally set with attributes
            %                                   in the test definition file, but can be changed
            %                                   before publishing.
            %
            %   Output:
            %   obj - mtestcase object
            %
            %
            %   See also mtestcase.mtestcase mtestcase.runTest mtestcase.publishDescription mtestcase.publishResults mtestengine mtest
            
            %% Check whether there is any input
            if nargin == 0
                return
            end
            
            %% Check testcase number
            if ~isnumeric(varargin{1})
                if ischar(varargin{1})
                    % support a hidden functionality that automatically creates an mtest object if
                    % this function is called with a filename.
                    try
                        newobj = mtest(varargin{:});
                        if ~isempty(newobj)
                            warning('MTestCase:WrongInput','Input appears to be a filename. Try mtest to create an mtest object.');
                        else
                            error('MTestCase:WrongInput','First input argument must be the number of the testcase.');
                        end
                        return
                    catch err
                        error('MTestCase:WrongInput','First input argument must be the number of the testcase.');
                    end
                else
                    error('MTestCase:WrongInput','First input argument must be the number of the testcase.');
                end
            end
            obj.casenumber = varargin{1};
            varargin(1)=[];
            
            %% Retrieve description from input
            id = find(strcmpi(varargin,'descriptioncode'));
            if ~isempty(id)
                obj.descriptioncode = varargin(id+1);
                if iscell(obj.descriptioncode{1})
                    obj.descriptioncode = obj.descriptioncode{1};
                end
                varargin(id:id+1)=[];
            end
            %% Retrieve name
            id = find(strcmpi(varargin,'name'));
            if ~isempty(id)
                obj.name = varargin{id+1};
                varargin(id:id+1)=[];
            end
            
            %% Retrieve runcode from input
            id = find(strcmpi(varargin,'runcode'));
            if ~isempty(id)
                obj.runcode = varargin(id+1);
                if iscell(obj.runcode{1})
                    obj.runcode = obj.runcode{1};
                end
                varargin(id:id+1)=[];
            end
            
            %% Retrieve publishcode from input
            id = find(strcmpi(varargin,'publishcode'));
            if ~isempty(id)
                obj.publishcode = varargin(id+1);
                if iscell(obj.publishcode{1})
                    obj.publishcode = obj.publishcode{1};
                end
                varargin(id:id+1)=[];
            end
            
            %% Set other properties that are defined in the input
            if ~isempty(varargin)
                propstoset = {'functionoutputname','functionname','initializationcode','functionheader','baseworkspacecode','inputneeded','descriptionoutputfile','descriptionincludecode','descriptionevaluatecode','publishoutputfile','publishincludecode','publishevaluatecode'};
                propsid = 1:2:length(varargin);
                memid = ismember(varargin(propsid),propstoset);
                for im = 1:length(memid)
                    prop = varargin{propsid(im)};
                    if ~memid(im)
                        try
                            % in case of hidden property
                            obj.(prop) = varargin{propsid(im)+1};
                        catch me %#ok<NASGU>
                            warning('MTest:NoProperty',['The property "' prop '" could not be found or sets.']);
                        end
                    else
                        obj.(prop) = varargin{propsid(im)+1};
                    end
                end
            end
            
            %% Create event listeners
            obj.eventlisteners = cat(1,...
                event.listener(obj,'ReadyToSetDescriptionOutputFileName',@obj.setDescriptionOutputFileName),...
                event.listener(obj,'ReadyToSetCoverageOutputFileName',@obj.setCoverageOutputFileName),...
                event.listener(obj,'ReadyToSetPublishOutputFileName',@obj.setPublishOutputFileName),...
                event.listener(obj,'CaseInitialized',@obj.storeInitVars),...
                event.listener(obj,'CaseInitialized',@obj.startTestCase),...
                event.listener(obj,'CaseFailed',@obj.publishFailedCase),...
                event.listener(obj,'CaseFailed',@obj.failTestCase),...
                event.listener(obj,'CaseRun',@obj.storeRunVars),...
                event.listener(obj,'CaseRun',@obj.stopTestCase),...
                event.listener(obj,'PublishCase',@obj.fullPublish));
        end
        function run(obj,varargin)
            %run  Runs the code included in the RunTest cell of the testcase
            %
            %   This function runs the code specified in the RunTest cell of the test definition
            %   file. Previous to running the test code, any results of the code specifying the
            %   description of the testcase are created in the workspace where the test is performed.
            %
            %   Syntax:
            %   runTest(obj);
            %   runTest(...,'keepfigures');
            %   obj.runTest;
            %
            %   Input:
            %   obj             - An instance of an mtestcase object.
            %   'keepfigures'   - The runTest function automatically closes any figures that were
            %                     created during the test process and were not already there.
            %                     The optional argument 'keepfigures' prevents these figures from
            %                     being closed (unless stated in the test code somewhere).
            %
            %   See also mtestcase mtestcase.mtestcase mtestcase.publishResults mtestcase.publishDescription mtest mtestengine

            %% Don't run ignored tests
            if obj.ignore
                return;
            end
            
            %% Check whether the testcase has been initialized
            if ~obj.initialized
                notify(obj,'ReadyToInitialize'); % mtest object listenes and prepares the tests
            end
            
            %% store necessary objects in a mtestworspace variable
            mtestworkspace.obj = obj;

            storevarsstring = sprintf('%s\n',...
                'mtest_12thf9e230eu.vars = whos;',...
                'for mtest_12thf9e230eui = 1:length(mtest_12thf9e230eu.vars)',...
                'mtest_12thf9e230eu.varargout{mtest_12thf9e230eui,1} = mtest_12thf9e230eu.vars(mtest_12thf9e230eui).name;',...
                'mtest_12thf9e230eu.varargout{mtest_12thf9e230eui,2} = eval(mtest_12thf9e230eu.vars(mtest_12thf9e230eui).name);',...
                'end',...
                'mtest_12thf9e230eu.varargout(strcmp(mtest_12thf9e230eu.varargout(:,1),''mtest_tempstring12fhj123''),:)=[];',...
                'setappdata(0,''mtesttempworkspace'',mtest_12thf9e230eu.varargout);');
            
            mtestworkspace.str = sprintf('%s\n',...
                obj.descriptioncode{~strncmp(obj.descriptioncode,'%',1)},... % Always run the description before running the test
                obj.runcode{:},...
                char(10),...
                storevarsstring);
            
            %% check tempdir
            obj.verifyTempDir;
            
            %% create temp file with code that needs to be executed
            mtestworkspace.filename = mtestcase.makeTempFile(...
                obj.tempdir,...
                mtestworkspace.str,...
                obj.functionname);

            %% Check open figures
            mtestworkspace.openfigures = findobj('Type','figure');
            
            %% clear all variables except the mtestworkspace
            clear('obj','ans','varargin','restorevarsstring','storevarsstring');
            
            %% create base workspace if needed
            if ~isempty(mtestworkspace.obj.initworkspace)
                if iscell(mtestworkspace.obj.initworkspace)
                    % workspace evaluated ==> paste in workspace
                    for mtestworkspace2435i = 1:size(mtestworkspace.obj.initworkspace,1)
                        eval([mtestworkspace.obj.initworkspace{mtestworkspace2435i,1} ' = mtestworkspace.obj.initworkspace{mtestworkspace2435i,2};']);
                    end
                end
            end
            
            clear mtestworkspace2435i
            
            %% Run the test
            try
                %% run the mfile
                tic
                run(mtestworkspace.filename);
                mtestworkspace.obj.time = toc;
                
                drawnow update
                
                %% delete the temp file (we don't need it anymore)
                delete(mtestworkspace.filename);
                
                %% create testresult
                mtestworkspace.testresult = nan;
                if ~isempty(mtestworkspace.obj.functionoutputname)
                    mtestworkspace.testresult = eval(mtestworkspace.obj.functionoutputname{1});
                end
                
                %% Store variables that were created during the test 
                % needed for the publish function...
                mtestworkspace.obj.runworkspace = getappdata(0,'mtesttempworkspace');
                rmappdata(0,'mtesttempworkspace');
                
            catch err
                %% Handle error
                % Something went wrong while testing
                if strcmp(err.identifier,'MTest:NoTestResult')
                    % The test did not crash, but there was no testresult
                    % variable
                    warning('MTest:NoTestResult','This piece of code did not produce a test result');
                else
                    % Something els went wrong (probably the test code).
                    warning('MTest:TestCodeFailed','There appears to be an error in the test code');
                end
                mtestworkspace.testresult = false;
                
            end
            
            %% Close all remaining open figures from the test
            newopenfigures = findobj('Type','figure');
            id = ~ismember(newopenfigures,mtestworkspace.openfigures);
            if any(id) && isempty(find(strcmpi(varargin,'keepfigures'), 1))
                close(newopenfigures(id));
            end
            
            %% Store the result
            % store the test result in the obj. We do not need to specify
            % the object as output whereas it is a subclass of the handle
            % class. all copies will be adjusted immediately.
            mtestworkspace.obj.testresult = mtestworkspace.testresult;
            
            %% Set flag
            mtestworkspace.obj.testperformed = true;
            
            %% notify
            notify(mtestworkspace.obj,'TestPerformed');
            
        end
        function runAndPublish(obj,varargin)
            %runAndPublish  Runs the testcase and publishes the description and result.
            %
            %   This function runs the testcase object and publishes the case description and
            %   results.
            %
            %   Syntax:
            %   runAndPublish(obj,'property','value');
            %   obj.publisResults(...'property','value');
            %
            %   Input:
            %   obj  = An instance of an mtestcase object.
            %
            %   property value pairs:
            %           'resdir'     -  Specifies the output directory
            %           'outputfile' -  Main part of the name of the output file. The description is
            %                           output file appends _description to this name. The results
            %                           output file appends _results to it.
            %           'maxwidth'  -   Maximum width of the published figures (in pixels). By 
            %                           default the maximum width is set to 600 pixels. 
            %           'maxheight' -   Maximum height of the published figures (in pixels). By 
            %                           default the maximum height is set to 600 pixels.
            %           'stylesheet'-   Style sheet that is used for publishing (see publish
            %                           documentation for more information).
            %
            %   See also mtestcase mtestcase.mtestcase mtestcase.publishDescription mtest.publishResults mtestcase.runTest mtestengine mtest

            %% Retrieve input
            if isempty(obj.resdir)
                obj.resdir = cd;
            end
            if any(strcmpi(varargin,'resdir'))
                obj.resdir = varargin{find(strcmpi(varargin,'resdir'))+1};
            end
            
            obj.outputfile = '';
            if any(strcmpi(varargin,'outputfile'))
                [pth nm] = fileparts(varargin{find(strcmpi(varargin,'outputfile'))+1});
                obj.outputfile = fullfile(pth,nm);
            end
            
            if isempty(obj.functionname)
                obj.functionname = 'Unnamed_test';
            end
            
            if isempty(obj.outputfile)
                obj.outputfile = [obj.functionname '_case_' num2str(obj.casenumber)];
            end
            if isempty(obj.descriptionoutputfile)
                obj.descriptionoutputfile = [obj.outputfile '_description.html'];
            end
            if isempty(obj.publishoutputfile)
                obj.publishoutputfile = [obj.outputfile '_results.html'];
            end
            if isempty(obj.coverageoutputfile)
                obj.coverageoutputfile = [obj.outputfile '_coverage.html'];
            end
            
            % Maxwidth
            if any(strcmpi(varargin,'maxwidth'))
                id = find(strcmpi(varargin,'maxwidth'));
                obj.maxwidth = varargin{id+1};
            end
            
            % maxheight
            if any(strcmpi(varargin,'maxheight'))
                id = find(strcmpi(varargin,'maxheight'));
                obj.maxheight = varargin{id+1};
            end
            
            % stylesheet
            if any(strcmpi(varargin,'stylesheet'))
                id = find(strcmpi(varargin,'stylesheet'));
                obj.stylesheet = varargin{id+1};
            end
            
            %% publih description
            obj.publishDescription(...
                'resdir',obj.resdir,...
                'stylesheet',obj.stylesheet,...
                'maxheight',obj.maxheight,...
                'maxwidth',obj.maxwidth,...
                'filename',obj.descriptionoutputfile);
            
            %% run test
            obj.run;

            %% and publish result
            obj.publishResult(...
                'resdir',obj.resdir,...
                'stylesheet',obj.stylesheet,...
                'maxheight',obj.maxheight,...
                'maxwidth',obj.maxwidth,...
                'filename',obj.publishoutputfile);
        end
        function fullPublish(obj,varargin)
            % This function assumes the testcase has been run fully
%             MoreThanTwoInputArgs = nargin>2;
%             if MoreThanTwoInputArgs
%                 SecondVararginMtesteventData = strcmp(class(varargin{2}),'mtesteventdata');
%                 RemoveTemoObj = varargin{2}.removetempobj;
%                 if SecondVararginMtesteventData && RemoveTemoObj
%                     obj.tmpobjname = [];
%                 end
%             end
            
            if obj.publish
                %% publish the description
                obj.publishDescription;
                
                %% publish the result
                obj.publishResult;
            end
            
            %% Clean object
            obj.cleanUp;
        end
        function cleanUp(obj)
            %cleanUp  Cleans up the mtestcase object
            %
            %   Some information is stored in hidden properties of the object. For example the test 
            %   workspace (workspace that is created during the test, including all variables) can 
            %   take a lot of space. This function cleans these variables. Consequently after
            %   cleaning the mtestcase object, test results can not be published anymore without 
            %   rerunning the test. This is done automatically when a call to publishResults is made
            %   without the object having test results. The property testresult stayes intact so 
            %   that the test result is still there. Typically this function is run after publishing 
            %   the results to remember the property testresult, but clear memory for other tests.
            %
            %   Syntax:
            %   cleanUp(obj);
            %   obj.cleanUp;
            %
            %   Input:
            %   obj  = An instance of an mtestcase object.
            %
            %   See also mtestcase mtestcase.mtestcase mtestcase.publishDescription mtest.publishResults mtestcase.runTest mtestengine mtest
            
            %% Clear relevant properties
            obj.initworkspace = [];
            obj.initialized = false;
            obj.runworkspace = [];
            obj.testperformed = false;
        end
    end
    %% Hidden methods
    methods (Hidden = true)
        function startTestCase(obj,varargin)
            if obj.postteamcitymessage 
               postmessage('testStarted',obj.postteamcitymessage,...
                    'name',obj.name,...
                    'captureStandardOutput','true');
            end
        end
        function stopTestCase(obj,varargin)
            postmessage('testFinished',obj.postteamcitymessage,...
                'name',obj.name,...
                'duration','0');
        end
        function failTestCase(obj,varargin)
            if nargin>2 && strcmp(class(varargin{2}),'mtesteventdata')
                me = varargin{2}.workspace{strcmp(varargin{2}.workspace(:,1),'mtest_error_message'),2};
                if ~isempty(me)
                    postmessage('testFailed',obj.postteamcitymessage,...
                        'name',obj.name,...
                        'message',me.message,...
                        'details',me.getReport);
                end
            end
            postmessage('testFinished',obj.postteamcitymessage,...
                'name',obj.name,...
                'duration','0');
        end
        function publishFailedCase(obj,varargin)
            % This function assumes the testcase has been run fully
%             MoreThanTwoInputArgs = nargin>2;
%             if MoreThanTwoInputArgs
%                 SecondVararginMtesteventData = strcmp(class(varargin{2}),'mtesteventdata');
%                 RemoveTemoObj = varargin{2}.removetempobj;
%                 if SecondVararginMtesteventData && RemoveTemoObj
%                     obj.tmpobjname = [];
%                 end
%             end
            
            %% publish the description
            if obj.publish
                obj.publishDescription;
            end
           
            %% Clean object
            obj.cleanUp;
        end
        function verifyTempDir(obj)
            if isempty(obj.tempdir) || ~isdir(obj.tempdir)
                obj.tempdir = uigetdir(cd,'Select temp dir');
            end
        end
        function makeFakeFunction(obj,rundir)
            % prepares the fake function. This is a function that returns true in all circumstances.
            fname = fullfile(rundir,[obj.functionname '.m']);
            
            %% prepare content
            str = sprintf('%s\n',...
                obj.functionheader,...
                [obj.functionoutputname ' = true;']);
            
            %% write function
            fid = fopen(fname,'w');
            fprintf(fid,'%s\n',str);
            fclose(fid);
        end
        function makeInitFunction(obj,rundir)
            % prepares the init function. This is a function that stores the input variables with
            % the help of setappdata.
            fname = fullfile(rundir,[obj.functionname '.m']);
            
            %% prepare content
            str = sprintf('%s\n',...
                obj.functionheader,...
                ['notify(getappdata(0,''' obj.storedobjname '''),''CaseInitialized'',mtesteventdata(whos,''remove'',true));'],...
                [obj.functionoutputname{1} ' = true;']);
            
            %% write function
            fid = fopen(fname,'w');
            fprintf(fid,'%s\n',str);
            fclose(fid);
        end
        function makeRunFunction(obj,rundir)
            % prepares the init function. This is a function that stores the input variables with
            % the help of setappdata.
            fname = fullfile(rundir,[obj.functionname '.m']);
           
            %% prepare content
            str = sprintf('%s\n',...
                obj.functionheader,...
                'mtest_245y7e_tic = tic;',...
                ['notify(getappdata(0,''' obj.storedobjname '''),''CaseInitialized'',mtesteventdata(whos,''remove'',false));'],...
                obj.descriptioncode{~strncmp(obj.descriptioncode,'%',1)},...
                'profile on',...
                obj.runcode{:},...
                'profile off',...
                ['notify(getappdata(0,''' obj.storedobjname '''),''CaseRun'',mtesteventdata(whos,''time'',toc(mtest_245y7e_tic)));']);
            
            %% write function
            fid = fopen(fname,'w');
            fprintf(fid,'%s\n',str);
            fclose(fid);
        end
        function makeRunAndPublishFunction(obj,rundir)
            % prepares the runAndPublish function. This is a function that stores the input variables 
            % and with result after running the help of setappdata. It uses notifications to
            % initialize the publish function.
            fname = fullfile(rundir,[obj.functionname '.m']);
            
            %% prepare content
            str = sprintf('%s\n',...
                obj.functionheader,...
                'mtest_245y7e_tic = tic;',...
                ['notify(getappdata(0,''' obj.storedobjname '''),''CaseInitialized'',mtesteventdata(whos,''remove'',false));'],...
                'try',...
                    obj.descriptioncode{~strncmp(obj.descriptioncode,'%',1)},...
                    'profile on',...
                    obj.runcode{:},...
                    'profile off',...
                'catch mtest_error_message',...
                    ['notify(getappdata(0,''' obj.storedobjname '''),''CaseFailed'',mtesteventdata(whos,''time'',toc(mtest_245y7e_tic),''remove'',true));'],...
                    'rethrow(mtest_error_message);',...
                'end',...
                ['notify(getappdata(0,''' obj.storedobjname '''),''CaseRun'',mtesteventdata(whos,''time'',toc(mtest_245y7e_tic),''remove'',false));'],...
                ['notify(getappdata(0,''' obj.storedobjname '''),''PublishCase'',mtesteventdata(whos,''time'',toc(mtest_245y7e_tic),''remove'',true));']);
            
            %% write function
            fid = fopen(fname,'w');
            fprintf(fid,'%s\n',str);
            fclose(fid);
        end
        function storeInitVars(obj,varargin)
            % get workspace
            data = varargin{2};
            ws = data.workspace;
            
            % store init workspace
            obj.initworkspace = ws;
            obj.initialized = true;
        end
        function storeRunVars(obj,varargin)
            %% get workspace
            data = varargin{2};
            ws = data.workspace;
            
            %% store run workspace
            obj.runworkspace = ws;
            obj.testperformed = true;
            
            %% store run time
            if ~isempty(varargin{2}.time)
                obj.time = varargin{2}.time;
            end
            
            %% store testresult
            obj.testresult = nan;
            if ~isempty(obj.functionoutputname)
                if iscell(obj.functionoutputname)
                    if ~isempty(obj.functionoutputname{1})
                        obj.testresult = ws{strcmp(ws(:,1),obj.functionoutputname{1}),2};
                    end
                else
                    obj.testresult = ws{strcmp(ws(:,1),obj.functionoutputname),2};
                end
            end
            
            %% get profiler data
            obj.profinfo = profile('info');
            profile clear
            
            obj.functioncalls = mtestfunction;
            for i = 1:size(obj.profinfo.FunctionTable,1)
                % TODO => takes too long
                obj.functioncalls(i) = mtestfunction(obj.profinfo,i);
            end
            
            %% notify
            notify(obj,'TestPerformed');
            mtestworkspace.obj.testperformed = true;
        end
        
        function setDescriptionOutputFileName(obj,varargin)
           obj.descriptionoutputfile = ['UnnamedTest' '_description_case_' num2str(obj.casenumber) '.html']; 
        end
        function setCoverageOutputFileName(obj,varargin)
            obj.coverageoutputfile = [obj.filename '_coverage_case' num2str(obj.casenumber) '.html'];
        end
        function setPublishOutputFileName(obj,varargin)
            obj.publishoutputfile = ['UnnamedTest' '_results_case_' num2str(obj.casenumber) '.html'];
        end
    end
end
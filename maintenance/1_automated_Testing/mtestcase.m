classdef mtestcase < handle
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
        casename = [];                      % Name of the testcase

        functionheader = '';                % Header of the testcase function (first line)
        functionname = '';                  % Name of the testcase function
        functionoutputname = '';            % Name of 1x1 output boolean

        description = {};                   % Code that was included in the testfile description cell
        descriptionoutputfile = {};         % Name of the published output file of the description
        descriptionincludecode = false;     % Attribute IncludeCode for publishing the description cell
        descriptionevaluatecode = true;     % Attribute EvaluateCode for publishing the description cell

        runcode = {};                       % Code that was included in the testfile RunTest cell
        coverageoutputfile = {};            % Name of the published coverage output file

        publishcode = {};                   % Code that was included in the testfile TestResults cell
        publishoutputfile = {};             % Name of the published output file of the TestResults cell
        publishincludecode = false;         % Attribute IncludeCode for publishing the TestResults cell
        publishevaluatecode = true;         % Attribute EvaluateCode for publishing the TestResults cell
        
        testresult = false;                 % Boolean indicating whether the test was run successfully
        time = [];                          % time needed for the testcase
        profinfo = [];                      % Profile info structure
        functioncalls = [];

        resdir = '';                        % Location where files are published
    end
    properties (Hidden = true)
        initialized = false;
        testperformed = false;              % Variable to indicate whether the test was executed.

        tempdir = tempdir;                  % Temporary directory for publishing output files.
        tmpobjname = [];
        initworkspace = [];                 % Variable that can be used as workspace to pass input variables
        runworkspace = [];                  % Variable that can be used as workspace to pass variables after running (for publishing)
        
        eventlisteners = [];

        maxwidth  = 600;                    % Maximum width of the published figures (in pixels). By default the maximum width is set to 600 pixels.
        maxheight = 600;                    % Maximum height of the published figures (in pixels). By default the maximum height is set to 600 pixels.
        stylesheet = '';                    % Style sheet that is used for publishing (see publish documentation for more information).
        testname = '';
        outputfile = '';
        
        % old props that should not be used
        inputneeded = false;                % Boolean determining if there is any code in the baseworkspace that must be included.
    end
    
    %% events
    events
        NeedToInitialize % not a good name
        CaseInitialized
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
            id = find(strcmpi(varargin,'description'));
            if ~isempty(id)
                obj.description = varargin(id+1);
                if iscell(obj.description{1})
                    obj.description = obj.description{1};
                end
                varargin(id:id+1)=[];
            end
            %% Retrieve casename
            id = find(strcmpi(varargin,'casename'));
            if ~isempty(id)
                obj.casename = varargin{id+1};
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
                        warning('MTest:NoProperty',['The property "' prop '" could not be found or sets.']);
                    else
                        obj.(prop) = varargin{propsid(im)+1};
                    end
                end
            end
            obj.eventlisteners{1} = event.listener(obj,'CaseInitialized',@obj.storeInitVars);
            obj.eventlisteners{2} = event.listener(obj,'CaseRun',@obj.storeRunVars);
            obj.eventlisteners{3} = event.listener(obj,'PublishCase',@obj.fullPublish);
        end
        function publishDescription(obj,varargin)
            %publishDescripton  Creates an html file from the description code with publish
            %
            %   This function publishes the code included in the Description cell of the test file 
            %   for this testcase with the help of the publish function.
            %
            %   Syntax:
            %   publishDescripton(obj,'property','value')
            %   publishDescripton(...,'keepfigures');
            %   obj.publisDescription('property','value')
            %
            %   Input:
            %   obj             - An instance of an mtestcase object with the information of the 
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
            %           'testname'   -  Name of the main test.
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
            %   See also mtestcase mtestcase.mtestcase mtestcase.publishResults mtestcase.runTest mtestengine mtest
            
            %% Check whether the testcase has been initialized
            if ~obj.initialized
                notify(obj,'NeedToInitialize'); % mtest object listens and prepares the tests
            end
            
            if ~obj.initialized
                warning('MtestCase:RunSolo','TestCase is run solo');
                obj.run;
            end
            
            %% subtract result dir from input
            if isempty(obj.resdir)
                obj.resdir = cd;
            end
            id = find(strcmp(varargin,'resdir'));
            if ~isempty(id)
                obj.resdir = varargin{id+1};
                varargin(id:id+1) = [];
            end
            
            %% Get filename from input
            id = find(strcmp(varargin,'filename'));
            if ~isempty(id)
                [pt nm] = fileparts(varargin{id+1});
                obj.descriptionoutputfile = [nm '.html'];
                if ~isempty(pt)
                    obj.resdir = pt;
                end
                varargin(id:id+1) = [];
            end
            
            %% Process other input arguments
            % includeCode
            if any(strcmpi(varargin,'includecode'))
                id = find(strcmpi(varargin,'includecode'));
                obj.descriptionincludecode = varargin{id+1};
            end
            
            % evaluateCode
            if any(strcmpi(varargin,'evaluatecode'))
                id = find(strcmpi(varargin,'evaluatecode'));
                obj.descriptionevaluatecode = varargin{id+1};
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
            
            %% createoutputname
            if isempty(obj.descriptionoutputfile)
                obj.descriptionoutputfile = ['UnnamedTest' '_description_case_' num2str(obj.casenumber) '.html'];
            end
            [pt fn] = fileparts(obj.descriptionoutputfile);
            if isempty(pt)
                pt = obj.resdir;
            end
            outputname = fullfile(pt,[fn '.html']);
            
            %% retrieve testname from input
            [dum outname]= fileparts(outputname); 
            
            if any(strcmpi(varargin,'testname'))
                id = find(strcmpi(varargin,'testname'));
                obj.testname = varargin{id+1};
            else
                if isempty(obj.testname)
                    obj.testname = outname;
                end
            end
            
            %% set publish options
            opt = struct(...
                'format','html',...
                'stylesheet',obj.stylesheet,...
                'outputDir',fileparts(outputname),...
                'maxHeight',obj.maxheight,...
                'maxWidth',obj.maxwidth,...
                'showCode',obj.descriptionincludecode,...
                'useNewFigure',false,... % Maybe add this to the input of properties?
                'evalCode',obj.descriptionevaluatecode);
            
            %% Check open figures
            openfigures = findobj('Type','figure');
      
            %% publish results to resdir
            if ~isempty(obj.casename)
                descrstr = cat(1,{['%% Test description of testcase: "' obj.casename '"']},obj.description);
            else
                descrstr = cat(1,{['%% Test description of "' obj.testname '" (Case' num2str(obj.casenumber) ')']},obj.description);
            end
            mtestcase.publishCodeString(outputname,...
                [],...
                obj.initworkspace,...
                descrstr,...
                opt);
            
            %% Close all remaining open figures from the test
            newopenfigures = findobj('Type','figure');
            id = ~ismember(newopenfigures,openfigures);
            if any(id) && isempty(find(strcmpi(varargin,'keepfigures'), 1))
                close(newopenfigures(id));
            end
            
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
            
            %% Check whether the testcase has been initialized
            if ~obj.initialized
                notify(obj,'NeedToInitialize'); % mtest object listenes and prepares the tests
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
                obj.description{~strncmp(obj.description,'%',1)},... % Always run the description before running the test
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
                    mtestworkspace.testresult = eval(mtestworkspace.obj.functionoutputname);
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
            %           'testame'    -  Name of the main test.
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
            
            if isempty(obj.testname)
                obj.testname = 'Unnamed_test';
            end
            if any(strcmpi(varargin,'testname'))
                obj.testname = varargin{find(strcmpi(varargin,'testname'))+1};
            end
            
            if isempty(obj.outputfile)
                obj.outputfile = [obj.testname '_case_' num2str(obj.casenumber)];
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
                'testname',obj.testname,...
                'filename',obj.descriptionoutputfile);
            % [outputfile '_description_case_' num2str(obj.casenumber) '.html']
            
            %% run test
            obj.run;

            %% and publish result
            obj.publishResults(...
                'resdir',obj.resdir,...
                'stylesheet',obj.stylesheet,...
                'maxheight',obj.maxheight,...
                'maxwidth',obj.maxwidth,...
                'testname',obj.testname,...
                'filename',obj.publishoutputfile);
            %             [outputfile '_results_case_' num2str(obj.casenumber) '.html']
        end
        function publishCoverage(obj,varargin)
            %publishResult  Creates an html file with coverage information of this test
            %
            %   This function only creates an overview of the coverages. The coverage files for
            %   individual functions are linked to, but not generated.
            %
            %   Syntax:
            %   publishCoverage(obj,'property','value')
            %   obj.publisCoverage('property','value')
            %
            %   Input:
            %   obj             - An instance of an mtestcase object.
            %
            %   property value pairs:
            %           'resdir'     -  Specifies the output directory (default is the current
            %                           directory)
            %           'filename'   -  Name of the output file. If the filename includes a path,
            %                           this pathname overrides the specified resdir.
            %           'testname'   -  Name of the test.
            %           'exclude'    -  Cell with strings indicating the functions that should be
            %                           excluded from the overview.
            %           'include'    -  Cell with strings indicating the functions that should be
            %                           included in the overview.
            %           'coveragedir'-  dirname (relative) of the referenced coverage files
            %           
            %
            %   See also mtestcase mtest.run mtest.runAndPublish mtestengine
            
            %% Run test if we do not have results
%             if ~obj.testperformed
%                 obj.run;
%             end
            % This is a workaround. After a full publish cleanup is run... This removes most of the
            % information. we should either publish the coverage in that early stage (leaving no
            % possibilities to include the overall results) or eliminate this check entirely
            
            %% subtract result dir from input
            if isempty(obj.resdir)
                obj.resdir = cd;
            end
            id = find(strcmp(varargin,'resdir'));
            if ~isempty(id)
                obj.resdir = varargin{id+1};
                varargin(id:id+1) = [];
            end
            
            %% Get exclusions
            exclude = {};
            id = find(strcmp(varargin,'exclude'));
            if ~isempty(id)
                exclude = varargin{id+1};
            end
            
            coveragedir = {};
            id = find(strcmp(varargin,'coveragedir'));
            if ~isempty(id)
                coveragedir = varargin{id+1};
            end
            
            %% Get inclusions
            include = {};
            id = find(strcmp(varargin,'include'));
            if ~isempty(id)
                include = varargin{id+1};
            end
            
            %% Get filename from input
            id = find(strcmp(varargin,'filename'));
            if ~isempty(id)
                [pt nm] = fileparts(varargin{id+1});
                obj.coverageoutputfile = [nm '.html'];
                if ~isempty(pt)
                    obj.resdir = pt;
                end
                varargin(id:id+1) = [];
            end
            
            %% createoutputname
            if isempty(obj.coverageoutputfile)
                obj.coverageoutputfile = [obj.filename '_coverage_case' num2str(obj.casenumber) '.html'];
            end
            [pt fn] = fileparts(obj.coverageoutputfile);
            if isempty(pt)
                pt = obj.resdir;
            end
            obj.coverageoutputfile = fullfile(pt,[fn '.html']);
            
            %% retrieve testname from input
            if any(strcmpi(varargin,'testname'))
                id = find(strcmpi(varargin,'testname'));
                obj.testname = varargin{id+1};
            end
            
            %% calculate coverage
            fcns = {obj.functioncalls.functionname}';
            
            if isempty(fcns{1})
                fcns = [];
            else
                fcnspath = cellfun(@fileparts,{obj.functioncalls.filename}','UniformOutput',false);
                id = cellfun(@isempty,{obj.functioncalls.coverage});
                cov = nan(size(obj.functioncalls,2),1);
                cov(~id) = deal([obj.functioncalls(~id).coverage]);
                id = true(size(fcns));
                if ~isempty(include)
                    id = false(size(fcns));
                    for i = 1:length(include)
                        id(~cellfun(@isempty,strfind(lower(fcns),lower(include{i}))))=true;
                        id(~cellfun(@isempty,strfind(lower(fcnspath),lower(include{i}))))=true;
                    end
                end
                for i = 1:length(exclude)
                    id(~cellfun(@isempty,strfind(fcns,exclude{i})))=false;
                    id(~cellfun(@isempty,strfind(fcnspath,exclude{i})))=false;
                end
                fcns(~id)=[];
                
                cov(~id)=[];
            end
            
            %% Create header
            s{1} = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">';
            s{2} = '<html xmlns="http://www.w3.org/1999/xhtml">';
            
            s{3} = '<head>';
            s{end+1} = '<title>Coverage information</title>';
            s{end+1} = '</head>';
            s{end+1} = '<body>';
 
            if isempty(fcns)
                s{end+1} = 'This testcase did not address any function within the maindir';
            else
                %% Create table
                s{end+1} = '<table>';
                s{end+1} = '    <tr>';
                s{end+1} = '        <th>Function Name</th>';
                s{end+1} = '        <th>Coverage during testcase (%)</th>';
                s{end+1} = '    </tr>';
                for ifcn = 1:length(fcns)
                    [dummy fn] = fileparts(fcns{ifcn});
                    htmlfile = strrep(fullfile(coveragedir,mtestfunction.constructfilename([fn '_coverage.html'])),filesep,'/');
                    s{end+1} = '    <tr>';
                    s{end+1} = ['        <td><a class="RelFunctionRef" href="#" deltares:functioncoverageref="' htmlfile '">' code2html(fcns{ifcn}) '</a></td>']; %#ok<*AGROW>
                    s{end+1} = ['        <td>' num2str(cov(ifcn),'%0.0f') '</td>'];
                    s{end+1} = '    </tr>';
                end
                s{end+1} = '</table>';
            end
            %% end file
            s{end+1} = '</body>';
            s{end+1} = '</html>';
            
            %% save file
            fid = fopen(obj.coverageoutputfile,'w');
            fprintf(fid,'%s\n',s{:});
            fclose(fid);
        end
        function publishResults(obj,varargin)
            %publishResults  Creates an html file from the code included in the TestResult cell with publish
            %
            %   This function publishes the code included in the TestResult cell of the test file 
            %   with the help of the publish function. All variables created by running the test are
            %   still in the workspace and can therefore be used while publishing the results.
            %
            %   Syntax:
            %   publishResults(obj,'property','value')
            %   publishResults(...,'keepfigures');
            %   obj.publisResults(...)
            %
            %   Input:
            %   obj             - An instance of an mtestcase object with the information of the 
            %                     test results that has to be published.
            %   'keepfigures'   - The publishResults function automatically closes any figures that 
            %                     were created during publishing and were not already there.
            %                     The optional argument 'keepfigures' prevents these figures from
            %                     being closed (unless stated in the test code somewhere).
            %
            %   property value pairs:
            %           'resdir'     -  Specifies the output directory
            %           'filename'   -  Name of the output file
            %           'testname'   -  Name of the main test (only used if the casename property of
            %                           the mtestcase object is empty).
            %           'includeCode'-  Boolean overriding the mtest-property descriptionincludecode. 
            %                           This property determines whether the code parts of the
            %                           description are included in the published html file (see
            %                           publish documentation for more info).
            %           'evaluateCode'- Boolean overriding the mtest-property descriptionevaluatecode. 
            %                           This property determines whether the code parts of the
            %                           description are executed before publishing the code to html
            %                           (see publish documentation for more info).
            %           'maxwidth'  -   Maximum width of the published figures (in pixels). By 
            %                           default the maximum width is set to 600 pixels. 
            %           'maxheight' -   Maximum height of the published figures (in pixels). By 
            %                           default the maximum height is set to 600 pixels.
            %           'stylesheet'-   Style sheet that is used for publishing (see publish
            %                           documentation for more information).
            %
            %   See also mtest mtest.mtest mtest.publishDescription mtest.runTest mtestengine
 
            %% Check whether the test has been executed. If not... execute
            if ~obj.testperformed
                obj.run;
            end
            
            %% subtract result dir from input
            if isempty(obj.resdir)
                obj.resdir = cd;
            end
            id = find(strcmp(varargin,'resdir'));
            if ~isempty(id)
                obj.resdir = varargin{id+1};
                varargin(id:id+1) = [];
            end
            
            %% Get filename from input
            id = find(strcmp(varargin,'filename'));
            if ~isempty(id)
                obj.publishoutputfile = varargin{id+1};
                varargin(id:id+1) = [];
            end            
            
            %% Process other input arguments
            % includeCode
            if any(strcmpi(varargin,'includecode'))
                id = find(strcmpi(varargin,'includecode'));
                obj.descriptionincludecode = varargin{id+1};
            end
            
            % evaluateCode
            if any(strcmpi(varargin,'evaluatecode'))
                id = find(strcmpi(varargin,'evaluatecode'));
                obj.descriptionevaluatecode = varargin{id+1};
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
            
            %% createoutputname
            if isempty(obj.publishoutputfile)
                obj.publishoutputfile = ['UnnamedTest' '_results_case_' num2str(obj.casenumber) '.html'];
            end
            [pt fn] = fileparts(obj.publishoutputfile);
            if isempty(pt)
                pt = obj.resdir;
            end
            outputname = fullfile(pt,[fn '.html']);
       
            %% retrieve testname from input
            [dum outname]= fileparts(outputname); 
            if any(strcmpi(varargin,'testname'))
                id = find(strcmpi(varargin,'testname'));
                obj.testname = varargin{id+1};
            else
                if isempty(obj.testname)
                    obj.testname = outname;
                end
            end

            %% set publish options
            opt = struct(...
                'format','html',...
                'stylesheet',obj.stylesheet,...
                'outputDir',fileparts(outputname),...
                'maxHeight',obj.maxheight,...
                'maxWidth',obj.maxwidth,...
                'showCode',obj.publishincludecode,...
                'useNewFigure',false,... % Maybe add this to the input of properties?
                'evalCode',obj.publishevaluatecode);
            
            %% Check open figures
            openfigures = findobj('Type','figure');
      
            %% publish results to resdir
            if ~isempty(obj.casename)
                publstr = cat(1,{['%% Test results of testcase: "' obj.casename '"']},obj.publishcode);
            else
                publstr = cat(1,{['%% Test results of "' obj.testname '" (Case' num2str(obj.casenumber) ')']},obj.publishcode);
            end
            mtestcase.publishCodeString(outputname,...
                [],...
                obj.runworkspace,...
                publstr,...
                opt);
            
            %% Close all remaining open figures from the test
            newopenfigures = findobj('Type','figure');
            id = ~ismember(newopenfigures,openfigures);
            if any(id) && isempty(find(strcmpi(varargin,'keepfigures'), 1))
                close(newopenfigures(id));
            end
        end
        function fullPublish(obj,varargin)
            % This function assumes the testcase has been run fully
            MoreThanTwoInputArgs = nargin>2;
            if MoreThanTwoInputArgs
                SecondVararginMtesteventData = strcmp(class(varargin{2}),'mtesteventdata');
                RemoveTemoObj = varargin{2}.removetempobj;
                if SecondVararginMtesteventData && RemoveTemoObj
                    obj.tmpobjname = [];
                end
            end
            
            %% publish the description
            obj.publishDescription;
           
            %% publish the result
            obj.publishResults;
            
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
            obj.tmpobjname = [];
        end
    end
    methods % set and get methods
        function set.tmpobjname(obj,varargin)
            if isempty(varargin{1})
                % rmappdata
                if ~isempty(obj.tmpobjname)
                    rmappdata(0,obj.tmpobjname);
                end
                obj.tmpobjname = varargin{1};
            else
                % setappdata
                if ~isempty(obj.tmpobjname)
                    rmappdata(0,obj.tmpobjname);
                end
                setappdata(0,varargin{1},obj);
                obj.tmpobjname = varargin{1};
            end
        end
    end
    %% Hidden methods
    methods (Hidden = true)
        function verifyTempDir(obj)
            if isempty(obj.tempdir) || ~isdir(obj.tempdir)
                obj.tempdir = uigetdir(cd,'Select temp dir');
            end
        end
        function makeFakeFunction(obj,rundir)
            % prepares the fake function. This is a function that returns true in all circumstances.
            fname = fullfile(rundir,[obj.functionname '.m']);
            
            obj.tmpobjname = ['mtest_obj_testcase_' obj.functionname];
            
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
            
            obj.tmpobjname = ['mtest_obj_init_' obj.functionname];
            
            %% prepare content
            str = sprintf('%s\n',...
                obj.functionheader,...
                ['notify(getappdata(0,''' obj.tmpobjname '''),''CaseInitialized'',mtesteventdata(whos,''remove'',true));'],...
                [obj.functionoutputname ' = true;']);
            
            %% write function
            fid = fopen(fname,'w');
            fprintf(fid,'%s\n',str);
            fclose(fid);
        end
        function makeRunFunction(obj,rundir)
            % prepares the init function. This is a function that stores the input variables with
            % the help of setappdata.
            fname = fullfile(rundir,[obj.functionname '.m']);
            
            obj.tmpobjname = ['mtest_obj_testcase_' obj.functionname];
            
            %% prepare content
            str = sprintf('%s\n',...
                obj.functionheader,...
                'mtest_245y7e_tic = tic;',...
                ['notify(getappdata(0,''' obj.tmpobjname '''),''CaseInitialized'',mtesteventdata(whos,''remove'',false));'],...
                obj.description{~strncmp(obj.description,'%',1)},...
                'profile on',...
                obj.runcode{:},...
                'profile off',...
                ['notify(getappdata(0,''' obj.tmpobjname '''),''CaseRun'',mtesteventdata(whos,''time'',toc(mtest_245y7e_tic)));']);
            
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
            
            obj.tmpobjname = ['mtest_obj_testcase_' obj.functionname];
            
            %% prepare content
            str = sprintf('%s\n',...
                obj.functionheader,...
                'mtest_245y7e_tic = tic;',...
                ['notify(getappdata(0,''' obj.tmpobjname '''),''CaseInitialized'',mtesteventdata(whos,''remove'',false));'],...
                obj.description{~strncmp(obj.description,'%',1)},...
                'profile on',...
                obj.runcode{:},...
                'profile off',...
                ['notify(getappdata(0,''' obj.tmpobjname '''),''CaseRun'',mtesteventdata(whos,''time'',toc(mtest_245y7e_tic),''remove'',false));'],...
                ['notify(getappdata(0,''' obj.tmpobjname '''),''PublishCase'',mtesteventdata(whos,''time'',toc(mtest_245y7e_tic),''remove'',true));']);
            
            %% write function
            fid = fopen(fname,'w');
            fprintf(fid,'%s\n',str);
            fclose(fid);
        end
        function storeInitVars(obj,varargin)
            % get workspace
            data = varargin{2};
            ws = data.workspace;
            
            % remove temp appdata
            if varargin{2}.removetempobj
                obj.tmpobjname = [];
            end
            
            % store init workspace
            obj.initworkspace = ws;
            obj.initialized = true;
        end
        function storeRunVars(obj,varargin)
            %% get workspace
            data = varargin{2};
            ws = data.workspace;
            
            %% remove temp appdata
            if varargin{2}.removetempobj
                obj.tmpobjname = [];
            end
                
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
                obj.functioncalls(i) = mtestfunction(obj.profinfo,i);
            end
            
            %% notify
            notify(obj,'TestPerformed');
            mtestworkspace.obj.testperformed = true;
        end
    end
    %% Hidden static methods
    methods (Static = true, Hidden = true)
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
        function publishCodeString(outputname,tempdir,workspace,string2publish,publishoptions)
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
            PublishInOutputDir = false;
            if isempty(tempdir)
                tempdir = fileparts(outputname);
                PublishInOutputDir = true;
            end
            tempfilename = mtestcase.makeTempFile(tempdir,string2publish,outputname);
            [ newdir newname ] = fileparts(outputname);
            FileNamesIdentical = strcmp(tempfilename,fullfile(newdir,[newname '.m']));
            
            if PublishInOutputDir && ~FileNamesIdentical
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
            setappdata(0,'mtest_workspace',workspace);
            
            % Build a string that restores the variables and executes the tempfile.
            string2evaluate = [...
                'mtest_tempvar16543fgwcxvdaq_workspace = getappdata(0,''mtest_workspace'');', char(10),...
                'if ~isempty(mtest_tempvar16543fgwcxvdaq_workspace)', char(10),...
                '    for imtest_tempvar16543fgwcxvdaq_counter = 1:size(mtest_tempvar16543fgwcxvdaq_workspace,1)', char(10),...
                '        eval([mtest_tempvar16543fgwcxvdaq_workspace{imtest_tempvar16543fgwcxvdaq_counter} '' = mtest_tempvar16543fgwcxvdaq_workspace{imtest_tempvar16543fgwcxvdaq_counter,2};'']);', char(10),...
                '    end', char(10),...
                'end', char(10),...
                'clear mtest_tempvar16543fgwcxvdaq_workspace imtest_tempvar16543fgwcxvdaq_counter', char(10),...
                tempfileshortname, ';', char(10)];
            
            % Store the string in the appdata as well (does not take too much time)
            setappdata(0,'mtest_string2evaluate',string2evaluate);
            
            % Now specify the code to evaluate. The string constructed above should be evaluated in
            % an empty workspace. Therefore in the base workspace we only call evalinemptyworkspace,
            % with the string we just constructed as input.
            publishoptions.codeToEvaluate = 'evalinemptyworkspace(getappdata(0,''mtest_string2evaluate''));' ;

            %% publish file
            tempcd = cd;
            cd(tempdir)
            if datenum(version('-date')) >= datenum(2009,08,12) && datenum(version('-date')) < datenum(2010,01,01)
                intwarning('off');
            end
            publish(tempfilename,publishoptions);
            cd(tempcd);
           
            %% Remove tempdata in the UserData of the matlab root
            rmappdata(0,'mtest_workspace');
            
            %% delete the temp file
            delete(tempfilename);
            
            %% move output file
            [dr fname] = fileparts(tempfilename); %#ok<*ASGLU>
            if ~strcmp(fullfile(publishoptions.outputDir,[fname '.html']),outputname)
                movefile(fullfile(publishoptions.outputDir,[fname '.html']),outputname);
            end
        end
    end
end
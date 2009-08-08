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
    end
    properties (SetAccess = protected)
        description = {};                   % Code that was included in the testfile description cell
    end
    properties
        descriptionoutputfile = {};         % Name of the published output file of the description
        descriptionincludecode = false;     % Attribute IncludeCode for publishing the description cell
        descriptionevaluatecode = true;     % Attribute EvaluateCode for publishing the description cell
    end
    properties (SetAccess = protected)
        runcode = [];                       % Code that was included in the testfile RunTest cell
        publishcode = [];                   % Code that was included in the testfile TestResults cell
    end
    properties
        publishoutputfile = {};             % Name of the published output file of the TestResults cell
        publishincludecode = false;         % Attribute IncludeCode for publishing the TestResults cell
        publishevaluatecode = true;         % Attribute EvaluateCode for publishing the TestResults cell
    end
    properties %(SetAccess = protected)
        testresult = false;                 % Boolean indicating whether the test was run successfully
    end
    properties (Hidden = true)
        tempdir = tempdir;                  % Temporary directory for publishing output files.
        testworkspace = [];                 % Variable that can be used as workspace to pass variables
        testperformed = false;              % Variable to indicate whether the test was executed.
        descriptionrun = false;             % Variable to inficate whether the description code has been executed
    end
    
    %% events
    events
        TestPerformed
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
                propstoset = {'descriptionoutputfile','descriptionincludecode','descriptionevaluatecode','publishoutputfile','publishincludecode','publishevaluatecode'};
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
            
            %% subtract result dir from input
            resdir = cd;
            id = find(strcmp(varargin,'resdir'));
            if ~isempty(id)
                resdir = varargin{id+1};
                varargin(id:id+1) = [];
            end
            
            %% Get filename from input
            id = find(strcmp(varargin,'filename'));
            if ~isempty(id)
                [pt nm] = fileparts(varargin{id+1});
                obj.descriptionoutputfile = [nm '.html'];
                if ~isempty(pt)
                    resdir = pt;
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
            maxwidth = 600;
            if any(strcmpi(varargin,'maxwidth'))
                id = find(strcmpi(varargin,'maxwidth'));
                maxwidth = varargin{id+1};
            end
            
            % maxheight
            maxheight = 600;
            if any(strcmpi(varargin,'maxheight'))
                id = find(strcmpi(varargin,'maxheight'));
                maxheight = varargin{id+1};
            end
            
            % stylesheet
            stylesheet = '';
            if any(strcmpi(varargin,'stylesheet'))
                id = find(strcmpi(varargin,'stylesheet'));
                stylesheet = varargin{id+1};
            end
            
            %% createoutputname
            if isempty(obj.descriptionoutputfile)
                obj.descriptionoutputfile = ['UnnamedTest' '_description_case_' num2str(obj.casenumber) '.html'];
            end
            outputname = fullfile(resdir,obj.descriptionoutputfile);
            
            %% retrieve testname from input
            [dum outname]= fileparts(outputname); 
            if any(strcmpi(varargin,'testname'))
                id = find(strcmpi(varargin,'testname'));
                testname = varargin{id+1};
            else
                testname = outname;
            end
            
            %% set publish options
            opt = struct(...
                'format','html',...
                'stylesheet',stylesheet,...
                'outputDir',resdir,...
                'maxHeight',maxheight,...
                'maxWidth',maxwidth,...
                'showCode',obj.descriptionincludecode,...
                'useNewFigure',false,... % Maybe add this to the input of properties?
                'evalCode',obj.descriptionevaluatecode);
            
            %% Check open figures
            openfigures = findobj('Type','figure');
      
            %% publish results to resdir
            if ~isempty(obj.casename)
                descrstr = cat(1,{['%% Test description of testcase: "' obj.casename '"']},obj.description);
            else
                descrstr = cat(1,{['%% Test description of "' testname '" (Case' num2str(obj.casenumber) ')']},obj.description);
            end
            mtestcase.publishCodeString(outputname,...
                [],...
                obj.testworkspace,...
                descrstr,...
                opt);
            
            %% Close all remaining open figures from the test
            newopenfigures = findobj('Type','figure');
            id = ~ismember(newopenfigures,openfigures);
            if any(id) && isempty(find(strcmpi(varargin,'keepfigures'), 1))
                close(newopenfigures(id));
            end
            
        end
        function runTest(obj,varargin)
            %runTest  Runs the code included in the RunTest cell of the testcase
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

            %% store necessary objects in a mtestworspace variable
            mtestworkspace.obj = obj;
            mtestworkspace.str = cat(1,...
                obj.description(~strncmp(obj.description,'%',1)),... % Always run the description before running the test
                obj.runcode);
            
            %% check tempdir
            obj.verifyTempDir;
            
            %% create temp file with code that needs to be executed
            mtestworkspace.filename = mtestcase.makeTempFile(obj.tempdir,mtestworkspace.str);

            %% Check open figures
            mtestworkspace.openfigures = findobj('Type','figure');
            
            %% clear all variables except the mtestworkspace
            clear('obj','fid','i','ans');
            
            %% Run the test
            try
                %% run the mfile
                run(mtestworkspace.filename);
                drawnow update
                
                %% delete the temp file (we don't need it anymore)
                delete(mtestworkspace.filename);
                
                %% check the existance of the testresult variable
                if ~exist('testresult','var')
                    % arror is caught by the catch statement and tuned into
                    % a warning. The testresult is set to false.
                    warning('MTest:NoTestResult','This piece of code did not produce a test result');
                    testresult = nan; %#ok<PROP>
                end
                
                %% Store variables that were created during the test 
                % needed for the publish function...
                mtestworkspace.nms = whos;
                mtestworkspace.obj.testworkspace = cell(length(mtestworkspace.nms),2);
                for mtest_counter_i = 1:length(mtestworkspace.nms)
                    mtestworkspace.obj.testworkspace(mtest_counter_i,:) = {...
                        mtestworkspace.nms(mtest_counter_i).name,...
                        eval(mtestworkspace.nms(mtest_counter_i).name)};
                end   
                % remove the mtestwokspace variable from the testworkspace
                id = strcmp(mtestworkspace.obj.testworkspace(:,1),'mtestworkspace');
                mtestworkspace.obj.testworkspace(id,:)=[];
                
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
                testresult = false; %#ok<PROP>
                
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
            mtestworkspace.obj.testresult = testresult; %#ok<PROP>
            
            %% Set flag
            mtestworkspace.obj.testperformed = true;
            mtestworkspace.obj.descriptionrun = true;
            
            %% notify
            notify(mtestworkspace.obj,'TestPerformed');
            
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
                obj.runTest;
            end
            
            %% subtract result dir from input
            resdir = cd;
            id = find(strcmp(varargin,'resdir'));
            if ~isempty(id)
                resdir = varargin{id+1};
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
            maxwidth = 600;
            if any(strcmpi(varargin,'maxwidth'))
                id = find(strcmpi(varargin,'maxwidth'));
                maxwidth = varargin{id+1};
            end
            
            % maxheight
            maxheight = 600;
            if any(strcmpi(varargin,'maxheight'))
                id = find(strcmpi(varargin,'maxheight'));
                maxheight = varargin{id+1};
            end
            
            % stylesheet
            stylesheet = '';
            if any(strcmpi(varargin,'stylesheet'))
                id = find(strcmpi(varargin,'stylesheet'));
                stylesheet = varargin{id+1};
            end
            
            %% createoutputname
            if isempty(obj.publishoutputfile)
                obj.publishoutputfile = ['UnnamedTest' '_results_case_' num2str(obj.casenumber) '.html'];
            end
            outputname = fullfile(resdir,obj.publishoutputfile);
       
            %% retrieve testname from input
            [dum outname]= fileparts(outputname); 
            if any(strcmpi(varargin,'testname'))
                id = find(strcmpi(varargin,'testname'));
                testname = varargin{id+1};
            else
                testname = outname;
            end

            %% set publish options
            opt = struct(...
                'format','html',...
                'stylesheet',stylesheet,...
                'outputDir',resdir,...
                'maxHeight',maxheight,...
                'maxWidth',maxwidth,...
                'showCode',obj.publishincludecode,...
                'useNewFigure',false,... % Maybe add this to the input of properties?
                'evalCode',obj.publishevaluatecode);
            
            %% Check open figures
            openfigures = findobj('Type','figure');
      
            %% publish results to resdir
            if ~isempty(obj.casename)
                publstr = cat(1,{['%% Test results of testcase: "' obj.casename '"']},obj.publishcode);
            else
                publstr = cat(1,{['%% Test results of "' testname '" (Case' num2str(obj.casenumber) ')']},obj.publishcode);
            end
            mtestcase.publishCodeString(outputname,...
                [],...
                obj.testworkspace,...
                publstr,...
                opt);
            
            %% Close all remaining open figures from the test
            newopenfigures = findobj('Type','figure');
            id = ~ismember(newopenfigures,openfigures);
            if any(id) && isempty(find(strcmpi(varargin,'keepfigures'), 1))
                close(newopenfigures(id));
            end
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
            resdir = cd;
            if any(strcmpi(varargin,'resdir'))
                resdir = varargin{find(strcmpi(varargin,'resdir'))+1};
            end
            
            outputfile = '';
            if any(strcmpi(varargin,'outputfile'))
                [pth nm] = fileparts(varargin{find(strcmpi(varargin,'outputfile'))+1});
                outputfile = fullfile(pth,nm);
            end
            
            testname = 'Unnamed_test';
            if any(strcmpi(varargin,'testname'))
                testname = varargin{find(strcmpi(varargin,'testname'))+1};
            end
            
            if isempty(outputfile)
                outputfile = testname;
            end
                        
            % Maxwidth
            maxwidth = 600;
            if any(strcmpi(varargin,'maxwidth'))
                id = find(strcmpi(varargin,'maxwidth'));
                maxwidth = varargin{id+1};
            end
            
            % maxheight
            maxheight = 600;
            if any(strcmpi(varargin,'maxheight'))
                id = find(strcmpi(varargin,'maxheight'));
                maxheight = varargin{id+1};
            end
            
            % stylesheet
            stylesheet = '';
            if any(strcmpi(varargin,'stylesheet'))
                id = find(strcmpi(varargin,'stylesheet'));
                stylesheet = varargin{id+1};
            end
            
            %% publih description
            obj.publishDescription(...
                'resdir',resdir,...
                'stylesheet',stylesheet,...
                'maxheight',maxheight,...
                'maxwidth',maxwidth,...
                'testname',testname,...
                'filename',[outputfile '_description_case_' num2str(obj.casenumber) '.html']);

            %% run test
            obj.runTest;

            %% and publish result
            obj.publishResults(...
                'resdir',resdir,...
                'stylesheet',stylesheet,...
                'maxheight',maxheight,...
                'maxwidth',maxwidth,...
                'testname',testname,...
                'filename',[outputfile '_results_case_' num2str(obj.casenumber) '.html']);

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

            obj.testworkspace = [];
            obj.testperformed = false;
        end
    end
    %% Hidden methods
    methods (Hidden = true)
        function verifyTempDir(obj)
            if isempty(obj.tempdir) || ~isdir(obj.tempdir)
                obj.tempdir = uigetdir(cd,'Select temp dir');
            end
        end
    end
    %% Hidden static methods
    methods (Static = true, Hidden = true)
        function fname = makeTempFile(tempdir,str)
            [dum fn] = fileparts(tempname);
            fname = fullfile(tempdir,[fn '.m']);
            fid = fopen(fname,'w');
            for i=1:size(str,1)
                fprintf(fid,'%s\n',str{i});
            end
            fclose(fid);
        end
        function publishCodeString(mtest_outputname,mtest_tempdir,mtest_workspace,mtest_string2publish,mtest_publishoptions)
            %PUBLISHCODESTRING  publishes a string (mtest_string2publish) to a html page
            %
            %   his function publishes a string to a html page. it uses the UserData of the matlab 
            %   root to store any variables that are used as input.
            %
            %   Syntax:
            %   publishCodeString(...
            %       mtest_outputname,...
            %       mtest_tempdir,...
            %       mtest_workspace,...
            %       mtest_string2publish,...
            %       mtest_publishoptions)
            %
            %   Input:
            %   mtest_outputname    -   Name of the html output file. If this is 
            %   mtest_tempdir       -   Name of the temp dir where the file can be created. If this
            %                           variable is left empty the file is published in the output
            %                           directory (filepath of mtest_outputname).
            %   mtest_workspace     -   Variables that should be in the workspace to be able to
            %                           publish the code string. This variable should be an Nx2 cell
            %                           array. The first column should contain a string with the
            %                           name of the variable. The second column stores the content
            %                           of that variable.
            %   mtest_string2publish-   String that has to be published
            %   mtest_publishoptions-   A struct with publish options as described in the help
            %                           documentation of the matlab function "publish".
            %
            %   See also mtest publish mtest.mtest mtest.runTest
             
            %% create temp file with code that needs to be executed
            mtest_PublishInOutputDir = false;
            if isempty(mtest_tempdir)
                mtest_tempdir = fileparts(mtest_outputname);
                mtest_PublishInOutputDir = true;
            end
            mtest_tempfilename = mtestcase.makeTempFile(mtest_tempdir,mtest_string2publish);
                        
            if mtest_PublishInOutputDir
                % move the tempfile to the correct name (to have sensible names for the figures) and
                % the correct directory
                [ mtest_newdir mtest_newname ] = fileparts(mtest_outputname);
                movefile(mtest_tempfilename,fullfile(mtest_newdir,[mtest_newname '.m']));
                % renew filename
                mtest_tempfilename = fullfile(mtest_newdir,[mtest_newname '.m']);
            end
            % split output dir and filename
            [mtest_tempdir mtest_tempfileshortname] = fileparts(mtest_tempfilename);
            
            %% fill workspace
            % store mtest_workspace in UserData of the matlab root. The publish function is preceded
            % by code to retrieve the variables from the root UserData.
            mtest_tempvars = get(0,'UserData');
            set(0,'UserData',mtest_workspace);
            
            % First restore the variables, then execute the tempfile.
            mtest_publishoptions.codeToEvaluate  = [...
                'mtest_workspace = get(0,''UserData'');', char(10),...
                'if ~isempty(mtest_workspace)', char(10),...
                '    for mtest_counter_i = 1:size(mtest_workspace,1)', char(10),...
                '        eval([mtest_workspace{mtest_counter_i} '' = mtest_workspace{mtest_counter_i,2};'']);', char(10),...
                '    end', char(10),...
                'end', char(10)...
                mtest_tempfileshortname, ';', char(10)];

            %% publish file
            mtest_tempcd = cd;
            cd(mtest_tempdir)
            publishincaller(mtest_tempfilename,mtest_publishoptions);
%             publish(mtest_tempfilename,mtest_publishoptions);
            cd(mtest_tempcd);
           
            %% Remove tempdata in the UserData of the matlab root
            set(0,'UserData',mtest_tempvars);
            
            %% delete the temp file
            delete(mtest_tempfilename);
            
            %% move output file
            [dr fname] = fileparts(mtest_tempfilename);
            if ~strcmp(fullfile(mtest_publishoptions.outputDir,[fname '.html']),mtest_outputname)
                movefile(fullfile(mtest_publishoptions.outputDir,[fname '.html']),mtest_outputname);
            end
        end
        
    end
end
classdef mtest < handle
    % MTEST - Object to handle tests written in WaveLab format
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
    % above.
    %
    % Description is seen purely as documentation of the test (in other words: what do we test, how
    % do we test it and what outcome do we expect).
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
    % See also mtest.mtest mtest.publishDescription mtest.runTest mtest.publishResults mtestengine
    
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
        testname = [];                      % Name of the test
        filename = [];                      % Original name of the testfile
        filepath = [];                      % Path of the "_test.m" file
        author   = [];                      % Last author of the test (obtained from svn keywords)
        shortdescription = [];              % A one line description of the test (h1 line)
        time     = 0;                      % Time that was needed to perform the test
        date     = NaN;                      % Date and time the test was performed
        
        testdescription = {};               % Description of the test (first part of the testdescription file before the start of the first testcase)
        includecode = false;                % indicates whether the code must be included when publishing the test description
        evaluatecode = true;
        descriptionoutputfile = {};         % Name of the published output file of the description
        
        currentcase = [];                   % Number of the testcase that is last adressed

        testcases = mtestcase;              % mtestcases objects that contain testcase information for each individual testcase
    end
    properties (SetAccess = protected)
        testresult = false;                 % Boolean indicating whether the test was run successfully
    end
    properties (Hidden = true)
        fullstring = [];                    % Full string of the contents of the test file
        tempdir = tempdir;                  % Temporary directory for publishing output files.
        eventlisteners = [];                % Listeren to event runTest of testcases
    end
    
    %% Methods
    methods
        function obj = mtest(varargin)
            %mtest  Creates an mtest object from a WaveLab test definition file.
            %
            %   This function reads the contents of a WaveLab test definition file and creates an
            %   mtest object that stores all the necessary test information and results. This object
            %   can later be used to publish the description (mtest.publishDescription), run the
            %   test (mtest.runTest) or publish the testresults (mtest.publishResults).
            %
            %   Syntax:
            %   obj = mtest(filename,...);
            %   obj = mtest(...,'filename',filename);
            %   obj = mtest(...,'property','value');
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
            %
            %   See also mtest mtest.runTest mtest.publishDescription mtest.publishResults mtestengine mtestcase
            
            %% Check whether there is any input
            if nargin == 0
                return
            end
            %% Retrieve filename from input
            fname = [];
            if ischar(varargin{1}) && ~strcmpi(varargin{1},'filename')
                fname = varargin{1};
                varargin(1)=[];
            else
                id = find(strcmpi(varargin,'filename'),1,'first');
                if ~isempty(id)
                    fname = varargin{id+1};
                    varargin(id:id+1) = [];
                end
            end
            %% Set other properties that are defined in the input
            if ~isempty(varargin)
                propstoset = {'descriptionoutputfile','publishoutputfile','testname'};
                propsid = 1:2:length(varargin);
                memid = ismember(varargin(propsid),propstoset);
                for im = 1:length(memid)
                    prop = varargin{propsid(im)};
                    if ~memid(im)
                        warning('MTest:NoProperty',['The property "' prop '" could not be found or set.']);
                    else
                        obj.(prop) = varargin{propsid(im)+1};
                    end
                end
            end
            %% split filename into parts
            [pt fn ext] = fileparts(fname);
            if isempty(ext)
                ext = '.m';
            end
            if ~strcmp(ext,'.m')
                error('MTest:NoMatlabFile','Input must be a matlab (*.m) file');
            end
            %% #1 Open the input file
            % first try full file name
            if exist(fullfile(pt,[fn ext]),'file')
                fid = fopen(fullfile(pt,[fn ext]));
                if isempty(pt)
                    pt = fileparts(which([fn ext]));
                end
            else
                % if fullname does not exist, try which
                fls = which(fn,'-all');
                if length(fls)>1
                    warning('MTest:MultipleFiles','Multiple files were found with the same name. The first one in the search path is taken.');
                    fid = fopen(fls{1});
                elseif length(fls) == 1
                    fid = fopen(fls{1});
                else
                    % which didn't work either. File can not be
                    % found
                    error('MTest:NoFile','Input file could not be found.');
                end
                [pt fn] = fileparts(fls{1});
            end
            
            %% #2 Read the contents of the file
            str = fread(fid,'*char')';
            str = strread(str,'%s','delimiter',char(10));
            %% #3 Close the input file
            fclose(fid);
            %% #4 Process contents of the input file
            obj.filename = fn;
            obj.filepath = pt;
            obj.fullstring = str;
            
            % First find the celldividers between the description parts, the runtTest parts and the Publish part
            descrid = find(strncmp(str,'%% #',4) & ~cellfun(@isempty,strfind(str,'Description')));
            runcodeid = find(strncmp(str,'%% #',4) & ~cellfun(@isempty,strfind(str,'RunTest')));
            publishcodeid = find(strncmp(str,'%% #',4) & ~cellfun(@isempty,strfind(str,'TestResults')));
            
            % Create temp testcase struct
            testcasesstruct = struct(...
                'caseNumber',[],...
                'caseName',[],...
                'description',[],...
                'descrIncludeCode',[],...
                'descrEvaluateCode',[],...
                'runcode',[],...
                'publishcode',[],...
                'publishIncludeCode',[],...
                'publishEvaluateCode',[]);
            
            % Error if there is no RunTest part (test code)
            if isempty(runcodeid)
                error('MTest:NoTestDefinition',['The specified file (' fullfile(obj.filepath,[obj.filename '.m']) ') does not contain a test definition cell']);
            end
            
            % list all celldividers that separate important parts
            celldividers = sort(cat(1,descrid,runcodeid,publishcodeid,length(obj.fullstring)+1));
            
            % Read test specifications (description, last author h1 line etc)
            if min(celldividers)>1
                obj.shortdescription = strtrim(strrep(lower(str{1}(find(~ismember(1:length(str{1}),strfind(str{1},'%')),1,'first'):end)),lower(fn),''));
                id = find(~cellfun(@isempty,strfind(str,'TestName:')),1,'first');
                obj.testname = strtrim(strrep(str{id},'% TestName:',''));
                testdescr = str(2:min(celldividers)-1);
                testdescr(id-1)=[];
                id = find(~strcmp(strtrim(testdescr),'%'),1,'first');
                testdescr = testdescr(id:end);
                
                tmpstr = testdescr{~cellfun(@isempty,strfind(testdescr,'$Author:'))};
                obj.author = strtrim(tmpstr(min(strfind(tmpstr,':'))+1:min([length(tmpstr)+1 max(strfind(tmpstr,'$'))])-1));
                
                id =  min([...
                    find(~cellfun(@isempty,strfind(testdescr,'%% %% Copyright')),1,'first'),...
                    find(~cellfun(@isempty,strfind(testdescr,'%% Version')),1,'first'),...
                    find(~cellfun(@isempty,strfind(testdescr,'%% Credentials')),1,'first')]);
                if ~isempty(id)
                    testdescr(id:end)=[];
                end
                testdescr = testdescr(1:find(~cellfun(@isempty,testdescr),1,'last'));
                if ~isempty(strfind(testdescr{end},'See also '))
                    testdescr(end)=[];
                end
                
                obj.testdescription = testdescr;
            else
                obj.testname = obj.filename;
                obj.testdescription = '% This test still has no general description. This can be placed on the first lines of the test description file (*_test.m).';
            end
            
            % Isolate descriptions
            for i=1:length(descrid)
                begid = descrid(i);
                endid = celldividers(find(celldividers==begid,1,'first')+1);
                % header
                descrheader = obj.fullstring{begid};
                % body
                descrstr = obj.fullstring(begid+1:endid-1);
                % subtract casenr
                id1 = strfind(descrheader,'#Case')+5;
                id2 = min(strfind(descrheader(id1:end),' ')) + id1 -1;
                casenr = str2double(descrheader(id1 : id2));
                
                % store body information
                id = [testcasesstruct.caseNumber]==casenr;
                if sum(id)==0
                    id = length(id)+1;
                    testcasesstruct(id).caseNumber = casenr;
                end
                testcasesstruct(id).description = descrstr;
                testcasesstruct(id).descrIncludeCode = false;
                testcasesstruct(id).descrEvaluateCode = true;
                
                % isolate attributes
                id1 = strfind(descrheader,'(')+1;
                id2 = strfind(descrheader,')')-1;
                if ~isempty(id1) && ~isempty(id2)
                    attr = strread(descrheader(id1:id2),'%s','delimiter','&');
                    for iatt = 1:length(attr)
                        a = strread(attr{iatt},'%s','delimiter','=');
                        att = strtrim(strrep(a{1},'''',''));
                        try
                            val = eval(strrep(a{2},'''',''));
                        catch err %#ok<NASGU>
                            % No boolean, this is a string probably
                            val = a{2};
                        end
                        switch att
                            case 'CaseName'
                                testcasesstruct(id).caseName = val;
                            case 'IncludeCode'
                                testcasesstruct(id).descrIncludeCode = val;
                            case 'EvaluateCode'
                                testcasesstruct(id).descrEvaluateCode = val;
                        end
                    end
                end
            end
            
            % Isolate Run Codes
            for i=1:length(runcodeid)
                begid = runcodeid(i);
                endid = celldividers(find(celldividers==begid,1,'first')+1);
                % header
                runheader = obj.fullstring{begid};
                % body
                runstr = obj.fullstring(begid+1:endid-1);
                % subtract casenr
                id1 = strfind(runheader,'#Case')+5;
                id2 = min(strfind(runheader(id1:end),' ')) + id1 -1;
                casenr = str2double(runheader(id1 : id2));
                
                id = [testcasesstruct.caseNumber]==casenr;
                if sum(id)==0
                    id = length(id)+1;
                    testcasesstruct(id).caseNumber = casenr;
                end
                
                % store body
                testcasesstruct(id).runcode = runstr;
            end
            
            % Isolate publish codes
            for i=1:length(publishcodeid)
                begid = publishcodeid(i);
                endid = celldividers(find(celldividers==begid,1,'first')+1);
                % header
                publishheader = obj.fullstring{begid};
                % body
                publishstr = obj.fullstring(begid+1:endid-1);
                % subtract casenr
                id1 = strfind(publishheader,'#Case')+5;
                id2 = min(strfind(publishheader(id1:end),' ')) + id1 -1;
                casenr = str2double(publishheader(id1 : id2));
                
                id = [testcasesstruct.caseNumber]==casenr;
                if sum(id)==0
                    id = length(id)+1;
                    testcasesstruct(id).caseNumber = casenr;
                end
                
                % store body
                testcasesstruct(id).publishcode = publishstr;
                testcasesstruct(id).publishIncludeCode = false;
                testcasesstruct(id).publishEvaluateCode = true;
                
                % isolate attributes
                id1 = strfind(publishheader,'(')+1;
                id2 = strfind(publishheader,')')-1;
                if ~isempty(id1) && ~isempty(id2)
                    attr = strread(publishheader(id1:id2),'%s','delimiter','&');
                    for iatt = 1:length(attr)
                        a = strread(attr{iatt},'%s','delimiter','=');
                        att = strtrim(strrep(a{1},'''',''));
                        val = eval(strrep(a{2},'''',''));
                        switch att
                            case 'IncludeCode'
                                testcasesstruct(id).publishIncludeCode = val;
                            case 'EvaluateCode'
                                testcasesstruct(id).publishEvaluateCode = val;
                        end
                    end
                end
            end
            %% create mtestcase objects
            for itestcases = 1:length(testcasesstruct)
                % create outputfilenames
                obj.currentcase = itestcases;
                if isempty(testcasesstruct(itestcases).publishcode)
                    testcasesstruct(itestcases).publishEvaluateCode = true;
                    testcasesstruct(itestcases).publishIncludeCode = false;
                end
                if isempty(testcasesstruct(itestcases).description)
                    testcasesstruct(itestcases).descrIncludeCode = false;
                    testcasesstruct(itestcases).descrEvaluateCode = true;
                end
                
                descroutputfilen = [obj.filename '_description_case_' num2str(testcasesstruct(itestcases).caseNumber) '.html'];
                publishoutputfilen = [obj.filename '_results_case_' num2str(testcasesstruct(itestcases).caseNumber) '.html'];
                
                % create the object
                obj.testcases(itestcases) = mtestcase(...
                    testcasesstruct(itestcases).caseNumber,...
                    'casename',testcasesstruct(itestcases).caseName,...
                    'description',testcasesstruct(itestcases).description,...
                    'descriptionoutputfile',descroutputfilen,...
                    'descriptionincludecode',testcasesstruct(itestcases).descrIncludeCode,...
                    'descriptionevaluatecode',testcasesstruct(itestcases).descrEvaluateCode,...
                    'runcode',testcasesstruct(itestcases).runcode,...
                    'publishcode',testcasesstruct(itestcases).publishcode,...
                    'publishoutputfile',publishoutputfilen,...
                    'publishincludecode',testcasesstruct(itestcases).publishIncludeCode,...
                    'publishevaluatecode',testcasesstruct(itestcases).publishEvaluateCode);
                
            end
            % add listener
            obj.eventlisteners = event.listener(obj.testcases,'TestPerformed',@obj.refreshTestResult);
            
        end
        function publishDescription(obj,varargin)
            %publishDescripton  Creates html files of the description codes of the specified testcases with publish
            %
            %   This function publishes the code included in the Description cell of the test file
            %   with the help of the publish function for the specified testcases
            %
            %   Syntax:
            %   publishDescripton(obj,'property','value')
            %   publishDescripton(...,'keepfigures')
            %   obj.publisDescription('property','value')
            %
            %   Input:
            %   obj             - An instance of an mtest object.
            %   'keepfigures'   - The publishResults function automatically closes any figures that
            %                     were created during publishing and were not already there.
            %                     The optional argument 'keepfigures' prevents these figures from
            %                     being closed (unless stated in the test code somewhere).
            %
            %   property value pairs:
            %           'casenumber'-   An 1xN doouble specifying the test case numbers for which the
            %                           descriptions must be published. By default this routine
            %                           prints the description of all testcases.
            %           'resdir'    -   Specifies the output directory (default is the current
            %                           directory)
            %           'filename'  -   Main part that is used for naming the output files.
            %           'includeCode'-  Boolean overriding the mtestcase - property
            %                           "descriptionincludecode". This property determines whether the
            %                           code parts of the description are included in the published
            %                           html file (see publish documentation for more info).
            %           'evaluateCode'- Boolean overriding the mtestcase - property
            %                           "descriptionevaluatecode". This property determines whether
            %                           the code parts of the description are executed before
            %                           publishing the code to html (see publish documentation for
            %                           more information).
            %           'maxwidth'  -   Maximum width of the published figures (in pixels)
            %                           overriding the value of the mtestcase object.
            %           'maxheight' -   Maximum height of the published figures (in pixels)
            %                           overriding the value of the mtestcase object.
            %           'stylesheet'-   Style sheet that is used for publishing (see publish
            %                           documentation for more information).
            %
            %   See also mtest mtest.mtest mtest.publishResults mtest.runTest mtestengine
            
            %% subtract result dir from input
            resdir = cd;
            id = find(strcmp(varargin,'resdir'));
            if ~isempty(id)
                resdir = varargin{id+1};
            end
            
            %% subtract casenumbers from input
            casenumbers = 1:length(obj.testcases);
            id = find(strcmp(varargin,'casenumber'));
            if ~isempty(id)
                casenumbers = varargin{id+1};
            end
            
            %% Get filename from input
            % store the filename temporarily in the variable filenm. _case_nr is added lateron for
            % each case that is published.
            id = find(strcmp(varargin,'filename'));
            if ~isempty(id)
                [pt filenm] = fileparts(varargin{id+1});
                if ~isempty(pt)
                    resdir = pt;
                end
            else
                filenm = [obj.filename '_description'];
            end
            % Store the final result dir
            inargs = {'resdir',resdir};
            
            %% Process other input arguments
            % includeCode
            if any(strcmpi(varargin,'includecode'))
                id = find(strcmpi(varargin,'includecode'));
                inargs = cat(2,inargs,{'includeCode',varargin{id+1}});
            end
            
            % evaluateCode
            if any(strcmpi(varargin,'evaluatecode'))
                id = find(strcmpi(varargin,'evaluatecode'));
                inargs = cat(2,inargs,{'evaluateCode',varargin{id+1}});
            end
            
            % Maxwidth
            if any(strcmpi(varargin,'maxwidth'))
                id = find(strcmpi(varargin,'maxwidth'));
                inargs = cat(2,inargs,{'maxwidth',varargin{id+1}});
            end
            
            % maxheight
            if any(strcmpi(varargin,'maxheight'))
                id = find(strcmpi(varargin,'maxheight'));
                inargs = cat(2,inargs,{'maxheight',varargin{id+1}});
            end
            
            % stylesheet
            if any(strcmpi(varargin,'stylesheet'))
                id = find(strcmpi(varargin,'stylesheet'));
                inargs = cat(2,inargs,{'stylesheet',varargin{id+1}});
            end
            
            % keepfigures
            if any(strcmpi(varargin,'keepfigures'))
                inargs = cat(2,inargs,'keepfigures');
            end
            
            %% loop case numbers
            for icase = 1:length(casenumbers)
                obj.currentcase = casenumbers(icase);
                
                inargsfinal = inargs;
                filen = [filenm '_case_' num2str(obj.testcases(obj.currentcase).casenumber) '.html'];
                if ~isempty(obj.testname)
                    inargsfinal = cat(2,inargsfinal,{'testname',obj.testname});
                end
                inargsfinal = cat(2,{'filename',filen},inargsfinal);
                
                obj.testcases(obj.currentcase).publishDescription(inargsfinal{:});
            end
            
        end
        function runTest(obj,casenumbers,varargin)
            %runTest  Runs all testcases
            %
            %   This function runs the code specified in the RunTest cell of the test definition
            %   file for each testcase. Previous to running the test code, any results of the code
            %   specifying the description of the test are created in the workspace where the test
            %   is performed (this is all code that is not preceeded by a "%" sign).
            %
            %   Syntax:
            %   runTest(obj);
            %   runTest(obj,casenumbers);
            %   runTest(obj,casenumbers,'keepfigures');
            %   obj.runTest(casenumbers);
            %
            %   Input:
            %   obj             - An instance of an mtest object.
            %   casenumbers     - A 1xN doouble specifying the test case numbers for which the
            %                     tests must be performed. By default this routine
            %                     runs all testcases. The testresult property of the mtest object is
            %                     automatically refreshed after running a testcase.
            %   'keepfigures'   - The publishResults function automatically closes any figures that
            %                     were created during publishing and were not already there.
            %                     The optional argument 'keepfigures' prevents these figures from
            %                     being closed (unless stated in the test code somewhere).
            %
            %   See also mtest mtest.mtest mtestcase.runTest mtestcase mtestengine
            
            %% Set casenumber
            if nargin<2
                casenumbers = 1:length(obj.testcases);
            end
            
            % keepfigures
            kpfig = false;
            if any(strcmpi(varargin,'keepfigures'))
                kpfig = true;
            end
            
            %% Make shure the directory of the test is in the searchpath
            pt = path;
            addpath(obj.filepath);
            
            %% perform tests
            for icase = 1:length(casenumbers)
                obj.currentcase = casenumbers(icase);
                
                if kpfig
                    obj.testcases(obj.currentcase).runTest('keepfigures');
                else
                    obj.testcases(obj.currentcase).runTest;
                end
                
            end
            
            %% Return the initial searchpath
            path(pt);
        end
        function publishResults(obj,varargin)
            %publishResults  Creates a html files of the TestResults of the specified testcases
            %
            %   This function publishes the code included in the TestResult cells of the test file
            %   with the help of the publish function. All variables created by running the test are
            %   stored in a hidden property of the mtestcase objects and can therefore be used while
            %   publishing the results. By default this routines publishes the results of all
            %   testcases.
            %
            %   Syntax:
            %   publishResults(obj,'property','value')
            %   obj.publisResults(...)
            %
            %   Input:
            %   obj  = An instance of an mtest object.
            %
            %   property value pairs:
            %           'casenumber'-   An 1xN doouble specifying the test case numbers for which the
            %                           testresults must be published. By default this routine
            %                           prints the test results of all testcases.
            %           'resdir'    -   Specifies the output directory (default is the current
            %                           directory)
            %           'filename'  -   Main part that is used for naming the output files.
            %           'includeCode'-  Boolean overriding the mtestcase - property
            %                           "publishincludecode". This property determines whether the
            %                           code parts of the test results cell are included in the
            %                           published html file (see publish documentation for more info).
            %           'evaluateCode'- Boolean overriding the mtestcase - property
            %                           "publishevaluatecode". This property determines whether
            %                           the code parts of the test results cell are executed before
            %                           publishing the code to html (see publish documentation for
            %                           more information).
            %           'maxwidth'  -   Maximum width of the published figures (in pixels)
            %                           overriding the value of the mtestcase object.
            %           'maxheight' -   Maximum height of the published figures (in pixels)
            %                           overriding the value of the mtestcase object.
            %           'stylesheet'-   Style sheet that is used for publishing (see publish
            %                           documentation for more information).
            %
            %   See also mtest mtest.mtest mtest.publishDescription mtest.runTest mtestengine
            
            %% subtract result dir from input
            resdir = cd;
            id = find(strcmp(varargin,'resdir'));
            if ~isempty(id)
                resdir = varargin{id+1};
            end
            inargs = {'resdir',resdir};
            
            %% subtract casenumbers from input
            casenumbers = 1:length(obj.testcases);
            id = find(strcmp(varargin,'casenumber'));
            if ~isempty(id)
                casenumbers = varargin{id+1};
            end
            
            %% Get filename from input
            id = find(strcmp(varargin,'filename'));
            if ~isempty(id)
                filenm = varargin{id+1};
            else
                filenm = [obj.filename '_results'];
            end
            
            %% Process other input arguments
            % includeCode
            if any(strcmpi(varargin,'includecode'))
                id = find(strcmpi(varargin,'includecode'));
                inargs = cat(2,inargs,{'includeCode',varargin{id+1}});
            end
            
            % evaluateCode
            if any(strcmpi(varargin,'evaluatecode'))
                id = find(strcmpi(varargin,'evaluatecode'));
                inargs = cat(2,inargs,{'evaluateCode',varargin{id+1}});
            end
            
            % Maxwidth
            if any(strcmpi(varargin,'maxwidth'))
                id = find(strcmpi(varargin,'maxwidth'));
                inargs = cat(2,inargs,{'maxwidth',varargin{id+1}});
            end
            
            % maxheight
            if any(strcmpi(varargin,'maxheight'))
                id = find(strcmpi(varargin,'maxheight'));
                inargs = cat(2,inargs,{'maxheight',varargin{id+1}});
            end
            
            % stylesheet
            if any(strcmpi(varargin,'stylesheet'))
                id = find(strcmpi(varargin,'stylesheet'));
                inargs = cat(2,inargs,{'stylesheet',varargin{id+1}});
            end
            
            % keepfigures
            if any(strcmpi(varargin,'keepfigures'))
                inargs = cat(2,inargs,'keepfigures');
            end
            
            %% loop case numbers
            for icase = 1:length(casenumbers)
                obj.currentcase = casenumbers(icase);
                
                %% Check whether the test has been executed. If not... execute
                if ~obj.testcases(obj.currentcase).testperformed
                    obj.testcases(obj.currentcase).runTest;
                end
                
                %% create publish output file
                inargsfinal = inargs;
                 filen = [filenm '_case_' num2str(obj.testcases(obj.currentcase).casenumber) '.html'];
                if ~isempty(obj.testname)
                    inargsfinal = cat(2,inargsfinal,{'testname',obj.testname});
                end
                inargsfinal = cat(2,{'filename',filen},inargsfinal);
                
                obj.testcases(obj.currentcase).publishResults(inargsfinal{:});
            end
            
        end
        function cleanUp(obj)
            %cleanUp  Cleans up the mtestcase objects of the mtest object
            %
            %   Some information is stored in hidden properties of an mtestcase object. For example
            %   the test testworkspace (workspace that is created during the test, including all
            %   variables) can take a lot of space. This function cleans these variables.
            %   Consequently after cleaning the mtestcase object, test results can not be published
            %   anymore without rerunning the test. Rerunning a test is done automatically when a
            %   call to publishResults is made without the object having test results. The property
            %   testresult stayes intact so that the test result is still there. Typically this
            %   function is run after publishing the results to remember the property testresult,
            %   but clear memory for other tests or testcases.
            %
            %   Syntax:
            %   cleanUp(obj);
            %   obj.cleanUp;
            %
            %   Input:
            %   obj  = An instance of an mtest object.
            %
            %   See also mtest mtest.mtest mtestcase mtestengine
            
            %% cleanup the mtestcase objects
            for itestcase = 1:length(obj.testcases);
                obj.currentcase = itestcase;
                obj.testcases(itestcase).cleanUp;
            end
            
        end
        function runAndPublish(obj,varargin)
            %runAndPublish  Runs the testcases and publishes the descriptions and results.
            %
            %   This function runs the specified testcase objects and publishes the case
            %   description and test results.
            %
            %   Syntax:
            %   runAndPublish(obj,'property','value');
            %   obj.publisResults(...'property','value');
            %
            %   Input:
            %   obj  = An instance of an mtestcase object.
            %
            %   property value pairs:
            %           'casenumber'-   An 1xN doouble specifying the numbers of the test cases that
            %                           must be included. By default this routine takes all testcases.
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
            
            %% Get casenumbers
            %(rest of the input arguments is directly passed to the runAndPublish function of the
            %mtestcase objects.
            casenumbers = 1:length(obj.testcases);
            id = find(strcmp(varargin,'casenumber'));
            if ~isempty(id)
                casenumbers = varargin{id+1};
                varargin(id:id+1)=[];
            end
            
            %% subtract outputfilename
            id = find(strcmp(varargin,'outputfile'));
            outputfile = [];
            if ~isempty(id)
                outputfile = varargin{id+1};
                varargin(id:id+1)=[];
            end
            
            %% include testname
            if isempty(obj.testname)
                obj.testname = obj.filename;
            end
            id = find(strcmp(varargin,'testname'));
            if ~isempty(id)
                obj.testname = varargin{id+1};
                varargin(id:id+1)=[];
            end
            if isempty(outputfile)
                outputfile = obj.filename;
            end
            
            %% Loop the testcases
            for icase = 1:length(casenumbers)
                obj.currentcase = casenumbers(icase);
                
                % runAndPublish
                inputargs = cat(2,{'testname',obj.testname,'outputfile',[outputfile '_case_' num2str(obj.currentcase)]},varargin{:});
                obj.testcases(obj.currentcase).runAndPublish(inputargs{:});
                
                % Clean test
                obj.testcases(obj.currentcase).cleanUp;
                
            end
        end
        function refreshTestResult(obj,varargin)
            %refreshTestResult  refreshes the testresult property
            %
            %   This function checks the testresults of all testcases. If all testresults are
            %   positive the mtest property testresult is set to true.
            %
            %   Syntax:
            %   refreshTestResult(obj);
            %   obj.refreshTestResult;
            %
            %   Input:
            %   obj  = An instance of an mtest object.
            %
            %   See also mtest mtest.mtest mtestcase mtestengine
            
            %% Check testcases
            results = [obj.testcases(:).testresult];
            if all(isnan(results))
                obj.testresult = nan;
            elseif all(results(~isnan(results)))
                % Don't count NaN values. We don't know the testresult...
                obj.testresult = true;
            else
                obj.testresult = false;
            end
            
            %% count total time
            totaltime = [obj.testcases(:).time];
            if ~isempty(totaltime)
                obj.time = sum(totaltime);
            end
            
            %% assign date to testresult
            obj.date = now;
            
        end
        function publishTestDescription(obj,varargin)
            %publishTestDescription  Creates an html file from the test description with publish
            %
            %   This function publishes the code included in the first part of a test description
            %   file. 
            %
            %   Syntax:
            %   publishDescripton(obj,'property','value')
            %   publishDescripton(...,'keepfigures');
            %   obj.publisDescription('property','value')
            %
            %   Input:
            %   obj             - An instance of an mtest.
            %   'keepfigures'   - The publishTestDescription function automatically closes any figures 
            %                     that was created during publishing and were not already there.
            %                     The optional argument 'keepfigures' prevents these figures from
            %                     being closed (unless stated in the test code somewhere).
            %
            %   property value pairs:
            %           'resdir'     -  Specifies the output directory (default is the current
            %                           directory)
            %           'filename'   -  Name of the output file. If the filename includes a path,
            %                           this pathname overrides the specified resdir.
            %           'testname'   -  Name of the test.
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
            %   See also mtestcase mtest.run mtest.runAndPublish mtestengine
            
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
                obj.includecode = varargin{id+1};
            end
            
            % evaluateCode
            if any(strcmpi(varargin,'evaluatecode'))
                id = find(strcmpi(varargin,'evaluatecode'));
                obj.evaluatecode = varargin{id+1};
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
                obj.descriptionoutputfile = [obj.filename '_main_description.html'];
            end
            outputname = fullfile(resdir,obj.descriptionoutputfile);
            
            %% retrieve testname from input
            if any(strcmpi(varargin,'testname'))
                id = find(strcmpi(varargin,'testname'));
                obj.testname = varargin{id+1};
            end
            
            %% set publish options
            opt = struct(...
                'format','html',...
                'stylesheet',stylesheet,...
                'outputDir',resdir,...
                'maxHeight',maxheight,...
                'maxWidth',maxwidth,...
                'showCode',obj.includecode,...
                'useNewFigure',false,... % Maybe add this to the input of properties?
                'evalCode',obj.evaluatecode);
            
            %% Check open figures
            openfigures = findobj('Type','figure');
      
            %% check for empty description
            if isempty(obj.testdescription)
                obj.testdescription = {...
                    '% This test still has no general description. This can be placed on the first lines of the test description file (*_test.m).'...
                    };
            end
            %% publish results to resdir
            mtestcase.publishCodeString(outputname,...
                [],...
                [],...
                cat(1,{['%% Test description of "' obj.testname '"']},obj.testdescription),...
                opt);
            
            %% Close all remaining open figures from the test
            newopenfigures = findobj('Type','figure');
            id = ~ismember(newopenfigures,openfigures);
            if any(id) && isempty(find(strcmpi(varargin,'keepfigures'), 1))
                close(newopenfigures(id));
            end
        end
    end
end
classdef mtest < handle & mtestdefinitionblock & mtestpublishable
    % MTEST - Object to handle tests written in mtest format
    %
    % TODO: edit help. Adjust to new format and maybe put this in the documentation
    % This objects stores the information written in an mtest format test definition file. The test
    % files consist of three parts divided by a cell break (%%). The three cells represent:
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
    % $Keywords: testing test unittest$
    
    %% Properties
    properties
        filename = [];                      % Original name of the testfile
        filepath = [];                      % Path of the "_test.m" file
        
        h1line   = [];                      % A one line description of the test (h1 line)
        description = {};                   % Detailed description of the test that appears in the help block
        author   = [];                      % Last author of the test (obtained from svn keywords)
        seealso  = {};                      % see also references
        
        testcases = mtestcase;              % mtestcases objects that contain testcase information for each individual testcase
        currentcase = [];                   % Number of the testcase that is last adressed
        
        testresult = false;                 % Boolean indicating whether the test was run successfully

        time     = 0;                       % Time that was needed to perform the test
        date     = NaN;                     % Date and time the test was performed
        profinfo = [];                      % Profile info structure
        functioncalls = [];
        stack    = [];
        
        resdir = '';                        % Directory where published files are stored
        postteamcitymessage = true;
    end
    properties (Hidden = true)
        fullstring = [];                    % Full string of the contents of the test file
        eventlisteners = [];                % Listeren to event runTest of testcases
        rundir = [];
        testperformed = false;
    end
    
    %% Events
    events
        TestPerformed
        RunWorkspaceSaved
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

            %% Test is initialized by default
            % This property belongs to mtestpublishable and is true for tests by default (the
            % default is false, because it is false by default for testcases)
            obj.initialized = true;
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
            %% #5 Interpret the definition string
            obj.interpretDefinitionString;
            %% #6 add event listeners
            obj.eventlisteners = cat(1,...
                event.listener(obj.testcases,'ReadyToInitialize',@obj.prepareTest),...
                event.listener(obj,'ReadyToSetDescriptionOutputFileName',@obj.setDescriptionOutputFileName),...
                event.listener(obj,'ReadyToSetCoverageOutputFileName',@obj.setCoverageOutputFileName),...
                event.listener(obj,'ReadyToSetPublishOutputFileName',@obj.setPublishOutputFileName),...
                ...
                event.listener(obj,'TestPerformed',@obj.storeRunWorkspace),...
                event.listener(obj,'RunWorkspaceSaved',@obj.fullPublish));
        end
        function interpretDefinitionString(obj)
            str = strtrim(obj.fullstring);
            
            %% -- find function calls
            fcnid = find(strncmp(str,'function ',9));
            endid = find(strcmp(str,'end') | strncmp(str,'end ',4) | strncmp(str,'end%',4) | strncmp(str,'end...',6));

            %% -- Divide info string into teststring and testcases
            if length(fcnid)>1
                %% subtract testinfo
                teststr = str(1:max(endid(endid<min(fcnid(fcnid>1))))-1);                
                %% seperate full strings of testcases
                fcnid = cat(1,fcnid,length(str)+1);
                for icase = 1:length(fcnid)-2
                    obj.testcases(icase) = mtestcase(icase,'fulldefinitionstring',str(fcnid(icase+1):max(endid(endid<fcnid(icase+2)))));
                    obj.testcases(icase).interpretDefinitionBlock;
                    obj.testcases(icase).functionoutputname = mtest.argsinname(obj.testcases(icase).functionheader,obj.testcases(icase).functionname);
                end
            elseif length(fcnid)==1
                %% subtract testinfo
                teststr = str(fcnid:end);
                obj.testcases(1) = [];
            else
                teststr = str;
                obj.testcases(1) = [];
            end
            %% -- Process test information
            % Read test specifications
            % testname
            % h1line
            % description
            % see also
            % last author
            % publishdescription
            % runcode
            
            if ~isempty(teststr)
                comments = strncmp(teststr,'%',1);

                %% header
                id = strfind(teststr{1},'function');
                if ~comments(1) && ~isempty(id)
                    obj.functionheader = teststr{1};
                    teststr(1)=[];
                    comments(1)=[];
                end
                
                %% h1line
                if comments(1)
                    h1linetemp = teststr{1};
                    if ~strncmp(h1linetemp,'%%',2)
                        obj.h1line = strtrim(strrep(lower(h1linetemp(find(~ismember(1:length(h1linetemp),strfind(h1linetemp,'%')),1,'first'):end)),lower(obj.filename),''));
                        teststr(1)=[];
                        comments(1)=[];
                    end
                end
                
                %% remaining helpblock
                idcommend = min([find((~comments),1,'first') find(strncmp(teststr,'%% ',3),1,'first')]);
                if ~isempty(idcommend) && idcommend > 1
                    helpblock = teststr(1:idcommend-1);
                    teststr(1:idcommend-1)=[];
                    comments(1:idcommend-1)=[];
                    
                    % see also
                    % remove blanks
                    helpblock = helpblock(1:find(~cellfun(@isempty,strtrim(helpblock)),1,'last'));
                    % remove single % signs
                    helpblock = helpblock(1:find(cellfun(@length,helpblock)>1 & strncmp(helpblock,'%',1),1,'last'));
                    
                    LastLengthMoreThanOne = length(helpblock{end})>1;
                    SeeAlsoReferencesPresent = strncmpi(strtrim(helpblock{end}(2:end)),'see also ',9);
                    if LastLengthMoreThanOne && SeeAlsoReferencesPresent
                        idbegin = min(strfind(lower(helpblock{end}),'see also'));
                        obj.seealso = strread(strtrim(helpblock{end}(idbegin+8:end)),'%s','delimiter',' ');
                        helpblock(end)=[];
                    end
                    
                    % desciption
                    % remove single % signs
                    helpblock = helpblock(1:find(cellfun(@length,helpblock)>1 & strncmp(helpblock,'%',1),1,'last'));
                    helpblock = helpblock(find(cellfun(@length,helpblock)>1 & strncmp(helpblock,'%',1),1,'first'):end);
                    obj.description = helpblock;
                end
                
                %% Credentials 
                credid = find(strncmp(teststr,'%% Credentials',14) | strncmp(teststr,'%% Copyright',12));
                if ~isempty(credid)
                    credend = find(~comments);
                    credend = min(credend(credend>credid));
                    teststr(credid:credend)=[];
                    comments(credid:credend)=[];
                end
                
                %% Version info
                versionid = find(strncmp(teststr,'%% Version',10));
                if ~isempty(versionid)
                    authorid = find(strncmp(teststr,'% $Author:',10), 1);
                    versionend = find(~comments)-1;
                    if ~isempty(authorid)
                        % last author
                        tmpstr = teststr{~cellfun(@isempty,strfind(teststr,'$Author:'))};
                        obj.author = strtrim(tmpstr(min(strfind(tmpstr,':'))+1:min([length(tmpstr)+1 max(strfind(tmpstr,'$'))])-1));
                        versionend = min(versionend(versionend>authorid));
                    else
                        versionend = min(versionend(versionend>versionid));
                    end
                    teststr(1:versionend)=[];
                end
            else
                % No runcode
                obj.testname = obj.filename;
                obj.ignore = true;
                obj.ignoremessage = 'No run code in definition.';
            end
            
            %% Analyse test definition blocks of test and testcases
            obj.fulldefinitionstring = teststr;
            obj.interpretDefinitionBlock
            
            %% -- check runcode
            if ischar(obj.runcode)
                obj.runcode = strread(obj.runcode,'%s',-1,'delimiter',char(10));
            end
            rncode = sprintf('%s\n',obj.runcode{~strncmp(obj.runcode,'%',1)});
            
            % subtract run code for individual testcases
            if ~isempty(rncode)
                for icase = length(obj.testcases):-1:1
                    call = strfind(rncode,obj.testcases(icase).functionname);
                    if isempty(call)
                        % No call to the testcase. This one is disabled. We do not have to remember it.
                        obj.testcases(icase) = [];
                    end
                end
            end
            
            %% -- Correct testcase numbers
            for itestcases = 1:length(obj.testcases)
                % create outputfilenames
                obj.currentcase = itestcases;
                
                % give default output filenames
                obj.testcases(itestcases).descriptionoutputfile = [obj.filename '_description_case_' num2str(obj.testcases(itestcases).casenumber) '.html'];
                obj.testcases(itestcases).publishoutputfile = [obj.filename '_results_case_' num2str(obj.testcases(itestcases).casenumber) '.html'];
                % TODO coverage outputname?
             end
        end
        function run(obj,varargin)
            %run  Runs all testcases
            %
            % TODO update this function (with profiler etc.)
            
            %   This function runs the code specified in the RunTest cell of the test definition
            %   file for each testcase. Previous to running the test code, any results of the code
            %   specifying the description of the test are created in the workspace where the test
            %   is performed (this is all code that is not preceeded by a "%" sign).
            %
            %   Syntax:
            %   runTest(obj);
            %   runTest(obj,'keepfigures');
            %   obj.runTest;
            %
            %   Input:
            %   obj             - An instance of an mtest object.
            %   'keepfigures'   - The publishResults function automatically closes any figures that
            %                     were created during publishing and were not already there.
            %                     The optional argument 'keepfigures' prevents these figures from
            %                     being closed (unless stated in the test code somewhere).
            %
            %   See also mtest mtest.mtest mtestcase.runTest mtestcase mtestengine
            
            %% Don't run ignored tests
            if obj.ignore
                return;
            end
            
            %% Make sure the directory of the test is in the searchpath
            pt = path;
            addpath(obj.filepath);
            
            %% construct temp rundir
            obj.rundir = tempname;
            mkdir(obj.rundir);
            
            %% Prepare testcase functions
            for icase = 1:length(obj.testcases)
                obj.testcases(icase).makeRunFunction(obj.rundir);
            end
            
            %% go to rundir
            cdtemp = cd;
            cd(obj.rundir);
            
            %% run general part of the code
            str = sprintf('%s\n',...
                strrep(obj.functionheader,obj.filename,'mtest_testfunction'),...
                obj.descriptioncode{~strncmp(obj.descriptioncode,'%',1)},...
                obj.runcode{:},...
                ['notify(getappdata(0,''' obj.storedobjname '''),''TestPerformed'',mtesteventdata(whos,''remove'',true));']);
            
            fid = fopen(fullfile(obj.rundir,'mtest_testfunction.m'),'w');
            fprintf(fid,'%s\n',str);
            fclose(fid);
            
            if ~exist(fullfile(obj.rundir,'mtest_testfunction.m'),'file')
                % Since Windows is slower in writing the file than the matlab fclose function..?
                % This is a workaround to let windos finish the file...
            end
            
            tic
            try
                obj.testresult = feval(@mtest_testfunction);
            catch
                obj.testresult = false;
            end
            obj.time = toc;
            
            %% cd back
            cd(cdtemp);
            
            %% remove tempdir
            rmdir(obj.rundir,'s');
            
            %% Return the initial searchpath
            path(pt);
            
            %% set additional parameters
            if ~isempty(obj.testcases)
                totaltime = [obj.testcases(:).time];
                if ~isempty(totaltime)
                    obj.time = sum(totaltime);
                end
            end
            obj.date = now;
            
            %% Set flag
            obj.testperformed = true;
        end
        function runAndPublish(obj,varargin)
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
            
            %% notify begin of test
            if obj.postteamcitymessage
                postmessage('testStarted',obj.postteamcitymessage,...
                    'name',obj.name,...
                    'captureStandardOutput','true');
            end
            
            %% return ignored tests
            if obj.ignore
                if obj.postteamcitymessage
                    postmessage('testIgnored',obj.postteamcitymessage,...
                        'name',obj.name,...
                        'message',obj.ignoremessage);
                    postmessage('testFinished',obj.postteamcitymessage,...
                        'name',obj.name,...
                        'duration','0');
                end
                return;
            end
            
            %% subtract result dir
            if isempty(obj.resdir)
                obj.resdir = cd;
            end
            id = find(strcmp(varargin,'resdir'));
            if ~isempty(id)
                obj.resdir = varargin{id+1};
                varargin(id:id+1)=[];
            end
            
            %% Make sure the directory of the test is in the searchpath
            pt = path;
            addpath(obj.filepath);
            
            %% construct temp rundir
            obj.rundir = tempname;
            mkdir(obj.rundir);
            
            %% subtract outputfilename
            id = find(strcmp(varargin,'outputfile'));
            caseoutputfile = [];
            if ~isempty(id)
                caseoutputfile = varargin{id+1};
                varargin(id:id+1)=[];
            end
            
            %% include testname
            if isempty(obj.name)
                obj.name = obj.filename;
            end
            id = find(strcmp(varargin,'testname'));
            if ~isempty(id)
                obj.name = varargin{id+1};
                varargin(id:id+1)=[];
            end
            if isempty(caseoutputfile)
                caseoutputfile = obj.filename;
            end
            
            %% Prepare testcase functions
            for icase = 1:length(obj.testcases)
                obj.currentcase = icase;
                
                % make runAndPublish files
                obj.testcases(icase).makeRunAndPublishFunction(obj.rundir);
                
                % set publish options
                for iargs = 1:2:length(varargin)
                    try
                        obj.testcases(icase).(varargin{iargs}) = varargin{iargs+1};
                    catch me %#ok<NASGU>
                        if ischar(varargin{iargs})
                            warning('Mtest:WrongInput',['The following property: "' varargin{iargs} '" could not be set and is not used.']);
                        else
                            warning('Mtest:WrongInput','Input must be valid property value pairs.');
                        end
                    end
                end
                obj.testcases(icase).outputfile = caseoutputfile;
                obj.testcases(icase).descriptionoutputfile = fullfile(obj.resdir,[caseoutputfile '_case_' num2str(icase) '_description.html']);
                obj.testcases(icase).publishoutputfile = fullfile(obj.resdir,[caseoutputfile '_case_' num2str(icase) '_results.html']);
            end
            
            %% go to rundir
            cdtemp = cd;
            cd(obj.rundir);
            
            %% run general part of the code
            if ~isempty(obj.functionheader)
                if isempty(obj.testcases)
                    str = sprintf('%s\n',...
                        strrep(obj.functionheader,obj.filename,'mtest_testfunction'),...
                        'mtest_245y7e_tic = tic;',...
                        'profile clear',...
                        'try',...
                            obj.descriptioncode{~strncmp(obj.descriptioncode,'%',1)},...
                            'profile on',...
                            obj.runcode{:},...
                            'profile off',...
                        'catch mtest_error_message',...
                            ['notify(getappdata(0,''' obj.storedobjname '''),''TestPerformed'',mtesteventdata(whos,''remove'',false,''time'',toc(mtest_245y7e_tic)));'],...
                            'profile off',...
                            'rethrow(mtest_error_message);',...
                        'end',...
                        ['notify(getappdata(0,''' obj.storedobjname '''),''TestPerformed'',mtesteventdata(whos,''remove'',false,''time'',toc(mtest_245y7e_tic)));'],...
                        ['notify(getappdata(0,''' obj.storedobjname '''),''RunWorkspaceSaved'',mtesteventdata(whos,''remove'',true));']);
                else
                    str = sprintf('%s\n',...
                        strrep(obj.functionheader,obj.filename,'mtest_testfunction'),...
                        'try',...
                        obj.descriptioncode{~strncmp(obj.descriptioncode,'%',1)},...
                        obj.runcode{:},...
                        'catch mtest_error_message',...
                            ['notify(getappdata(0,''' obj.storedobjname '''),''TestPerformed'',mtesteventdata(whos,''remove'',false));'],...
                            'rethrow(mtest_error_message);',...
                        'end',...
                        ['notify(getappdata(0,''' obj.storedobjname '''),''TestPerformed'',mtesteventdata(whos,''remove'',false));'],...
                        ['notify(getappdata(0,''' obj.storedobjname '''),''RunWorkspaceSaved'',mtesteventdata(whos,''remove'',true));']);
                end
                fid = fopen(fullfile(obj.rundir,'mtest_testfunction.m'),'w');
                fprintf(fid,'%s\n',str);
                fclose(fid);
                
                if ~exist(fullfile(obj.rundir,'mtest_testfunction.m'),'file')
                    % Since Windows is slower in writing the file than the matlab fclose function..?
                    % This is a workaround to let windows finish the file...
                end
                try
                    obj.testresult = feval(@mtest_testfunction);
                catch me
                    obj.testresult = false;
                    obj.stack = me;
                    if obj.postteamcitymessage
                        postmessage('testFailed',obj.postteamcitymessage,...
                            'name',obj.name,...
                            'message',me.message,...
                            'details',me.getReport);
                    end
                end
            else
                obj.testresult = false;
                postmessage('testFailed',obj.postteamcitymessage,...
                            'name',obj.name,...
                            'message','Error in test definition',...
                            'details','This test does not work due to a missing function declaration.');
                postmessage('testFinished',obj.postteamcitymessage,...
                        'name',obj.name,...
                        'duration','0');
            end
                            
            if ~isnan(obj.testresult) && ~islogical(obj.testresult)
                obj.testresult = false;
            end
            
            %% cd back
            cd(cdtemp);
            
            %% remove tempdir
            rmdir(obj.rundir,'s');
            
            %% set additional parameters
            if ~isempty(obj.testcases)
                totaltime = [obj.testcases(:).time];
                if ~isempty(totaltime)
                    obj.time = sum(totaltime);
                end
            end
            obj.date = now;
            
            %% Return the initial searchpath
            path(pt);

            %% Finish test
            postmessage('testFinished',obj.postteamcitymessage,...
                'name',obj.name,...
                'duration',num2str(round(obj.time*1000)));
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
            
            obj.runworkspace = [];
            %% Set flag
            obj.testperformed = false;
            
        end
        function edit(obj)
            edit(obj.filename);
        end
    end
    methods (Hidden = true)
        function setDescriptionOutputFileName(obj,varargin)
            % listener to ReadtToSetDescriptionOutputFile:
            obj.descriptionoutputfile = [obj.filename '_main_description.html'];
        end
        function setCoverageOutputFileName(obj,varargin)
            %% createoutputname
            obj.coverageoutputfile = [obj.filename '_main_coverage.html'];
        end
        function setPublishOutputFileName(obj,varargin)
            %% createoutputname
                obj.publishoutputfile = [obj.filename '_main_results.html'];
        end
        
        function storeRunWorkspace(obj,varargin)
            %% get workspace
            data = varargin{2};
            ws = data.workspace;
            
%             %% remove temp appdata
%             if varargin{2}.removetempobj
%                 obj.tmpobjname = [];
%             end
            
            %% store init workspace
            ws(strcmp(ws(:,1),'storedobjname'),:)=[];
            obj.runworkspace = ws;
            
            %% time
            if ~isempty(varargin{2}.time)
                obj.time = varargin{2}.time;
            end
            
            %% Save profiler info
            if isempty(obj.testcases)
                obj.profinfo = profile('info');
            else
                obj.profinfo = mergeprofileinfo(obj.testcases.profinfo);
            end
            
            obj.functioncalls = mtestfunction;
            for i = 1:size(obj.profinfo.FunctionTable,1)
                obj.functioncalls(i) = mtestfunction(obj.profinfo,i);
            end
            
            %% Set flag
            obj.testperformed = true;
        end
        function prepareTest(obj,varargin)
            %% construct temp rundir
            obj.rundir = tempname;
            mkdir(obj.rundir);
            
            %% Prepare testcase functions
            for icase = 1:length(obj.testcases)
                obj.testcases(icase).makeInitFunction(obj.rundir);
            end
            
            %% go to rundir
            cdtemp = cd;
            cd(obj.rundir);
            
            %% run general part of the code
            try
                evalinemptyworkspace(sprintf('%s\n',obj.descriptioncode{:},obj.runcode{:}));
            catch me %#ok<NASGU>
                disp('There appears to be something wrong with the descriptioncode or runcode of the mtest object.');
            end
            
            %% cd back
            cd(cdtemp);
            
            %% remove tempdir
            rmdir(obj.rundir,'s');
        end
        function fullPublish(obj,varargin)
            % This function assumes the test has been run fully
%             MoreThanTwoInputArgs = nargin>2;
%             if MoreThanTwoInputArgs
%                 SecondVararginMtesteventData = strcmp(class(varargin{2}),'mtesteventdata');
%                 RemoveTemoObj = varargin{2}.removetempobj;
%                 if SecondVararginMtesteventData && RemoveTemoObj
%                     obj.tmpobjname = [];
%                 end
%             end
            
            %% publish description
            obj.publishDescription;
            
            %% publish result
            obj.publishResult;
        end
    end
    methods (Static=true)
        function outargs = argsinname(str,fn)
            %% fund function name in call
            str = strtrim(str(strfind(str,'function')+length('function'):end));
            fnid = strfind(str,fn);
            
            %% output arguments
            outargs = [];
            if ~isempty(strfind(str(1:fnid),'='))
                % There is output defined
                outargstemp = strtrim(strread(strrep(strrep(strtrim(str(1:min(strfind(str(1:fnid),'='))-1)),'[',''),']',''),'%s',-1,'delimiter',','));
                
                for iargs = 1:length(outargstemp)
                    outargs = cat(1,outargs,strtrim(strread(outargstemp{iargs},'%s',-1,'delimiter',' ')));
                end
            end
        end
    end
end
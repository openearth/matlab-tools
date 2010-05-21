classdef mtestpublishable < handle & mtestdefinitionblock
    properties
        descriptionoutputfile = {};         % Name of the published output file of the description
        coverageoutputfile = {};            % Name of the published coverage output file
        publishoutputfile = {};             % Name of the published output file of the TestResults cell
        
        maxwidth  = 600;                    % Maximum width of the published figures (in pixels). By default the maximum width is set to 600 pixels.
        maxheight = 600;                    % Maximum height of the published figures (in pixels). By default the maximum height is set to 600 pixels.
        stylesheet = '';                    % Style sheet that is used for publishing (see publish documentation for more information).
    end
    properties (Hidden = true)
        initialized = false;
        tempdir = tempdir;                  % Temporary directory for publishing output files.

        initworkspace = [];                 % Variable that can be used as workspace to pass input variables
        runworkspace = [];                  % Variable that can be used as workspace to pass variables after running (for publishing)
    end
    events
        ReadyToInitialize
        ReadyToSetDescriptionOutputFileName
        ReadyToSetCoverageOutputFileName
        ReadyToSetPublishOutputFileName
        ReadyToPublish
    end
    methods
        function publishDescription(obj,varargin)
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
            if isempty(obj.descriptioncode) || obj.ignore
                return;
            end
            
            %% Check whether the testcase has been initialized
            if ~obj.initialized
                % Testcases should be initialized. Input variables are created by the call to the
                % testcase. The mtest object hosting testcases is listening to the events of its
                % testcases (initialized property is set to true for a test by default).
                notify(obj,'ReadyToInitialize'); % mtest object listens and prepares the tests
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
                notify(obj,'ReadyToSetDescriptionOutputFileName');
            end
            [pt fn] = fileparts(obj.descriptionoutputfile);
            if isempty(pt)
                pt = obj.resdir;
            end
            outputname = fullfile(pt,[fn '.html']);
            
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
            if ~isempty(obj.name)
                descrstr = cat(1,{['%% Description ("' obj.name '")']},obj.descriptioncode);
            else
                descrstr = cat(1,{['%% Description ("' obj.functionname '")']},obj.descriptioncode);
            end
            mtestpublishable.publishCodeString(outputname,...
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
                notify(obj,'ReadyToSetCoverageOutputFileName');
                %obj.coverageoutputfile = [obj.filename '_coverage_case' num2str(obj.casenumber) '.html'];
            end
            [pt fn] = fileparts(obj.coverageoutputfile);
            if isempty(pt)
                pt = obj.resdir;
            end
            obj.coverageoutputfile = fullfile(pt,[fn '.html']);
            
            %% retrieve testname from input
            if any(strcmpi(varargin,'name'))
                id = find(strcmpi(varargin,'name'));
                obj.name = varargin{id+1};
            end
            
            %% calculate coverage
            fcns = [];
            if ~isempty(obj.functioncalls)
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
        function publishResult(obj,varargin)
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
            if obj.ignore || isempty(obj.publishcode)
                return;
            end
            
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
                [pt nm] = fileparts(varargin{id+1});
                obj.publishoutputfile = [nm '.html'];
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
            if isempty(obj.publishoutputfile)
                notify(obj,'ReadyToSetPublishOutputFileName');
            end
            [pt fn] = fileparts(obj.publishoutputfile);
            if isempty(pt)
                pt = obj.resdir;
            end
            outputname = fullfile(pt,[fn '.html']);
       
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
            if ~isempty(obj.name)
                publstr = cat(1,{['%% Results ("' obj.name '")']},obj.publishcode);
            else
                publstr = cat(1,{['%% Results ("' obj.functionname '")']},obj.publishcode);
            end
            mtestpublishable.publishCodeString(outputname,...
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
    end
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
            tempfilename = mtestpublishable.makeTempFile(tempdir,string2publish,outputname);
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
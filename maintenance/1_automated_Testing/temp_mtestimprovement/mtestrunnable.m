classdef mtestrunnable < handle & mtestdefinitionblock
    properties
        testresult = [];
        stack = [];
        initworkspace = [];
        runworkspace = [];
        
        time     = 0;                       % Time that was needed to perform the test
        date     = NaN;                     % Date and time the test was performed
        profinfo = [];                      % Profile info structure
        functioncalls = [];
    end
    properties (Hidden = true)
        rundir = [];
        testperformed = false;
    end
    events
        RunFileCreated
    end
    methods
        function run(obj)
            if obj.postteamcity
                postmessage('testStarted',obj.postteamcity,...
                    'name',obj.name,...
                    'captureStandardOutput','true');
            end
            
            %% return ignored tests
            if obj.ignore
                if obj.postteamcity
                    postmessage('testIgnored',obj.postteamcity,...
                        'name',testname,...
                        'message',obj.ignoremessage);
                    postmessage('testFinished',obj.postteamcity,...
                        'name',obj.name,...
                        'duration','0');
                end
                return;
            end
            
            %% Prepare run file
            makeRunFunction(obj);
            notify(obj,'RunFileCreated');
            
            %% go to rundir
            cdtemp = cd;
            cd(obj.rundir);
            
            if ~exist(fullfile(obj.rundir,[obj.functionname '.m']),'file')
                % Since Windows is slower in writing the file than the matlab fclose function..?
                % This is a workaround to let windows finish the file...
            end
            
            try
                obj.testresult = true;
                feval(@mtest_testfunction);
            catch me
                obj.testresult = false;
                obj.stack = me;
                if obj.postteamcity
                    
                end
            end
            
            testperformed = true;
            postmessage('testFinished',obj.postteamcity,...
                        'name',obj.name,...
                        'duration',num2str(obj.time));
            
                %% cd back
            cd(cdtemp);
            
            %% remove tempdir
            % rmdir(obj.rundir,'s');
            
            %% set date
%             if ~isempty(obj.testcases)
%                 totaltime = [obj.testcases(:).time];
%                 if ~isempty(totaltime)
%                     obj.time = sum(totaltime);
%                 end
%             end
            obj.date = now;
            
            %% Return the initial searchpath
            path(pt);
        end
    end
    methods
        function makeRunFunction(obj)
            % prepares the runAndPublish function. This is a function that stores the input variables
            % and with result after running the help of setappdata. It uses notifications to
            % save the workspaces.
            fname = fullfile(obj.rundir,[obj.functionname '.m']);
            
            %% prepare content
            if obj.publish
                str = sprintf('%s\n',...
                    obj.functionheader,...
                    ' ',...
                    ['mtestrunnable.pasteworkspace(getappdata(0,''', obj.storedobjname, '''),''init'''],...
                    ['notify(getappdata(0,''' obj.storedobjname '''),''TestInitialized'',mtesteventdata(whos,''remove'',false));'],...
                    'mtest_245y7e_tic = tic;',...
                    ' ',...
                    'try',...
                    ' ',...
                    obj.descriptioncode{~strncmp(obj.descriptioncode,'%',1)},...
                    'profile on',...
                    obj.runcode{:},...
                    'profile off',...
                    'catch mtest_error_message',...
                    ['notify(getappdata(0,''' obj.tmpobjname '''),''TestCompleted'',mtesteventdata(whos,''time'',toc(mtest_245y7e_tic),''remove'',false));'],...
                    'rethrow(mtest_error_message);',...
                    'end',...
                    ' ',...
                    ['notify(getappdata(0,''' obj.tmpobjname '''),''TestCompleted'',mtesteventdata(whos,''time'',toc(mtest_245y7e_tic),''remove'',false));']...
                    );
            else
                str = sprintf('%s\n',...
                    obj.functionheader,...
                    'mtest_245y7e_tic = tic;',...
                    obj.descriptioncode{~strncmp(obj.descriptioncode,'%',1)},...
                    'profile on',...
                    obj.runcode{:},...
                    'profile off',...
                    ['notify(getappdata(0,''' obj.tmpobjname '''),''TestCompleted'',mtesteventdata(whos,''time'',toc(mtest_245y7e_tic),''remove'',false));']...
                    );
            end
            %% write function
            fid = fopen(fname,'w');
            fprintf(fid,'%s\n',str);
            fclose(fid);
        end
    end
end
function RunModelLoop(hObject, eventdata)

% This is the model loop timer function. It is executed every 5 seconds,
% until all simulations are finished.
%
% It first checks whether any new simulations can be started. If this is
% the case, then for each model,the pre-processing will be done, and the
% job will be submitted.
%
% Next, the model loop checks whether simulations are finished and waiting
% somewhere on the network. If so, the model output of each simulation
% will be moved to the local directory.
%
% Next, the model loop does the post-processing (extracting data, making
% figures, uploading to website). It does this for only one
% model. This is better than post-processing all models in one execution of the model
% loop, as this can take a bit of time. In the mean time, simulations
% could be ready to run, but would have to (unnecessarily) wait for
% post-processing of other models.
%
% Finally, the model loop checks if all simulations are finished. If so,
% the main loop timer (which executes every 6 or 12 hours) and the model loop
% timer are deleted. A new main loop timer is started if the the cycle mode
% has been set to continuous.

try

    hm=guidata(findobj('Tag','OMSMain'));

%    if hm.RunSimulation

        %%   Pre-Processing

        % Check which models need to run next
        [hm,WaitingList]=UpdateWaitingList(hm);

        % If there are model ready to run ...
        if ~isempty(WaitingList)

            % Pre process all waiting simulations
            for i=1:length(WaitingList)

                % Close all files that may have been left open due to an error
                % in previous model
                fclose all;

                m=WaitingList(i);

                if ~strcmpi(hm.Models(m).Status,'failed') && ~isempty(timerfind('Tag', 'ModelLoop'))

                    % Check if simulation actually needs to run (not sure how
                    % this could happen... TODO Should check it out.
                    if hm.Models(m).RunSimulation
                        mdl=hm.Models(m).Name;
                        set(hm.TextModelLoopStatus,'String',['Status : pre-processing ' mdl ' ...']);drawnow;
                        try
                            WriteLogFile(['Pre-processing ' hm.Models(m).Name]);
                            % Pre-processing
                            PreProcess(hm,m);
                        catch
                            WriteErrorLogFile(hm,['Something went wrong pre-processing ' hm.Models(m).Name]);
                            hm.Models(m).Status='failed';
                        end
                        try
                            % If pre-processing went okay, now submit the job
                            if ~strcmpi(hm.Models(m).Status,'failed') && ~isempty(timerfind('Tag', 'ModelLoop'))
                                WriteLogFile(['Submitting job ' hm.Models(m).Name]);
                                % Submitting
                                %                            if ~strcmpi(hm.Models(m).Type,'xbeachcluster')
                                SubmitJob(hm,m);
                                %                            end
                            end
                        catch
                            WriteErrorLogFile(hm,['Something went wrong submitting job for ' hm.Models(m).Name]);
                            hm.Models(m).Status='failed';
                        end
                    end

                    % If everything went okay, set model status to running
                    if ~strcmpi(hm.Models(m).Status,'failed')
                        hm.Models(m).Status='running';
                    end

                end
            end
        end

        %%   Moving all finished model output to local directory

        % First check which simulations have been finished and are waiting to
        % be moved to local main directory
        [hm,FinishedList]=CheckForFinishedSimulations(hm);

        % If there are simulations ready ...
        if ~isempty(FinishedList)

            n=length(FinishedList);

            % Move all waiting simulations
            for i=1:n

                % Moving data
                m=FinishedList(i);

                if ~strcmpi(hm.Models(m).Status,'failed') && ~isempty(timerfind('Tag', 'ModelLoop'))
                    mdl=hm.Models(m).Name;
                    set(hm.TextModelLoopStatus,'String',['Status : moving ' mdl ' ...']);drawnow;
                    try
                        WriteLogFile(['Moving data ' hm.Models(m).Name]);
                        tic
                        % Move the model results to local main directory
                        MoveData(hm,m);
                    catch
                        WriteErrorLogFile(hm,['Something went wrong moving data of ' hm.Models(m).Name]);
                        hm.Models(m).Status='failed';
                    end
                    hm.Models(m).MoveDuration=toc;

                    % Set model status to simulationfinished (if everything went okay)
                    % The model is now ready for further post-processing (extracting data, making figures, uploading to website)
                    if ~strcmpi(hm.Models(m).Status,'failed')
                        hm.Models(m).Status='simulationfinished';
                    end

                end
            end
        end

%    end

%%   Post-Processing

    % Find simulations that are finished and been moved to local pc
    m=[];
    for i=1:hm.NrModels
        if strcmpi(hm.Models(i).Status,'simulationfinished')
            m=i;
            % Only post-process one model at a time
            break;
        end
    end

    % If there is a simulation ready for processing ...
    if ~isempty(m)

        mdl=hm.Models(m).Name;
        set(hm.TextModelLoopStatus,'String',['Status : post-processing ' mdl ' ...']);drawnow;

        WriteLogFile(['Processing data ' hm.Models(m).Name]);
        
        % Process model results
        hm=ProcessData(hm,m);
        
        disp(['Post-processing ' hm.Models(m).Name ' finished']);
        
        % Check if anything went wrong
        if ~strcmpi(hm.Models(m).Status,'failed')
            % Model finished, no failures
            writeJoblistFile(hm,m,'finished');
            hm.Models(m).Status='finished';
        else
            % Model finished, with failures
            writeJoblistFile(hm,m,'failed');
            hm.Models(m).Status='failed';
        end

    end
    set(hm.TextModelLoopStatus,'String','Status : active');drawnow;


%%  Check if all simulations are finished

    alfin=1;
    failed=0;
    for i=1:hm.NrModels
        if ~strcmpi(hm.Models(i).Status,'finished') && ~strcmpi(hm.Models(i).Status,'failed') && hm.Models(i).Priority>0
            alfin=0;
        end
        % Check if one of the models failed.
        if strcmpi(hm.Models(i).Status,'failed')
            failed=1;
        end
    end

    if alfin
        disp('All models finished!');
    end
    
    % If all finished, delete timer functions ModelLoop and MainLoop
    t1 = timerfind('Tag', 'ModelLoop');
    t2 = timerfind('Tag', 'MainLoop');
    if alfin && ~isempty(t2)
        delete(t1);
        delete(t2);
        set(hm.TextModelLoopStatus,'String','Status : inactive');drawnow;        
        % If cycle mode is continuous, start new MainLoop 
        if strcmpi(hm.CycleMode,'continuous')
            disp(['Finished cycle ' datestr(hm.Cycle,'yyyymmdd.HHMMSS')]);
            hm.Cycle=hm.Cycle+hm.RunInterval/24;
            disp(['Starting cycle ' datestr(hm.Cycle,'yyyymmdd.HHMMSS')]);
            set(hm.EditCycle,'String',datestr(hm.Cycle,'yyyymmdd HHMMSS'));
            set(hm.TextModelLoopStatus,'String','Status : waiting');drawnow;        
            guidata(findobj('Tag','OMSMain'),hm);
            StartMainLoop(hm);
        end
    end

    guidata(findobj('Tag','OMSMain'),hm);

catch

    WriteErrorLogFile(hm,'Something went wrong running in the model loop');

end

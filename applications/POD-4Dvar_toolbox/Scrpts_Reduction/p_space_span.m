function [varargout] = p_space_span(options, modelbg, numparam, params, numsnaps, numsteps, deviations, bgcov)
    
    % [ROM,MODEL] = SNAPSHOT_RUNS()
        if strcmpi(options.snapshotsRuns,'spsa')
            error('Not operational yet')
        else
        
        
        
        %-> Run the background simulation (linearizing trajectory)
        if options.bg.runflag,
            disp([char(10),'Executing background run']); 
            config_rund3d(modelbg,options.numNodesInCluster); 
            save([modelbg.mainpath,'model.mat'],'modelbg'); 
        end



        %-> Run perturbed simulations to span parameter space (for projection sub-space)
        pars = configureSnapshotRuns(options.snapshotsRuns,modelbg,deviations,numparam,params,numsnaps);
        if options.snapshots.runflag, 
            for iModel=1:1:length(pars), 
                config_rund3d(pars(iModel),options.numNodesInCluster);
                par_model = pars(iModel); 
                save([pars(iModel).mainpath,'model.mat'],'par_model'); 
                clear par_model; 
            end, 
        end
        
        disp([char(10),'Loading: Initial runs information']);
        disp([char(10),'Attempting to upload background simulation information']); 
        

        % Load the background model information
        [modelbg,runbg,pars,snapshot]     = get_data(options,modelbg,{pars.mainpath},bgcov,numsnaps,numsteps);
        
        
        for iparam = 1:1:numparam, params(iparam).bgValue = getfield(modelbg,params(iparam).filext,params(iparam).acronym); end       %Update the background parameters value configuration
        
        varargout{1} = modelbg;        
        varargout{2} = runbg;        
        varargout{3} = pars;
        varargout{4} = snapshot;   
        varargout{5} = params;
    end
end

%  ________________________________________________________________________
%% Get the information from the initial runs in order to make PCA
function [modelbg, bgrun, pars, snapshots] = get_data(options, modelbg, par_paths, bgcov, numsnaps, numsteps)
    
    disp(['Importing data from: ',modelbg.mainpath,'model.mat'])
            saved_modelbg = importdata([modelbg.mainpath,'model.mat']);
            format long g;
            if ~isequal(saved_modelbg.mdf,modelbg.mdf)
                disp([char(10), ...
                     '** Differences between saved configured and current configuration found in backgroud runs **', char(10), ...
                     'Diagnostics',char(10),'Saved setup: '])
                saved_modelbg.mdf
                disp([char(10),'Current setup: '])
                modelbg.mdf
                disp(char(10))
                
                if ~input('Continue execution: [1]Yes   [0]Abort')    
                    error(['Flow conditions mismatch between current ', ...
                       'background setup and stored setup'])
                end
                
            elseif ~isequal(saved_modelbg.mor,modelbg.mor)
                disp([char(10), ...
                     '** Differences between saved configured and current configuration found in backgroud runs **', char(10), ...
                     'Diagnostics',char(10),'Saved setup: '])
                saved_modelbg.mor
                disp([char(10),'Current setup: '])
                modelbg.mor
                disp(char(10))
                if ~input('Continue execution: [1]Yes   [0]Abort')    
                    error(['Morphologic conditions mismatch between current ', ...
                           'background setup and stored setup'])
                end
            elseif ~isequal(saved_modelbg.mdw,modelbg.mdw)
                disp([char(10), ...
                     '** Differences between saved configured and current configuration found in backgroud runs **', char(10), ...
                     'Diagnostics',char(10),'Saved setup: '])
                saved_modelbg.mdw
                disp([char(10),'Current setup: '])
                modelbg.mdw
                disp(char(10))
                if ~input('Continue execution: [1]Yes   [0]Abort')    
                    error(['Wave conditions mismatch between current ', ...
                           'background setup and stored setup'])
                end
            elseif ~isequal(saved_modelbg.bcc,modelbg.bcc)
                error(['Boundary conditions mismatch between current ', ...
                       'background setup and stored setup'])
            elseif ~isequal(saved_modelbg.configP,modelbg.configP)
                error(['State vector mismatch (configP) between current ', ...
                       'background setup and stored setup'])
            end
            
            if modelbg.Totalrun ~= saved_modelbg.Totalrun
                if modelbg.Totalrun > saved_modelbg.Totalrun
                    error(['Current simulation time is longer than saved ', ...
                        'simulation time'])
                else
                    disp([char(10),'!! Warning !! Current simulation time is shorter than ', ...
                        'the simulation time stored in: ',char(10),'  ',modelbg.mainpath,'model.mat'])
                    disp('Using current (shorter) simulation time')
                end

            end

            if ~strcmpi(modelbg.mainpath,saved_modelbg.mainpath);
                disp([char(10),'!! Warning !! Current model folder is different than ', ...
                        'the path stored in: ',char(10),'  ',modelbg.mainpath,'model.mat'])
                disp('Will use current path...')
            end
            pause(5)
            format;
    disp(['Consistency of the data checked. Data succesfully imported'])
    
    
    
    % Load the snapshot information
    if options.bg.loadinfoflag,
        
        disp([char(10),'Awaiting for simulations to be finished']);
        d3dfinish('garcia_in',10);
        bgrun = getrunsinfo(modelbg.mainpath,modelbg.mdf.runID,options.getrunsinfo);
    else
        disp(['Loading: ',modelbg.mainpath,'bg_results.mat']); bgrun = importdata([modelbg.mainpath,'bg_results.mat']); 
    end
    
     
    % Load the snapshot information
    if options.snapshots.loadinfoflag
        
        
        
        for iModel=1:1:numsnaps
            
            pars(iModel)          = importdata([par_paths{iModel},'model.mat']);    %Load the true model parameters... maybe in previous run this was background.
            pars(iModel).mainpath = par_paths{iModel};                              %Update the path... maybe I ran it in another test. New paths therefore.
            parsresults(iModel)   = getrunsinfo(pars(iModel).mainpath,pars(iModel).mdf.runID,options.getrunsinfo);
            
        end

        if options.bg.automaticselect, [modelbg,bgrun,parsresults,pars] = choose_bg(modelbg,bgrun,parsresults,pars); end
        save([modelbg.mainpath,'bg_results.mat'],'bgrun')
        
        for iModel=1:1:numsnaps
                par_res = parsresults(iModel); 
                save([pars(iModel).mainpath,'snap_results.mat'],'par_res');
                clear par_res;
        end
            
        for iModel=1:1:numsnaps
            inicol = (iModel-1)*(numsteps)+1; 
            endcol = (iModel)*(numsteps);
                        
            if length(parsresults(iModel).times) < (numsteps+1)
                error(['Perturbed run number ',num2str(iModel),' has less times than expected.'])
            end
                
            if (parsresults(iModel).times(2:numsteps+1) - bgrun.times(2:numsteps+1))~= 0, 
                error('ROMconstruct:timesyncerror','Asynchronic times between background and perturbations'); 
            end
            snapshots(:,inicol:endcol) = parsresults(iModel).vectors.dps(:,2:numsteps+1) - bgrun.vectors.dps(:,2:numsteps+1);
            
            clear inicol endcol;
        end
        
        % Only the validcells, multiply by morcells
        for isnap = size(snapshots,2):-1:1, snapshots(:,isnap) = snapshots(:,isnap).*bgrun.vectors.morcells; end
        save([modelbg.mainpath(1:end-11),'snapshots.mat'],'snapshots')
        
        
        
    else
        
        
        disp([char(10),'Attempting to upload perturbed simulations information']); 
        disp(['Loading: ',modelbg.mainpath(1:end-11),'snapshots.mat'])
        snapshots = importdata([modelbg.mainpath(1:end-11),'snapshots.mat']);
        for iModel = numsnaps:-1:1, 
            pars(iModel) = importdata([par_paths{iModel},'model.mat']); 
            pars(iModel).mainpath = par_paths{iModel}; 
        end
    end
end


%%
function [modelbg,rbg,rsnap,msnap] = choose_bg(modelbg,rbg,rsnap,msnap)
        % Load the observation information
        obs = arrangeobsinfo(options.observations, modelbg.mdf.runID, rbg);

        ladiff = estdiff(obs,rbg);
        thecost.bg = evalcost(ladiff,obs.matCov,bgcov,modelbg.configP');

        for iModel=1:1:numsnaps
            ladiff = estdiff(obs,rsnap(iModel));        
            thecost.pars(iModel) = evalcost(ladiff,obs.matCov,bgcov,msnap(iModel).configP');
        end
        disp([char(10),'Cost of the initial guess: ',num2str(thecost.bg)])
        disp(['Minimum cost of the perturbed runs: ',num2str(min(thecost.msnap))])

        if min(thecost.msnap)<thecost.bg,  %Perturbation less expensive than background?
            disp('Better perturbation than background')
            elind = find(thecost.msnap==min(thecost.msnap));

            [status,message,messageid] = movefile(modelbg.mainpath,[msnap(elind).mainpath(1:end-1),'temp',filesep]);     if ~status, error(messageid,message); end
            [status,message,messageid] = movefile(msnap(elind).mainpath,modelbg.mainpath);                               if ~status, error(messageid,message); end
            [status,message,messageid] = movefile([msnap(elind).mainpath(1:end-1),'temp',filesep],msnap(elind).mainpath); if ~status, error(messageid,message); end

            % Swap Model Setup
            temp_model = modelbg; 
            temp_model.mainpath = msnap(elind).mainpath;
            msnap(elind).mainpath = modelbg.mainpath;
            modelbg = msnap(elind);
            msnap(elind) = temp_model;
            clear temp_model

            % Swap Simulation Results
            temp_results = rsnap(elind);
            rsnap(elind) = rbg;
            rbg = temp_results;
            clear temp_results

            for iModel=1:1:nursnaps
                msnap(iModel).configP = msnap(iModel).configP - modelbg.configP; 
                
                par_model = msnap(iModel); 
                save([msnap(iModel).mainpath,'model.mat'],'par_model'); 
                
                par_res = rsnap(iModel); 
                save([msnap(iModel).mainpath,'snap_results.mat'],'par_res');
                clear par_model par_res;
            end
            modelbg.configP = zeros(size(modelbg.configP));
            save([modelbg.mainpath,'model.mat'],'modelbg')
        end
end
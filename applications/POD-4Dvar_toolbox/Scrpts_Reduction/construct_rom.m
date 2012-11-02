function [rom,modelbg,obs] = construct_rom(rom,model,modelbg,options)
    
    %% Make the initial runs
    disp('MAKING INITIAL RUNS');
    
    if options.bg.automaticselect
        
        % Will choose as the linearizing trajectory the snapshot with the
        % lowest cost function
        [modelbg,rom.bg,model.pars,snapshots,rom.Params,obs] = p_space_span(options,modelbg,rom.numParam,rom.Params,model.numSnapshotsRuns,rom.steps,model.deviations,rom.initialGuess.matCov);
    else
        
        % The initial guess is the linearizing trajectory
        [modelbg,rom.bg,model.pars,snapshots,rom.Params]     = p_space_span(options,modelbg,rom.numParam,rom.Params,model.numSnapshotsRuns,rom.steps,model.deviations,rom.initialGuess.matCov);
        model = rmfield(model,'deviations');
    end

    rom.initialGuess.cumMovement = [rom.Params.bgValue]' - rom.initialGuess.value';

    
    
    
    %  ____________________________________________________________________
    %% Make Singular value decomposition
    disp([char(10),'___________________________________________________________________________________________________']);
    disp('CONSTRUCTING THE REDUCED ORDER MODEL')

    disp([char(10),'Assessing Principal Components']);
    
    if options.patterns.calculate
        [patterns.vectors,patterns.V,patterns.D,patterns.Dprcnt] = getpatterns(options.patterns,snapshots);
        patterns.No = size(patterns.vectors,2); 
        disp(['Number of patterns selected: ' num2str(patterns.No)])
        
        % Get those patterns back into matrix form so that we can make some sense
        % out of them through graphical presentation.
        patterns.n = rom.bg.n; patterns.m = rom.bg.m;
        for iPattern=1:1:patterns.No, patterns.info(iPattern) = {reshape(patterns.vectors(:,iPattern),patterns.n,patterns.m)}; end
        save([modelbg.mainpath(1:end-11),'patterns.mat'],'patterns'); rom.P=patterns.vectors;
        clear snapshots;
        
    else
        clear snapshots;
        load([modelbg.mainpath(1:end-11),'patterns.mat'],'patterns');
        rom.P = patterns.vectors;
    end
    
    

    
    
    
    
    
    %  ________________________________________________________________________
    %% MAKE ALL PERTURBED RUNS

    
    % RUN sensitivity
    disp([char(10),'Assessing the Sensitivities']);
    if strcmpi(options.sensitivities.type,'forward'),         sensitivity_derivative('run',options,rom.Params,rom.numParam,modelbg);
    elseif strcmpi(options.sensitivities.type,'central'),     sensitivity_derivative('run',options,rom.Params,rom.numParam,modelbg);
    end

    %Make directional derivative runs (if solve3forward or solve4central it is not necessary to run the model)    
    if     strcmpi(options.gateaux.type,'forward'),               disp([char(10),'Assessing the Gateaux Derivative',char(10),'Type of approximation: ', options.gateaux.type]);            directional_derivative('run',options,patterns,options.gateaux.epsilon,modelbg);
    elseif strcmpi(options.gateaux.type,'central'),           disp([char(10),'Assessing the Gateaux Derivative',char(10),'Type of approximation: ', options.gateaux.type]);            directional_derivative('run',options,patterns,options.gateaux.epsilon,modelbg);
    end

    %This order of loading info matters, it gives enough time to finish
    %copying all files from h4.
    
    % LOAD sensitivities information
    if     strcmpi(options.sensitivities.type,'forward'),     rom.dN_dAlpha = sensitivity_derivative('load',options,rom.Params,rom.numParam,modelbg,rom.steps,rom.P,rom.bg);
    elseif strcmpi(options.sensitivities.type,'central'),     rom.dN_dAlpha = sensitivity_derivative('load',options,rom.Params,rom.numParam,modelbg,rom.steps,rom.P,rom.bg.vectors.morcells);
    end
    
    % Load the directional derivative information
    if     strcmpi(options.gateaux.type,'forward'),           rom.N = directional_derivative('load',options,patterns,options.gateaux.epsilon,modelbg,rom.steps,rom.bg);
    elseif strcmpi(options.gateaux.type,'central'),           rom.N = directional_derivative('load',options,patterns,options.gateaux.epsilon,modelbg,rom.steps,rom.bg.vectors.morcells);
    elseif strcmpi(options.gateaux.type,'solve'),             rom.N = directional_derivative('solve',options,patterns,model.pars,model.numSnapshotsRuns,rom.steps,rom.dN_dAlpha,modelbg.mainpath(1:end-11),rom.bg);
    end
    
    
    %for iTStep = rom.steps:-1:1, 
    %    rom.parrelevance = rom.parrelevance + abs(patterns.D(1:patterns.No)'./sum(patterns.D)*rom.dN_dAlpha{iTStep}); 
    %end
    %rom.parrelevance = 1/patterns.No*1/rom.steps*rom.parrelevance;


    
    
    
    %  ________________________________________________________________________
    %% Construct the adjoint reduced model
    disp([char(10),'Constructing the Adjoint Reduced Order Model']);   
    for iTStep = rom.steps:-1:1
         rom.dr_dDa{iTStep} = zeros(size(rom.P,2),rom.numParam);
         rom.dr_dr{iTStep} = ones(size(rom.P,2),size(rom.P,2));
         for jTStep = iTStep:-1:1             
             
             tempProduct = rom.dN_dAlpha{jTStep};
             
             for kTStep = jTStep+1:1:iTStep, tempProduct = rom.N{kTStep}*tempProduct; end
             
             rom.dr_dDa{iTStep} = tempProduct + rom.dr_dDa{iTStep};
             rom.dr_dr{iTStep} = rom.N{jTStep}*rom.dr_dr{iTStep};
         end
     end
     disp([char(10), 'Reduced Order Model (ROM) construction: Successful'])
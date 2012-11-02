clc, clear all
%function [IterConfig, bgmodel, elrom, options, test] = POD4Dvar_setSchemeOptions()
  
if isunix
    test.testFolder   = '/p/x0385-gs-mor/ivan/paper_2_steps/test_7/';
    bgmodel.setuppath = '/p/x0385-gs-mor/ivan/paper_2_steps/Setup_noRun/';  % Source of model configuration
else
    test.testFolder   = 'p:\x0385-gs-mor\ivan\paper_2_steps\test_7\';
    bgmodel.setuppath = 'p:\x0385-gs-mor\ivan\paper_2_steps\Setup_noRun\';  % Source of model configuration
end

        
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONFIGURE THE BACKGROUND/REFERENCE MODEL: TRAJECTORY TO BE LINEARIZED %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    disp('___________________________________________________________________________________________________')
    disp('SETTING UP THE MODEL')


    % -> User defined
        
        bgmodel.depname = 'wave_dep';                                      % Name of the depth file

        
        
        % Getting runId's for the different files.
        bgmodel.sensitivitypath = [];
        bgmodel.mdf.runID = getfield(dir([bgmodel.setuppath,'*.mdf']),'name');      % Name of the mdf
        bgmodel.mor.runID = getfield(dir([bgmodel.setuppath,'*.mor']),'name');      % Name of the mor
        bgmodel.mdw.runID = getfield(dir([bgmodel.setuppath,'*.mdw']),'name');      % Name of the mor
        bgmodel.bcc.runID = getfield(dir([bgmodel.setuppath,'*.bcc']),'name');      % Name of the mor
        bgmodel.runID     = bgmodel.mdf.runID(1:end-4);

        
                
        
    % -> Define the parameter set/state vector
        [elrom, bgmodel] = params_def(bgmodel);


        
    %-> Initialize some important variables
        bgmodel.configP                = zeros(1,elrom.numParam);          % Will store deviations of the state vector from reference
        elrom.initialGuess.cumMovement = zeros(elrom.numParam,1);          % Deviations from the initial guess

        
        
        
    
        disp(char(10)); for i=1:1:elrom.numParam, disp([sprintf('%-60s',elrom.Params(i).name),' ',num2str(elrom.Params(i).bgValue)]); end, clear i;
        disp(char(10)); disp(['Number of parameters of interest: ',num2str(elrom.numParam)])

        
        
        
    % -> Store the current configuration in the experiment folder
        copyfile([mfilename('fullpath'),'.m'], [test.testFolder,mfilename,'.m']);
        copyfile([pwd,filesep,'thedon.m'],    [test.testFolder,'thedon.m']);
        copyfile([pwd,filesep,'params_def.m'],[test.testFolder,'params_def.m']);
        
        
        
        
        
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% CONFIGURE YOUR RUN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    options.maxOutIter = 3;
    options.totalrun   = (0.5)*1440;                                         % First term corresponds to the number of days that I want to run the model.
    options.initialrun = (0.5)*1440;                                         % Run for the first outer iteration... we start with a short run to make a partial initial assimilation

    IterConfig.romFlag                    = [0 1 1 1 1];                                                 % Create a new ROM?
    IterConfig.obsFlag                    = [1 1 1 1 1];


%-> WHAT TO RUN    
    IterConfig.bgrunflag                  =  [0 1 1 1 1];                             % Background run?
    IterConfig.snapsrunflag               =  [0 1 1 1 1];                             % Snapshots run?
    IterConfig.sensrunflag                =  [0 1 1 1 1];                             % Sensitivity run?
    IterConfig.gatrunflag                 =  [0 1 1 1 1];                             % Gateaux run? If 'solve4forward/central' selected, this option is not checked.
    
    
%-> WHAT TO LOAD
    IterConfig.bgloadinfoflag             =  [0 1 1 1 1];                             % Read info from map-files? or are they already as a .mat file
    IterConfig.snapsloadinfoflag          =  [0 1 1 1 1];                             % Read info from map-files? or are they already as a .mat file
    IterConfig.sensitivities_loadinfoflag =  [0 1 1 1 1];                             % Two times false, means it will look for the mat file
    IterConfig.gatloadinfoflag            =  [0 1 1 1 1];                             % Two times false, means it will look for the mat file. Must be TRUE if solve4forward.
    
    
%-> SOME SPECIAL SETTINGS
    IterConfig.bgautomaticselect          =  [0 0 0 0 0];

    IterConfig.sensitivities_param_start  =  [1 1 1 1 1];     % In case a previous run crashed, you'll probably need to start
    IterConfig.sensitivities_step_start   =  [1 1 1 1 1];     % from the middle of the estimations
    IterConfig.gateaux_pattern_start      =  [1 1 1 1 1];
    IterConfig.gateaux_step_start         =  [1 1 1 1 1];


%-> SOME SPECIAL SETTINGS
    options.snapshotsRuns = 'rnd_simultaneous'; %'onebyone'; %'rnd_simultaneous';               % Four estimations possible: 'oneByOne' or 'rnd_simultaneous' or 'ctrl_simultaneous' or 'spsa'
    options.spsaiterations = 1;   
    
    options.patterns.calculate = 1;                                        % Estimate the SVD and get patterns? If false, it reads [modelbg.mainpath(1:end-11),'patterns.mat']
    options.patterns.type      = 'number';                                 % Can be ENERGY or NUMBER
    options.patterns.criterion = 40;                                       % Either PERCENTAGE of energy or NUMBER of patterns (respectively with types explained in the previous lines)
        
    options.gateaux.type = 'solve';                                        % Two estimations possible: 'central' or 'forward' or 'solve'
    options.gateaux.solver_num_iterations = 100;                           % Only valid for 'solve'
    options.gateaux.epsilon = 0.1;                                         % If 'solve' selected, this option is not checked.
    options.gateaux.numNodes = 80;                                         % If 'solve' selected, this option is not checked.
    
    options.sensitivities.type = 'central';                                % Four estimations possible: 'central', 'forward', 'solve4forward' or 'solve4central'
    options.sensitivities.perturbation = 1;                                % Delta = parameter_significant_figure*sensitivity_perturbation;
    options.sensitivities.numNodes =  options.gateaux.numNodes;
    
    options.getrunsinfo.depthreshold = 0.01;                               % Depth threshold for reading from mapfile, nothing to-do with Delft3D. For getrunsinfo script.
    options.getrunsinfo.time = 'mor';                                      % could also be 'flow'... but if morphological scaling, then should be mor
    options.getrunsinfo.bordermarginN = 1;
    options.getrunsinfo.bordermarginS = 1;
    options.getrunsinfo.bordermarginE = 1;
    options.getrunsinfo.bordermarginW = 1;
    
    options.observations.path = [pwd,filesep,'the_observations',filesep];
    options.observations.domain = 'fulldomain';                            % 'stations' or 'fulldomain'... this is no longer functional
    
    
    
%-> ERRORTYPE: 'relative' or 'fixed'
    % If 'fix' specify magnitude of standard deviation, 2*sigma contains 95% of normal mass
    % If 'relative' standard deviation = error.*observation 
    options.observations.errortype = 'fix';
    options.observations.error = 0;
    
    
    
%-> CONFIGURE THE SNAPSHOTS
    if strcmpi(options.snapshotsRuns,'onebyone');
                    test.deviations = [0.5];                                   % Of the standard deviations!
                    test.numSnapshotsRuns = length(test.deviations)*elrom.numParam;
    elseif strcmpi(options.snapshotsRuns,'ctrl_simultaneous');
                    test.deviations = [1 -1 1; 1 1 -1; 1 -1 -1].*repmat([0.3 0.3 0.5],elrom.numParam,1);
                    test.numSnapshotsRuns = size(test.deviations,2);
    elseif strcmpi(options.snapshotsRuns,'rnd_simultaneous');
                    test.numSnapshotsRuns = 50; %elrom.numParam;                    %At least we should expand the parameter space!!
                    disp(['Number of perturbed runs for snapshot generation: ', num2str(test.numSnapshotsRuns)])
                    
                    %test.deviations = roundto((0.1*rand(elrom.numParam,test.numSnapshotsRuns)+0.05),6).*sign(2*rand(elrom.numParam,test.numSnapshotsRuns)-1);
                    test.deviations = roundto((0.1*rand(elrom.numParam,test.numSnapshotsRuns)+0.05),6); % TODAS POSITIVAS
                                        
                    % Remember, Perturbation Size = test.deviations * param.std
    elseif strcmpi(options.snapshotsRuns,'spsa')
                    test.deviations = [];
                    test.numSnapshotsRuns = 2*options.spsaiterations;
    else   disp('Snapshots run type not known'); 
    end
function [varargout] = params_def(varargin)
    
    if nargin ~= 1, error('Incorrect number of arguments'); end
        
    bgm = varargin{1}; 
        
    elID = 1;
    rom.Params(elID).name = 'Roughness coefficient U direction';
    rom.Params(elID).filext = 'mdf';
    rom.Params(elID).acronym = 'Ccofu';
    rom.Params(elID).bgValue = 30;
    rom.Params(elID).minValue = 5;
    rom.Params(elID).maxValue = 80;
    rom.Params(elID).std = 7;                   %  In snapshots run, Delta = params(iParam).std*deviations(iDev);
    rom.Params(elID).significant_figure = 1;   % In sensitivity estimation,  Delta = parameter_significant_figure * options.sensitivity.perturbation;
    rom.Params(elID).enforce_sigFig_in_value = false;
    rom.initialGuess.matCov(elID,elID) = rom.Params(elID).std^2; %Or fill in your own
    
    elID = 2;    
    rom.Params(elID).name = 'Roughness coefficient V direction';
    rom.Params(elID).filext = 'mdf';
    rom.Params(elID).acronym = 'Ccofv';
    rom.Params(elID).bgValue = 30;
    rom.Params(elID).minValue = 5;
    rom.Params(elID).maxValue = 80;
    rom.Params(elID).std = 7;                   %  In snapshots run, Delta = params(iParam).std*deviations(iDev);
    rom.Params(elID).significant_figure = 1;   % In sensitivity estimation,  Delta = parameter_significant_figure * options.sensitivity.perturbation;
    rom.Params(elID).enforce_sigFig_in_value = false;
    rom.initialGuess.matCov(elID,elID) = rom.Params(elID).std^2; %Or fill in your own
    
    elID = 3;   
    rom.Params(elID).name = 'Horizontal eddy viscosity'; %Momentum
    rom.Params(elID).filext = 'mdf';
    rom.Params(elID).acronym = 'Vicouv';
    rom.Params(elID).bgValue = 0.01;
    rom.Params(elID).minValue = 0.001;
    rom.Params(elID).maxValue = 10;
    rom.Params(elID).std = 0.04;                   %  In snapshots run, Delta = params(iParam).std*deviations(iDev);
    rom.Params(elID).significant_figure = 0.001;   % In sensitivity estimation,  Delta = parameter_significant_figure * options.sensitivity.perturbation;
    rom.Params(elID).enforce_sigFig_in_value = false;
    rom.initialGuess.matCov(elID,elID) = rom.Params(elID).std^2; %Or fill in your own
    
    elID = 4;   
    rom.Params(elID).name = 'Horizontal eddy diffusivity'; %Sediments
    rom.Params(elID).filext = 'mdf';
    rom.Params(elID).acronym = 'Dicouv';
    rom.Params(elID).bgValue = 0.01;
    rom.Params(elID).minValue = 0.001;
    rom.Params(elID).maxValue = 10;
    rom.Params(elID).std = 0.04;                   %  In snapshots run, Delta = params(iParam).std*deviations(iDev);
    rom.Params(elID).significant_figure = 0.001;   % In sensitivity estimation,  Delta = parameter_significant_figure * options.sensitivity.perturbation;
    rom.Params(elID).enforce_sigFig_in_value = false;
    rom.initialGuess.matCov(elID,elID) = rom.Params(elID).std^2; %Or fill in your own

    elID = 5;       
    rom.Params(elID).name = 'Threshold depth drying and flooding';
    rom.Params(elID).filext = 'mdf';
    rom.Params(elID).acronym = 'Dryflc';
    rom.Params(elID).bgValue = 0.05;
    rom.Params(elID).minValue = 0.001;
    rom.Params(elID).maxValue = 0.07;
    rom.Params(elID).std = 0.01;                   %  In snapshots run, Delta = params(iParam).std*deviations(iDev);
    rom.Params(elID).significant_figure = 0.001;   % In sensitivity estimation,  Delta = parameter_significant_figure * options.sensitivity.perturbation;
    rom.Params(elID).enforce_sigFig_in_value = false;
    rom.initialGuess.matCov(elID,elID) = rom.Params(elID).std^2; %Or fill in your own

    elID = 6;   
    rom.Params(elID).name = 'Frequency of Wave Updates [min]';
    rom.Params(elID).filext = 'mdw';
    rom.Params(elID).acronym = 'COMWriteInterval';
    rom.Params(elID).bgValue = 20; %min
    rom.Params(elID).minValue = 5;
    rom.Params(elID).maxValue = 120;
    rom.Params(elID).std = 10;                   %  In snapshots run, Delta = params(iParam).std*deviations(iDev);
    rom.Params(elID).significant_figure = 1;     % In sensitivity estimation,  Delta = parameter_significant_figure * options.sensitivity.perturbation;
    rom.Params(elID).enforce_sigFig_in_value = true;
    rom.initialGuess.matCov(elID,elID) = rom.Params(elID).std^2; %Or fill in your own
    
    elID = 7;
    rom.Params(elID).name = 'Wave significant height';
    rom.Params(elID).filext = 'mdw';
    rom.Params(elID).acronym = 'WaveHeight';
    rom.Params(elID).bgValue = 0.15; %Meters
    rom.Params(elID).minValue = 0.09;
    rom.Params(elID).maxValue = 0.21;
    rom.Params(elID).std = 0.02;                   %  In snapshots run, Delta = params(iParam).std*deviations(iDev);
    rom.Params(elID).significant_figure = 0.01;   % In sensitivity estimation,  Delta = parameter_significant_figure * options.sensitivity.perturbation;
    rom.Params(elID).enforce_sigFig_in_value = false;
    rom.initialGuess.matCov(elID,elID) = rom.Params(elID).std^2; %Or fill in your own
 
    elID = 8;
    rom.Params(elID).name = 'Wave peak period';
    rom.Params(elID).filext = 'mdw';
    rom.Params(elID).acronym = 'Period';
    rom.Params(elID).bgValue = 3.5;  %Seconds
    rom.Params(elID).minValue = 2.8;
    rom.Params(elID).maxValue = 4.2;
    rom.Params(elID).std = 0.1;                   %  In snapshots run, Delta = params(iParam).std*deviations(iDev);
    rom.Params(elID).significant_figure = 0.01;   % In sensitivity estimation,  Delta = parameter_significant_figure * options.sensitivity.perturbation;
    rom.Params(elID).enforce_sigFig_in_value = false;
    rom.initialGuess.matCov(elID,elID) = rom.Params(elID).std^2; %Or fill in your own
 
    elID = 9;
    rom.Params(elID).name = 'Wave Direction';
    rom.Params(elID).filext = 'mdw';
    rom.Params(elID).acronym = 'Direction';
    rom.Params(elID).bgValue = 0.0;  %Degrees
    rom.Params(elID).minValue = -30;
    rom.Params(elID).maxValue = 30;
    rom.Params(elID).std = 5;
    rom.Params(elID).significant_figure = 0.1;   % In sensitivity estimation,  Delta = parameter_significant_figure * options.sensitivity.perturbation;
    rom.Params(elID).enforce_sigFig_in_value = false;
    rom.initialGuess.matCov(elID,elID) = rom.Params(elID).std^2; %Or fill in your own
 
    elID = 10;
    rom.Params(elID).name = 'Wave directional spreading';
    rom.Params(elID).filext = 'mdw';
    rom.Params(elID).acronym = 'DirSpreading';
    rom.Params(elID).bgValue = 5.0; %Degrees
    rom.Params(elID).minValue = 0;
    rom.Params(elID).maxValue = 10;
    rom.Params(elID).std = 1.0;                   %  In snapshots run, Delta = params(iParam).std*deviations(iDev);
    rom.Params(elID).significant_figure = 0.1;   % In sensitivity estimation,  Delta = parameter_significant_figure * options.sensitivity.perturbation;
    rom.Params(elID).enforce_sigFig_in_value = false;
    rom.initialGuess.matCov(elID,elID) = rom.Params(elID).std^2; %Or fill in your own
 
    elID = 11;
    rom.Params(elID).name = 'Adjacent cell erosion';
    rom.Params(elID).filext = 'mor';    
    rom.Params(elID).acronym = 'ThetSD';
    rom.Params(elID).bgValue = 0.6; % Between 0 and 1
    rom.Params(elID).minValue = 0;
    rom.Params(elID).maxValue = 1;
    rom.Params(elID).std = 0.1;                   %  In snapshots run, Delta = params(iParam).std*deviations(iDev);
    rom.Params(elID).significant_figure = 0.01;   % In sensitivity estimation,  Delta = parameter_significant_figure * options.sensitivity.perturbation;
    rom.Params(elID).enforce_sigFig_in_value = false;
    rom.initialGuess.matCov(elID,elID) = rom.Params(elID).std^2; %Or fill in your own
 
    elID = 12;
    rom.Params(elID).name = 'Wave-related suspended sed. trans. factor';
    rom.Params(elID).filext = 'mor';
    rom.Params(elID).acronym = 'SusW';
    rom.Params(elID).bgValue = 0.1; % Between 0 and 1
    rom.Params(elID).minValue = 0;
    rom.Params(elID).maxValue = 1;
    rom.Params(elID).std = 0.1;                   %  In snapshots run, Delta = params(iParam).std*deviations(iDev);
    rom.Params(elID).significant_figure = 0.01;   % In sensitivity estimation,  Delta = parameter_significant_figure * options.sensitivity.perturbation;
    rom.Params(elID).enforce_sigFig_in_value = false;
    rom.initialGuess.matCov(elID,elID) = rom.Params(elID).std^2; %Or fill in your own
 
    elID = 13;
    rom.Params(elID).name = 'Wave-related bed-load sed. trans. factor';
    rom.Params(elID).filext = 'mor';
    rom.Params(elID).acronym = 'BedW';
    rom.Params(elID).bgValue = 0.1; % Between 0 and 1
    rom.Params(elID).minValue = 0;
    rom.Params(elID).maxValue = 1;
    rom.Params(elID).std = 0.1;                   %  In snapshots run, Delta = params(iParam).std*deviations(iDev);
    rom.Params(elID).significant_figure = 0.01;   % In sensitivity estimation,  Delta = parameter_significant_figure * options.sensitivity.perturbation;
    rom.Params(elID).enforce_sigFig_in_value = false;
    rom.initialGuess.matCov(elID,elID) = rom.Params(elID).std^2; %Or fill in your own
     
    elID = 14;
    rom.Params(elID).name = 'Factor for suspended sed. reference concentration';
    rom.Params(elID).filext = 'mor';
    rom.Params(elID).acronym = 'Sus';
    rom.Params(elID).bgValue = 0.35;
    rom.Params(elID).minValue = 0;
    rom.Params(elID).maxValue = 1;
    rom.Params(elID).std = 0.12;                   %  In snapshots run, Delta = params(iParam).std*deviations(iDev);
    rom.Params(elID).significant_figure = 0.01;   % In sensitivity estimation,  Delta = parameter_significant_figure * options.sensitivity.perturbation;
    rom.Params(elID).enforce_sigFig_in_value = false;
    rom.initialGuess.matCov(elID,elID) = rom.Params(elID).std^2; %Or fill in your own
     
    elID = 15;
    rom.Params(elID).name = 'factor for bed-load trans. vector magnitude';
    rom.Params(elID).filext = 'mor';
    rom.Params(elID).acronym = 'Bed';
    rom.Params(elID).bgValue = 0.35;
    rom.Params(elID).minValue = 0;
    rom.Params(elID).maxValue = 1;
    rom.Params(elID).std = 0.12;                   %  In snapshots run, Delta = params(iParam).std*deviations(iDev);
    rom.Params(elID).significant_figure = 0.01;   % In sensitivity estimation,  Delta = parameter_significant_figure * options.sensitivity.perturbation;
    rom.Params(elID).enforce_sigFig_in_value = false;
    rom.initialGuess.matCov(elID,elID) = rom.Params(elID).std^2; %Or fill in your own
 
    elID = 16;
    rom.Params(elID).name = 'van Rijn ref. height = AKSFAC * KS';  %KS := user-defined current-related effective roughness height
    rom.Params(elID).filext = 'mor';
    rom.Params(elID).acronym = 'AksFac';
    rom.Params(elID).bgValue = 0.05;
    rom.Params(elID).minValue = 0;
    rom.Params(elID).maxValue = 0.1;
    rom.Params(elID).std = 0.1;                   %  In snapshots run, Delta = params(iParam).std*deviations(iDev);
    rom.Params(elID).significant_figure = 0.01;   % In sensitivity estimation,  Delta = parameter_significant_figure * options.sensitivity.perturbation;
    rom.Params(elID).enforce_sigFig_in_value = false;
    rom.initialGuess.matCov(elID,elID) = rom.Params(elID).std^2; %Or fill in your own
     
    elID = 17;
    rom.Params(elID).name = 'Wave related roughness = RWAVE * ripple height'; % Ripple height fixed to 0.25
    rom.Params(elID).filext = 'mor';
    rom.Params(elID).acronym = 'RWave';
    rom.Params(elID).bgValue = 2.00;
    rom.Params(elID).minValue = 1;
    rom.Params(elID).maxValue = 3;                   %  In snapshots run, Delta = params(iParam).std*deviations(iDev);
    rom.Params(elID).std = 0.2; %Van Rijn Recommends range 1-3
    rom.Params(elID).significant_figure = 0.01;   % In sensitivity estimation,  Delta = parameter_significant_figure * options.sensitivity.perturbation;
    rom.Params(elID).enforce_sigFig_in_value = false;
    rom.initialGuess.matCov(elID,elID) = rom.Params(elID).std^2; %Or fill in your own
         
    elID = 18;
    rom.Params(elID).name = 'Streamwise bed gradient factor for bed-load trans.';
    rom.Params(elID).filext = 'mor';
    rom.Params(elID).acronym = 'AlfaBs';
    rom.Params(elID).bgValue = 1.0;
    rom.Params(elID).minValue = 0;
    rom.Params(elID).maxValue = 10;
    rom.Params(elID).std = 0.2;                   %  In snapshots run, Delta = params(iParam).std*deviations(iDev);
    rom.Params(elID).significant_figure = 0.01;   % In sensitivity estimation,  Delta = parameter_significant_figure * options.sensitivity.perturbation;
    rom.Params(elID).enforce_sigFig_in_value = false;
    rom.initialGuess.matCov(elID,elID) = rom.Params(elID).std^2; %Or fill in your own
     
    elID = 19;
    rom.Params(elID).name = 'Transverse bed gradient factor for bed-load trans.';
    rom.Params(elID).filext = 'mor';
    rom.Params(elID).acronym = 'AlfaBn';
    rom.Params(elID).bgValue = 1.5;
    rom.Params(elID).minValue = 0;
    rom.Params(elID).maxValue = 10;
    rom.Params(elID).std = 0.2;                   %  In snapshots run, Delta = params(iParam).std*deviations(iDev);
    rom.Params(elID).significant_figure = 0.01;   %  In sensitivity estimation,  Delta = parameter_significant_figure * options.sensitivity.perturbation;
    rom.Params(elID).enforce_sigFig_in_value = false;
    rom.initialGuess.matCov(elID,elID) = rom.Params(elID).std^2; %Or fill in your own
    
    rom.numParam = length(rom.Params);
    for i=1:1:rom.numParam, 
        bgm = setfield(bgm,rom.Params(i).filext,rom.Params(i).acronym,rom.Params(i).bgValue); 
        rom.initialGuess.value(i) = rom.Params(i).bgValue;
    end

    
    
    
%% Non-parameters
% This are not considered parameters in the assimilation but are declared
% to avoid mistakes. 


    rom.romTimeIntervals = 20;

    bgm.mdf.Tlfsmo       = 0;                                          % Smoothing time. From what i have heard: Never ever, ever, ever... f*!#ing ever say more than zero here!
    bgm.mdf.waveOL       = '#Y#';                                      % Waves Online?
    bgm.mdf.Dpsopt       = '#DP#';                                     % How the water depth is read at water level points
    bgm.mdf.roller       = '#No #';                                    % Never ever, ever, ever... f*!#ing ever say YES here!
    bgm.mdf.cstbnd       = '#Yes#';
    bgm.mdf.Dco          = -999;                                        % Marginal depth, what ever the hell that is...
    bgm.mdf.mapInterval = rom.romTimeIntervals;                       % Frequency of map saves (min)
        
    bgm.mor.coldstartSpinup = 180;                                     % Spin-up interval from TStart till start of morphological changes
    bgm.mor.restartSpinup   = 100;                                     % Spin-up interval for THE RE-STARTING PROCESS
    bgm.mor.MorFac          = 1;                                       % Morphological scale factor.

    bgm.mdw.FlowBedLevel   = 2;
    bgm.mdw.FlowWaterLevel = 2;                                                 
    bgm.mdw.FlowVelocity   = 0;                                               
    bgm.mdw.FlowWind       = 0;
    bgm.mdw.UseHotFile     = 'true';
    bgm.mdw.WriteCOM       = 'true';
    bgm.mdw.MapWriteInterval = 0;
    
    if ~isfield(bgm.mdw,'COMWriteInterval')
        bgmodel(jouterloop).mdw.COMWriteInterval = bgm.mdf.mapInterval;
    end

    varargout{1} = rom; varargout{2} = bgm;
end

%% MDF
% Rettis  := Thatcher-Harleman return time surface
% Rettib  := Thatcher-Harleman return time bottom
% Tempw   := Background water temperature
% Salw    := Background salinity
%
% ROLLER MODEL
% alfaro  :=
% gamdis  :=
% betaro  :=
% Ndis    :=
% F_lam   := Breaker delay parameter in roller model



%% MDW
%    
%    MinimumDepth         =  0.01
%    
%    Breaking       = true
%    BreakAlpha     := alpha coefficient for wave breaking (default: 1.0)
%    BreakGamma     := gamma coefficient for wave breaking (default: 0.73)

%    BedFricCoef    := bed friction coecient (default: 0.067 for jonswap, 0.015 for collins, 0.05 for madsen et al.)
%    PeakEnhanceFac := peak enhancement factor in case of jonswap spectrum
%    GaussSpread    := width of spectral distribution in case of gaussian spectrum

%    DirSpaceCDD          =  0.50
%    FreqSpaceCSS         =  0.50
%    RChHsTm01            =  0.01
%    RChMeanHs            =  0.01
%    RChMeanTm01          =  0.01
%    
%    NDir                 = 45
%    FreqMin              =  0.05
%    FreqMax              =  0.50
%    NFreq                = 12                           
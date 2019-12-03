%                                                                               
%-------------------------------------------------------------------------------
%  $Id: initsed_fluff.m 8409 2013-04-08 07:27:33Z boer_aj $
%  $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/programs/SandMudBedModule/02_Matlab/03_flufflayer_demo/initsed_fluff.m $
%%--description-----------------------------------------------------------------
%
%    Function: Settings of morphological parameters
%
%% executable statements ------------------
%
    % ================================================================================
    %   USER INPUT
    % ================================================================================
    %
    %   Parameters sediment
    %
    eropar      = zeros(morlyr.number_of_fractions,morlyr.number_of_columns)+1.0e-2;	% erosion parameter for mud [kg/m2/s]
    tcrdep      = zeros(morlyr.number_of_fractions,morlyr.number_of_columns)+1000.0;	% critical bed shear stress for mud sedimentation [N/m2]
    tcrero      = zeros(morlyr.number_of_fractions,morlyr.number_of_columns)+1.0;	% critical bed shear stress for mud erosion [N/m2]
    %
    %   Parameters fluff layer
    %   
    depeff      = zeros(morlyr.number_of_fractions,morlyr.number_of_columns) + 0.95;	% deposition efficiency [-]
    depfac      = zeros(morlyr.number_of_fractions,morlyr.number_of_columns) + 0.2;	% deposition factor (flufflayer=2) [-]
    tcrfluff    = zeros(morlyr.number_of_fractions,morlyr.number_of_columns) + 0.05;	% critical bed shear stress for fluff layer erosion [N/m2]
    parfluff0   = zeros(morlyr.number_of_fractions,morlyr.number_of_columns) + 2e-4;	% erosion parameter 1 (M0) [kg/m2/s] (keyword ParFluff0 in MOR-file)                          
    parfluff1   = zeros(morlyr.number_of_fractions,morlyr.number_of_columns) + 0.1;	% erosion parameter 2 (M1) [1/s] (keyword ParFluff1 in MOR-file)    
    if (morlyr.flufflayer_model_type==1) 
        bf1   = zeros(morlyr.number_of_fractions,morlyr.number_of_columns) + 0;  	% burial coefficient 1 (M0) [kg/m2/s] (keyword BurFluff0 in MOR-file, only if Flufflyr=1)                          
        bf2   = zeros(morlyr.number_of_fractions,morlyr.number_of_columns) + 0;   	% burial coefficient 2 (M1) [1/s] (keyword BurFluff1 in MOR-file, only if Flufflyr=1)                          
        morlyr.burial_coeff_1 = bf1;
        morlyr.burial_coeff_2 = bf2;
    end    %
    %   Parameters sand-mud interaction
    %
    betam       =  3.0;       								% power factor for adaptation of critical bottom shear stress [-]
    pmcrit      = zeros(morlyr.number_of_fractions,morlyr.number_of_columns)-1;       	% critical mud fraction [-]
    %
    %   Parameters sediment transport formulation
    %
    alf1        = 2.0;		% calibration coefficient [-]
    rksc        = 0.1;		% reference level [m]
    %
    % ================================================================================
    
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Create simulations variation from file input. 

%% PREAMBLE

% dbclear all;
clear
clc
fclose all;

%% PATHS

fpath_add_oet='c:\checkouts\oet_matlab\applications\vtools\general\addOET.m';
fdir_d3d='c:\checkouts\qp\';

% fpath_add_fcn='p:\dflowfm\projects\2020_d-morphology\modellen\checkout\openearthtools_matlab\applications\vtools\general\';
% fdir_d3d='p:\dflowfm\projects\2020_d-morphology\modellen\checkout\qp2';

fpath_project='p:\dflowfm\users\chavarri\240625_test_bar_properties\';

%% ADD OET

if isunix %we assume that if Linux we are in the p-drive. 
    fpath_add_oet=strrep(strrep(strcat('/',strrep(fpath_add_oet,'P:','p:')),':',''),'\','/');
end
run(fpath_add_oet);

%% PATHS

fpaths=paths_project(fpath_project);

%% INPUT

fdir_sims=fpaths.fdir_sim_runs; %path to folder where to create simulations
fdir_refmdf=''; %relative path of input with respect to mdf-file

flg.only_run_script=0; 
flg.overwrite=1; %0: do not overwrite; 1=overwrite; 2=overwrite only if it does not exist

fcn_input_D3D=@(X)input_D3D(X); %function to create default input
fcn_adapt=@(X,Y)adapt_input_01(X,Y); %function to adapt the default input. From a `simdef` and `input_m_s`, adapt `simdef`
fcn_variation=@(X)matrix_variation_01(X); %function to create the variation

%% CALC

input_m=D3D_input_variation(fdir_sims,'',fdir_refmdf,fcn_variation);
D3D_create_simulation_all(flg,input_m,fcn_adapt,fcn_input_D3D)













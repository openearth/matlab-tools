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

fpath_add_fcn='c:\Users\chavarri\checkouts\openearthtools_matlab\applications\vtools\general\';
% fpath_add_fcn='p:\dflowfm\projects\2020_d-morphology\modellen\checkout\openearthtools_matlab\applications\vtools\general\';

% fpath_project='d:\temporal\220517_improve_exner\';
fpath_project='p:\i1000561-riverlab-2021\08_bars_chaos\';

%% ADD OET

if isunix
    fpath_add_fcn=strrep(strrep(strcat('/',strrep(fpath_add_fcn,'P:','p:')),':',''),'\','/');
end
addpath(fpath_add_fcn)
addOET(fpath_add_fcn) 

%% PATHS

fpaths=paths_project(fpath_project);

%% INPUT

% fdir_input_folder_refmdf='../../01_input';

flg.only_run_script=0;
flg.overwrite=1;

input_m=input_variation_01('',''); %!!! CHANGE copying from `main_create_simulations_variation_from_existing_layout.m`
fcn_adapt=@(X)adapt_input_01(X);

%% CALC

fdir_sim_runs=fpaths.fdir_sim_runs;
D3D_create_simulation_all(flg,input_m,fdir_sim_runs,fcn_adapt)
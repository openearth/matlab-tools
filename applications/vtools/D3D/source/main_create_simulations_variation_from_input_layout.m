%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 45 $
%$Date: 2022-05-05 11:24:21 +0200 (Thu, 05 May 2022) $
%$Author: chavarri $
%$Id: main_plot.m 45 2022-05-05 09:24:21Z chavarri $
%$HeadURL: file:///P:/11208075-002-ijsselmeer/07_scripts/svn/main_plot.m $
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

input_m=input_variation_01('','');
fcn_adapt=@(X)adapt_input_01(X);

%% CALC

fdir_sim_runs=fpaths.fdir_sim_runs;
D3D_create_simulation_all(flg,input_m,fdir_sim_runs,fcn_adapt)
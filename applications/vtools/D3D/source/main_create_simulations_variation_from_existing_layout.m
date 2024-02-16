%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%creates a set of simulations based on a reference one 
%and the variations set in a structure

%% PREAMBLE

clear
clc
fclose all;

%% PATHS

fpath_add_fcn='c:\checkouts\oet_matlab\applications\vtools\general\';
% fpath_add_fcn='p:\dflowfm\projects\2020_d-morphology\modellen\checkout\openearthtools_matlab\applications\vtools\general\';

% fpath_project='d:\temporal\220517_improve_exner\';
fpath_project='p:\11209261-004-groynes\';

%% ADD OET

if isunix
    fpath_add_fcn=strrep(strrep(strcat('/',strrep(fpath_add_fcn,'P:','p:')),':',''),'\','/');
end
addpath(fpath_add_fcn)
addOET(fpath_add_fcn) 

%% INPUT

    %% paths
path_folder_sims='p:\11209261-004-groynes\06_simulations\04_runs_03\02_runs\';
path_input_folder='p:\11209261-004-groynes\06_simulations\04_runs_03\01_input\';
path_input_folder_refmdf='../../01_input';

    %% sims
path_ref=fullfile(path_folder_sims,sprintf('r%03d',0));
fcn_adapt=@(X)matrix_variation_01(X);

%% CALL

input_m=D3D_input_variation(path_folder_sims,path_input_folder,path_input_folder_refmdf,fcn_adapt);
D3D_create_variation_simulations(path_ref,input_m);

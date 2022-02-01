%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%

%% PREAMBLE

clear
clc
fclose all;

%% ADD OET

path_add_fcn='c:\Users\chavarri\checkouts\openearthtools_matlab\applications\vtools\general\';
addpath(path_add_fcn)
addOET(path_add_fcn) 

    %% input to function

% path_input='input_ECT_2D.m';
path_input='c:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\00_codes\210825_grid_sensitivity\input_ECT_bars.m';

%% CALL

run(path_input);
in_2D.flg=ECT_input.flg;
[ECT_matrices,sed_trans]=call_ECT(ECT_input);
% sed_trans.qbk.*(1-(2650-1590)/2650)
in_2D.lims_lw=[1,100];
[eig_r,eig_i,kwx_v,kwy_v]=twoD_study(ECT_matrices,in_2D);
fig_twoD(in_2D,eig_r,eig_i,kwx_v,kwy_v)

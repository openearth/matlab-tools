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
addOET(path_add_fcn) %1=c-drive; 2=p-drive

    %% input to function

path_input="c:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\00_codes\210305_parallel_sequential\input_ECT_2D_bars.m";

%% CALL

run(path_input);
in_2D.flg=ECT_input.flg;
[ECT_matrices,sed_trans]=call_ECT(ECT_input);
[eig_r,eig_i,kwx_v,kwy_v]=twoD_study(ECT_matrices,in_2D);
fig_twoD(in_2D,eig_r,eig_i,kwx_v,kwy_v)



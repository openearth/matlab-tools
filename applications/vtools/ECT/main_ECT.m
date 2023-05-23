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

path_input='input_ECT_eh.m';
% path_input='c:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\00_codes\220517_improve_exner\input_ECT_2D.m';

in_2D.fig.fig_print=0;
in_2D.fig.fig_name='c:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\00_codes\220517_improve_exner\domain';

%% CALL

run(path_input);
in_2D.flg=ECT_input.flg;
[ECT_matrices,sed_trans]=call_ECT(ECT_input);
% sed_trans.qbk.*(1-(2650-1590)/2650)
in_2D.lims_lw=[0.01,100];
[eig_r,eig_i,kwx_v,kwy_v]=twoD_study(ECT_matrices,in_2D);
fig_twoD(in_2D,eig_r,eig_i,kwx_v,kwy_v)

%% CFL
% [c_anl,eig_i_morpho]=ECT_celerity_growth(ECT_matrices,'kwx',2*pi/100);
% c_app=max((sed_trans.Qbk(1:end-1).*(1-ECT_input.Fi1)+ECT_input.Fi1.*sed_trans.Qbk(end))/ECT_input.La);
% max_dt=1*ECT_input.dx/c_anl;
% max_dt_app=1*ECT_input.dx/c_app;
% fprintf('max dt        = %4.2f s \n',max_dt);
% fprintf('max dt aprox. = %4.2f s \n',max_dt_app);




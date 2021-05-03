%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 7 $
%$Date: 2021-04-16 23:44:32 +0200 (Fri, 16 Apr 2021) $
%$Author: chavarri $
%$Id: main_create_RL_polylines.m 7 2021-04-16 21:44:32Z chavarri $
%$HeadURL: file:///P:/11206792-kpp-rivierkunde-2021/003_maas/09_scrips/svn/main_create_RL_polylines.m $
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

path_input='input_ECT_2D.m';

in_2D.kwx_v=2*pi/0.001;
in_2D.np=1;
in_2D.pert_anl=1; %0=NO; 1=full; 2=no friction; 3=no friction & no diffusion; 
in_2D.qs_anl=0; %0=NO; 1=YES;

%% CALL

run(path_input);
in_2D.flg=ECT_input.flg;
[ECT_matrices,sed_trans]=call_ECT(ECT_input);
[eig_r,eig_i,kwx_v,kwy_v]=twoD_study(ECT_matrices,in_2D);




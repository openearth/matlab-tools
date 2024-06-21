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

%% PATHS

fpath_add_oet='c:\checkouts\oet_matlab\applications\vtools\general\addOET.m';
fdir_d3d='c:\checkouts\qp\';

% fpath_add_oet='p:\dflowfm\projects\2020_d-morphology\modellen\checkout\openearthtools_matlab\applications\vtools\general\addOET.m';
% fdir_d3d='p:\dflowfm\projects\2020_d-morphology\modellen\checkout\qp2';

% fpath_project='d:\temporal\220517_improve_exner\';
fpath_project='p:\dflowfm\users\chavarri\231005_redolfi\';

%% ADD OET

if isunix %we assume that if Linux we are in the p-drive. 
    fpath_add_oet=strrep(strrep(strcat('/',strrep(fpath_add_oet,'P:','p:')),':',''),'\','/');
end
run(fpath_add_oet);

    %% input to function

% path_input='input_ECT_2D.m';
path_input='c:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\00_codes\231015_redolfi\input_ECT_Run3.m';

in_2D.fig.fig_print=0;
in_2D.fig.fig_name='c:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\00_codes\240619_ect\domain';

%% CALL

run(path_input);
in_2D.flg=ECT_input.flg;
[ECT_matrices,sed_trans]=call_ECT(ECT_input);

fprintf('Fr = %4.2f \n',ECT_input.u/sqrt(9.81*ECT_input.h));
fprintf('dk = %4.2f \n',ECT_input.gsd(1));
fprintf('theta = %4.2f \n',sed_trans.thetak(1));

%%
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





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
path_input='c:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\00_codes\240625_test_bar_properties\input_ECT_2D.m';

in_2D.fig.fig_print=0;
in_2D.fig.fig_name='c:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\00_codes\240625_test_bar_properties\domain_1';

in_2D_nondim.fig_print=0;
in_2D_nondim.fig_name='c:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\00_codes\240625_test_bar_properties\domain_2';

in_2D.pert_anl=1; 

%% CALL

%run a script with ECT input
run(path_input);

%run a function wtih D3D input (preferred)
simdef=input_D3D_01;
ECT_input=D3D_input_2_ECT_input(simdef);


in_2D.flg=ECT_input.flg;

[ECT_matrices,sed_trans]=call_ECT(ECT_input);

fprintf('Fr = %4.2f \n',ECT_input.u/sqrt(9.81*ECT_input.h));
fprintf('dk = %4.2f \n',ECT_input.gsd(1));
fprintf('theta = %4.2f \n',sed_trans.thetak(1));

%%
% sed_trans.qbk.*(1-(2650-1590)/2650)
in_2D.lims_lwy=[1,100];
in_2D.lims_lwx=[10,10000];

[eig_r,eig_i,kwx_v,kwy_v,kw_m]=twoD_study(ECT_matrices,in_2D);
[kw_p,kwx_p,kwy_p,kwx_m,kwy_m,lwx_v,lwy_v,lwx_p,lwy_p,lwx_m,lwy_m,lambda_p,beta_p,tri,max_gr_p,max_gr_m,eig_r_p,c_morph_p,c_morph_m]=derived_variables_twoD_study(ECT_input.h,eig_r,eig_i,kwx_v,kwy_v,kw_m);
fig_twoD_2(in_2D,c_morph_m,max_gr_m,kwx_m,kwy_m,lwx_m,lwy_m); %new
in_2D_nondim.xlims=[0,3.5];
fig_twoD_nondim(in_2D_nondim,tri,lambda_p,beta_p,max_gr_p,c_morph_p);

%%

figure
hold on
scatter3(lwx_p,lwy_p,c_morph_p,10,c_morph_p)
colorbar
clim([-1e-5,1e-5])

%% CFL
% [c_anl,eig_i_morpho]=ECT_celerity_growth(ECT_matrices,'kwx',2*pi/100);
% c_app=max((sed_trans.Qbk(1:end-1).*(1-ECT_input.Fi1)+ECT_input.Fi1.*sed_trans.Qbk(end))/ECT_input.La);
% max_dt=1*ECT_input.dx/c_anl;
% max_dt_app=1*ECT_input.dx/c_app;
% fprintf('max dt        = %4.2f s \n',max_dt);
% fprintf('max dt aprox. = %4.2f s \n',max_dt_app);

% %% plot section eigenvalues 
% 
% idx=15;
% 
% bol_lw=lw_m(:,2)==lwy_v(idx);
% 
% lwx_get=lw_m(bol_lw,1);
% kwx_get=kw_m(bol_lw,1);
% eig_r_get=eig_r(bol_lw,:);
% eig_i_get=eig_i(bol_lw,:);
% 
% %%
% figure
% subaxis(2,1,1)
% hold on
% plot(lwx_get,eig_r_get./kwx_get)
% plot(lwx_get,zeros(size(lwx_get)),'--k')
% ylabel('celerity [m/s]')
% 
% subaxis(2,1,2)
% hold on
% plot(lwx_get,eig_i_get)
% plot(lwx_get,zeros(size(lwx_get)),'--k')
% ylabel('damping [1/s]')

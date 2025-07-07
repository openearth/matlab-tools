%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Description

%% PREAMBLE

% dbclear all;
clear
clc
fclose all;

%% PATHS

%Check out SVN repository:
%https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/
%into a folder (e.g., <dir_checkout>).
%`fpath_add_oet` points to <dir_checkout\applications\vtools\general\addOET.m>
fpath_add_oet='c:\checkouts\oet_matlab\applications\vtools\general\addOET.m';

%The source of QuickPlot is now within the source code of Delft3D.
%Check it out by:
%```
% git init
% git remote add -f origin https://git.deltares.nl/oss/delft3d
% git config core.sparseCheckout true
% git sparse-checkout set src/tools_lgpl/matlab/quickplot/progsrc
%```
%and point here to the folder where it has been checked out.
fdir_d3d='c:\checkouts\sc_fm_trunk\';

% fpath_add_oet='p:\dflowfm\projects\2020_d-morphology\modellen\checkout\openearthtools_matlab\applications\vtools\general\addOET.m';
% fdir_d3d='p:\dflowfm\projects\2020_d-morphology\modellen\checkout\qp2';

% fpath_add_oet='p:\studenten-riv\05_OpenEarthTools\01_matlab\applications\vtools\general\addOET.m';
% fdir_d3d='p:\studenten-riv\05_OpenEarthTools\02_qp\';

%Path to folder with project paths. See `paths_project_layout`.
fpath_project='d:\temporal\220517_improve_exner\';

    %% input to function

%script with ECT
path_input='c:\checkouts\sc_branch\test\deltares_testbench\data\cases\e02_f022_c104_act_layer_diff_reg\input_ECT_2D.m'; 
% path_input=@input_D3D_01;

in_2D.pert_anl=1; 

np=25;
La_v=linspace(1e-3,1,np);
% La_v=0.1;

%% CALL

% cd(fpath_project) %necessary for getting where the D3D function is

%run a script with ECT input
run(path_input);

%run a function with D3D input (preferred)
% simdef.dummy=NaN;
% simdef=path_input(simdef);
% ECT_input=D3D_input_2_ECT_input(simdef);

in_2D.flg=ECT_input.flg;

input_m=allcomb(La_v);

%%
% sed_trans.qbk.*(1-(2650-1590)/2650)
in_2D.kwx_v=2*pi/10;
in_2D.kwy_v=2*pi/10;

%%
np=size(input_m,1);
max_i=NaN(np,1);
for kp=1:np
    ECT_input.La=input_m(kp,1);

    [ECT_matrices,sed_trans]=call_ECT(ECT_input);
    [eig_r,eig_i,kwx_v,kwy_v,kw_m]=twoD_study(ECT_matrices,in_2D);
    max_i(kp)=max(eig_i);
end


%%

figure
hold on
plot(La_v,max_i)
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
fdir_d3d='c:\checkouts\qp\';

% fpath_add_oet='p:\dflowfm\projects\2020_d-morphology\modellen\checkout\openearthtools_matlab\applications\vtools\general\addOET.m';
% fdir_d3d='p:\dflowfm\projects\2020_d-morphology\modellen\checkout\qp2';

% fpath_add_oet='p:\studenten-riv\05_OpenEarthTools\01_matlab\applications\vtools\general\addOET.m';
% fdir_d3d='p:\studenten-riv\05_OpenEarthTools\02_qp\';

%Path to folder with project paths. See `paths_project_layout`.
% fpath_project='d:\temporal\220517_improve_exner\';
fpath_project='p:\dflowfm\users\chavarri\UNST-8388_Pure1D';

%% ADD OET

if isunix %we assume that if Linux we are in the p-drive. 
    fpath_add_oet=strrep(strrep(strcat('/',strrep(fpath_add_oet,'P:','p:')),':',''),'\','/');
end
run(fpath_add_oet);

%% PATHS

fpaths=paths_project(fpath_project);

%% INPUT

fdir_sims=fpaths.fdir_sim_runs; %path to folder where to create simulations
fdir_refmdf=''; %relative path of input with respect to mdf-file

flg.only_run_script=0; 
flg.overwrite=1; %0: do not overwrite; 1=overwrite; 2=overwrite only if it does not exist

fcn_input_D3D=@(X)input_D3D(X); %function to create default input
fcn_adapt=@(X,Y)adapt_input_01(X,Y); %function to adapt the default input. From a `simdef` and `input_m_s`, adapt `simdef`
fcn_variation=@(X)matrix_variation_01(X); %function to create the variation

%% CALC

input_m=D3D_input_variation(fdir_sims,'',fdir_refmdf,fcn_variation);
D3D_create_simulation_all(flg,input_m,fcn_adapt,fcn_input_D3D)













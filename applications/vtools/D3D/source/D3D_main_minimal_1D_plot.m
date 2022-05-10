%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%1D minimal plot

%% PREAMBLE

% dbclear all;
clear
clc
fclose all;

%% PATHS

% fpath_add_fcn='c:\Users\chavarri\checkouts\openearthtools_matlab\applications\vtools\general\';
% fpath_add_fcn='p:\dflowfm\projects\2020_d-morphology\modellen\checkout\openearthtools_matlab\applications\vtools\general\';
fpath_add_fcn='p:\studenten-riv\05_OpenEarthTools\01_matlab\applications\vtools\general\';

%% ADD OET

if isunix
    fpath_add_fcn=strrep(strrep(strcat('/',strrep(fpath_add_fcn,'P:','p:')),':',''),'\','/');
end
addpath(fpath_add_fcn)
addOET(fpath_add_fcn) 

%% INPUT

in_read.branch={'Channel_1D_1'}; %branch
in_read.kt=inf; %output time index
simdef.D3D.dire_sim='p:\studenten-riv\03_Work\220324_Josephien_Lingbeek\01_runs\r043\dflowfm\';
simdef.flg.which_v=2; %see list: open input_D3D_fig_layout

%% do not change

simdef.flg.which_p=3; %plot type 

%% CALL

simdef=D3D_simpath(simdef);
out_read=D3D_read(simdef,in_read);

%% PLOT

figure
plot(out_read.SZ,out_read.z)
ylabel(out_read.zlabel)
xlabel('streamwise coordinate [m]')
title(sprintf('time = %f s',out_read.time_r))


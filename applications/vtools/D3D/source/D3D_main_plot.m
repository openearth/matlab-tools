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

%% INPUT

path_input='c:\Users\chavarri\temporal\220429_ice\03_scripts\input_D3D_fig_ice.m'; 

%% CALL

run(path_input)
out_read=D3D_plot(simdef,in_read,def);


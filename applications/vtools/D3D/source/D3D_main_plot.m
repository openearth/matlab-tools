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
addOET

%% INPUT

path_input='c:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\00_codes\200522_vow20\input_D3D_fig_news.m'; 

%% CALL

run(path_input)
out_read=D3D_plot(simdef,in_read,def);


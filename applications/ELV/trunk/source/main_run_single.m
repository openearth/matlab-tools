%Main calling script to run ELV.

%% PREAMBLE

fclose all;
clear;
close all;
clc;

%Call from the folder where this function is located i.e., <source>.
%Consider either restoring the default paths and exectuting or adding the
%OET tools and cd to the <source> folder.

% restoredefaultpath
% run('c:\Users\chavarri\checkouts\openearthtools_matlab\oetsettings.m')
cd('c:\Users\chavarri\checkouts\openearthtools_matlab\applications\ELV\trunk\source\') 

%% INPUT 

runid_serie='Q';
runid_number='022';
input_filename='input_ELV_Q022.m';
% input_filename='input_ELV.m';
paths_runs='C:\Users\chavarri\temporal\ELV\';
erase_previous=1; %it is dangerous, use with care and attention
do_profile=0; %0=NO; 1=YES
do_postprocessing=0; %0=NO; 1=YES
debug_mode=1; %0=NO; 1=YES

%% DEBUG COMMANDS

% dbstop in d:\victorchavarri\SURFdrive\projects\00_codes\ELV\branch_V\main\particle_activity_update.m if (any(any(isnan(Gammak)==1)) && kt~=1)

%% Please run!

oh_ELV_please_run
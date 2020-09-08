%run in the folder where the script is

%% PREAMBLE

fclose all;
clear;
close all;
clc;
restoredefaultpath
% dbstop in d:\victorchavarri\SURFdrive\projects\00_codes\ELV\branch_V\main\particle_activity_update.m if (any(any(isnan(Gammak)==1)) && kt~=1)

%% INPUT 

runid_serie='P';
runid_number='005';
input_filename='input_ELV_P005';
paths_runs='C:\Users\chavarri\temporal\ELV\';
erase_previous=1; %it is dangerous, use with care and attention
do_profile=0; %0=NO; 1=YES
do_postprocessing=0; %0=NO; 1=YES
debug_mode=1; %0=NO; 1=YES

%% Please run!

oh_ELV_please_run
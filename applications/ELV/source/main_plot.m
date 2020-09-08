

%% PREAMBLE

% open d:\victorchavarri\SURFdrive\projects\00_codes\ELV\branch_V\source\input_fig_input.m 
% close all
% clear all %if changes outside matlab
% cd d:\victorchavarri\SURFdrive\projects\00_codes\ELV\branch_V\source\
% cd("C:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\00_codes\ELV\branch_V\source\")
cd('C:\Users\chavarri\checkouts\ELV\source\')

%% INPUT

% dire_in='c:\Users\victorchavarri\temporal\ELV\D\025\';
% dire_in='c:\Users\victorchavarri\temporal\ELV\J\247\';
% dire_in='c:\Users\victorchavarri\temporal\ELV\K\053\';
% dire_in='c:\Users\victorchavarri\temporal\ELV\L\028\';
% dire_in='c:\Users\victorchavarri\temporal\ELV\M\011\';
% dire_in='c:\Users\victorchavarri\temporal\ELV\N\031\';
% dire_in='c:\Users\victorchavarri\temporal\ELV\O\026\';
% dire_in='c:\Users\victorchavarri\temporal\ELV\test\006\';
% dire_in='c:\Users\victorchavarri\temporal\ELV\trial\004\';

% dire_in='d:\victorchavarri\storage\02_runs\ELV\D\026\';
% dire_in='d:\victorchavarri\storage\02_runs\ELV\H\083\';
% dire_in='d:\victorchavarri\storage\02_runs\ELV\J\120\';
% dire_in='d:\victorchavarri\storage\02_runs\ELV\K\056\';
% dire_in='d:\victorchavarri\storage\02_runs\ELV\L\028\';
% dire_in='d:\victorchavarri\storage\02_runs\ELV\N\022\';
% dire_in='d:\victorchavarri\storage\02_runs\ELV\J\094\';

% dire_in='d:\victorchavarri\SURFdrive\projects\02_runs\ELV\J\094\';
% dire_in='d:\victorchavarri\SURFdrive\projects\02_runs\ELV\H\069\';

% dire_in='c:\Users\victorchavarri\Downloads\';

% dire_in='o:\BC2\';
% dire_in='p:\BC\';

dire_in='C:\Users\chavarri\temporal\ELV\P\003\';

%% PATHS

addpath('..\auxiliary\')
addpath('..\postprocessing\')
addpath('..\main\')

%% RUN INPUT

% run('input_fig_input.m')
run('input_fig_input_P.m')

%% patch
fig_patch(dire_in,fig_input)    
%% level
fig_level(dire_in,fig_input)    
%% x-cnt
fig_x_cnt(dire_in,fig_input)
%% t-cnt
fig_t_cnt(dire_in,fig_input)
%% x-t-var
fig_xt(dire_in,fig_input)    
%% time_loop
fig_time_loop(dire_in,fig_input)
%% x-cnt (pmm)
fig_x_cnt_pmm(dire_in,fig_input)    

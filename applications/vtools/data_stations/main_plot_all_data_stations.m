%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
addOET(path_add_fcn) %1=c-drive; 2=p-drive

%% INPUT

paths_main_folder='C:\Users\chavarri\checkouts\riv\data_stations\';

%% PATHS

paths=paths_data_stations(paths_main_folder);

%% CALC

load(paths.data_stations_index);

%% PLOT

ns=numel(data_stations_index);
for ks=1:ns
% for ks=70:ns
    load(fullfile(paths.separate,sprintf('%06d.mat',ks)),'data_one_station');
    
    in_p.fname=fullfile(paths.figures,sprintf('%06d',ks));
    in_p.data_station=data_one_station;
    in_p.fig_print=1;
    in_p.fig_visible=0;
    
    fig_data_station(in_p)

    fprintf('done %4.2f %% \n',ks/ns*100)
end %ks
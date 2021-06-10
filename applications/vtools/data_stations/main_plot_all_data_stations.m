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
    load(fullfile(paths.separate,sprintf('%06d.mat',ks)),'data_one_station');
    figure('visible',0)
    plot(data_one_station.time,data_one_station.waarde)
    title(data_one_station.location_clear);
    ylabel(sprintf('%s [%s]',data_one_station.grootheid,data_one_station.eenheid))
    print(gcf,fullfile(paths.figures,sprintf('%06d.png',ks)),'-dpng','-r300')
    fprintf('done %4.2f %% \n',ks/ns*100)
end %ks
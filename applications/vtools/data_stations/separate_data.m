%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17162 $
%$Date: 2021-04-08 11:02:29 +0200 (Thu, 08 Apr 2021) $
%$Author: chavarri $
%$Id: figure_layout.m 17162 2021-04-08 09:02:29Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/figure_layout.m $
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

paths.main_folder='c:\Users\chavarri\temporal\data_stations';

%% PATHS

paths=paths_data_stations(paths);

%% CALC

load(paths.data_stations,'data_stations');

%%

ns=numel(data_stations);
data_stations_index=data_stations;
for ks=1:ns
    data_stations_index(ks).time=[];
    data_stations_index(ks).waarde=[];
    data_one_station=data_stations(ks);
    fname=fullfile(paths.separate,sprintf('%06d.mat',ks));
    save(fname,'data_one_station')
    fprintf('done %4.2f %% \n',ks/ns*100)
end

save(paths.data_stations_index,'data_stations_index')
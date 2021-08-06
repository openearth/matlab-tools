%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 14 $
%$Date: 2021-08-04 13:25:20 +0200 (Wed, 04 Aug 2021) $
%$Author: chavarri $
%$Id: main_plot_all.m 14 2021-08-04 11:25:20Z chavarri $
%$HeadURL: file:///P:/11206813-007-kpp2021_rmm-3d/E_Software_Scripts/00_svn/rmm_plot/main_plot_all.m $
%

%%

path_data_stations='C:\Users\chavarri\checkouts\riv\data_stations\';
path_ds_idx=fullfile(path_data_stations,'data_stations_index.mat');
load(path_ds_idx,'data_stations_index');

idx_mod=82;

%%
path_mod=fullfile(path_data_stations,'separate',sprintf('%06d.mat',idx_mod));

load(path_ds_idx,'data_stations_index');
load(path_mod)

data_one_station.eenheid='m3/s';
data_stations_index(idx_mod).eenheid='m3/s';

save(path_mod,'data_one_station');
save(path_ds_idx,'data_stations_index');

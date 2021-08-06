%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
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

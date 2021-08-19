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

idx_mod=[58,59,60];

%%

ns=numel(idx_mod);
for ks=1:ns
path_mod=fullfile(path_data_stations,'separate',sprintf('%06d.mat',idx_mod(ks)));

load(path_ds_idx,'data_stations_index');
load(path_mod)

data_one_station.location_clear='Spijkenissebrug';
data_stations_index(idx_mod(ks)).location_clear='Spijkenissebrug';

% data_one_station.eenheid='m3/s';
% data_stations_index(idx_mod(ks)).eenheid='m3/s';

% data_one_station.parameter='';
% data_stations_index(idx_mod(ks)).parameter='';

save(path_mod,'data_one_station');
save(path_ds_idx,'data_stations_index');
end
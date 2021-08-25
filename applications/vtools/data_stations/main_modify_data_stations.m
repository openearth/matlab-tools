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

fclose all;
clear
clc

%%

path_data_stations='C:\Users\chavarri\checkouts\riv\data_stations\';
path_ds_idx=fullfile(path_data_stations,'data_stations_index.mat');
load(path_ds_idx,'data_stations_index');

%%

idx_mod=[47];

ks=0;

% ks=ks+1;
% idx_mod(ks)=find_str_in_cell({data_stations_index.location_clear},{'Rood-6'}); 
% bh(ks)=-1.25;

%%

ns=numel(idx_mod);
for ks=1:ns
path_mod=fullfile(path_data_stations,'separate',sprintf('%06d.mat',idx_mod(ks)));

load(path_ds_idx,'data_stations_index');
load(path_mod)

% data_one_station.location_clear='Spijkenissebrug';
% data_stations_index(idx_mod(ks)).location_clear='Spijkenissebrug';

% data_one_station.eenheid='m3/s';
% data_stations_index(idx_mod(ks)).eenheid='m3/s';

% data_one_station.parameter='';
% data_stations_index(idx_mod(ks)).parameter='';

% data_one_station.bemonsteringshoogte=bh(ks);
% data_stations_index(idx_mod(ks)).bemonsteringshoogte=bh(ks);

data_one_station.time=tim_s;
data_one_station.waarde=val_s;
data_one_station.x=data_stations(1).x;
data_one_station.y=data_stations(1).y;
data_one_station.epsg=data_stations(1).epsg;

data_stations_index(idx_mod(ks))=data_one_station;
data_stations_index(idx_mod(ks)).time=[];
data_stations_index(idx_mod(ks)).waarde=[];

save(path_mod,'data_one_station');
save(path_ds_idx,'data_stations_index');
end


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
addOET(path_add_fcn)

%% INPUT

paths_main_folder='C:\Users\chavarri\checkouts\riv\data_stations\';

%%
load(fullfile(paths_main_folder,'data_stations_index.mat'))
%% ADD

% fpath_data='c:\Users\chavarri\temporal\210805_HvH_sal\20210730_034.csv';
% 
% data_stations=read_csv_data(fpath_data,'flg_debug',0);
% 
% %%
% ns=numel(data_stations);
% for ks=1:ns
%     data_stations(ks).location_clear='Hoek van Holland';
%     add_data_stations(paths_main_folder,data_stations(ks))
% end

%%

% fpath_data='c:\Users\chavarri\temporal\210805_HvH_sal\20210818_002.csv';
% 
% data_stations=read_csv_data(fpath_data,'flg_debug',0);
% 
% %%
% ns=numel(data_stations);
% for ks=1:ns
%     data_stations(ks).location_clear='Brienenoordbrug';
%     add_data_stations(paths_main_folder,data_stations(ks))
% end

%%

% fpath_data='c:\Users\chavarri\temporal\210805_HvH_sal\20210818_003.csv';
% 
% data_stations=read_csv_data(fpath_data,'flg_debug',0);
% 
% %%
% ns=numel(data_stations);
% for ks=1:ns
%     data_stations(ks).location_clear='Lekhaven';
%     add_data_stations(paths_main_folder,data_stations(ks))
% end

%%
% fpath_data='c:\Users\chavarri\temporal\210805_HvH_sal\20210819_011.csv';
% 
% data_stations=read_csv_data(fpath_data,'flg_debug',0);
% 
% %%
% ns=numel(data_stations);
% for ks=1:ns
%     data_stations(ks).location_clear='Tiel Waal';
%     data_stations(ks).bemonsteringshoogte=NaN;
%     add_data_stations(paths_main_folder,data_stations(ks))
% end
%%
% fpath_data='c:\Users\chavarri\temporal\210805_HvH_sal\20210819_003.csv';
% 
% data_stations=read_csv_data(fpath_data,'flg_debug',0);
% location_clear_v={'Beerenplaat','SPIJKNSBWTLK','SPIJKNSBWTLK','SPIJKNSBWTLK'};
% %%
% ns=numel(data_stations);
% for ks=2:ns-1
%     data_stations(ks).location_clear=location_clear_v{ks};
%     add_data_stations(paths_main_folder,data_stations(ks))
% end
%%
% fpath_data='c:\Users\chavarri\temporal\210805_HvH_sal\20210819_006.csv';
% 
% data_stations=read_csv_data(fpath_data,'flg_debug',0);
% location_clear_v={'Inloop Spui';'Inloop Spui';'Volkeraksluizen';'Volkeraksluizen'};
% %%
% ns=numel(data_stations);
% for ks=1:4
%     data_stations(ks).location_clear=location_clear_v{ks};
%     add_data_stations(paths_main_folder,data_stations(ks))
% end
%%



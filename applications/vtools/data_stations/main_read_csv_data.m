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

%% SEVERAL FILES SAME DATA

% fdir_data='C:\Users\chavarri\temporal\q\';
% 
% dire=dir(fdir_data);
% nf=numel(dire)-2;
% for kf=1:nf
%     fpath_data=fullfile(dire(kf+2).folder,dire(kf+2).name);
%     data_stations(kf)=read_csv_data(fpath_data,'flg_debug',0);
% end
% 
% %%
% tim=[];
% val=[];
% for kf=1:nf
%   tim=cat(1,tim,data_stations(kf).time);  
%   val=cat(1,val,data_stations(kf).waarde); 
% end
% 
% %%
% 
% figure
% hold on
% plot(tim,val,'*-')
% 
% %%
% 
% tt=timetable(tim,val);
% tt2=rmmissing(tt);
% tt3=sortrows(tt2);
% [tt4,idx_u,idx_u2]=unique(tt3);
% 
% % vidx=1:1:numel(tt3);
% % idxnu=find(~ismember(vidx,idx_u));
% % tt3.tim(idxnu(3))
% 
% dupTimes=sort(tt4.tim);
% tf=(diff(dupTimes)==0);
% dupTimes=dupTimes(tf);
% dupTimes=unique(dupTimes);
% if ~isempty(dupTimes)
%     warning('problem with duplicates')
% end
% 
% ttres=retime(tt4,'daily','mean');
% ttres_y=retime(tt4,'yearly','mean');
% 
% %%
% 
% figure
% plot(ttres.tim,ttres.val,'-*')
% 
% %%
% figure
% plot(ttres_y.tim,ttres_y.val,'-*')

%% SINGLE FILE SEVERAL STATIONS

% location_clear_v={'Inloop Spui';'Inloop Spui';'Volkeraksluizen';'Volkeraksluizen'};
% 
% ns=numel(data_stations);
% for ks=1:4
%     data_stations(ks).location_clear=location_clear_v{ks};
%     add_data_stations(paths_main_folder,data_stations(ks))
% end


%% SINGLE FILE 

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

%% FROM NC FILE

fdir_nc='p:\11205259-004-dcsm-fm\waterlevel_data\RWS_data-distributielaag\ncFiles';

dire=dir(fdir_nc);
nf=numel(dire);
for kf=1:nf
    fpath=fullfile(dire(kf).folder,dire(kf).name);
    [~,~,ext]=fileparts(fpath);
    if strcmp(ext,'.nc')==0
        continue
    end
    station_name=ncread(fpath,'station_name')';
    platform_name=ncread(fpath,'platform_name')';
    platform_id=ncread(fpath,'platform_id')';
    xco=ncread(fpath,'station_x_coordinate');
    yco=ncread(fpath,'station_y_coordinate');
    val=ncread(fpath,'waterlevel');
    
    tim=NC_read_time(fpath,[1,Inf]);
    
    nci=ncinfo(fpath);
    if strcmp(nci.Variables(5).Attributes(1).Value,'latitude')==0
        error('solve')
    else
        epsg=4326;
    end
    
    data_station.location=deblank(platform_id);
    data_station.location_clear=deblank(station_name);
    data_station.x=xco;
    data_station.y=yco;
    data_station.epsg=epsg;
    data_station.grootheid='WATHTE';
    data_station.eenheid='mNAP';
    data_station.time=tim;
    data_station.waarde=val;
    
    OPT.ask=0;
    add_data_stations(paths_main_folder,data_station,OPT);

end


%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19354 $
%$Date: 2024-01-15 14:21:36 +0100 (Mon, 15 Jan 2024) $
%$Author: chavarri $
%$Id: main_Q_statistics.m 19354 2024-01-15 13:21:36Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/data_stations/main_Q_statistics.m $
%

%% PREAMBLE

clear
clc
fclose all;

%% PATHS

fpath_add_oet='c:\checkouts\oet_matlab\applications\vtools\general\addOET.m';
fdir_d3d='c:\checkouts\qp\';
path_data_stations='c:\checkouts\data_stations';

% path_add_fcn='p:\dflowfm\projects\2020_d-morphology\modellen\checkout\openearthtools_matlab\applications\vtools\general\';

%% ADD OET

if isunix %we assume that if Linux we are in the p-drive. 
    fpath_add_oet=strrep(strrep(strcat('/',strrep(fpath_add_oet,'P:','p:')),':',''),'\','/');
end
run(fpath_add_oet);

%% INPUT

nd=365;
q_sort_all=cell(nd,1);
p_all=q_sort_all;

data_station=read_data_stations(path_data_stations,'location_clear','Lobith','grootheid','Q');
data_station_prob=data_station_probability(data_station);

q_sort_all{1}=data_station_prob.year.max.sort.val;
p_all{1}=data_station_prob.year.max.sort.p;

for k=2:nd
    data_station.time=data_station.time+days(1);

    data_station_prob=data_station_probability(data_station);

    q_sort_all{k}=data_station_prob.year.max.sort.val;
    p_all{k}=data_station_prob.year.max.sort.p;

    fprintf('%4.2f %% \n',k/nd*100);
end

save('tmp.mat','q_sort_all','p_all');

%%

data_station_r=read_data_stations(path_data_stations,'location_clear','Lobith','grootheid','Q');

bol_1=data_station.time<datetime(1950,1,1,'TimeZone','+01:00');

val_p=data_station_r.waarde;
val_p( bol_1)=val_p( bol_1)*1.05;
val_p(~bol_1)=val_p(~bol_1)*1.025;

data_station.waarde=val_p;
data_station_prob=data_station_probability(data_station);

q_sort_un{1}=data_station_prob.year.max.sort.val;
p_all_un{1}=data_station_prob.year.max.sort.p;

val_n=data_station_r.waarde;
val_n( bol_1)=val_n( bol_1)*0.95;
val_n(~bol_1)=val_n(~bol_1)*0.975;

data_station.waarde=val_n;
data_station_prob=data_station_probability(data_station);

q_sort_un{2}=data_station_prob.year.max.sort.val;
p_all_un{2}=data_station_prob.year.max.sort.p;

%%

% figure
% hold on
% plot(data_station.time,data_station.waarde)

figure
hold on
plot(data_station.time,[val_p,val_n]')

%% 

figure
hold on
for k=2:nd
plot(q_sort_all{k},1./p_all{k},'color',[0.8,0.8,0.8])
end
k=1;
plot(q_sort_all{k},1./p_all{k},'color','k')
for k=1:2
plot(q_sort_un{k},1./p_all_un{k},'color','r')
end
set(gca,'YScale','log')
xlabel('discharge [m^3/s]')
title('Lobith')
ylabel('return period of max. annual discharge [y]')
printV(gcf,'p.png')
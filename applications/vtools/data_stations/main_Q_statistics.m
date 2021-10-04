%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 20 $
%$Date: 2021-08-23 15:45:11 +0200 (Mon, 23 Aug 2021) $
%$Author: chavarri $
%$Id: main_raw.m 20 2021-08-23 13:45:11Z chavarri $
%$HeadURL: file:///P:/11206813-007-kpp2021_rmm-3d/E_Software_Scripts/00_svn/rmm_plot/main_raw.m $
%

%% PREAMBLE

clear
clc
fclose all;

%% PATHS

path_add_fcn='c:\Users\chavarri\checkouts\openearthtools_matlab\applications\vtools\general\';
path_data_stations='C:\Users\chavarri\checkouts\riv\data_stations\';

% path_add_fcn='p:\dflowfm\projects\2020_d-morphology\modellen\checkout\openearthtools_matlab\applications\vtools\general\';

%% ADD OET

addpath(path_add_fcn)
addOET(path_add_fcn)

%% INPUT

flg.write_csv=0;

% data_station=read_data_stations(path_data_stations,'location_clear','Lobith','grootheid','Q');
data_station=read_data_stations(path_data_stations,'location_clear','Calamar','grootheid','Q');

%% CALC

tim=data_station.time;
val=data_station.waarde;

tt=timetable(tim,val);
ttres_d=retime(tt,'daily','mean');
ttres_y=retime(tt,'yearly','mean');
ttres_y_tim=year(ttres_y.tim);

time_year=year(tim);
[year_u,year_u_idx1,year_u_idx2]=unique(time_year);

ny=numel(year_u);
q_year_stat=NaN(ny,2);
time_q_year_stat=NaT(ny,2);
time_q_year_stat.TimeZone='+00:00';
for ky=1:ny
    q_loc=val(year_u_idx2==ky);
    time_loc=tim(year_u_idx2==ky);
    [q_year_stat(ky,1),idx_max]=max(q_loc);
    [q_year_stat(ky,2),idx_min]=min(q_loc);
%     q_year_stat(ky,3)=std(q_loc); %use the daily discharges for this
    time_q_year_stat(ky,1)=time_loc(idx_max);
    time_q_year_stat(ky,2)=time_loc(idx_min);
end %ky

[q_sort,q_sort_idx]=sort(q_year_stat(:,1));
p_q_max=(ny:-1:1)'/(ny+1);

tim_w=ttres_y.tim;

if numel(tim_w)~=numel(year_u)
    error('ups')
end
if any(year_u-year(tim_w))
    error('ups2')
end

%%
tim_w=ttres_d.tim;
val_w=ttres_d.val;

empty_days=zeros(ny,1);

np=numel(tim_w);
for kp=1:np
    if isnan(val_w(kp))
        year_n=year(tim_w(kp));
        idx_y=find(year_n==ttres_y_tim);
        empty_days(idx_y)=empty_days(idx_y)+1;
    end
end

%% WRITE

if flg.write_csv
    
%% all

tim_w=tim;
val_w=val;

np=numel(tim_w);
fid=fopen('c:\Users\chavarri\Downloads\lobith_all.csv','w');
for kp=1:np
    if isnan(val_w(kp))
        val_w(kp)=-999;
    end
    fprintf(fid,'%s, %f \n',datestr(tim_w(kp),'dd-mm-yyyy HH:MM'),val_w(kp));
    fprintf('done %4.2f%% \n',kp/np*100);
end
fclose(fid);

%% daily

tim_w=ttres_d.tim;
val_w=ttres_d.val;

np=numel(tim_w);
fid=fopen('c:\Users\chavarri\Downloads\lobith_daily.csv','w');
for kp=1:np
    if isnan(val_w(kp))
        val_w(kp)=-999;
    end
    fprintf(fid,'%s, %f \n',datestr(tim_w(kp),'dd-mm-yyyy'),val_w(kp));
    fprintf('done %4.2f%% \n',kp/np*100);
end
fclose(fid);

%% yearly

tim_w=ttres_y.tim;
val_w=ttres_y.val;

if numel(tim_w)~=numel(year_u)
    error('ups')
end
if any(year_u-year(tim_w))
    error('ups2')
end

np=numel(tim_w);
fid=fopen('c:\Users\chavarri\Downloads\lobith_yearly.csv','w');
fprintf(fid,'year, mean, max, day max, min, day min, days no data \n');
for kp=1:np
    if isnan(val_w(kp))
        val_w(kp)=-999;
    end
    fprintf(fid,'%s, %f, %f, %s, %f, %s, %d \n',datestr(tim_w(kp),'yyyy'),val_w(kp),q_year_stat(kp,1),datestr(time_q_year_stat(kp,1),'dd-mm-yyyy'),q_year_stat(kp,2),datestr(time_q_year_stat(kp,2),'dd-mm-yyyy'),empty_days(kp));
    fprintf('done %4.2f%% \n',kp/np*100);
end
fclose(fid);

end

%% PLOT

%% raw

figure
hold on
plot(year_u,q_year_stat(:,1),'*-')
plot(year_u,q_year_stat(:,2),'*-')
plot(ttres_y_tim,ttres_y.val,'*-')

%%

figure
hold on
plot(ttres_d.tim,ttres_d.val,'*-');

%% nice
in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fname='Q_analysis';
in_p.fig_visible=1;
in_p.data_station=data_station;
in_p.lan='es';
in_p.time_q_year_max=time_q_year_stat(:,1);
in_p.q_year_max=q_year_stat(:,1);
in_p.q_sort=q_sort;
in_p.p_q_max=p_q_max;

fig_Q_analysis_vertical(in_p);
% fig_Q_analysis_horizontal(in_p);
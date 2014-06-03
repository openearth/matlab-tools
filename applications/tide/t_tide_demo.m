clear all
%% read
       url   = 'http://dods.ndbc.noaa.gov/thredds/dodsC/data/dart/46419/46419t2014.nc';
       D.h   = ncread(url,'height',[1 1 1],[1 1 1e4]); % total water column height, so huge A0
       D.day = double(ncread(url,'time',1,1e4))/3600/24; % sec since 1970
       D.t   = datenum(1970,1,D.day); % irregular: 15, 30, 60,... 900 sec
       D.lat = ncread(url,'latitude');

%% analyze easy
      D.z0 = nanmean(D.h);
      [T,hfit] = t_tide2struc(D.t, D.h - D.z0) ;    

%% analyze  difficult
       [T2,hfit2] = t_tide(D.h(:),...
           'lat',D.lat,...
           'sort','amp',...
           'interval',diff(D.t)*24,...
           'start',D.t(1),...
           'output','46419t2014_comp.asc',...
           'err','lin'); % D.z0 = T2.z0
      
%% plot      
       plot(D.t,D.h(:) - D.z0,'DisplayName','observation');
       hold on;plot(D.t,hfit,'r','DisplayName','t\_tide');
       legend show; grid on
       datetick('x')
       
%% export
       
       %T = t_tide_read('46419t2014.asc');

       t_tide2html(T,'filename','46419t2014_comp.html');

       t_tide2xml(T,'filename','46419t2014_comp.xml');

       t_tide2nc(T,'filename','46419t2014_comp.nc');  
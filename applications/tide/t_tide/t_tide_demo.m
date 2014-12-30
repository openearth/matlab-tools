%function t_tide_demo
% t_tide_demo demo for t_tide
%
%See also: t_tide, harmanal

% for all tidal function please use 
% >> help tide

%% read
       url   = 'http://dods.ndbc.noaa.gov/thredds/dodsC/data/dart/46419/46419t2014.nc';
       url   = 'c:\checkouts\openearthtoolsroot\test\matlab\applications\tide\46419t2014.nc';
       D.h   = ncread(url,'height',[1 1 1],[1 1 1e4]); % total water column height, so huge A0
       D.day = double(ncread(url,'time',1,1e4))/3600/24; % sec since 1970
       D.t   = datenum(1970,1,D.day); % irregular: 15, 30, 60,... 900 sec
       D.lat = ncread(url,'latitude');

%% analyze easy with t_tide wrapper
      D.z0 = nanmean(D.h);
      [T,hfit] = t_tide2struc(D.t, D.h - D.z0) ;    

%% analyze somewhat more difficult with t_tide
% requires licensed signal processing toolbox by default, switch of with 'err'='wboot'
      [T2,hfit2] = t_tide(D.h(:),...
          'lat',D.lat,... % required to active nodal corrections
          'sort','-amp',...
          'interval',diff(D.t)*24,... % non-constant dt only with with t_tide in openearthtools
          'start',D.t(1),...
          'output','46419t2014_t_tide.asc',...
          'err','wboot'); % only methods that does not need signal processing toolbox license
      % D.z0 = T2.z0

%% analyze with UTide
% Requires licensed signal processing toolbox always, no option to switch off

       T3 = ut_solv(D.t(:),D.h(:) - D.z0,[],D.lat,'auto','ols'); % hanning
       hfit3 = ut_reconstr ( D.t(:), T3 ); 
%% plot
       plot(D.t,D.h(:) - D.z0,'DisplayName','observation');
       hold on;
       plot(D.t,hfit ,'r-','DisplayName','t\_tide');
       plot(D.t,hfit3,'g:','DisplayName','UTide');
       legend show; grid on
       datetick('x')
       plot(D.t,hfit - D.h(:)' + D.z0,'g','DisplayName','\eps');
       
%% export
       
       %T = t_tide_read('46419t2014.asc');

       t_tide2html(T,'filename','46419t2014_t_tide.html');
       
%% harmonic
%  use frequency units as timeseries: days
%  abuse t_tide to get frequencies

       ind = strmatch('M2',T.data.name);

       H = harmanal(D.t,D.h(:),'freq',24/12.5);
       a(1) = H.hamplitudes;
       H = harmanal(D.t,D.h(:),'freq',24/(12+25/60));
       a(2) = H.hamplitudes;
       f = 1/T.data.frequency(ind) % 12.42
       H = harmanal(D.t,D.h(:),'freq',24/f);
       a(3) = H.hamplitudes;
       a(4) = T.data.fmaj(ind);

   

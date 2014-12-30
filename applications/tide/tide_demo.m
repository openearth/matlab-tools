function t_tide_demo
% t_tide_demo demo for t_tide and utide
%
%See also: t_tide, utide, harmanal

% for all tidal function please use 
% >> help tide

%% read

       url   = 'http://dods.ndbc.noaa.gov/thredds/dodsC/data/dart/46419/46419t2014.nc';       % OPeNDAP
       url   = 'http://dods.ndbc.noaa.gov/thredds/fileServer/data/dart/46419/46419t2014.nc';  % http dirfect download to local cache
       url   = 'c:\checkouts\openearthtoolsroot\test\matlab\applications\tide\46419t2014.nc'; % local cache
       
       D.h   = ncread(url,'height',[1 1 1],[1 1 1e4]); % total water column height, so huge A0
       D.day = double(ncread(url,'time',1,1e4))/3600/24; % sec since 1970
       D.t   = datenum(1970,1,D.day); % irregular: 15, 30, 60,... 900 sec
       D.lat = ncread(url,'latitude');

%% Analyze easy with t_tide wrapper

      D.z0 = nanmean(D.h);
      [T,hfit] = t_tide2struc(D.t, D.h - D.z0) ;    

%% Analyze with t_tide directy, somewhat more difficult
%  Note special OpenEarthTools t_tide version to handle non_equdistant time.
%  Requires licensed signal processing toolbox by default, switch of with 'err'='wboot'

      [T2,hfit2] = t_tide(D.h(:),...
          'lat',D.lat,... % required to active nodal corrections
          'sort','-amp',... % same order as Utide
          'interval',diff(D.t)*24,... % non-constant dt only with with t_tide in openearthtools
          'start',D.t(1),...
          'output','46419t2014_t_tide.asc',...
          'err','wboot'); % only methods that does not need signal processing toolbox license
      % D.z0 = T2.z0

%% Analyze with UTide
%  Requires ALWAYS licensed signal processing toolbox always, no option to switch it off

       T3 = ut_solv(D.t(:),D.h(:) - D.z0,[],D.lat,'auto'); % hanning
       
       ut_save(T3,'46419t2014_utide.asc')
       
       hfit3 = ut_reconstr ( D.t', T3 );        
 
%% plot

       plot(D.t,D.h(:) - D.z0,'DisplayName','observation');
       hold on;
       plot(D.t,hfit ,'r-','DisplayName','t\_tide');
       plot(D.t,hfit3,'g-','DisplayName','UTide');
       plot(D.t,hfit  - D.h(:)' + D.z0,'r--','DisplayName','\epsilon t\_tide');
       plot(D.t,hfit3 - D.h(:)' + D.z0,'g--','DisplayName','\epsilon UTide');
       legend show; grid on
       datetick('x')   

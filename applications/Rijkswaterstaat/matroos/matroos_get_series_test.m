%MATROOS_GET_SERIES_TEST   test for matroos_get_series
%
%See also: matroos

%% get data

   [O.datenum,O.wl]=matroos_get_series('unit','waterlevel','source','observed' ,'loc','hoekvanholland','tstart',now-7,'tstop',now+7,'check','');
   [P.datenum,P.wl]=matroos_get_series('unit','waterlevel','source','dcsm_oper','loc','hoekvanholland','tstart',now-7,'tstop',now+7,'check','');

%% plot data

   plot(P.datenum,P.wl,'b-','displayname',mktex('observed' ));
   hold on;
   plot(O.datenum,O.wl,'k.','displayname',mktex('dcsm_oper'));
   vline(now)
   hold off
   datetick(gca);
   xlabel ('time');
   legend show
   ylabel('water level [m]')
   xlabel('time GMT')



%MATROOS_GET_SERIES_TEST   test for matroos_get_series
%
%See also: matroos

%% get data, save to file

   O = matroos_get_series('unit','waterlevel','source','observed' ,'loc','hoekvanholland','tstart',now-7,'tstop',now+7,'check','','file','O.txt');
   P = matroos_get_series('unit','waterlevel','source','dcsm_oper','loc','hoekvanholland','tstart',now-7,'tstop',now+7,'check','','file','P.txt');
   
%% plot data

   plot    (P.datenum,P.waterlevel,'b-','displayname',mktex('observed' ));
   hold     on
   plot    (O.datenum,O.waterlevel,'k.','displayname',mktex('dcsm_oper'));
   vline   (now)
   datetick(gca);
   xlabel  ('time');
   ylabel  ('water level [m]')
   xlabel  (['time ',O.timezone])
   legend   show
   grid     on
   title   ([O.loc,' ',O.latlonstr])

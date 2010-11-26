function matroos_get_series_test()
% MATROOS_GET_SERIES_TEST   test for matroos_get_series
%  
% This function tests matroos_get_series.
%
%
%See also: MATROOS

MTestCategory.DataAccess;
if TeamCity.running
    TeamCity.ignore('Test requires access to matroos, which the buildserver does not have.');
    return;
end

%% get data, save to file

   O = matroos_get_series('unit','waterlevel','source','observed' ,'loc','hoekvanholland;den helder;delfzijl','tstart',now-7,'tstop',now+7,'check','','file','O.txt');
   P = matroos_get_series('unit','waterlevel','source','dcsm_oper','loc','hoekvanholland;den helder;delfzijl','tstart',now-7,'tstop',now+7,'check','','file','P.txt');
   
%% plot data

for iloc=1:length(O)

   figure

   plot    (P(iloc).datenum,P(iloc).waterlevel,'b-','displayname',mktex('observed' ));
   hold     on
   plot    (O(iloc).datenum,O(iloc).waterlevel,'k.','displayname',mktex('dcsm_oper'));
   vline   (now)
   datetick(gca);
   xlabel  ('time');
   ylabel  ('water level [m]')
   xlabel  (['time ',O(iloc).timezone])
   legend   show
   grid     on
   title   ([O(iloc).loc,' ',O(iloc).latlonstr])

end

%% EOF

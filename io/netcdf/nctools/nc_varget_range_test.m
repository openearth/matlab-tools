function OK = nc_varget_range_test
%nc_varget_range_test test for nc_varget_range
%
%See also: nc_varget_range

ncfile = 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/waterbase/sea_surface_height/id1-DENHDR.nc'; % empty in request range
ncfile = 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/waterbase/sea_surface_height/id1-TERNZN.nc';

OPT.datenum   = datenum(1953,1,30 + [0 5]);% datestr(OPT.datenum)

%% get full time series: order  5.0 seconds.

   tic
   D = nc_cf_stationTimeSeries(ncfile,'sea_surface_height','plot',1);
   hold on
   S0.datenum   = find(D.datenum > OPT.datenum(1) & D.datenum < OPT.datenum(2));
   toc

%% subset time series: order 0.5 seconds.

   tic
   [S.datenum,S.ind] = nc_varget_range(ncfile,'time',OPT.datenum)
   if ~isempty(S.ind)
   S.sea_surface_height   = nc_varget(ncfile,'sea_surface_height',[0 S.ind(1)-1],[1 length(S.ind)]);
   plot(S.datenum,S.sea_surface_height,'r:')
   end
   toc
   hold on

%% subset time series: order 0.5 seconds.

   tic
   [S.datenum,start,count] = nc_varget_range(ncfile,'time',OPT.datenum);
   if ~isempty(start)
   S.sea_surface_height   = nc_varget(ncfile,'sea_surface_height',[0 start],[1 count]);
   toc
   hold on
   plot(S.datenum,S.sea_surface_height,'g.')
   end
   
   xlim(OPT.datenum)

%% assess

   % datestr(S.datenum)
   % datestr(D.datenum(ind.datenum))

   OK = isequal(S.datenum,S.datenum);
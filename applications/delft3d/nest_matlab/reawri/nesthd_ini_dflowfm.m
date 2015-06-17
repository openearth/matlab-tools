      function [sds_ini] = nesthd_ini_dflowfm(filename)

      % ini_dflowfm : Get some general information from a DFLOWFM history file

      times          = ncread(filename,'time');
      sds_ini.notims = length(times);
      sds_ini.dtmin  = (times(2) - times(1))/60.;
      sds_ini.tstart = times (1)  /60.;
      sds_ini.tend   = times (end)/60.;
      refdate         = ncreadatt(filename,'time','units');
      sds_ini.itdate  = datenum(refdate(15:end),'yyyy-mm-dd HH:MM:SS');

      sds_ini.kmax    = 1;

      %
      % get names of stations
      %

      stations = ncread(filename,'station_name');
      stations = cellstr(stations');
      nostat   = length (stations);

      for istat = 1: nostat
          sds_ini.mnstat(1,istat)= NaN;
          sds_ini.mnstat(2,istat)= NaN;
          sds_ini.names{istat}         = stations{istat};
          sds_ini.list_stations(istat) = istat;
      end
      %
      % Get the depth data
      %
      for istat = 1: nostat
          sds_ini.dps(istat) = NaN;
      end

      %
      % Thicknesses (to do, tricky, for now only depth averaged)
      %
      
      if sds_ini.kmax > 1

      else
         sds_ini.thick(1) = 1.0;
      end

      sds_ini.lstci = 0; % no nesting of constituents for now

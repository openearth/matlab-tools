      function [sds_ini] = nesthd_ini_dflowfm(filename)

      % ini_dflowfm : Get some general information from a DFLOWFM history file

      times          = ncread(filename,'time');
      sds_ini.notims = length(times);
      sds_ini.time   = times;
      sds_ini.dtmin  = (times(2) - times(1))/60.;
      sds_ini.tstart = times (1)  /60.;
      sds_ini.tend   = times (end)/60.;
      refdate         = ncreadatt(filename,'time','units');
      sds_ini.itdate  = datenum(refdate(15:end),'yyyy-mm-dd HH:MM:SS');
      sds_ini.itdate  = str2num(datestr(sds_ini.itdate,'yyyymmdd'));

           
      % number of layers
      sds_ini.kmax    = 1;
      
      Info = ncinfo(filename);
      Vars = {Info.Variables.Name};
      i_vel = find(strcmp(Vars,'x_velocity')==1);
      if ~isempty(i_vel)
          sds_ini.kmax = Info.Variables(i_vel).Size(1);
      end
            
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
      % Get the depth data (assumes sigma layer distribution!!!)
      %
      tmp_zw      = ncread(filename,'zcoordinate_w');
      tmp_zc      = ncread(filename,'zcoordinate_c');
      sds_ini.dps = -1.*squeeze(tmp_zw(1,:,1));                      % For now, d3d-flow convention 
      
      %
      % Thicknesses (for now only works with assumes sigma layer
      % distribution
      %
      
      if sds_ini.kmax > 1
          sds_ini.thick(1:sds_ini.kmax) = 1.0/sds_ini.kmax;
          % create relative position cell centres, measured from the bed
          for i_stat = 1: nostat
              w_depth = tmp_zw(sds_ini.kmax + 1,i_stat,1) - tmp_zw(1,i_stat,1);
              for k = 1: sds_ini.kmax
                  sds_ini.rel_pos(i_stat,k) = (tmp_zc(k,i_stat,1) - tmp_zw(1,i_stat,1))/w_depth;
              end
          end
          
      else
         sds_ini.thick(1)   = 1.0;
         sds_ini.rel_pos(1) = 0.5;
      end
      
      sds_ini.lstci = 0; % 
      i_sal = find(strcmpi(Vars,'Salinity'   )==1);
      i_tem = find(strcmpi(Vars,'Temperature')==1);
      if ~isempty(i_sal) sds_ini.lstci = sds_ini.lstci + 1;sds_ini.namcon(sds_ini.lstci,1:20) = 'Salinity            '   ; end
      if ~isempty(i_tem) sds_ini.lstci = sds_ini.lstci + 1;sds_ini.namcon(sds_ini.lstci,1:20) = 'Temperature         '; end
          
      
      

      function [wl,uu,vv] =  nesthd_hisnch(runid,istat,nfs_inf,vartype)

      % nesthd_hisnch : gets water level and/or velocity data from a DFLOWFM history file

      %% Initialisation
      wl = [];
      uu = [];
      vv = [];

      deg2rd = pi/180.;

      kmax   = nfs_inf.kmax;
      notims = nfs_inf.notims;

      if strcmpi(vartype,'wl') || strcmpi(vartype,'all')
%%       Get the waterlevel data
         
         data_all = ncread(runid,'waterlevel');
         wl       = data_all(istat,:);

      end

      if strcmpi(vartype,'c') || strcmpi(vartype,'all')
%%        Get velocity data and rotate to obtain north and south velocities

         data_all  = ncread(runid,'x_velocity');
         if  nfs_inf.kmax == 1         % depth averaged
             uu       = data_all(istat,:);
         else
             uu       = squeeze(data_all(:,istat,:))';
         end
         
         data_all  = ncread(runid,'y_velocity');
         if  nfs_inf.kmax == 1         % depth averaged
             vv       = data_all(istat,:);
         else
             vv       = squeeze(data_all(:,istat,:))';
         end
      end

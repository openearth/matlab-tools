      function [wl,uu,vv] =  getdata_hyd(filename,istat,nfs_inf,vartype)

      % getdata_hyd : gets water level and/or velocity data from trih or SDS file

      wl = [];
      uu = [];
      vv = [];

      filetype = nesthd_det_filetype(filename);

      switch filetype
         case {'Delft3D'}
            [wl,uu,vv] = nesthd_simhsh(filename,istat,nfs_inf,vartype);
         case {'SIMONA'}
            [wl,uu,vv] = nesthd_sdshsh(filename,istat,nfs_inf,vartype);
      end

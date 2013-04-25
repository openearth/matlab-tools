      function [conc] =  getdata_tran(filename,istat,nfs_inf,l)

      % getdata_tran : Get concentration data out of a trih or SDS file

      conc = [];

      filetype = nesthd_det_filetype(filename);

      switch filetype
         case {'Delft3D'}
            [conc] = nesthd_simhsc(filename,istat,nfs_inf,l);
         case {'SIMONA'}
            [conc] = nesthd_sdshsc(filename,istat,nfs_inf,l);
      end

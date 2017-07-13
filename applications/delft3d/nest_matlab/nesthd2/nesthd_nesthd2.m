      function nesthd_nesthd2 (varargin)

      % nesthd2 : nesting of hydrodynamic models (stage 2)

      %
      % Matlab version of nesthd2 (beta release; based on the original fortran code)
      % Theo van der Kaaij, March 2011
      %

      if nargin > 0

         %
         % Called from ui
         %

         files   = varargin{1};
         if nargin == 2
            add_inf             = varargin{2};
            %% Temporary, set path to mdf file with NSC layer distribution
            if exist('nsc_thick.mdf','file')
                add_inf.interpolate_z = 'nsc_thick.mdf';
            end
         else
            add_inf = nesthd_additional( );
         end
      else

         %
         % Standalone
         %

         oetsettings;
         addpath(genpath('..\general'));
         addpath(genpath('..\reawri'));

         files{1}    = 'D:\projects\nesthd_matlab\test\002\new_XP.bnd';
         files{2}    = 'D:\projects\nesthd_matlab\test\002\s.adm';
         files{3}    = 'D:\projects\nesthd_matlab\test\002\trih-w41_2';
         files{4}    = 'D:\projects\nesthd_matlab\test\002\new_XP.bct';
         files{5}    = 'D:\projects\nesthd_matlab\test\002\new_XP.bcc';

         %
         % Retrieve additional input
         %

         add_inf     = nesthd_additional();
      end

      fid_adm     = fopen(files{2},'r');      %
      % Read the boundary definition (use points structure!)
      %

      bnd         = nesthd_get_bnd_data (files{1},'Points',true);
      if isempty(bnd) return; end;

      %
      % Get general information from history file
      %

      nfs_inf = nesthd_get_general(files{3});

      nobnd       = length(bnd.DATA);
      kmax        = nfs_inf.kmax;
      lstci       = nfs_inf.lstci;
      notims      = nfs_inf.notims;

      %
      % Generate hydrodynamic boundary conditions
      %

      [bndval,error]      = nesthd_dethyd(fid_adm,bnd,nfs_inf,add_inf,files{3});
      
      %% Vertical interpolation, temprary, not correct place, shoud be don inside dethyd
      if isfield(add_inf,'interpolate_z')
          det_inf         = nesthd_get_general  (add_inf.interpolate_z);
          bndval          = nesthd_interpolate_z(bndval,nsf_inf.rel_pos, det_inf.rel_pos);
      end
      if error return; end;

      %
      % Generate depth averaged bc from 3D simulation
      %

      [bndval,nfs_inf] = nesthd_dethyd2dh(bndval,bnd,nfs_inf,add_inf);

      %
      % Write the hydrodynamic boundary conditions to file
      %

      nesthd_wrihyd (files{4},bnd,nfs_inf,bndval, add_inf);

      clear bndval 

      %
      % Generate transport bc if avaialble on history file
      %

      if lstci > 0
         if sum(add_inf.genconc) > 0
             if isempty(bnd) return; end;

             bndval      = nesthd_detcon(fid_adm,bnd,nfs_inf,add_inf,files{3});

            %
            % Write concentrations to file
            %

            nesthd_wricon(files{5},bnd,nfs_inf,bndval,add_inf);

         end
      end

      fclose (fid_adm);

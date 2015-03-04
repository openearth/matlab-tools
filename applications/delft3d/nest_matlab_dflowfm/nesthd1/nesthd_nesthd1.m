      function nesthd1 (varargin)

      % nesthd1 nesting for delft3d and simona (first stage)

      % Matlab version of Nesthd1 (based on the original fortran code) beta
      % release
      %

      h = waitbar(0,'Generate the nest administration','Color',[0.831 0.816 0.784]);

      if nargin == 1
         %
         % Input specified through ui
         %
         files = varargin{1};
      else
         %
         % Specify files here
         %
         oetsettings;
         addpath(genpath('..\general'));
         addpath(genpath('..\reawri'));

         files{1}      = '..\test\milford\csm_activeonly.grd';

         files{2}      = '..\test\milford\milford_geo.grd';
         files{3}      = '..\test\milford\3dbx.bnd';

         files{4}      = '..\test\milford\test.obs';
         files{5}      = '..\test\milford\test.adm';
      end

      fid_obs       = fopen(files{4},'w+');
      fid_adm       = fopen(files{5},'w+');
      sphere        = false;

      %
      % Read overall grid; Make the icom matrix (active, inactive)
      %

      grid_coarse = wlgrid  ('read',files{1});
      icom_coarse = nesthd_det_icom(grid_coarse.X,grid_coarse.MissingValue);
      [grid_coarse.Xcen,grid_coarse.Ycen] = nesthd_det_cen(grid_coarse.X,grid_coarse.Y,icom_coarse);
      if strcmpi(grid_coarse.CoordinateSystem,'Spherical');sphere = true;end

      %
      % Read detailled grid, read the boundary definition ; Make the icom matrix (active, inactive)
      %

      bnd       = nesthd_get_bnd_data (files{3});
      grid_fine = wlgrid   ('read',files{2});
      icom_fine = nesthd_det_icom (grid_fine.X,grid_fine.MissingValue,files{6});

      %
      % Determine world coordinates of boundary support points for water level boundaries
      %

      [X_bnd,Y_bnd,positi]  = nesthd_detxy (grid_fine.X,grid_fine.Y,bnd,icom_fine,'WL ');

      %
      % Determine coordinates and relative weights of the required neting stations
      %

      [mcnes,ncnes,weight]  = nesthd_detnst(grid_coarse.X,grid_coarse.Y,icom_coarse,X_bnd,Y_bnd,sphere,1);

      %
      % Write the the observation file and the nest administration file for water level boundaries
      %

      nesthd_wrista (fid_obs,files{4},mcnes,ncnes,length(bnd.DATA));
      nesthd_wrinst (fid_adm,bnd, mcnes , ncnes , weight,'WL ');

      %
      % TK new (suggestion for structure) not based on M,N coordinates but based upon names
      %

      string_mnbsp = nesthd_convertmn2string(bnd.m,bnd.n)
      string_mnnes = nesthd_convertmn2string(mcnes,ncnes)
      nesthd_wrinst (fid_adm_2,string_mnbcp,stringmnnes,weight,'WL ');
      nesthd_wrista (fid_obs,files{4},string_mnnes,length(bnd.DATA));

      %
      % Same story, this time for (perpendicular) velocity boundaries
      %

      clear X_bnd Y_bnd positi mcnes ncnes weight

      [X_bnd,Y_bnd,positi]  = nesthd_detxy (grid_fine.X,grid_fine.Y,bnd,icom_fine,'UVp');
      [mcnes,ncnes,weight]  = nesthd_detnst(grid_coarse.X,grid_coarse.Y,icom_coarse,X_bnd,Y_bnd,sphere,2);

      %
      % Determine the orientation of the velocity boundary      %
      %

      angles = nesthd_detang (X_bnd,Y_bnd,icom_fine,bnd);

      %
      % Write the the observation file and the nest administration file for velocity (perpendicular) boundaries
      %

      nesthd_wrista (fid_obs,files{4},mcnes,ncnes,length(bnd.DATA));
      nesthd_wrinst (fid_adm,bnd, mcnes , ncnes , weight,'UVp',angles,positi,grid_coarse);

      %
      % Same story, this time for (tangential) velocity boundaries
      %

      clear X_bnd Y_bnd positi mcnes ncnes weight angles

      [X_bnd,Y_bnd,positi]  = nesthd_detxy (grid_fine.X,grid_fine.Y,bnd,icom_fine,'UVt');
      [mcnes,ncnes,weight]  = nesthd_detnst(grid_coarse.X,grid_coarse.Y,icom_coarse,X_bnd,Y_bnd,sphere,3);

      %
      % Determine the orientation of the velocity boundary      %
      %

      angles = nesthd_detang (X_bnd,Y_bnd,icom_fine,bnd);

      %
      % Write the the observation file and the nest administration file for velocity (tangential) boundaries
      %

      nesthd_wrista (fid_obs,files{4},mcnes,ncnes,length(bnd.DATA));
      nesthd_wrinst (fid_adm,bnd, mcnes , ncnes , weight,'UVt',angles);

      %
      % Close the files
      %

      close (h);
      fclose all;

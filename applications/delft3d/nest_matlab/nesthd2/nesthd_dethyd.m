      function [bndval,error] = dethyd(fid_adm,bnd,nfs_inf,add_inf,filename)

      % dethyd : determines nested hydrodynamic boundary conditions (part of nesthd2)

%***********************************************************************
% delft hydraulics                         marine and coastal management
%
% subroutine         : dethyd
% version            : v1.0
% date               : May 1999
% programmer         : Theo van der Kaaij
%
% function           : Determines hydrodynamic boundary conditions
%                      (time-series)
% limitations        :
% subroutines called : getwgh, check, getwcr
%***********************************************************************
      error = false;

      h = waitbar(0,'Generating Hydrodynamic boundary conditions','Color',[0.831 0.816 0.784]);

      nobnd  = length(bnd.DATA);
      notims = nfs_inf.notims;
      kmax   = nfs_inf.kmax;
      mnstat = nfs_inf.mnstat;

      g = 9.81;

      for itim = 1: notims
         bndval (itim).value(1:nobnd,1:2*kmax,1,1:2) = 0.;
      end

%
%-----cycle over all boundary support points
%
      for ibnd = 1: nobnd
          type = lower(bnd.DATA(ibnd).bndtype);
%
%--------for water level or velocity boundaries
%

         for isize = 1: 2
            waitbar(((ibnd-1)*2+isize)/(2*nobnd));
%
%-----------first get nesting stations, weights and orientation
%           of support point
%
            mcbsp = bnd.m(ibnd,isize);
            ncbsp = bnd.n(ibnd,isize);
            switch type
               case 'z'
                  [mnes,nnes,weight] = nesthd_getwgh(fid_adm,mcbsp,ncbsp,type);
               case {'c' 'p'}
                  [mnes,nnes,weight,angle] = nesthd_getwgh(fid_adm,mcbsp,ncbsp,'c');
               case {'r' 'x'}
                  [mnes,nnes,weightr,angle,ori] = nesthd_getwgh(fid_adm,mcbsp,ncbsp,'r');
               case 'n'
                  [mnes,nnes,weight,angle,ori,x,y] = nesthd_getwgh(fid_adm,mcbsp,ncbsp,'n');
            end

            if isempty(mnes)
                error = true;
                close(h);
                simona2mdf_message({'Inconsistancy between boundary definition and' 'administration file'},'Window','Nesthd2 Error','Close',true,'n_sec',10);
                return
            end

            %
            % Get station numbers needed; store in ines
            %

            for iwght = 1: 4
                ines(iwght) = 0;
                if mnes(iwght) ~= 0
                   istat       = find(mnstat(1,:) == mnes(iwght) & mnstat(2,:) == nnes(iwght),1);
                   if ~isempty(istat)
                      ines(iwght) = nfs_inf.list_stations(istat);
                   else
                      weight(iwght) = 0;
                   end
               end
            end

            %
            % Normalise weights (stations not found on history file)
            %

            wghttot = sum(weight);
            weight = weight/wghttot;
%
%-----------Determine time series of the boundary conditions
%
            for iwght = 1: 4
                if ines(iwght) ~=0
                   switch type
%
%----------------------a) For water level boundaries
%
                       case 'z'
                          [wl,~,~] = nesthd_getdata_hyd(filename,ines(iwght),nfs_inf,'wl');
                          for itim = 1: notims
                             bndval(itim).value(ibnd,1,1,isize) = bndval(itim).value(ibnd,1,1,isize) + ...
                                weight(iwght)*(wl(itim) + add_inf.a0);
                          end
%
%----------------------b) for velocity boundaries (perpendicular component)
%
                       case {'c' 'p'}
                          [~,uu,vv] = nesthd_getdata_hyd(filename,ines(iwght),nfs_inf,'c');
                          [uu,~]     = nesthd_rotate_vector(uu,vv,pi/2. - angle);
                          for itim = 1: notims
                              bndval(itim).value(ibnd,1:kmax,1,isize) = bndval(itim).value(ibnd,1:kmax,1,isize) +  uu(itim,:)*weight(iwght);
                          end
%
%----------------------c) for Rieman boundaries
%
                       case {'r' 'x'}
                          [wl,uu,vv] = nesthd_getdata_hyd(filename,ines(iwght),nfs_inf,'all');
                          [uu,~]     = nesthd_rotate_vector(uu,vv,pi/2. - angle);
                          ori = char(ori);
                          if ori(1:2) == 'in'
                             rpos = 1.0;
                          else
                             rpos = -1.0;
                          end
                          for itim = 1: notims
                             bndval(itim).value(ibnd,1:kmax,1,isize) = bndval(itim).value(ibnd,1:kmax,1,isize)  +               ...
                                   (uu(itim,:) +  rpos*wl(itim)*sqrt(g/nfs_inf.dps(ines(iwght))))*weight(iwght);
                          end
                   end
                end
            end
%
%-----------d) for Neumann boundaries
%
            switch type
               case 'n'
                  clear wl
                  x    = x   (ines ~= 0);
                  y    = y   (ines ~= 0);
                  ines = ines(ines ~= 0);
                  %
                  % Neumann boundaries require 3 surrounding support points
                  %
                  if length(ines) >= 3
                     for istat = 1: 3
                        [wl(istat,:),~,~] = nesthd_getdata_hyd(filename,ines(istat),nfs_inf,'wl');
                     end
                     for itim = 1: notims
                        gradient_global    = nesthd_tri_grad      (x(1:3),y(1:3),wl(1:3,itim));
                        [gradient_boundary,~]  = nesthd_rotate_vector (gradient_global(1),gradient_global(2),pi/2. - angle);
                        bndval(itim).value(ibnd,1,1,isize) = gradient_boundary;
                     end
                  else
                     bndval(itim).value(ibnd,1,1,isize) = NaN;
                  end
            end

%
%-----------Determine time series for the parallel velocity component
%
            switch type
               case {'x' 'p'}
                  [mnes,nnes,weight,angle] = nesthd_getwgh(fid_adm,mcbsp,ncbsp,type);
                  for iwght = 1:4
                     ines(iwght) = 0;
                     if mnes(iwght) ~= 0
                        istat        = find(mnstat(1,:) == mnes(iwght) & mnstat(2,:) == nnes(iwght),1);
                        if ~isempty(istat)
                           ines (iwght) = nfs_inf.list_stations(istat);
                        else
                           weight(iwght) = 0;
                        end
                     end
                  end

                  %
                  % Normalise weights (stations not found on history file)
                  %

                  wghttot = sum (weight);
                  weight = weight/wghttot;

                  for iwght = 1: 4
                     if ines(iwght) ~=0
                        [~,uu,vv] = nesthd_getdata_hyd(filename,ines(iwght),nfs_inf,'c');
                        [~,vv]     = nesthd_rotate_vector(uu,vv,pi/2. - angle);
                        vv = -vv;
                        for itim = 1: notims
                           bndval(itim).value(ibnd,kmax+1:2*kmax,1,isize) = bndval(itim).value(ibnd,kmax+1:2*kmax,1,isize) + vv(itim,:)*weight(iwght);
                        end
                     end
                  end
            end
         end
      end

      close(h);

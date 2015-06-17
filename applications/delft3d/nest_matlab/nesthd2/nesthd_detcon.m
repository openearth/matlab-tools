      function [bndval] = detcon(fid_adm,bnd,nfs_inf,add_inf,filename)

%***********************************************************************
% delft hydraulics                         marine and coastal management
%
% subroutine         : detcon
% version            : v1.0
% date               : May 1999
% programmer         : Theo van der Kaaij
%
% function           : Determines transport boundary conditions
%                      (time-series)
% limitations        :
% subroutines called : getwgh, check, getwcr
%***********************************************************************
      h = waitbar(0,'Generating transport boundary conditions','Color',[0.831 0.816 0.784]);


      nobnd  = length(bnd.DATA);
      notims = nfs_inf.notims;
      kmax   = nfs_inf.kmax;
      lstci  = nfs_inf.lstci;
      mnstat = nfs_inf.mnstat;

      for itim = 1: notims
         bndval(itim).value(1:nobnd,1:kmax,1:lstci,1:2) = 0.;
      end

%
%-----cycle over all boundary support points
%
      for ibnd = 1: nobnd

         for isize = 1: 2

            waitbar(((ibnd-1)*2+isize)/(2*nobnd));

%
%-----------first get nesting stations, weights and orientation
%           of support point
%

            mcbsp = bnd.m(ibnd,isize);
            ncbsp = bnd.n(ibnd,isize);
            [mnes,nnes,weight] = nesthd_getwgh(fid_adm,mcbsp,ncbsp,'z');
            if isempty(mnes) return; end;

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
            % Determine time series of the boundary conditions
            %

            for iwght = 1: 4
               if ines(iwght) ~=0
                  for l = 1:lstci

                     %
                     % If bc for this constituent are requested
                     %

                     if add_inf.genconc(l)

                        %
                        % Get the time series
                        %

                        conc = nesthd_getdata_tran(filename,ines(iwght),nfs_inf,l);

                        %
                        % Determine weighed value
                        %

                        for itim = 1: notims
                           for k = 1: kmax
                              bndval(itim).value(ibnd,k,l,isize) = bndval(itim).value(ibnd,k,l,isize) +             ...
                                                                conc(itim,k)*weight(iwght);
                           end
                        end
                     end
                  end
               end
            end

            %
            % Adjust boundary conditions
            %

            for l = 1: lstci
                if add_inf.genconc(l)
                    for itim = 1 : notims
                        bndval(itim).value(ibnd,:,l,isize) =  bndval(itim).value(ibnd,:,l,isize) + add_inf.add(l);
                        bndval(itim).value(ibnd,:,l,isize) =  min(bndval(itim).value(ibnd,:,l,isize),add_inf.max(l));
                        bndval(itim).value(ibnd,:,l,isize) =  max(bndval(itim).value(ibnd,:,l,isize),add_inf.min(l));
                    end
                end
            end
         end
      end

      close(h);


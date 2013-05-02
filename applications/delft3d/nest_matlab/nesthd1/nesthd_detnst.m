      function [mcnes,ncnes,weight] = detnst  (x,y,icom,xbnd,ybnd,sphere,itime)

      %detnst  determines coordinates nest stations and belonging weight factors
      %
      %See also: inpolygon, nesthd1, poly_fun

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % delft hydraulics                         marine and coastal management
      %
      % subroutine         : detnst
      % version            : v1.0
      % date               : June 1997
      % programmer         : Theo van der kaaij
      %
      % function           : determines coordinates nest stations and
      %                      belonging weight factors
      % error messages     :
      %
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      nobnd = size(xbnd,1);

      mcnes (1:nobnd,2,4) = 0 ;
      ncnes (1:nobnd,2,4) = 0 ;
      weight(1:nobnd,2,4) = 0.;

      for ibnd = 1: nobnd
         for isize = 1: 2

            waitbar(((itime-1)*nobnd*2 + (ibnd-1)*2 + isize)/(nobnd*6));

            xbsp = xbnd  (ibnd, isize);
            ybsp = ybnd  (ibnd, isize);
%
%-----------find surrounding depth points overall model
%
            if ~isnan(xbsp)
                inside = false;
                for m = 1: size(x,1) - 1
                   for n = 1: size(x,2) - 1
                      if icom(m+1,n+1) == 1
                         xx(1) = x(m  ,n  );yy(1) = y(m  ,n  );
                         xx(2) = x(m+1,n  );yy(2) = y(m+1,n  );
                         xx(3) = x(m+1,n+1);yy(3) = y(m+1,n+1);
                         xx(4) = x(m  ,n+1);yy(4) = y(m  ,n+1);
                         in = inpolygon(xbsp,ybsp,xx,yy);
                         if in
                            inside = in;
                            mnst   = m;
                            nnst   = n;
                            %
                            % Determine relative distances (within a
                            % computational cell)
                            %
                            [rmnst,rnnst] = nesthd_reldif(xbsp,ybsp,xx,yy,sphere);
                         end
                      end
                   end
                end

                if inside

%
%--------------from depth points to zeta points
%
                   rmnst = rmnst + 0.5;
                   rnnst = rnnst + 0.5;

                   if rmnst > 1.
                      mnst  = mnst  + 1  ;
                      rmnst = rmnst - 1.0;
                   end

                   if rnnst > 1.
                      nnst  = nnst  + 1  ;
                      rnnst = rnnst - 1.0;
                   end

%
%------------------fill mcnes and ncnes and compute weights
%
                   mcnes (ibnd,isize,1) = mnst;
                   ncnes (ibnd,isize,1) = nnst;
                   weight(ibnd,isize,1) = (1.- rmnst)*(1. - rnnst);

                   mcnes (ibnd,isize,2) = mcnes (ibnd,isize,1) + 1;
                   ncnes (ibnd,isize,2) = ncnes (ibnd,isize,1);
                   weight(ibnd,isize,2) = rmnst*(1. - rnnst);

                   mcnes (ibnd,isize,3) = mcnes (ibnd,isize,1);
                   ncnes (ibnd,isize,3) = ncnes (ibnd,isize,1) + 1;
                   weight(ibnd,isize,3) = (1.- rmnst)*rnnst;

                   mcnes (ibnd,isize,4) = mcnes (ibnd,isize,1) + 1;
                   ncnes (ibnd,isize,4) = ncnes (ibnd,isize,1) + 1;
                   weight(ibnd,isize,4) = rmnst*rnnst;
               end
            end
         end
      end
%
%-----delete inactive points from mcnes and ncnes arrays
%
      for ibnd = 1: nobnd
         for isize = 1: 2
            noin = 0;
            for inst = 1: 4

               mnst = mcnes(ibnd,isize,inst);
               nnst = ncnes(ibnd,isize,inst);

               if mnst ~= 0
                  if icom(mnst,nnst) ~= 1
                     noin = noin + 1;
                     mcnes (ibnd,isize,inst) = 0 ;
                     ncnes (ibnd,isize,inst) = 0 ;
                     weight(ibnd,isize,inst) = 0.;
                  end
               else
                  noin = noin + 1;
               end
            end
            if noin == 4
%
%--------------no active surrounding overall model points found
%              search nearest active point (not for diagonal vel bnd.)
%

               if ~isnan(xbnd(ibnd,isize))
                  [mcnes(ibnd,isize,1),ncnes(ibnd,isize,1)] = nesthd_nearmn (xbnd(ibnd, isize),ybnd(ibnd,isize),x,y,icom);
                  weight(ibnd,isize,1) = 1.0;
               end
            end
         end
      end
%
%-----finally normalize weights
%
      for ibnd = 1: nobnd
         for isize = 1: 2
            wtot = 0.;
            for inst = 1: 4
               if weight(ibnd,isize,inst) <= 0.
                  weight (ibnd,isize,inst) = 1.0e-6;
               end
               wtot = wtot + weight(ibnd,isize,inst);
            end

            for inst = 1: 4
               weight (ibnd,isize,inst) = weight (ibnd,isize,inst)/wtot;
            end
         end
      end

      function [Xbnd, Ybnd,positi] = detxy (X,Y,bnd,icom,type)

      % detxy: Determine the world coordinates of the boundary support points for both water level and velocity boundaries

      %
      % Determine the world coordinates of the boundary support points for both water level and velocity boundaries
      %

%-----------------------------------------------------------------------
%---- 1. determine X,Y co-ordinates of boundary support points
%        in WL and UV points
%-----------------------------------------------------------------------

      for ibnd = 1: length(bnd.DATA)
          ma = bnd.m(ibnd,1);
          na = bnd.n(ibnd,1);
          mb = bnd.m(ibnd,2);
          nb = bnd.n(ibnd,2);

%
%---- 1.1 determine the orientation of the boundary section
%
%....... boundary section along a vertical grid line
%
         if  ma == mb && na ~= nb
%
%.......... check left or right side active grid
            left  = true;
            m     = ma;
            mstep = 1;
            if ma > 1
               n = round((na + nb) / 2);
               if icom(ma-1,n) ==  1
                  left  = false;
                  m     = ma - 1 ;
                  mstep = -1;
               end
            end
%
%-----------For Riemann type boundary conditions determine if inflow is
%           positive or negative
%
            if left
               positi {ibnd} = 'in ';
            else
               positi {ibnd} = 'out';
            end
%
%.......... then determine x and y coordinates boundary support points
%
            for iside = 1: 2
               n    = bnd.n(ibnd,iside);
               xmid = 0.5 * ( X(m,n) + X(m,n-1) );
               ymid = 0.5 * ( Y(m,n) + Y(m,n-1) );
               dx   = 0.5 * ( X(m  ,n  ) - X(m+mstep,n  )      ...
                            + X(m  ,n-1) - X(m+mstep,n-1) );
               dy   = 0.5 * ( Y(m  ,n  ) - Y(m+mstep,n  )      ...
                            + Y(m  ,n-1) - Y(m+mstep,n-1) );
               if type == 'UVp'
                  Xbnd   (ibnd,iside) = xmid;
                  Ybnd   (ibnd,iside) = ymid;
               elseif type == 'UVt'
                  Xbnd   (ibnd,iside) = X(m,n) + 0.5 * dx;
                  Ybnd   (ibnd,iside) = Y(m,n) + 0.5 * dy;
               elseif type == 'WL '
                  Xbnd (ibnd,iside) = xmid + 0.5 * dx;
                  Ybnd (ibnd,iside) = ymid + 0.5 * dy;
               end
            end
         end
%
%....... boundary section
%        along a horizontal grid line
%
         if na == nb && ma ~= mb
%
%.......... check lower or upper side active grid
%
            lower = true;
            n     = na;
            nstep = 1;
            if na > 1
               m = round((ma + mb) / 2);
               if icom(m,na-1) == 1
                  lower = false;
                  n     = na - 1;
                  nstep = -1;
               end
            end
%
%-----------For Riemann type boundary conditions determine if inflow is
%           positive or negative
%
            if lower
               positi {ibnd} = 'in ';
            else
               positi {ibnd} = 'out';
            end
%
%.......... then determine x and y coordinates boundary support points
%
            for iside = 1: 2
               m    = bnd.m(ibnd,iside);
               xmid = 0.5 * ( X(m,n) + X(m-1,n) );
               ymid = 0.5 * ( Y(m,n) + Y(m-1,n) );
               dx   = 0.5 * ( X(m  ,n  ) - X(m  ,n+nstep)    ...
                            + X(m-1,n  ) - X(m-1,n+nstep) );
               dy   = 0.5 * ( Y(m  ,n  ) - Y(m  ,n+nstep)    ...
                            + Y(m-1,n  ) - Y(m-1,n+nstep) );
               if type == 'UVp'
                  Xbnd   (ibnd,iside) = xmid;
                  Ybnd   (ibnd,iside) = ymid;
               elseif type == 'UVt'
                  Xbnd   (ibnd,iside) = X(m,n) + 0.5 * dx;
                  Ybnd   (ibnd,iside) = Y(m,n) + 0.5 * dy;
               elseif type == 'WL '
                  Xbnd   (ibnd,iside) = xmid + 0.5 * dx;
                  Ybnd   (ibnd,iside) = ymid + 0.5 * dy;
               end
            end
         end
      end

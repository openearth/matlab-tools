function [bndval,nfs_inf] = dethyd2dh(bndval,bnd,nfs_inf,add_inf)

% dethyd2dh : retrieves depth averaged bc (velocities) from a 3d simulation

%
% Get some general information
%

nobnd   = length(bnd.DATA);
notims  = nfs_inf.notims;
kmax    = nfs_inf.kmax;
thick   = nfs_inf.thick;
profile = add_inf.profile;

%
% Averaging needed?
%

if kmax > 1 && (strcmpi(profile,'logarithmic') || strcmpi(profile,'uniform'))

   for itim = 1: notims
      hulp(itim).value(1:nobnd,1:2,1,2) = 0.;
   end

   %
   % Cycle over all boundary points
   %

   for ibnd = 1: nobnd
       type = lower(bnd.DATA(ibnd).bndtype);

       for iside = 1: 2
           for itim = 1: notims
               switch type
                   case {'c' 'p' 'r' 'x'}
                       %
                       % Determine depth averaged value of velocity, riemann invariant
                       %
                       for k = 1: kmax
                          hulp(itim).value(ibnd,1,1,iside) = hulp(itim).value(ibnd,1,1,iside) + thick(k)*bndval(itim).value(ibnd,k,1,iside);
                       end
                   case {'z' 'n'}
                       hulp(itim).value(ibnd,1,1,iside) = bndval(itim).value(ibnd,1,1,iside);

               end
           end

           %
           % Parallel velocity component
           %

           switch type
               case {'p' 'x'}
                   for itim = 1: notims
                       for k = 1: kmax
                          hulp(itim).value(ibnd,2,1,iside) = hulp(itim).value(ibnd,2,1,iside) + thick(k)*bndval(itim).value(ibnd,k+kmax,1,iside);
                       end
                   end
           end

       end
    end

    clear bndval

    bndval = hulp;

    nfs_inf.nolay = 1;

else
    nfs_inf.nolay = kmax;
end

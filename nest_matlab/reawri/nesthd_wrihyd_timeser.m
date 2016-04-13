function wrihyd_timeser(filename,bnd,nfs_inf,bndval,add_inf)

% wrihyd_timeser : writes hydrodynamic bc to a SIMONA time series file

%
% Set some general parameters
%

no_bnd        = length(bnd.DATA)/2 ;
notims        = length(bndval);
kmax          = nfs_inf.nolay;

if isfield(add_inf,'profile')
   profile       = add_inf.profile;
else
   profile       = 'uniform';
end
%
% Open output file
%

fid = fopen(filename,'w+');

for ibnd = 1: no_bnd

   type     = lower (bnd.DATA(ibnd).bndtype);

   nolay    = 1;
   multilay = false;

   if (strcmp(type,'c') || strcmp(type,'r')) && kmax > 1 && strcmp(profile,'3d-profile')


      %
      % Velocities or Riemann invariant per Layer
      %

      nolay = kmax;
      multilay = true;
   end

   for iside = 1: 2
      i_pnt = (ibnd - 1)*2 + iside; 
      %
      % Set pointname
      %
      if isfield(bnd,'pntnr')
         pntname = ['P' num2str(bnd.pntnr(i_pnt))];
      else
         pntname  = ['P' num2str(ibnd,'%2.2i') 'A'];
         if iside == 2;  pntname  = ['P' num2str(ibnd,'%2.2i') 'B'];end
      end

      for k = 1:nolay

         %
         % Write general information
         %

         Line = ['S : ',pntname,' TID=0.0 SERIES=''','regular',''''];

         if multilay
           Line = [Line ' Layer = ' num2str(k)];
         end
         fprintf(fid, '%s\n', Line);
         Line = ['Frame = ' num2str(nfs_inf.tstart) ' ' num2str(nfs_inf.dtmin) ' ' num2str(nfs_inf.tend)];
         fprintf(fid, '%s\n', Line);
         Line = 'Values = ';
         fprintf(fid, '%s\n', Line);

         %
         % Write the series to file
         %

         for itim = 1: notims
            values(itim) =bndval(itim).value(i_pnt,k,1);
         end

         fprintf(fid,' %12.6f %12.6f %12.6f %12.6f %12.6f \n',values);
         if mod(notims,5) ~= 0; fprintf(fid,'\n');end

      end
   end
end

fclose (fid);


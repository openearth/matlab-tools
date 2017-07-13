function wrihyd_timeser(filename,bnd,nfs_inf,bndval,add_inf)

% wricon_timeser L: write transport bc to a tiemser (SIMONA) file

%
% Set some general parameters
%

no_bnd        = length(bnd.DATA)/2;
notims        = length(bndval);
kmax          = nfs_inf.kmax;
lstci         = nfs_inf.lstci;

%
% Open output file
%

fid = fopen(filename,'w+');

for l = 1: lstci
   for ibnd = 1: no_bnd

      for iside = 1: 2

      %
      % Set pointname
      %
         i_pnt = (ibnd -1)*2 + iside
         if isfield(bnd,'pntnr')
            pntname = ['P' num2str(bnd.pntnr(i_pnt))];
         else
            pntname  = ['P' num2str(ibnd,'%2.2i') 'A'];
            if iside == 2;  pntname  = ['P' num2str(ibnd,'%2.2i') 'B'];end
         end

         for k = 1:kmax

            %
            % Write general information
            %

            Line = ['TS : CO',num2str(l),' ',pntname,' CINIT=0.0 SERIES=','''','regular',''''];

            if kmax > 1
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
               values(itim) =bndval(itim).value(i_pnt,k,l,1);
            end

            fprintf(fid,' %12.6f %12.6f %12.6f %12.6f %12.6f \n',values);
            if mod(notims,5) ~= 0; fprintf(fid,'\n');end


         end
      end
   end
end

fclose (fid);


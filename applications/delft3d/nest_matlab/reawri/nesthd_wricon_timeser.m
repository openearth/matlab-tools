function wrihyd_timeser(filename,bnd,nfs_inf,bndval,add_inf)

% wricon_timeser L: write transport bc to a tiemser (SIMONA) file

%
% Set some general parameters
%

no_bnd        = length(bnd.DATA)/2;
notims        = length(bndval);
kmax          = size(bndval(1).value,2);
lstci         = size(bndval(1).value,3);

%
% Open output file
%

fid = fopen(filename,'w+');

for l = 1: lstci
    if add_inf.genconc(l)
        for ibnd = 1: no_bnd

            for iside = 1: 2

                %
                % Set pointname
                %
                i_pnt = (ibnd -1)*2 + iside;
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
                    tstart = (nfs_inf.times( 1 ) - nfs_inf.itdate)*1440. + add_inf.timeZone*60.;
                    tend   = (nfs_inf.times(end) - nfs_inf.itdate)*1440. + add_inf.timeZone*60.;
                    dtmin  = (nfs_inf.times(2) - nfs_inf.times(1))*1440 ;
                    Line = ['Frame = ' num2str(tstart) ' ' num2str(dtmin) ' ' num2str(tend)];
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
end

fclose (fid);


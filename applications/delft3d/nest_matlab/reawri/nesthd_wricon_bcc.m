function wricon_bcc(filename,bnd,nfs_inf,bndval,add_inf)

% wricon_bcc : writes transport boundary conditions to a bcc file

%
% Get some general parameters
%

no_bnd        = length(bnd.DATA);
kmax          = nfs_inf.kmax;
lstci         = nfs_inf.lstci;
namcon        = nfs_inf.namcon;
notims        = length(bndval);

%
% Fill the INFO structure (general information)
%

profile = 'uniform'; if kmax > 1 profile = '3d-profile';end
k = 0;

for ibnd = 1 : no_bnd
    if bnd.DATA(ibnd).datatype == 'T'
       for l = 1:lstci
           if add_inf.genconc(l)
               quant=namcon(l,:);
               switch lower(namcon(l,1:4))
                   case{'sali'}
                       unit='[ppt]';
                   case{'temp'}
                       unit='[oC]';
                   otherwise
                       unit='[-]';
               end

               k=k+1;
               Info.NTables=k;
               Info.Table(k).Name=['Boundary Section : ' num2str(ibnd)];
               Info.Table(k).Contents=profile;
               Info.Table(k).Location=bnd.DATA(ibnd).name;
               Info.Table(k).TimeFunction='non-equidistant';
               Info.Table(k).ReferenceTime=nfs_inf.itdate;
               Info.Table(k).TimeUnit='minutes';
               Info.Table(k).Interpolation='linear';
               Info.Table(k).Parameter(1).Name='time';
               Info.Table(k).Parameter(1).Unit='[min]';

               switch lower(profile)
                   case{'uniform'}
                       Info.Table(k).Parameter(2).Name=[quant 'End A'];
                       Info.Table(k).Parameter(2).Unit=unit;
                       Info.Table(k).Parameter(3).Name=[quant 'End B'];
                       Info.Table(k).Parameter(3).Unit=unit;
                   case{'3d-profile'}
                       j=1;
                       for kk=1:kmax
                           j=j+1;
                           Info.Table(k).Parameter(j).Name=[quant 'End A layer: ' num2str(kk)];
                           Info.Table(k).Parameter(j).Unit=unit;
                       end
                       for kk=1:kmax
                           j=j+1;
                           Info.Table(k).Parameter(j).Name=[quant 'End B layer: ' num2str(kk)];
                           Info.Table(k).Parameter(j).Unit=unit;
                       end
               end

%
% Fill Info structure with time series
%

               for itim = 1: notims
                   Info.Table(k).Data(itim,1) = nfs_inf.tstart + (itim-1)*nfs_inf.dtmin;
                   for ilay = 1: kmax
                       Info.Table(k).Data(itim,ilay+1     ) = bndval(itim).value(ibnd,ilay,l,1);
                       Info.Table(k).Data(itim,ilay+kmax+1) = bndval(itim).value(ibnd,ilay,l,2);
                   end
               end
           end
        end
    end
end

%
% Finally write to the bct file
%

ddb_bct_io('write',filename,Info);

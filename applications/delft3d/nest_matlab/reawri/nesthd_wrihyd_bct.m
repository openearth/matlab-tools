function wrihyd_bct(filename,bnd,nfs_inf,bndval,add_inf)

% wrihyd_bct : writes hydrodynamic bc to a *.bct (Delft3D-Flow) file

%
% Get some general parameters
%
% Modified 2/9/2015: bndval now point structured in stead of bnd
%                    structured

no_bnd        = length(bnd.DATA)/2;
notims        = length(bndval);
kmax          = nfs_inf.nolay;

%
% Fill the INFO structure (general information)
%

k = 0;
for ibnd = 1 : no_bnd
    quant2=[];
    unit2 =[];
    profile = 'uniform';
    if bnd.DATA(ibnd).datatype == 'T'
        k=k+1;
        switch lower(bnd.DATA(ibnd).bndtype)
            case{'z'}
                quant='Water elevation (Z)  ';
                unit='[m]';
            case{'c'}
                quant='Current         (C)  ';
                unit='[m/s]';
                profile = add_inf.profile;
            case{'n'}
                quant='Neumann         (N)  ';
                unit='[-]';
            case{'r'}
                quant='Riemann         (R)  ';
                unit='[m/s]';
                profile = add_inf.profile;
            case{'x'}
                quant='Riemann         (R)  ';
                unit='[m/s]';
                quant2='Parallel Vel.   (C)  ';
                unit2='[m/s]';
                profile = add_inf.profile;
            case{'p'}
                quant='Current         (C)  ';
                unit='[m/s]';
                quant2='Parallel Vel.   (C)  ';
                unit2='[m/s]';
                profile = add_inf.profile;
        end

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
            case{'uniform' 'logarithmic'}
                Info.Table(k).Parameter(2).Name=[quant 'End A'];
                Info.Table(k).Parameter(2).Unit=unit;
                Info.Table(k).Parameter(3).Name=[quant 'End B'];
                Info.Table(k).Parameter(3).Unit=unit;
                if ~isempty(quant2)
                    Info.Table(k).Parameter(4).Name=[quant2 'End A'];
                    Info.Table(k).Parameter(4).Unit=unit2;
                    Info.Table(k).Parameter(5).Name=[quant2 'End B'];
                    Info.Table(k).Parameter(5).Unit=unit2;
                end
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
                if ~isempty(quant2)
                    for kk=1:kmax
                        j=j+1;
                        Info.Table(k).Parameter(j).Name=[quant2 'End A layer: ' num2str(kk)];
                        Info.Table(k).Parameter(j).Unit=unit2;
                    end
                    for kk=1:kmax
                        j=j+1;
                        Info.Table(k).Parameter(j).Name=[quant2 'End B layer: ' num2str(kk)];
                        Info.Table(k).Parameter(j).Unit=unit2;
                    end
                end
        end

%
% Fill Info structure with time series
%

        for itim = 1: notims
           Info.Table(k).Data(itim,1) = nfs_inf.tstart + (itim-1)*nfs_inf.dtmin;
           switch bnd.DATA(ibnd).bndtype
               case{'Z' 'N'}
                  Info.Table(k).Data(itim,2) = bndval(itim).value((ibnd - 1)*2 + 1,1,1);
                  Info.Table(k).Data(itim,3) = bndval(itim).value((ibnd - 1)*2 + 2,1,1);
               case{'C' 'R' 'X' 'P'}
                   for ilay = 1: kmax
                       Info.Table(k).Data(itim,ilay+1     ) = bndval(itim).value((ibnd - 1)*2 + 1,ilay,1);
                       Info.Table(k).Data(itim,ilay+kmax+1) = bndval(itim).value((ibnd - 1)*2 + 2,ilay,1);
                   end
                   switch bnd.DATA(ibnd).bndtype
                      case{'X' 'P'}
                         for ilay = 1: kmax
                            Info.Table(k).Data(itim,ilay+2*kmax+1) = bndval(itim).value((ibnd - 1)*2 + 1,ilay+kmax,1);
                            Info.Table(k).Data(itim,ilay+3*kmax+1) = bndval(itim).value((ibnd - 1)*2 + 2,ilay+kmax,1,2);
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

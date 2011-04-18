function openBoundaries=nesthd2_hydro(openBoundaries,vertGrid,s,nest,zcor)

cr1=0;
cr2=0;

for i=1:length(openBoundaries)
    
    disp(['   Boundary ' openBoundaries(i).name ' - ' num2str(i) ' of ' num2str(length(openBoundaries))]);
    
    
    bnd=openBoundaries(i);
    
    switch lower(bnd.type)
        case{'z','r','x'}
            % Water levels
            % A
            m=bnd.M1;
            n=bnd.N1;
            j= find(s.wl.m==m & s.wl.n==n,1);
            wl(:,1)=nest.wl(:,j);
            dps(1)=nest.dps(j);
            
            % B
            m=bnd.M2;
            n=bnd.N2;
            j= find(s.wl.m==m & s.wl.n==n,1);
            wl(:,2)=nest.wl(:,j);
            dps(2)=nest.dps(j);
            
            wl=wl+zcor;
            
    end
    
    switch lower(bnd.type)
        case{'c','r','p','x'}
            % Currents
            
            % A
            m=bnd.M1;
            n=bnd.N1;
            j=find(s.wl.m==m & s.wl.n==n,1);
            u(:,:,1)=nest.u(:,:,j);
            v(:,:,1)=nest.v(:,:,j);
            z(:,:,1)=nest.z(:,:,j);
            
            % B
            m=bnd.M2;
            n=bnd.N2;
            j=find(s.wl.m==m & s.wl.n==n,1);
            u(:,:,2)=nest.u(:,:,j);
            v(:,:,2)=nest.v(:,:,j);
            z(:,:,2)=nest.z(:,:,j);
            
            u(isnan(u))=0;
            v(isnan(v))=0;

            for it=1:length(nest.t)
                tua=squeeze(u(it,:,1))';
                tub=squeeze(u(it,:,2))';
                tva=squeeze(v(it,:,1))';
                tvb=squeeze(v(it,:,2))';
                ua = tua.*cos(bnd.alphau(1)) + tva.*sin(bnd.alphau(1));
                ub = tub.*cos(bnd.alphau(2)) + tvb.*sin(bnd.alphau(2));
                va = tua.*cos(bnd.alphav(1)) + tva.*sin(bnd.alphav(1));
                vb = tub.*cos(bnd.alphav(2)) + tvb.*sin(bnd.alphav(2));
                u(it,:,1)=ua;
                u(it,:,2)=ub;
                v(it,:,1)=va;
                v(it,:,2)=vb;
            end
            
            dp(1)=-openBoundaries(i).depth(1);
            dp(2)=-openBoundaries(i).depth(2);
            
            if vertGrid.KMax>1

                % Now interpolate over water column
                
                if strcmpi(vertGrid.layerType,'z')
                    dplayer=squeeze(GetLayerDepths(dp,vertGrid.thick,vertGrid.zBot,vertGrid.zTop));
                    dplayer=fliplr(dplayer);
                else
                    dplayer=squeeze(GetLayerDepths(dp,vertGrid.thick));
                end
                
                for it=1:length(nest.t)
                    
                    z0=squeeze(z(it,:,1));
                    u0=squeeze(u(it,:,1));
                    v0=squeeze(v(it,:,1));
                    
                    imin=find(z0>-1e9, 1 );
                    imax=find(z0>-1e9, 1, 'last' );
                    z0=z0(imin:imax);
                    u0=u0(imin:imax);
                    v0=v0(imin:imax);
                    if z0(end)>z0(1)
                        imin=find(z0>z0(1), 1 );
                        imax=find(z0<z0(end), 1, 'last' );
                    else
                        imin=find(z0<=z0(1), 1 );
                        imax=find(z0>=z0(end), 1, 'last' );
                    end
                    z0=z0(imin:imax);
                    u0=u0(imin:imax);
                    v0=v0(imin:imax);
                    
                    if z0(end)>z0(1)
                        z0=[-12000 z0 12000];
                    else
                        z0=[12000 z0 -12000];
                    end
                    u0=[u0(1) u0 u0(end)];
                    v0=[v0(1) v0 v0(end)];
                    u1(it,:,1)=interp1(z0,u0,squeeze(-dplayer(1,:)))';
                    v1(it,:,1)=interp1(z0,v0,squeeze(-dplayer(1,:)))';
                    
                    z0=squeeze(z(it,:,2));
                    u0=squeeze(u(it,:,2));
                    v0=squeeze(v(it,:,2));
                    
                    imin=find(z0>-1e9, 1 );
                    imax=find(z0>-1e9, 1, 'last' );
                    z0=z0(imin:imax);
                    u0=u0(imin:imax);
                    v0=v0(imin:imax);
                    if z0(end)>z0(1)
                        imin=find(z0>z0(1), 1 );
                        imax=find(z0<z0(end), 1, 'last' );
                    else
                        imin=find(z0<=z0(1), 1 );
                        imax=find(z0>=z0(end), 1, 'last' );
                    end
                    z0=z0(imin:imax);
                    u0=u0(imin:imax);
                    v0=v0(imin:imax);
                    
                    if z0(end)>z0(1)
                        z0=[-12000 z0 12000];
                    else
                        z0=[12000 z0 -12000];
                    end
                    u0=[u0(1) u0 u0(end)];
                    v0=[v0(1) v0 v0(end)];
                    u1(it,:,2)=interp1(z0,u0,squeeze(-dplayer(2,:)));
                    v1(it,:,2)=interp1(z0,v0,squeeze(-dplayer(2,:)));
                end
            else
                u1=u;
                v1=v;
            end
            
    end
    
    openBoundaries(i).timeSeriesT=[];
    openBoundaries(i).timeSeriesA=[];
    openBoundaries(i).timeSeriesB=[];
    openBoundaries(i).timeSeriesAV=[];
    openBoundaries(i).timeSeriesBV=[];


    switch lower(bnd.type)
        case{'z'}
            openBoundaries(i).timeSeriesT=nest.t;
            openBoundaries(i).timeSeriesA=squeeze(wl(:,1));
            openBoundaries(i).timeSeriesB=squeeze(wl(:,2));
        case{'c'}
            openBoundaries(i).timeSeriesT=nest.t;
            openBoundaries(i).timeSeriesA=squeeze(u1(:,:,1));
            openBoundaries(i).timeSeriesB=squeeze(u1(:,:,2));
        case{'r'}
            openBoundaries(i).timeSeriesT=nest.t;
            calfac=1.0;
            acor1=-dps(1)/dp(1);
            acor1=max(min(acor1,2.0),0.5);
            acor2=-dps(2)/dp(2);
            acor2=max(min(acor2,2.0),0.5);
            acor1=acor1*calfac;
            acor2=acor2*calfac;
            %             cr1=cr1+acor1;
            %             cr2=cr2+acor2;
            for k=1:vertGrid.KMax
                switch lower(openBoundaries(i).side)
                    case{'left','bottom'}
                        r1(:,k)=acor1*squeeze(u1(:,k,1)) + squeeze(wl(:,1))*sqrt(9.81/dp(1));
                        r2(:,k)=acor2*squeeze(u1(:,k,2)) + squeeze(wl(:,2))*sqrt(9.81/dp(2));
                    case{'top','right'}
                        r1(:,k)=acor1*squeeze(u1(:,k,1)) - squeeze(wl(:,1))*sqrt(9.81/dp(1));
                        r2(:,k)=acor2*squeeze(u1(:,k,2)) - squeeze(wl(:,2))*sqrt(9.81/dp(2));
                end
            end
            openBoundaries(i).timeSeriesA=r1;
            openBoundaries(i).timeSeriesB=r2;
        case{'x'}
            openBoundaries(i).timeSeriesT=nest.t;
            for k=1:vertGrid.KMax
                switch lower(openBoundaries(i).side)
                    case{'left','bottom'}
                        r1(:,k)=squeeze(u1(:,k,1)) + squeeze(wl(:,1))*sqrt(9.81/dp(1));
                        r2(:,k)=squeeze(u1(:,k,2)) + squeeze(wl(:,2))*sqrt(9.81/dp(2));
                    case{'top','right'}
                        r1(:,k)=squeeze(u1(:,k,1)) - squeeze(wl(:,1))*sqrt(9.81/dp(1));
                        r2(:,k)=squeeze(u1(:,k,2)) - squeeze(wl(:,2))*sqrt(9.81/dp(2));
                end
            end
            openBoundaries(i).timeSeriesA=r1;
            openBoundaries(i).timeSeriesB=r2;
            openBoundaries(i).timeSeriesAV=squeeze(v1(:,:,1));
            openBoundaries(i).timeSeriesBV=squeeze(v1(:,:,2));
        case{'p'}
            openBoundaries(i).timeSeriesT=nest.t;
            openBoundaries(i).timeSeriesA=squeeze(u1(:,:,1));
            openBoundaries(i).timeSeriesB=squeeze(u1(:,:,2));
            openBoundaries(i).timeSeriesAV=squeeze(v1(:,:,1));
            openBoundaries(i).timeSeriesBV=squeeze(v1(:,:,2));
    end
    
    openBoundaries(i).profile='uniform';
    if vertGrid.KMax>1
        switch lower(bnd.type)
            case{'c','r','x','p'}
                openBoundaries(i).profile='3d-profile';
        end
    end

end

% cr1=cr1/Flow.NrOpenBoundaries
% cr2=cr2/Flow.NrOpenBoundaries

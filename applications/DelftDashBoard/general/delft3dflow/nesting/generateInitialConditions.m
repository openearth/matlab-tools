function generateInitialConditions(flow,opt,par,ii,dplayer,fname)

mmax=size(flow.gridXZ,1)+1;
nmax=size(flow.gridYZ,2)+1;
data=zeros(mmax,nmax,flow.KMax);

if isfield(opt,par)
    
    switch opt.(par)(ii).IC.source
        case 4
            pars=[0 1000;opt.(par)(ii).IC.constant opt.(par)(ii).IC.constant];
        case 5
            pars=opt.(par)(ii).IC.profile';
    end
    
    switch opt.(par)(ii).IC.source
        
        case{4,5}
            % Constant or profile
            depths=pars(1,:);
            vals=pars(2,:);
            if depths(2)>depths(1)
                depths=[-10000 depths 10000];
            else
                depths=[10000 depths -10000];
            end
            vals =[vals(1) vals vals(end)];
            data=interp1(depths,vals,dplayer);
            u=data;
            v=data;
            
        case{2,3}
            % File
            
            xz=flow.gridXZ;
            xz=mod(xz,360);
            yz=flow.gridYZ;
            nans=zeros(mmax,nmax);
            nans(nans==0)=NaN;
            xxz=nans;
            xxz(1:end-1,1:end-1)=xz;
            xz=xxz;
            yyz=nans;
            yyz(1:end-1,1:end-1)=yz;
            yz=yyz;
            
            
            switch lower(par)
                case{'current'}
                    dataname=opt.(par)(ii).IC.file_u;
                    s=load(dataname);
                    dataname=opt.(par)(ii).IC.file_v;
                    sv=load(dataname);
                    s.lon=mod(s.lon,360);
                    sv.lon=mod(sv.lon,360);
                otherwise
                    dataname=opt.(par)(ii).IC.file;
                    s=load(dataname);
                    s.lon=mod(s.lon,360);
            end
            
            
            times=s.time;
            
            ts=flow.startTime;
            it1=find(times<=ts, 1, 'last' );
            it2=find(times>ts, 1, 'first' );
            t0=times(it1);
            t1=times(it2);
            m1=(t1-ts)/(t1-t0);
            m2=(ts-t0)/(t1-t0);
            
            switch lower(par)
                case{'current'}
                    
                    xu=zeros(size(xz));
                    yu=xu;
                    xv=xu;
                    yv=xu;
                    dxu=xu;
                    dyu=xu;
                    dxv=xu;
                    dyv=xu;
                    alphau=xu;
                    alphav=xu;
                    
                    % Get xu,yu,xv,yv and alpha
                    
                    xu=zeros(size(xz));
                    yu=xu;
                    xv=xu;
                    yv=xu;
                    alphau=xu;
                    alphav=xu;
                    
                    xg=flow.gridX;
                    yg=flow.gridY;
                    
                    xg=mod(xg,360);
                    
                    % U Points
                    xu(1:end-1,2:end-1)=0.5*(xg(:,1:end-1)+xg(:,2:end));
                    yu(1:end-1,2:end-1)=0.5*(yg(:,1:end-1)+yg(:,2:end));
                    dx=xg(:,2:end)-xg(:,1:end-1);
                    dy=yg(:,2:end)-yg(:,1:end-1);
                    
                    for k=1:flow.KMax
                        alphau(1:end-1,2:end-1,k)=atan2(dy,dx)-0.5*pi;
                    end
                    
                    velu1=interpolate3D(xu,yu,dplayer,s,it1,'u');
                    velu2=interpolate3D(xu,yu,dplayer,s,it2,'u');
                    velv1=interpolate3D(xu,yu,dplayer,sv,it1,'v');
                    velv2=interpolate3D(xu,yu,dplayer,sv,it2,'v');
                    
                    uvelu=m1*velu1+m2*velu2;
                    vvelu=m1*velv1+m2*velv2;
                    
                    u = uvelu.*cos(alphau) + vvelu.*sin(alphau);
                    
                    u(xu==0)=0;
                    
                    % V Points
                    xv(2:end-1,1:end-1)=0.5*(xg(1:end-1,:)+xg(2:end,:));
                    yv(2:end-1,1:end-1)=0.5*(yg(1:end-1,:)+yg(2:end,:));
                    dx=xg(2:end,:)-xg(1:end-1,:);
                    dy=yg(2:end,:)-yg(1:end-1,:);
                    for k=1:flow.KMax
                        alphav(2:end-1,1:end-1,k)=atan2(dy,dx)+0.5*pi;
                    end
                    
                    velu1=interpolate3D(xv,yv,dplayer,s,it1,'u');
                    velu2=interpolate3D(xv,yv,dplayer,s,it2,'u');
                    velv1=interpolate3D(xv,yv,dplayer,sv,it1,'v');
                    velv2=interpolate3D(xv,yv,dplayer,sv,it2,'v');
                    
                    uvelv=m1*velu1+m2*velu2;
                    vvelv=m1*velv1+m2*velv2;
                    
                    v = uvelv.*cos(alphav) + vvelv.*sin(alphav);
                    
                otherwise
                    s1=interpolate3D(xz,yz,dplayer,s,it1);
                    s2=interpolate3D(xz,yz,dplayer,s,it2);
                    data=m1*s1+m2*s2;
            end
    end
end

if strcmpi(flow.vertCoord,'z')
    k1=flow.KMax;
    k2=1;
    dk=-1;
else
    k1=1;
    k2=flow.KMax;
    dk=1;
end
        
switch lower(par)
    case{'current'}
        for k=k1:dk:k2
            dd=squeeze(u(:,:,k));
            dd=internaldiffusion(dd,'nst',5);
            wldep('append',fname,dd,'negate','n','bndopt','n');
        end
        for k=k1:dk:k2
            dd=squeeze(v(:,:,k));
            dd=internaldiffusion(dd,'nst',5);
            wldep('append',fname,dd,'negate','n','bndopt','n');
        end
    otherwise
        for k=k1:dk:k2
            dd=squeeze(data(:,:,k));
            dd=internaldiffusion(dd,'nst',5);
            wldep('append',fname,dd,'negate','n','bndopt','n');
        end
end

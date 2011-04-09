function GenerateInitialConditions(Flow,par,ii,dplayer)

switch lower(Flow.(par)(ii).IC.Source)
    case{'constant'}
        pars=[0 Flow.(par)(ii).IC.Constant]';
        pars=[0 1000;pars pars];
    case{'profile'}
        pars=Flow.(par)(ii).IC.Profile';
end

switch lower(Flow.(par)(ii).IC.Source)

    case{'constant','profile'}
    
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
                
    case{'file'}

        mmax=size(Flow.GridXZ,1)+1;
        nmax=size(Flow.GridYZ,2)+1;

        xz=Flow.GridXZ;
        yz=Flow.GridYZ;
        nans=zeros(mmax,nmax);
        nans(nans==0)=NaN;
        xxz=nans;
        xxz(1:end-1,1:end-1)=xz;
        xz=xxz;
        yyz=nans;
        yyz(1:end-1,1:end-1)=yz;
        yz=yyz;

        fname=Flow.(par)(ii).IC.File;
        
        load(fname);
        
        s.lon=mod(s.lon,360);
                
        times=s.time;

        ts=Flow.StartTime;
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
                
                xg=Flow.GridX;
                yg=Flow.GridY;

                % U Points
                xu(1:end-1,2:end-1)=0.5*(xg(:,1:end-1)+xg(:,2:end));
                yu(1:end-1,2:end-1)=0.5*(yg(:,1:end-1)+yg(:,2:end));
                dx=xg(:,2:end)-xg(:,1:end-1);
                dy=yg(:,2:end)-yg(:,1:end-1);
                
                for k=1:Flow.KMax
                    alphau(1:end-1,2:end-1,k)=atan2(dy,dx)-0.5*pi;
                end

                velu1=Interpolate3D(Flow,xu,yu,dplayer,s,it1,'u');
                velu2=Interpolate3D(Flow,xu,yu,dplayer,s,it2,'u');
                velv1=Interpolate3D(Flow,xu,yu,dplayer,s,it1,'v');
                velv2=Interpolate3D(Flow,xu,yu,dplayer,s,it2,'v');
                
                uvelu=m1*velu1+m2*velu2;
                vvelu=m1*velv1+m2*velv2;

                u = uvelu.*cos(alphau) + vvelu.*sin(alphau);
                
                u(xu==0)=0;

                % V Points
                xv(2:end-1,1:end-1)=0.5*(xg(1:end-1,:)+xg(2:end,:));
                yv(2:end-1,1:end-1)=0.5*(yg(1:end-1,:)+yg(2:end,:));
                dx=xg(2:end,:)-xg(1:end-1,:);
                dy=yg(2:end,:)-yg(1:end-1,:);
                for k=1:Flow.KMax
                    alphav(2:end-1,1:end-1,k)=atan2(dy,dx)+0.5*pi;
                end
               
                velu1=Interpolate3D(Flow,xv,yv,dplayer,s,it1,'u');
                velu2=Interpolate3D(Flow,xv,yv,dplayer,s,it2,'u');
                velv1=Interpolate3D(Flow,xv,yv,dplayer,s,it1,'v');
                velv2=Interpolate3D(Flow,xv,yv,dplayer,s,it2,'v');
                
                uvelv=m1*velu1+m2*velu2;
                vvelv=m1*velv1+m2*velv2;
                
                v = uvelv.*cos(alphav) + vvelv.*sin(alphav);
%                v = -uvelv.*sin(alphav) + vvelv.*cos(alphav);

            otherwise
                s1=Interpolate3D(Flow,xz,yz,dplayer,s,it1);
                s2=Interpolate3D(Flow,xz,yz,dplayer,s,it2);
                data=m1*s1+m2*s2;
        end
end

if strcmpi(Flow.VertCoord,'z')
    k1=Flow.KMax;
    k2=1;
    dk=-1;
else
    k1=1;
    k2=Flow.KMax;
    dk=1;
end
        
switch lower(par)
    case{'current'}
        for k=k1:dk:k2
            dd=squeeze(u(:,:,k));
            dd=internaldiffusion(dd,'nst',5);
            wldep_mvo('append',[Flow.OutputDir Flow.IniFile],dd,'negate','n','bndopt','n');
        end
        for k=k1:dk:k2
            dd=squeeze(v(:,:,k));
            dd=internaldiffusion(dd,'nst',5);
            wldep_mvo('append',[Flow.OutputDir Flow.IniFile],dd,'negate','n','bndopt','n');
        end
    otherwise
        for k=k1:dk:k2
            dd=squeeze(data(:,:,k));
            dd=internaldiffusion(dd,'nst',5);
            wldep_mvo('append',[Flow.OutputDir Flow.IniFile],dd,'negate','n','bndopt','n');
        end
end

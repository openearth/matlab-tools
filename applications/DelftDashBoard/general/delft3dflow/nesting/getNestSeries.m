function nest=getNestSeries(hisfile,t0,t1,s,stride,varargin)

if nargin>2
    opt=varargin{1};
else
    opt='hydro';
end

fid=qpfopen(hisfile);
stations = qpread(fid,1,'water level','stations');
times = qpread(fid,1,'water level','times');

if ~isempty(t0)
    it1=find(times==t0);
    it2=find(times==t1);
else
    it1=1;
    it2=length(times);
end

times = times(it1:stride:it2);
nt=length(times);

vs_use(hisfile,'quiet');
kmax=vs_get('his-const','KMAX','quiet');

isteps=it1:stride:it2;

% First check which stations need to be downloaded

nrused=0;
mused=[];
nused=[];
for k=1:length(s.wl.m)
    for i=1:4
        m=s.wl.mm(k,i);
        n=s.wl.nn(k,i);
        if m>0
            ii=find(mused==m&nused==n, 1);
            if isempty(ii)
                nrused=nrused+1;
                mused(nrused)=m;
                nused(nrused)=n;
                m=[repmat(' ',1,5-length(num2str(m))) num2str(m)];
                n=[repmat(' ',1,5-length(num2str(n))) num2str(n)];
                st=['(M,N)=(' m ',' n ')'];
                istation(nrused)=strmatch(st,stations);
            end
        end
    end
end
for k=1:length(s.vel.m)
    for i=1:4
        m=s.vel.mm(k,i);
        n=s.vel.nn(k,i);
        if m>0
            ii=find(mused==m&nused==n, 1);
            if isempty(ii)
                nrused=nrused+1;
                mused(nrused)=m;
                nused(nrused)=n;
                m=[repmat(' ',1,5-length(num2str(m))) num2str(m)];
                n=[repmat(' ',1,5-length(num2str(n))) num2str(n)];
                st=['(M,N)=(' m ',' n ')'];
                istation(nrused)=strmatch(st,stations);
            end
        end
    end
end

u=[];
v=[];
z=[];
wl=[];

% bed levels

dps00=qpread(fid,1,'bed level at station','data',1,istation);
for k=1:length(s.wl.m)
    for i=1:4
        m=s.wl.mm(k,i);
        n=s.wl.nn(k,i);
        if m>0
            ii= mused==m&nused==n;
            dps0(i)=squeeze(dps00.Val(ii));
        else
            %                dps0(i)=zeros(nt,1);
            dps0(i)=0;
        end
    end
    dps(k)=dps0*squeeze(s.wl.w(k,:)');
end

%% Hydrodynamics    

switch lower(opt)
    case{'hydro','both'}
        
    % water levels

    wl00=qpread(fid,1,'water level','data',isteps,istation);
    for k=1:length(s.wl.m)
        for i=1:4
            m=s.wl.mm(k,i);
            n=s.wl.nn(k,i);
            if m>0
                ii= mused==m&nused==n;
                wl0(:,i)=squeeze(wl00.Val(:,ii));
            else
                wl0(:,i)=zeros(nt,1);
            end
        end
        wl(:,k)=wl0*squeeze(s.wl.w(k,:)');
    end

    % velocities

    if kmax==1
        vel00=qpread(fid,1,'depth averaged velocity','griddata',isteps,istation);
        vel00.Z=zeros(size(vel00.XComp));
    else
        vel00=qpread(fid,1,'horizontal velocity','griddata',isteps,istation);
    end
    
    err=0;
    for k=1:length(istation)
        if isnan(nanmax(nanmax(squeeze(vel00.XComp(:,k,:)),1)))
            disp(['Only NaNs found for support point (' num2str(mused(k)) ',' num2str(nused(k)) ')']);
            err=1;
        end
    end
    if err
        error('Boundary generation stopped');
    end

    u0=zeros(nt,kmax,4);
    v0=zeros(nt,kmax,4);
    z0=zeros(nt,kmax,4);

    u=zeros(nt,kmax,length(s.vel.m));
    v=u;
    z=u;
    
    for k=1:length(s.vel.m)
        w=squeeze(s.vel.w(k,:)');
        for i=1:4
            m=s.vel.mm(k,i);
            n=s.vel.nn(k,i);
            if m>0
                ii=find(mused==m&nused==n);
                u0(:,:,i)=squeeze(vel00.XComp(:,ii,:));
                v0(:,:,i)=squeeze(vel00.YComp(:,ii,:));
                z0(:,:,i)=squeeze(vel00.Z(:,ii,:));
            else
                u0(:,:,i)=zeros(nt,kmax,1);
                v0(:,:,i)=zeros(nt,kmax,1);
                z0(:,:,i)=zeros(nt,kmax,1);
            end
            u0(:,:,i)=u0(:,:,i)*w(i);
            v0(:,:,i)=v0(:,:,i)*w(i);
            z0(:,:,i)=z0(:,:,i)*w(i);
        end
        u(:,:,k)=sum(u0,3);
        v(:,:,k)=sum(v0,3);
        z(:,:,k)=sum(z0,3);
    end
    clear u0 v0 z0 w vel00
end

%% Constituents

namc=vs_get('his-const','NAMCON');
for ic=1:size(namc,1)
    nest.namcon{ic}=deblank(namc(ic,:));
end

switch lower(opt)
    case{'transport','both'}
        
        for ic=1:length(nest.namcon)
            
            par=nest.namcon{ic};
            
            % Salinity
            %    if Flow.salinity.include
            
            sal00=qpread(fid,1,par,'griddata',isteps,istation);
            sal0=zeros(nt,kmax,4);
            sal0(sal0==0)=NaN;
            sal=zeros(nt,kmax,length(s.wl.m));
            sal(sal==0)=NaN;
            z=sal;
            
            % Loop past every support point
            for k=1:length(s.wl.m)
                
                % Loop past surrounding points
                for i=1:4
                    m=s.wl.mm(k,i);
                    n=s.wl.nn(k,i);
                    if m>0
                        ii= find(mused==m&nused==n,1);
                        sal0(:,:,i)=squeeze(sal00.Val(:,ii,:));
                        z0(:,:,i)=squeeze(sal00.Z(:,ii,:));
                    else
                        sal0(:,:,i)=zeros(nt,kmax,1);
                        z0(:,:,i)=zeros(nt,kmax,1);
                    end
                end
                
                % Apply weighting factors
                w=zeros(size(sal0));
                w0=squeeze(s.wl.w(k,:)');
                for i=1:4
                    w(:,:,i)=w0(i);
                end
                w(isnan(sal0))=NaN;
                wsum=nansum(w,3);
                wmult=1./wsum;
                for i=1:4
                    w(:,:,i)=w(:,:,i).*wmult;
                end
                salw=w.*sal0;
                zw=w.*z0;
                sal(:,:,k)=nansum(salw,3);
                z(:,:,k)=nansum(zw,3);
                
                nest.constituent(ic).data=sal;

            end
        end
end

nest.t=times;
nest.dps=dps;
nest.wl=wl;
nest.u=u;
nest.v=v;
nest.z=z;



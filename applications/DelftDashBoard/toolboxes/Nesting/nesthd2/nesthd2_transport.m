function openBoundaries=nesthd2_transport(openBoundaries,vertGrid,s,nest)

for i=1:length(openBoundaries)
    
    disp(['   Boundary ' openBoundaries(i).name ' - ' num2str(i) ' of ' num2str(length(openBoundaries))]);

    namcon=nest.namcon;

    nsed=0;
    ntrac=0;
    
    bnd=openBoundaries(i);
    
    for j=1:length(namcon)
        nm=lower(namcon{j});       
        nm=nm(1:min(8,length(nm)));
        switch nm
            case{'salinity'}
                bnd=fillbnd(bnd,vertGrid,s,nest,j);
                openBoundaries(i).salinity.nrTimeSeries=bnd.data.nrTimeSeries;
                openBoundaries(i).salinity.timeSeriesT=bnd.data.timeSeriesT;
                openBoundaries(i).salinity.timeSeriesA=bnd.data.timeSeriesA;
                openBoundaries(i).salinity.timeSeriesB=bnd.data.timeSeriesB;
                openBoundaries(i).salinity.profile=bnd.data.profile;
            case{'temperat'}
                bnd=fillbnd(bnd,vertGrid,s,nest,j);
                openBoundaries(i).temperature.nrTimeSeries=bnd.data.nrTimeSeries;
                openBoundaries(i).temperature.timeSeriesT=bnd.data.timeSeriesT;
                openBoundaries(i).temperature.timeSeriesA=bnd.data.timeSeriesA;
                openBoundaries(i).temperature.timeSeriesB=bnd.data.timeSeriesB;
                openBoundaries(i).temperature.profile=bnd.data.profile;
            case{'sediment'}
                nsed=nsed+1;
                bnd=fillbnd(bnd,vertGrid,s,nest,j);
                openBoundaries(i).sediment(nsed).nrTimeSeries=bnd.data.nrTimeSeries;
                openBoundaries(i).sediment(nsed).timeSeriesT=bnd.data.timeSeriesT;
                openBoundaries(i).sediment(nsed).timeSeriesA=bnd.data.timeSeriesA;
                openBoundaries(i).sediment(nsed).timeSeriesB=bnd.data.timeSeriesB;
                openBoundaries(i).sediment(nsed).profile=bnd.data.profile;
            otherwise
                ntrac=ntrac+1;
                bnd=fillbnd(bnd,vertGrid,s,nest,j);
                openBoundaries(i).tracer(ntrac).nrTimeSeries=bnd.data.nrTimeSeries;
                openBoundaries(i).tracer(ntrac).timeSeriesT=bnd.data.timeSeriesT;
                openBoundaries(i).tracer(ntrac).timeSeriesA=bnd.data.timeSeriesA;
                openBoundaries(i).tracer(ntrac).timeSeriesB=bnd.data.timeSeriesB;
                openBoundaries(i).tracer(ntrac).profile=bnd.data.profile;
        end
            
    end
    
end

%%
function bnd=fillbnd(bnd,vertGrid,s,nest,ipar)

par=nest.constituent(ipar).data;

% A
m=bnd.M1;
n=bnd.N1;
j=find(s.wl.m==m & s.wl.n==n,1);
val(:,:,1)=par(:,:,j);
z(:,:,1)=nest.z(:,:,j);

% B
m=bnd.M2;
n=bnd.N2;
j=find(s.wl.m==m & s.wl.n==n,1);
val(:,:,2)=par(:,:,j);
z(:,:,2)=nest.z(:,:,j);

% Now interpolate over water column

dp(1)=-bnd.depth(1);
dp(2)=-bnd.depth(2);
if strcmpi(vertGrid.layerType,'z')
    dplayer=squeeze(GetLayerDepths(dp,vertGrid.thick,vertGrid.zBot,vertGrid.zTop));
    dplayer=fliplr(dplayer);
else
    dplayer=squeeze(GetLayerDepths(dp,vertGrid.thick));
end

if length(vertGrid.thick)==1
    dplayer=dplayer';
end

val1=zeros(length(nest.t),length(vertGrid.thick),2);

for it=1:length(nest.t)
    
    if strcmpi(vertGrid.layerType,'z')
        % A
        z0=squeeze(z(it,:,1));
        val0=squeeze(val(it,:,1));
        imin=find(~isnan(z0)&~isnan(val0), 1 );
        imax=find(~isnan(z0)&~isnan(val0), 1, 'last' );
        z0=z0(imin:imax);
        val0=val0(imin:imax);
        
        if isempty(imin)
            error(['Boundary ' bnd.name ' - end A contains only NaNs']);
        end
        
        dpa=squeeze(-dplayer(1,:));
        vala=interp1(z0,val0,dpa);
        
        % B
        z0=squeeze(z(it,:,2));
        val0=squeeze(val(it,:,2));
        imin=find(~isnan(z0)&~isnan(val0), 1 );
        imax=find(~isnan(z0)&~isnan(val0), 1, 'last' );
        z0=z0(imin:imax);
        val0=val0(imin:imax);
        
        if isempty(imin)
            error(['Boundary ' bnd.name ' - end B contains only NaNs']);
        end
        
        dpb=squeeze(-dplayer(2,:));
        valb=interp1(z0,val0,dpb);
        
        anotb=find(~isnan(vala) & isnan(valb));
        valb(anotb)=vala(anotb);
        
        bnota=find(~isnan(valb) & isnan(vala));
        vala(bnota)=valb(bnota);
        
        imin=find(~isnan(vala), 1 );
        imax=find(~isnan(vala), 1, 'last' );
        if imin>1
            vala(1:imin-1)=vala(imin);
        end
        if imax<length(vala)
            vala(imax+1:end)=vala(imax);
        end
        
        imin=find(~isnan(valb), 1 );
        imax=find(~isnan(valb), 1, 'last' );
        if imin>1
            valb(1:imin-1)=valb(imin);
        end
        if imax<length(valb)
            valb(imax+1:end)=valb(imax);
        end
        
        val1(it,:,1)=vala;
        val1(it,:,2)=valb;
        
    else
        % A
        z0=squeeze(z(it,:,1));
        val0=squeeze(val(it,:,1));
        imin=find(~isnan(z0)&~isnan(val0), 1 );
        imax=find(~isnan(z0)&~isnan(val0), 1, 'last' );
        z0=z0(imin:imax);
        val0=val0(imin:imax);
        
        if isempty(imin)
            error(['Boundary ' bnd.name ' - end A contains only NaNs']);
        end
        
        if z0(end)>z0(1)
            z0=[-12000 z0 12000];
        else
            z0=[12000 z0 -12000];
        end
        val0=[val0(1) val0 val0(end)];
        val1(it,:,1)=interp1(z0,val0,squeeze(-dplayer(1,:)));
        
        % B
        z0=squeeze(z(it,:,2));
        val0=squeeze(val(it,:,2));
        
        imin=find(~isnan(z0)&~isnan(val0), 1 );
        imax=find(~isnan(z0)&~isnan(val0), 1, 'last' );
        z0=z0(imin:imax);
        val0=val0(imin:imax);
        
        if isempty(imin)
            error(['Boundary ' bnd.name ' - end B contains only NaNs']);
        end
        
        if z0(end)>z0(1)
            z0=[-12000 z0 12000];
        else
            z0=[12000 z0 -12000];
        end
        val0=[val0(1) val0 val0(end)];
        val1(it,:,2)=interp1(z0,val0,squeeze(-dplayer(2,:)));
        
    end
end

bnd.data.nrTimeSeries=length(nest.t);
bnd.data.timeSeriesT = nest.t;
bnd.data.timeSeriesA = squeeze(val1(:,:,1));
bnd.data.timeSeriesB = squeeze(val1(:,:,2));
if vertGrid.KMax>1
    bnd.data.profile='3d-profile';
else
    bnd.data.profile='uniform';
end
    
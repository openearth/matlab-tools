function [times,u,v]=GenerateVelocitiesFromFile(Flow,dplayer)

t0=Flow.StartTime;
t1=Flow.StopTime;
dt=Flow.BctTimeStep;

nr=Flow.NrOpenBoundaries;
for i=1:nr
    dp(i,1)=-Flow.OpenBoundaries(i).Depth(1);
    dp(i,2)=-Flow.OpenBoundaries(i).Depth(2);
end

if strcmpi(Flow.VertCoord,'z')
    dplayer=GetLayerDepths(dp,Flow.Thick,Flow.ZBot,Flow.ZTop);
else
    dplayer=GetLayerDepths(dp,Flow.Thick);
end

% First interpolate data onto boundaries
nr=Flow.NrOpenBoundaries;
for i=1:nr

    % End A
    
    x(i,1)=0.5*(Flow.OpenBoundaries(i).X(1) + Flow.OpenBoundaries(i).X(2));
    y(i,1)=0.5*(Flow.OpenBoundaries(i).Y(1) + Flow.OpenBoundaries(i).Y(2));

    dx=Flow.OpenBoundaries(i).X(2)-Flow.OpenBoundaries(i).X(1);
    dy=Flow.OpenBoundaries(i).Y(2)-Flow.OpenBoundaries(i).Y(1);
    if strcmpi(Flow.OpenBoundaries(i).Orientation,'negative')
        dx=dx*-1;
        dy=dy*-1;
    end
    switch lower(Flow.OpenBoundaries(i).Side)
        case{'left','right'}
            % u-point
            alphau(i,1)=atan2(dy,dx)-0.5*pi;
            alphav(i,1)=atan2(dy,dx);
        case{'bottom','top'}
            % v-point
            alphau(i,1)=atan2(dy,dx)+0.5*pi;
            alphav(i,1)=atan2(dy,dx);
    end

    % End B

    x(i,2)=0.5*(Flow.OpenBoundaries(i).X(end-1) + Flow.OpenBoundaries(i).X(end));
    y(i,2)=0.5*(Flow.OpenBoundaries(i).Y(end-1) + Flow.OpenBoundaries(i).Y(end));

    dx=Flow.OpenBoundaries(i).X(end)-Flow.OpenBoundaries(i).X(end-1);
    dy=Flow.OpenBoundaries(i).Y(end)-Flow.OpenBoundaries(i).Y(end-1);
    if strcmpi(Flow.OpenBoundaries(i).Orientation,'negative')
        dx=dx*-1;
        dy=dy*-1;
    end
    switch lower(Flow.OpenBoundaries(i).Side)
        case{'left','right'}
            % u-point
            alphau(i,2)=atan2(dy,dx)-0.5*pi;
            alphav(i,2)=atan2(dy,dx);
        case{'bottom','top'}
            % v-point
            alphau(i,2)=atan2(dy,dx)+0.5*pi;
            alphav(i,2)=atan2(dy,dx);
    end

end

% fname=Flow.CurrentU.BC.File;
% 
% load(fname);
% 
% fname=Flow.CurrentV.BC.File;
% 
% sv=load(fname);


fname=Flow.Current.BC.File;
load(fname);

s.lon=mod(s.lon,360);

times=s.time;

it0=find(times<=t0, 1, 'last' );
it1=find(times>=t1, 1, 'first' );

times=times(it0:it1);

nt=0;

for it=it0:it1
    
    disp(['      Time step ' num2str(it) ' of ' num2str(it1-it0+1)]);

%     uu=Interpolate3D(Flow,x,y,dplayer,s,it,'data');
%     vv=Interpolate3D(Flow,x,y,dplayer,sv.s,it,'data');
    uu=Interpolate3D(Flow,x,y,dplayer,s,it,'u');
    vv=Interpolate3D(Flow,x,y,dplayer,s,it,'v');
    nt=nt+1;

    for j=1:nr

        tua=squeeze(uu(j,1,:))';
        tub=squeeze(uu(j,2,:))';
        tva=squeeze(vv(j,1,:))';
        tvb=squeeze(vv(j,2,:))';

        ua = tua.*cos(alphau(j,1)) + tva.*sin(alphau(j,1));
        ub = tub.*cos(alphau(j,2)) + tvb.*sin(alphau(j,2));
        va = tua.*cos(alphav(j,1)) + tva.*sin(alphav(j,1));
        vb = tub.*cos(alphav(j,2)) + tvb.*sin(alphav(j,2));

        u0(j,1,:,nt)=ua;
        u0(j,2,:,nt)=ub;
        v0(j,1,:,nt)=va;
        v0(j,2,:,nt)=vb;

    end
end

t=t0:dt/1440:t1;
for j=1:nr
    for k=1:Flow.KMax
        u(j,1,k,:) = spline(times,squeeze(u0(j,1,k,:)),t);
        u(j,2,k,:) = spline(times,squeeze(u0(j,2,k,:)),t);
        v(j,1,k,:) = spline(times,squeeze(v0(j,1,k,:)),t);
        v(j,2,k,:) = spline(times,squeeze(v0(j,2,k,:)),t);
    end
end
times=t;

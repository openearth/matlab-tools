function [times,u,v]=generateVelocitiesFromFile(flow,openBoundaries,opt)

t0=flow.startTime;
t1=flow.stopTime;
dt=opt.bctTimeStep;

nr=length(openBoundaries);

for i=1:nr
    dp(i,1)=-openBoundaries(i).depth(1);
    dp(i,2)=-openBoundaries(i).depth(2);
end

if strcmpi(flow.vertCoord,'z')
    dplayer=getLayerDepths(dp,flow.thick,flow.zBot,flow.zTop);
else
    dplayer=getLayerDepths(dp,flow.thick);
end

% First interpolate data onto boundaries
for i=1:nr

    % End A
    
    x(i,1)=0.5*(openBoundaries(i).x(1) + openBoundaries(i).x(2));
    y(i,1)=0.5*(openBoundaries(i).y(1) + openBoundaries(i).y(2));
    alphau(i,1)=openBoundaries(i).alphau(1);
    alphav(i,1)=openBoundaries(i).alphav(1);
    
    % End B
    x(i,2)=0.5*(openBoundaries(i).x(end-1) + openBoundaries(i).x(end));
    y(i,2)=0.5*(openBoundaries(i).y(end-1) + openBoundaries(i).y(end));
    alphau(i,2)=openBoundaries(i).alphau(2);
    alphav(i,2)=openBoundaries(i).alphav(2);

end

if isfield(flow,'coordSysType')
    if ~strcmpi(flow.coordSysType,'geographic')
        % First convert grid to WGS 84
        [x,y]=convertCoordinates(x,y,'persistent','CS1.name',flow.coordSysName,'CS1.type','xy','CS2.name','WGS 84','CS2.type','geo');
    end
    x=mod(x,360);
end

s=load(opt.current.BC.file_u);
sv=load(opt.current.BC.file_v);

s.lon=mod(s.lon,360);
sv.lon=mod(sv.lon,360);
x=mod(x,360);

times=s.time;

it0=find(times<=t0, 1, 'last' );
it1=find(times>=t1, 1, 'first' );

times=times(it0:it1);

nt=0;

for it=it0:it1
    
    disp(['      Time step ' num2str(it) ' of ' num2str(it1-it0+1)]);

    uu=interpolate3D(x,y,dplayer,s,it,'u');
    vv=interpolate3D(x,y,dplayer,sv,it,'v');

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

clear s sv

t=t0:dt/1440:t1;
for j=1:nr
    for k=1:flow.KMax
        u(j,1,k,:) = spline(times,squeeze(u0(j,1,k,:)),t);
        u(j,2,k,:) = spline(times,squeeze(u0(j,2,k,:)),t);
        v(j,1,k,:) = spline(times,squeeze(v0(j,1,k,:)),t);
        v(j,2,k,:) = spline(times,squeeze(v0(j,2,k,:)),t);
    end
end
times=t;

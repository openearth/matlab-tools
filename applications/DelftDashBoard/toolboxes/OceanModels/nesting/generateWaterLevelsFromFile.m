function [times,wl]=GenerateWaterLevelsFromFile(Flow)

t0=Flow.StartTime;
t1=Flow.StopTime;
dt=Flow.BctTimeStep;

% First interpolate data onto boundaries

nr=Flow.NrOpenBoundaries;

for i=1:nr

    % End A
    x(i,1)=0.5*(Flow.OpenBoundaries(i).X(1) + Flow.OpenBoundaries(i).X(2));
    y(i,1)=0.5*(Flow.OpenBoundaries(i).Y(1) + Flow.OpenBoundaries(i).Y(2));

    % End B
    x(i,2)=0.5*(Flow.OpenBoundaries(i).X(end-1) + Flow.OpenBoundaries(i).X(end));
    y(i,2)=0.5*(Flow.OpenBoundaries(i).Y(end-1) + Flow.OpenBoundaries(i).Y(end));

end

fname=Flow.WaterLevel.BC.File;

load(fname);

s.lon=mod(s.lon,360);

times=s.time;

it0=find(times<=t0, 1, 'last' );
it1=find(times>=t1, 1, 'first' );

times=times(it0:it1);

nt=0;

for it=it0:it1
    nt=nt+1;
    wl00=squeeze(s.data(:,:,it))+Flow.WaterLevel.BC.ZCor;
    wl00=internaldiffusion(wl00); 
    wl00=interp2(s.lon,s.lat,wl00,x,y);
    wl0(:,:,nt)=wl00;
end

t=t0:dt/1440:t1;
for j=1:nr
        wl(j,1,:) = spline(times,squeeze(wl0(j,1,:)),t);
        wl(j,2,:) = spline(times,squeeze(wl0(j,2,:)),t);
end
times=t;

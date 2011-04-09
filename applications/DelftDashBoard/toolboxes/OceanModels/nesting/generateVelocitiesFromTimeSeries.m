function [times,vel]=GenerateVelocitiesFromTimeSeries(Flow)

t0=Flow.StartTime;
t1=Flow.StopTime;
dt=Flow.BctTimeStep;
dt=dt/1440;

times=t0:dt:t1;

for j=1:Flow.NrOpenBoundaries
    ii=strmatch(Flow.OpenBoundaries(j).Name(1:3),Flow.Current.BC.BndPrefix,'exact');
    t=[];
    val=[];
    if isempty(ii)
        t=[t0 t1];
        val=[0 0];
    else
        tsfile=Flow.Current.BC.File{ii};
        fi=tekal('open',tsfile);
        data=tekal('read',fi,1);
        for k=1:size(data,1)
            k;
            dat=num2str(data(k,1));
            tim=num2str(data(k,2),'%0.6i');
            t(k)=datenum([dat tim],'yyyymmddHHMMSS');
            val(k)=data(k,3);
        end
    end
    ddt=t(2:end)-t(1:end-1);
% plot(ddt)    ;
    vals=interp1(t,val,times);
    for k=1:Flow.KMax
        for i=1:length(times)
            vel(j,1,k,i) = vals(i);
            vel(j,2,k,i) = vals(i);
        end
    end
end

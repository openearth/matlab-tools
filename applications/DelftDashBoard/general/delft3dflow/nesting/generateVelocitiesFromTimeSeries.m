function [times,vel]=generateVelocitiesFromTimeSeries(flow,openBoundaries,opt)

t0=flow.startTime;
t1=flow.stopTime;
dt=opt.bctTimeStep;
dt=dt/1440;

times=t0:dt:t1;

for j=1:length(openBoundaries)
    ii=strmatch(openBoundaries(j).name(1:3),opt.Current.BC.BndPrefix,'exact');
    t=[];
    val=[];
    if isempty(ii)
        t=[t0 t1];
        val=[0 0];
    else
        tsfile=opt.Current.BC.File{ii};
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
    for k=1:flow.KMax
        for i=1:length(times)
            vel(j,1,k,i) = vals(i);
            vel(j,2,k,i) = vals(i);
        end
    end
end

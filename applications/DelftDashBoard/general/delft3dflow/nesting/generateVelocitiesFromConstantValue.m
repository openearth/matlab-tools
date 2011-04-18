function [times,vel]=generateVelocitiesFromConstantValue(flow,openBoundaries,opt)

t0=flow.startTime;
t1=flow.stopTime;
dt=opt.bctTimeStep;
dt=dt/1440;

times=t0:dt:t1;

for j=1:length(openBoundaries)
    for k=1:flow.KMax
        for i=1:length(times)
            vel(j,1,k,i) = opt.Current.BC.Constant;
            vel(j,2,k,i) = opt.Current.BC.Constant;
        end
    end
end

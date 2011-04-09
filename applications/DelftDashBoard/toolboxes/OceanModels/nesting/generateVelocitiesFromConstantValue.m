function [times,vel]=GenerateVelocitiesFromConstantValue(Flow)

t0=Flow.StartTime;
t1=Flow.StopTime;
dt=Flow.BctTimeStep;
dt=dt/1440;

times=t0:dt:t1;

for j=1:Flow.NrOpenBoundaries
    for k=1:Flow.KMax
        for i=1:length(times)
            vel(j,1,k,i) = Flow.Current.BC.Constant;
            vel(j,2,k,i) = Flow.Current.BC.Constant;
        end
    end
end

function [times,wl]=GenerateWaterLevelsFromConstantValue(Flow)

t0=Flow.StartTime;
t1=Flow.StopTime;
dt=Flow.BctTimeStep/1440;

times=t0:dt:t1;

for i=1:Flow.NrOpenBoundaries
    for j=1:length(times)
        wl(i,1,j)=Flow.WaterLevel.BC.Constant;
        wl(i,2,j)=Flow.WaterLevel.BC.Constant;
    end    
end


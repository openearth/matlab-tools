function [times,wl]=generateWaterLevelsFromAstro(flow,opt)

t0=flow.startTime;
t1=flow.stopTime;
dt=opt.bctTimeStep;
times=t0:dt/1440:t1;

openBoundaries=delft3dflow_readBndFile([opt.inputDir filesep opt.waterLevel.BC.bndAstroFile]);
astronomicComponentSets=delft3dflow_readBcaFile([opt.inputDir filesep opt.waterLevel.BC.astroFile]);

for k=1:length(astronomicComponentSets)
    compSet{k}=astronomicComponentSets(k).name;
end

nr=length(openBoundaries);

for i=1:nr

    ia=strmatch(openBoundaries(i).compA,compSet,'exact');
    setA=astronomicComponentSets(ia);
    comp=[];
    A=[];
    G=[];
    for j=1:setA.nr
        comp{j}=setA.component{j};
        A(j,1)=setA.amplitude(j);
        G(j,1)=setA.phase(j);
    end
    prediction=makeTidePrediction(times,comp,A,G,45);
    wl(i,1,:)=prediction;
    
    ib=strmatch(openBoundaries(i).compB,compSet,'exact');
    setB=astronomicComponentSets(ib);
    comp=[];
    A=[];
    G=[];
    for j=1:setB.nr
        comp{j}=setB.component{j};
        A(j,1)=setB.amplitude(j);
        G(j,1)=setB.phase(j);
    end
    prediction=makeTidePrediction(times,comp,A,G,45);
    wl(i,2,:)=prediction;
    
end

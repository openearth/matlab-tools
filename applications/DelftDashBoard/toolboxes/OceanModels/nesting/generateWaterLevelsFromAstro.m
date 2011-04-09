function [times,wl]=generateWaterLevelsFromAstro(flow,opt)

t0=flow.startTime;
t1=flow.stopTime;
dt=opt.bctTimeStep;

%flwTmp=flow;
%flwTmp.inputDir=opt.inputDir;
%flwTmp.bndFile=opt.WaterLevel.BC.BndAstroFile;
%flwTmp=readBndFile(flwTmp);
%fname=[Flow.InputDir Flow.WaterLevel.BC.AstroFile];
openBoundaries=delft3dflow_readBndFile(opt.WaterLevel.BC.BndAstroFile);
astronomicComponentSets=delft3dflow_readBcaFile(opt.WaterLevel.BC.AstroFile);

for k=1:length(astronomicComponentSets)
    compSet{k}=astronomicComponentSets(k).name;
end

nr=length(openBoundaries);
for i=1:nr

    ia=strmatch(openBoundaries(i).compA,compSet,'exact');
    setA=astronomicComponentSets(ia);
    for j=1:setA.Nr
        comp{j}=setA.component{j};
        A(j,1)=setA.amplitude(j);
        G(j,1)=setA.phase(j);
    end
    [prediction,times]=delftPredict2007(comp,A,G,t0,t1,dt/60);
    prediction(end)=prediction(end-1);
    wl(i,1,:)=prediction;
    
    ib=strmatch(openBoundaries(i).compB,compSet,'exact');
    setB=astronomicComponentSets(ib);
    for j=1:setB.Nr
        comp{j}=setB.component{j};
        A(j,1)=SetB.Amplitude(j);
        G(j,1)=SetB.Phase(j);
    end
    [prediction,times]=delftPredict2007(comp,A,G,t0,t1,dt/60);
    prediction(end)=prediction(end-1);
    wl(i,2,:)=prediction;
    
end

function [times,vel,tanvel]=generateVelocitiesFromAstro(flow,opt,itanvel)

tanvel=[];

t0=flow.startTime;
t1=flow.stopTime;
dt=opt.bctTimeStep;

% if isfield(Flow.WaterLevel.BC,'AstroVelFile')
    bndfile=opt.current.BC.bndAstroFile;
    bcafile=opt.current.BC.astroFile;
% else
%     bndfile=Flow.WaterLevel.BC.BndAstroVelFile;
%     bcafile=Flow.WaterLevel.BC.AstroVelFile;
% end

openBoundaries=delft3dflow_readBndFile(opt.current.BC.bndAstroFile);
astronomicComponentSets=delft3dflow_readBcaFile(opt.current.BC.astroFile);

% FlwTmp=Flow;
% FlwTmp.BndFile=bndfile;
% FlwTmp=ReadBndFile(FlwTmp);

% fname=[FlwTmp.InputDir bcafile];
% FlwTmp=ReadBcaFile(FlwTmp,fname);
for k=1:length(astronomicComponentSets)
    compSet{k}=astronomicComponentSets(k).name;
end

nr=length(openBoundaries);

for i=1:nr

    ia=strmatch(openBoundaries(i).compA,compSet,'exact');
    setA=astronomicComponentSets(ia);
    for j=1:setA.nr
        comp{j}=setA.component{j};
        A(j,1)=setA.amplitude(j);
        G(j,1)=setA.phase(j);
    end
    [prediction,times]=delftPredict2007(comp,A,G,t0,t1,dt/60);
    prediction(end)=prediction(end-1);
    
    for k=1:flow.KMax
        vel(i,1,k,:)=prediction;
    end
    
    ib=strmatch(openBoundaries(i).compB,compSet,'exact');
    setB=astronomicComponentSets(ib);
    for j=1:setB.nr
        comp{j}=setB.component{j};
        A(j,1)=setB.amplitude(j);
        G(j,1)=setB.phase(j);
    end
    [prediction,times]=delftPredict2007(comp,A,G,t0,t1,dt/60);
    prediction(end)=prediction(end-1);
    
    for k=1:flow.KMax
        vel(i,2,k,:)=prediction;
    end
    
end

if itanvel

    openBoundaries=delft3dflow_readBndFile(opt.current.BC.bndAstroTanVelFile);
    astronomicComponentSets=delft3dflow_readBcaFile(opt.current.BC.astroTanVelFile);
    
    for k=1:length(astronomicComponentSets)
        compSet{k}=astronomicComponentSets(k).name;
    end
    
    nr=length(openBoundaries);

    for i=1:nr

        ia=strmatch(openBoundaries(i).compA,compSet,'exact');
        setA=astronomicComponentSets(ia);
        for j=1:setA.nr
            comp{j}=setA.component{j};
            A(j,1)=setA.amplitude(j);
            G(j,1)=setA.phase(j);
        end
        [prediction,times]=delftPredict2007(comp,A,G,t0,t1,dt/60);
        prediction(end)=prediction(end-1);

        for k=1:flow.KMax
            tanvel(i,1,k,:)=prediction;
        end

        ib=strmatch(openBoundaries(i).compB,compSet,'exact');
        setB=astronomicComponentSets(ib);
        for j=1:setB.nr
            comp{j}=setB.component{j};
            A(j,1)=setB.amplitude(j);
            G(j,1)=setB.phase(j);
        end
        [prediction,times]=delftPredict2007(comp,A,G,t0,t1,dt/60);
        prediction(end)=prediction(end-1);
        tanvel(i,2,:)=prediction;

        for k=1:flow.KMax
            tanvel(i,2,k,:)=prediction;
        end

    end
else
    tanvel=zeros(size(vel));
end

for k=1:flow.KMax
end

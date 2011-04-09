function [times,vel,tanvel]=GenerateVelocitiesFromAstro(Flow)

tanvel=[];

t0=Flow.StartTime;
t1=Flow.StopTime;
dt=Flow.BctTimeStep;

% if isfield(Flow.WaterLevel.BC,'AstroVelFile')
    bndfile=Flow.Current.BC.BndAstroVelFile;
    bcafile=Flow.Current.BC.AstroVelFile;
% else
%     bndfile=Flow.WaterLevel.BC.BndAstroVelFile;
%     bcafile=Flow.WaterLevel.BC.AstroVelFile;
% end

FlwTmp=Flow;
FlwTmp.BndFile=bndfile;
FlwTmp=ReadBndFile(FlwTmp);

fname=[FlwTmp.InputDir bcafile];
FlwTmp=ReadBcaFile(FlwTmp,fname);
for k=1:FlwTmp.NrAstronomicComponentSets
    CompSet{k}=FlwTmp.AstronomicComponentSets(k).Name;
end

nr=FlwTmp.NrOpenBoundaries;
for i=1:nr

    ia=strmatch(FlwTmp.OpenBoundaries(i).CompA,CompSet,'exact');
    SetA=FlwTmp.AstronomicComponentSets(ia);
    for j=1:SetA.Nr
        comp{j}=SetA.Component{j};
        A(j,1)=SetA.Amplitude(j);
        G(j,1)=SetA.Phase(j);
    end
    [prediction,times]=delftPredict2007(comp,A,G,t0,t1,dt/60);
    prediction(end)=prediction(end-1);
    vel(i,1,:)=prediction;
    
    ib=strmatch(FlwTmp.OpenBoundaries(i).CompB,CompSet,'exact');
    SetB=FlwTmp.AstronomicComponentSets(ib);
    for j=1:SetB.Nr
        comp{j}=SetB.Component{j};
        A(j,1)=SetB.Amplitude(j);
        G(j,1)=SetB.Phase(j);
    end
    [prediction,times]=delftPredict2007(comp,A,G,t0,t1,dt/60);
    prediction(end)=prediction(end-1);
    vel(i,2,:)=prediction;
    
end

if isfield(Flow.WaterLevel.BC,'AstroTanVelFile')

    bndfile=Flow.Current.BC.BndAstroTanVelFile;
    bcafile=Flow.Current.BC.AstroTanVelFile;

    FlwTmp=Flow;
    FlwTmp.BndFile=bndfile;
    FlwTmp=ReadBndFile(FlwTmp);

    fname=[FlwTmp.InputDir bcafile];
    FlwTmp=ReadBcaFile(FlwTmp,fname);
    for k=1:FlwTmp.NrAstronomicComponentSets
        CompSet{k}=FlwTmp.AstronomicComponentSets(k).Name;
    end

    nr=FlwTmp.NrOpenBoundaries;
    for i=1:nr

        ia=strmatch(FlwTmp.OpenBoundaries(i).CompA,CompSet,'exact');
        SetA=FlwTmp.AstronomicComponentSets(ia);
        for j=1:SetA.Nr
            comp{j}=SetA.Component{j};
            A(j,1)=SetA.Amplitude(j);
            G(j,1)=SetA.Phase(j);
        end
        [prediction,times]=delftPredict2007(comp,A,G,t0,t1,dt/60);
        prediction(end)=prediction(end-1);
        tanvel(i,1,:)=prediction;

        ib=strmatch(FlwTmp.OpenBoundaries(i).CompB,CompSet,'exact');
        SetB=FlwTmp.AstronomicComponentSets(ib);
        for j=1:SetB.Nr
            comp{j}=SetB.Component{j};
            A(j,1)=SetB.Amplitude(j);
            G(j,1)=SetB.Phase(j);
        end
        [prediction,times]=delftPredict2007(comp,A,G,t0,t1,dt/60);
        prediction(end)=prediction(end-1);
        tanvel(i,2,:)=prediction;

    end
else
    tanvel=zeros(size(vel));
end

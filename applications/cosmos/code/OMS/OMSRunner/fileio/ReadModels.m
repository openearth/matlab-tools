function hm=ReadModels(hm)

dirname=[hm.ScenarioDir 'models' filesep];

continent=hm.Continents;

i=0;

hm.Models=[];

for jj=1:length(continent)
    cntdir=[dirname continent{jj}];
    if exist(cntdir,'dir')
        dr=dir(cntdir);
        for kk=1:length(dr)
            if dr(kk).isdir && ~strcmpi(dr(kk).name(1),'.')

                fname=[dirname continent{jj} filesep dr(kk).name filesep dr(kk).name '.xml'];                
                i=i+1;
                [hm,ok]=ReadModel(hm,fname,i);

                if ~ok
                    i=i-1;
                end

            end
        end
    end
end

hm.NrModels=i;

for i=1:hm.NrModels
    hm.ModelNames{i}=hm.Models(i).LongName;
    hm.ModelAbbrs{i}=hm.Models(i).Name;
    hm.Models(i).NestedFlowModels=[];
    hm.Models(i).NestedWaveModels=[];
end

for i=1:hm.NrModels

    if hm.Models(i).FlowNested
        fnest=hm.Models(i).FlowNestModel;
        mm=findstrinstruct(hm.Models,'Name',fnest);
        hm.Models(i).FlowNestModelNr=mm;
        n=length(hm.Models(mm).NestedFlowModels);
        hm.Models(mm).NestedFlowModels(n+1)=i;
    end
    if hm.Models(i).WaveNested
        fnest=hm.Models(i).WaveNestModel;
        mm=findstrinstruct(hm.Models,'Name',fnest);
        hm.Models(i).WaveNestModelNr=mm;
        n=length(hm.Models(mm).NestedWaveModels);
        hm.Models(mm).NestedWaveModels(n+1)=i;
    end
end


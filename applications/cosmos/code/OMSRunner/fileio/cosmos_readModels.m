function hm=cosmos_readModels(hm)

dirname=[hm.scenarioDir 'models' filesep];

continent=hm.continents;

i=0;

hm.models=[];

for jj=1:length(continent)
    cntdir=[dirname continent{jj}];
    if exist(cntdir,'dir')
        dr=dir(cntdir);
        for kk=1:length(dr)
            if dr(kk).isdir && ~strcmpi(dr(kk).name(1),'.')

                fname=[dirname continent{jj} filesep dr(kk).name filesep dr(kk).name '.xml'];                
                i=i+1;
                [hm,ok]=cosmos_readModel(hm,fname,i);

                if ~ok
                    i=i-1;
                end

            end
        end
    end
end

hm.nrModels=i;

for i=1:hm.nrModels
    hm.modelNames{i}=hm.models(i).longName;
    hm.modelAbbrs{i}=hm.models(i).name;
    hm.models(i).nestedFlowModels=[];
    hm.models(i).nestedWaveModels=[];
end

for i=1:hm.nrModels

    if hm.models(i).flowNested
        fnest=hm.models(i).flowNestModel;
        mm=findstrinstruct(hm.models,'name',fnest);
        hm.models(i).flowNestModelNr=mm;
        n=length(hm.models(mm).nestedFlowModels);
        hm.models(mm).nestedFlowModels(n+1)=i;
    end
    if hm.models(i).waveNested
        fnest=hm.models(i).waveNestModel;
        mm=findstrinstruct(hm.models,'name',fnest);
        hm.models(i).waveNestModelNr=mm;
        n=length(hm.models(mm).nestedWaveModels);
        hm.models(mm).nestedWaveModels(n+1)=i;
    end
end


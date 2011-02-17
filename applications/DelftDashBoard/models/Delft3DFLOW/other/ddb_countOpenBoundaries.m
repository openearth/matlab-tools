function handles=ddb_countOpenBoundaries(handles,id)

nb=handles.Model(md).Input(id).nrOpenBoundaries;

ncor=0;
nastro=0;
nharmo=0;
ntime=0;
nqh=0;

for i=1:nb
    switch handles.Model(md).Input(id).openBoundaries(i).forcing,
        case{'A'}
            nastro=nastro+1;
            for j=1:handles.Model(md).Input(id).nrAstronomicComponentSets
                for k=1:handles.Model(md).Input(id).astronomicComponentSets(j).nr
                    if handles.Model(md).Input(id).astronomicComponentSets(j).correction(k)
                        ncor=ncor+1;
                    end
                end
            end
        case{'H'}
            nharmo=nharmo+1;
        case{'T'}
            ntime=ntime+1;
        case{'Q'}
            nqh=nqh+1;
    end
end

handles.Model(md).Input(id).nrAstro=nastro;
handles.Model(md).Input(id).nrCor=ncor;
handles.Model(md).Input(id).nrHarmo=nharmo;
handles.Model(md).Input(id).nrTime=ntime;
handles.Model(md).Input(id).nrQH=nqh;

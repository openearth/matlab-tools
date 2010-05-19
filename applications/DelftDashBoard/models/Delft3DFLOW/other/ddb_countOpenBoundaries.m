function handles=ddb_countOpenBoundaries(handles,id)

nb=handles.Model(md).Input(id).NrOpenBoundaries;

ncor=0;
nastro=0;
nharmo=0;
ntime=0;
nqh=0;

for i=1:nb
    switch handles.Model(md).Input(id).OpenBoundaries(i).Forcing,
        case{'A'}
            nastro=nastro+1;
            for j=1:handles.Model(md).Input(id).NrAstronomicComponentSets
                for k=1:handles.Model(md).Input(id).AstronomicComponentSets(j).Nr
                    if handles.Model(md).Input(id).AstronomicComponentSets(j).Correction(k)
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

handles.Model(md).Input(id).NrAstro=nastro;
handles.Model(md).Input(id).NrCor=ncor;
handles.Model(md).Input(id).NrHarmo=nharmo;
handles.Model(md).Input(id).NrTime=ntime;
handles.Model(md).Input(id).NrQH=nqh;

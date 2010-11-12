function handles=ddb_readCorFile(handles)

fid=fopen(handles.Model(md).Input(ad).CorFile);

for i=1:handles.Model(md).Input(ad).NrAstronomicComponentSets
    ComponentSets{i}=handles.Model(md).Input(ad).AstronomicComponentSets(i).Name;
end

k=0;
for i=1:10000
    tx0=fgets(fid);
    if and(ischar(tx0), size(tx0>0))
        v0=strread(tx0,'%q');
    else
        v0='';
    end
    if length(v0)>0
        if length(v0)==1
            ii=strmatch(v0{1},ComponentSets,'exact');
        else
            for j=1:handles.Model(md).Input(ad).AstronomicComponentSets(ii).Nr
                Components{j}=handles.Model(md).Input(ad).AstronomicComponentSets(ii).Component{j};
            end
            jj=strmatch(v0{1},Components,'exact');
            if length(jj)>0
                handles.Model(md).Input(ad).AstronomicComponentSets(ii).Correction(jj)=1;
                handles.Model(md).Input(ad).AstronomicComponentSets(ii).AmplitudeCorrection(jj)=str2num(v0{2});
                handles.Model(md).Input(ad).AstronomicComponentSets(ii).PhaseCorrection(jj)=str2num(v0{3});
            end
        end
    else
        fclose(fid);
        return
    end
end

fclose(fid);



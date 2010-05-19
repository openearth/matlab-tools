function handles=ddb_saveCorFile(handles,id)

fid=fopen(handles.Model(md).Input(id).CorFile,'w');

nr=handles.Model(md).Input(id).NrAstronomicComponentSets;

for i=1:nr
    k=0;
    for j=1:handles.Model(md).Input(id).AstronomicComponentSets(i).Nr
        if handles.Model(md).Input(id).AstronomicComponentSets(i).Correction(j)
            k=k+1;
        end
    end
    if k>0
        fprintf(fid,'%s\n',handles.Model(md).Input(id).AstronomicComponentSets(i).Name);
        for j=1:handles.Model(md).Input(id).AstronomicComponentSets(i).Nr
            if handles.Model(md).Input(id).AstronomicComponentSets(i).Correction(j)
                cmp=handles.Model(md).Input(id).AstronomicComponentSets(i).Component{j};
                amp=handles.Model(md).Input(id).AstronomicComponentSets(i).AmplitudeCorrection(j);
                pha=handles.Model(md).Input(id).AstronomicComponentSets(i).PhaseCorrection(j);
                fprintf(fid,'%s %15.7e %15.7e\n',[cmp repmat(' ',1,8-length(cmp))],amp,pha);
            end
        end
    end
end
fclose(fid);

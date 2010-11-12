function handles=ddb_saveBcaFile(handles,id)

fid=fopen(handles.Model(md).Input(id).BcaFile,'w');

nr=handles.Model(md).Input(id).NrAstronomicComponentSets;

for i=1:nr
    fprintf(fid,'%s\n',handles.Model(md).Input(id).AstronomicComponentSets(i).Name);
    for j=1:handles.Model(md).Input(id).AstronomicComponentSets(i).Nr
        cmp=handles.Model(md).Input(id).AstronomicComponentSets(i).Component{j};
        amp=handles.Model(md).Input(id).AstronomicComponentSets(i).Amplitude(j);
        pha=handles.Model(md).Input(id).AstronomicComponentSets(i).Phase(j);
        if isnan(pha) % then A0
            fprintf(fid,'%s %15.7e\n',[cmp repmat(' ',1,8-length(cmp))],amp);
        else
            fprintf(fid,'%s %15.7e %15.7e\n',[cmp repmat(' ',1,8-length(cmp))],amp,pha);
        end
    end
end
fclose(fid);

function handles=ddb_saveBcaFile(handles,id)

fid=fopen(handles.Model(md).Input(id).bcaFile,'w');

nr=handles.Model(md).Input(id).nrAstronomicComponentSets;

for i=1:nr
    fprintf(fid,'%s\n',handles.Model(md).Input(id).astronomicComponentSets(i).name);
    for j=1:handles.Model(md).Input(id).astronomicComponentSets(i).nr
        cmp=handles.Model(md).Input(id).astronomicComponentSets(i).component{j};
        amp=handles.Model(md).Input(id).astronomicComponentSets(i).amplitude(j);
        pha=handles.Model(md).Input(id).astronomicComponentSets(i).phase(j);
        if isnan(pha) % then A0
            fprintf(fid,'%s %15.7e\n',[cmp repmat(' ',1,8-length(cmp))],amp);
        else
            fprintf(fid,'%s %15.7e %15.7e\n',[cmp repmat(' ',1,8-length(cmp))],amp,pha);
        end
    end
end
fclose(fid);

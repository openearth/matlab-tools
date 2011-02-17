function handles=ddb_saveCorFile(handles,id)

fid=fopen(handles.Model(md).Input(id).corFile,'w');

nr=handles.Model(md).Input(id).nrAstronomicComponentSets;

for i=1:nr
    k=0;
    for j=1:handles.Model(md).Input(id).astronomicComponentSets(i).nr
        if handles.Model(md).Input(id).astronomicComponentSets(i).correction(j)
            k=k+1;
        end
    end
    if k>0
        fprintf(fid,'%s\n',handles.Model(md).Input(id).astronomicComponentSets(i).name);
        for j=1:handles.Model(md).Input(id).astronomicComponentSets(i).nr
            if handles.Model(md).Input(id).astronomicComponentSets(i).correction(j)
                cmp=handles.Model(md).Input(id).astronomicComponentSets(i).component{j};
                amp=handles.Model(md).Input(id).astronomicComponentSets(i).amplitudeCorrection(j);
                pha=handles.Model(md).Input(id).astronomicComponentSets(i).phaseCorrection(j);
                fprintf(fid,'%s %15.7e %15.7e\n',[cmp repmat(' ',1,8-length(cmp))],amp,pha);
            end
        end
    end
end
fclose(fid);

function delft3dflow_saveBcaFile(astronomicComponentSets,fname)

fid=fopen(fname,'w');
nr=length(astronomicComponentSets);
for i=1:nr
    fprintf(fid,'%s\n',astronomicComponentSets(i).name);
    for j=1:astronomicComponentSets(i).nr
        cmp=astronomicComponentSets(i).component{j};
        amp=astronomicComponentSets(i).amplitude(j);
        pha=astronomicComponentSets(i).phase(j);
        if isnan(pha) % then A0
            fprintf(fid,'%s %15.7e\n',[cmp repmat(' ',1,8-length(cmp))],amp);
        else
            fprintf(fid,'%s %15.7e %15.7e\n',[cmp repmat(' ',1,8-length(cmp))],amp,pha);
        end
    end
end
fclose(fid);

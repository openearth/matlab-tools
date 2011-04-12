function astronomicComponentSets=delft3dflow_readBcaFile(fname)

fid=fopen(fname);

k=0;
for i=1:10000
    tx0=fgets(fid);
    if and(ischar(tx0), size(tx0>0))
        v0=strread(tx0,'%q');
    else
        v0='';
    end
    if ~isempty(v0)
        if length(v0)==1
            k=k+1;
            j=1;
            astronomicComponentSets(k).name=v0{1};
        else
            astronomicComponentSets(k).component{j}=v0{1};
            astronomicComponentSets(k).amplitude(j)=str2double(v0{2});
            astronomicComponentSets(k).phase(j)=str2double(v0{3});
            astronomicComponentSets(k).correction(j)=0;
            astronomicComponentSets(k).amplitudeCorrection(j)=0;
            astronomicComponentSets(k).phaseCorrection(j)=0;
            astronomicComponentSets(k).nr=j;
            j=j+1;
        end
    else
        fclose(fid);
        return
    end
end

fclose(fid);


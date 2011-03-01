function handles=ddb_readBcaFile(handles,id)

fid=fopen(handles.Model(md).Input(id).bcaFile);

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
            handles.Model(md).Input(id).nrAstronomicComponentSets=k;
            handles.Model(md).Input(id).astronomicComponentSets(k).name=v0{1};
        elseif length(v0)==2 % A0!
            handles.Model(md).Input(id).astronomicComponentSets(k).nr=j;
            handles.Model(md).Input(id).astronomicComponentSets(k).component{j}=v0{1};
            handles.Model(md).Input(id).astronomicComponentSets(k).amplitude(j)=str2double(v0{2});
            handles.Model(md).Input(id).astronomicComponentSets(k).phase(j)=nan;
            handles.Model(md).Input(id).astronomicComponentSets(k).correction(j)=0;
            handles.Model(md).Input(id).astronomicComponentSets(k).amplitudeCorrection(j)=0;
            handles.Model(md).Input(id).astronomicComponentSets(k).phaseCorrection(j)=0;
            j=j+1;
        else
            handles.Model(md).Input(id).astronomicComponentSets(k).nr=j;
            handles.Model(md).Input(id).astronomicComponentSets(k).component{j}=v0{1};
            handles.Model(md).Input(id).astronomicComponentSets(k).amplitude(j)=str2double(v0{2});
            handles.Model(md).Input(id).astronomicComponentSets(k).phase(j)=str2double(v0{3});
            handles.Model(md).Input(id).astronomicComponentSets(k).correction(j)=0;
            handles.Model(md).Input(id).astronomicComponentSets(k).amplitudeCorrection(j)=0;
            handles.Model(md).Input(id).astronomicComponentSets(k).phaseCorrection(j)=0;
            j=j+1;
        end
    else
        fclose(fid);
        return
    end
end

fclose(fid);



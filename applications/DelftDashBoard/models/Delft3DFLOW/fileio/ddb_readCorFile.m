function handles=ddb_readCorFile(handles,id)

fid=fopen(handles.Model(md).Input(id).corFile);

for i=1:handles.Model(md).Input(id).nrAstronomicComponentSets
    componentSets{i}=handles.Model(md).Input(id).astronomicComponentSets(i).name;
end

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
            ii=strmatch(v0{1},componentSets,'exact');
        else
            for j=1:handles.Model(md).Input(id).astronomicComponentSets(ii).nr
                components{j}=handles.Model(md).Input(id).astronomicComponentSets(ii).component{j};
            end
            jj=strmatch(v0{1},components,'exact');
            if ~isempty(jj)
                handles.Model(md).Input(id).astronomicComponentSets(ii).correction(jj)=1;
                handles.Model(md).Input(id).astronomicComponentSets(ii).amplitudeCorrection(jj)=str2double(v0{2});
                handles.Model(md).Input(id).astronomicComponentSets(ii).phaseCorrection(jj)=str2double(v0{3});
            end
        end
    else
        fclose(fid);
        return
    end
end

fclose(fid);



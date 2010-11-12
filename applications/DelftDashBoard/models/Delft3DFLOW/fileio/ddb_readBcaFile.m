function handles=ddb_readBcaFile(handles)

fid=fopen(handles.Model(md).Input(ad).BcaFile);

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
            k=k+1;
            j=1;
            handles.Model(md).Input(ad).NrAstronomicComponentSets=k;
            handles.Model(md).Input(ad).AstronomicComponentSets(k).Name=v0{1};
        elseif length(v0)==2 % A0!
            handles.Model(md).Input(ad).AstronomicComponentSets(k).Nr=j;
            handles.Model(md).Input(ad).AstronomicComponentSets(k).Component{j}=v0{1};
            handles.Model(md).Input(ad).AstronomicComponentSets(k).Amplitude(j)=str2num(v0{2});
            handles.Model(md).Input(ad).AstronomicComponentSets(k).Phase(j)=nan;
            handles.Model(md).Input(ad).AstronomicComponentSets(k).Correction(j)=0;
            handles.Model(md).Input(ad).AstronomicComponentSets(k).AmplitudeCorrection(j)=0;
            handles.Model(md).Input(ad).AstronomicComponentSets(k).PhaseCorrection(j)=0;
            j=j+1;
        else
            handles.Model(md).Input(ad).AstronomicComponentSets(k).Nr=j;
            handles.Model(md).Input(ad).AstronomicComponentSets(k).Component{j}=v0{1};
            handles.Model(md).Input(ad).AstronomicComponentSets(k).Amplitude(j)=str2num(v0{2});
            handles.Model(md).Input(ad).AstronomicComponentSets(k).Phase(j)=str2num(v0{3});
            handles.Model(md).Input(ad).AstronomicComponentSets(k).Correction(j)=0;
            handles.Model(md).Input(ad).AstronomicComponentSets(k).AmplitudeCorrection(j)=0;
            handles.Model(md).Input(ad).AstronomicComponentSets(k).PhaseCorrection(j)=0;
            j=j+1;
        end
    else
        fclose(fid);
        return
    end
end

fclose(fid);



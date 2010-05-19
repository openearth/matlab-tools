function handles=ddb_readBchFile(handles)

fid=fopen(handles.Model(md).Input(ad).BchFile);

nrb=handles.Model(md).Input(ad).NrOpenBoundaries;

tx0=fgets(fid);
if and(ischar(tx0), size(tx0>0))
    v=strread(tx0,'%q');
end
v=str2num(char(v));

handles.Model(md).Input(ad).OpenBoundaries(1).NrHarmonicComponents=length(v);
nrh=length(v);
handles.Model(md).Input(ad).OpenBoundaries(1).HarmonicComponents=v;

tx0=fgets(fid);

for i=1:nrb
    handles.Model(md).Input(ad).OpenBoundaries(i).NrHarmonicComponents=handles.Model(md).Input(ad).OpenBoundaries(1).NrHarmonicComponents;
    handles.Model(md).Input(ad).OpenBoundaries(i).HarmonicComponents=handles.Model(md).Input(ad).OpenBoundaries(1).HarmonicComponents;
    if handles.Model(md).Input(ad).OpenBoundaries(i).Forcing=='H'
        tx0=fgets(fid);
        if and(ischar(tx0), size(tx0>0))
            v=strread(tx0,'%q');
        end
        v=str2num(char(v));
        handles.Model(md).Input(ad).OpenBoundaries(i).HarmonicAmpA=v;
    end
end

for i=1:nrb
    if handles.Model(md).Input(ad).OpenBoundaries(i).Forcing=='H'
        tx0=fgets(fid);
        if and(ischar(tx0), size(tx0>0))
            v=strread(tx0,'%q');
        end
        v=str2num(char(v));
        handles.Model(md).Input(ad).OpenBoundaries(i).HarmonicAmpB=v;
    end
end

tx0=fgets(fid);

for i=1:nrb
    if handles.Model(md).Input(ad).OpenBoundaries(i).Forcing=='H'
        tx0=fgets(fid);
        if and(ischar(tx0), size(tx0>0))
            v=strread(tx0,'%q');
        end
        v=str2num(char(v));
        handles.Model(md).Input(ad).OpenBoundaries(i).HarmonicPhaseA=zeros(1,nrh);
        handles.Model(md).Input(ad).OpenBoundaries(i).HarmonicPhaseA(2:end)=v;
    end
end

for i=1:nrb
    if handles.Model(md).Input(ad).OpenBoundaries(i).Forcing=='H'
        tx0=fgets(fid);
        if and(ischar(tx0), size(tx0>0))
            v=strread(tx0,'%q');
        end
        v=str2num(char(v));
        handles.Model(md).Input(ad).OpenBoundaries(i).HarmonicPhaseB=zeros(1,nrh);
        handles.Model(md).Input(ad).OpenBoundaries(i).HarmonicPhaseB(2:end)=v;
    end
end

fclose(fid);

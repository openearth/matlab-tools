function handles=ddb_readBchFile(handles)

fid=fopen(handles.Model(md).Input(ad).bchFile);

nrb=handles.Model(md).Input(ad).nrOpenBoundaries;

tx0=fgets(fid);
if and(ischar(tx0), size(tx0>0))
    v=strread(tx0,'%q');
end
v=str2num(char(v));

handles.Model(md).Input(ad).openBoundaries(1).nrHarmonicComponents=length(v);
nrh=length(v);
handles.Model(md).Input(ad).openBoundaries(1).harmonicComponents=v;

tx0=fgets(fid);

for i=1:nrb
    handles.Model(md).Input(ad).openBoundaries(i).nrHarmonicComponents=handles.Model(md).Input(ad).openBoundaries(1).nrHarmonicComponents;
    handles.Model(md).Input(ad).openBoundaries(i).harmonicComponents=handles.Model(md).Input(ad).openBoundaries(1).harmonicComponents;
    if handles.Model(md).Input(ad).openBoundaries(i).forcing=='H'
        tx0=fgets(fid);
        if and(ischar(tx0), size(tx0>0))
            v=strread(tx0,'%q');
        end
        v=str2num(char(v));
        handles.Model(md).Input(ad).openBoundaries(i).harmonicAmpA=v;
    end
end

for i=1:nrb
    if handles.Model(md).Input(ad).openBoundaries(i).forcing=='H'
        tx0=fgets(fid);
        if and(ischar(tx0), size(tx0>0))
            v=strread(tx0,'%q');
        end
        v=str2num(char(v));
        handles.Model(md).Input(ad).openBoundaries(i).harmonicAmpB=v;
    end
end

tx0=fgets(fid);

for i=1:nrb
    if handles.Model(md).Input(ad).openBoundaries(i).forcing=='H'
        tx0=fgets(fid);
        if and(ischar(tx0), size(tx0>0))
            v=strread(tx0,'%q');
        end
        v=str2num(char(v));
        handles.Model(md).Input(ad).openBoundaries(i).harmonicPhaseA=zeros(1,nrh);
        handles.Model(md).Input(ad).openBoundaries(i).harmonicPhaseA(2:end)=v;
    end
end

for i=1:nrb
    if handles.Model(md).Input(ad).openBoundaries(i).forcing=='H'
        tx0=fgets(fid);
        if and(ischar(tx0), size(tx0>0))
            v=strread(tx0,'%q');
        end
        v=str2num(char(v));
        handles.Model(md).Input(ad).openBoundaries(i).harmonicPhaseB=zeros(1,nrh);
        handles.Model(md).Input(ad).openBoundaries(i).harmonicPhaseB(2:end)=v;
    end
end

fclose(fid);

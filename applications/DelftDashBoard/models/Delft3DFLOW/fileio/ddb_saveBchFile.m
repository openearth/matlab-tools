function handles=ddb_saveBchFile(handles,id)

fid=fopen(handles.Model(md).Input(id).BchFile,'w');

nr=handles.Model(md).Input(id).NrHarmonicComponents;
nrb=handles.Model(md).Input(id).NrOpenBoundaries;

fmt=[repmat('%16.7e',1,nr) '\n'];
fprintf(fid,fmt,handles.Model(md).Input(id).HarmonicComponents);

fprintf(fid,'%s\n','');

for i=1:nrb
    if handles.Model(md).Input(id).OpenBoundaries(i).Forcing=='H'
        fmt=[repmat('%16.7e',1,nr) '\n'];
        fprintf(fid,fmt,handles.Model(md).Input(id).OpenBoundaries(i).HarmonicAmpA);
    end
end
for i=1:nrb
    if handles.Model(md).Input(id).OpenBoundaries(i).Forcing=='H'
        fmt=[repmat('%16.7e',1,nr) '\n'];
        fprintf(fid,fmt,handles.Model(md).Input(id).OpenBoundaries(i).HarmonicAmpB);
    end
end
fprintf(fid,'%s\n','');
for i=1:nrb
    if handles.Model(md).Input(id).OpenBoundaries(i).Forcing=='H'
        fmt=['                ' repmat('%16.7e',1,nr-1) '\n'];
        fprintf(fid,fmt,handles.Model(md).Input(id).OpenBoundaries(i).HarmonicPhaseA(2:end));
    end
end
for i=1:nrb
    if handles.Model(md).Input(id).OpenBoundaries(i).Forcing=='H'
        fmt=['                ' repmat('%16.7e',1,nr-1) '\n'];
        fprintf(fid,fmt,handles.Model(md).Input(id).OpenBoundaries(i).HarmonicPhaseB(2:end));
    end
end

fclose(fid);

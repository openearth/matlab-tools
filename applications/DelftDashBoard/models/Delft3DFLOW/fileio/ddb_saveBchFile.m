function handles=ddb_saveBchFile(handles,id)

fid=fopen(handles.Model(md).Input(id).bchFile,'w');

nr=handles.Model(md).Input(id).nrHarmonicComponents;
nrb=handles.Model(md).Input(id).nrOpenBoundaries;

fmt=[repmat('%16.7e',1,nr) '\n'];
fprintf(fid,fmt,handles.Model(md).Input(id).harmonicComponents);

fprintf(fid,'%s\n','');

for i=1:nrb
    if handles.Model(md).Input(id).openBoundaries(i).forcing=='H'
        fmt=[repmat('%16.7e',1,nr) '\n'];
        fprintf(fid,fmt,handles.Model(md).Input(id).openBoundaries(i).harmonicAmpA);
    end
end
for i=1:nrb
    if handles.Model(md).Input(id).openBoundaries(i).forcing=='H'
        fmt=[repmat('%16.7e',1,nr) '\n'];
        fprintf(fid,fmt,handles.Model(md).Input(id).openBoundaries(i).harmonicAmpB);
    end
end
fprintf(fid,'%s\n','');
for i=1:nrb
    if handles.Model(md).Input(id).openBoundaries(i).forcing=='H'
        fmt=['                ' repmat('%16.7e',1,nr-1) '\n'];
        fprintf(fid,fmt,handles.Model(md).Input(id).openBoundaries(i).harmonicPhaseA(2:end));
    end
end
for i=1:nrb
    if handles.Model(md).Input(id).openBoundaries(i).forcing=='H'
        fmt=['                ' repmat('%16.7e',1,nr-1) '\n'];
        fprintf(fid,fmt,handles.Model(md).Input(id).openBoundaries(i).harmonicPhaseB(2:end));
    end
end

fclose(fid);

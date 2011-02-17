function ddb_saveCrsFile(handles,id)

fid=fopen(handles.Model(md).Input(id).crsFile,'w');
for i=1:handles.Model(md).Input(id).nrCrossSections
    m1=handles.Model(md).Input(id).crossSections(i).M1;
    n1=handles.Model(md).Input(id).crossSections(i).N1;
    m2=handles.Model(md).Input(id).crossSections(i).M2;
    n2=handles.Model(md).Input(id).crossSections(i).N2;
    name=handles.Model(md).Input(id).crossSections(i).name;
    fprintf(fid,'%s %3.0f %3.0f %3.0f %3.0f\n',[name repmat(' ',1,21-length(name)) ] ,m1,n1,m2,n2);
end
fclose(fid);

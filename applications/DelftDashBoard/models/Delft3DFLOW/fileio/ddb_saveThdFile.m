function ddb_saveThdFile(handles,id)

fname=handles.Model(md).Input(id).ThdFile;

fid=fopen(fname,'w');
for i=1:handles.Model(md).Input(id).NrThinDams
    m1=handles.Model(md).Input(id).ThinDams(i).M1;
    n1=handles.Model(md).Input(id).ThinDams(i).N1;
    m2=handles.Model(md).Input(id).ThinDams(i).M2;
    n2=handles.Model(md).Input(id).ThinDams(i).N2;
    uv=handles.Model(md).Input(id).ThinDams(i).UV;
    fprintf(fid,'%6i %6i %6i %6i %s\n',m1,n1,m2,n2,uv);
end
fclose(fid);


function ddb_saveDryFile(handles,id)

fid=fopen(handles.Model(md).Input(id).DryFile,'w');
for i=1:handles.Model(md).Input(id).nrDryPoints
    m1=handles.Model(md).Input(id).DryPoints(i).M1;
    n1=handles.Model(md).Input(id).DryPoints(i).N1;
    m2=handles.Model(md).Input(id).DryPoints(i).M2;
    n2=handles.Model(md).Input(id).DryPoints(i).N2;
    fprintf(fid,'%6i %6i %6i %6i\n',m1,n1,m2,n2);
end
fclose(fid);

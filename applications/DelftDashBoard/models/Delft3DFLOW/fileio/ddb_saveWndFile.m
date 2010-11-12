function ddb_saveWndFile(handles,id)

fname=handles.Model(md).Input(id).WndFile;

fid=fopen(fname,'w');
fprintf(fid,'%16.7e %16.7e %16.7e\n',handles.Model(md).Input(id).WindData');
fclose(fid);


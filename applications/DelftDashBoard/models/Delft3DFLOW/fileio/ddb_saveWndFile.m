function ddb_saveWndFile(handles,id)

fname=handles.Model(md).Input(id).wndFile;

fid=fopen(fname,'w');
fprintf(fid,'%16.7e %16.7e %16.7e\n',handles.Model(md).Input(id).windData');
fclose(fid);


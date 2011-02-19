function ddb_saveWndFile(handles,id)

fname=handles.Model(md).Input(id).wndFile;

data(:,1)=1440*(handles.Model(md).Input(id).windTimeSeriesT-handles.Model(md).Input(id).itDate);
data(:,2)=handles.Model(md).Input(id).windTimeSeriesSpeed;
data(:,3)=handles.Model(md).Input(id).windTimeSeriesDirection;

fid=fopen(fname,'w');
fprintf(fid,'%16.7e %16.7e %16.7e\n',data');
fclose(fid);

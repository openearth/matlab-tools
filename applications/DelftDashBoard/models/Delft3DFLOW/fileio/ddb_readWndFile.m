function handles=ddb_readWndFile(handles,id)

fname=handles.Model(md).Input(id).wndFile;
data=load(fname);
handles.Model(md).Input(id).windTimeSeriesT=handles.Model(md).Input(id).itDate+data(:,1)/1440;
handles.Model(md).Input(id).windTimeSeriesSpeed=data(:,2);
handles.Model(md).Input(id).windTimeSeriesDirection=data(:,3);

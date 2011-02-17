function handles=ddb_readWndFile(handles,id)

fname=handles.Model(md).Input(id).wndFile;
handles.Model(md).Input(id).windData=load(fname);
